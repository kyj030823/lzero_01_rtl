package npu.core.memory

import chisel3._
import chisel3.util._

/** 단일 cache group의 설정. Replay 횟수는 최초 사용을 포함한 총 pass 수다. */
class CircularBufferCacheGroupConfig(
  val byteCountWidth: Int = 15,
  val groupIndexWidth: Int = 16,
  val replayCountWidth: Int = 16,
  val contextIdWidth: Int = 8
) extends Bundle {
  val contextId = UInt(contextIdWidth.W)
  val payloadBytes = UInt(byteCountWidth.W)
  val replayCount = UInt(replayCountWidth.W)
  val groupIndex = UInt(groupIndexWidth.W)
}

/** Consumer 수락 위치를 기준으로 계산한 일반 chunk 큐의 읽기 준비도. */
class CircularBufferReadiness(val byteCountWidth: Int = 15) extends Bundle {
  val readableBytesThisPass = UInt(byteCountWidth.W)
  val nextRequiredChunkReady = Bool()
}

/** 저장소, 쓰기 경로, 읽기 경로를 연결한 UB/WB 공통 core.
  *
  * Metadata를 요청 순서대로 소비한다. STREAM과 cache 마지막 pass에서는
  * chunk의 마지막 출력 수락 후 공간과 entry를 반환한다. 수신과 소비는 독립적이다.
  *
  * 기본은 STREAM이며, 비어 있는 상태에서 cacheGroup 설정을 수락하면
  * 단일 group을 local cache로 보존하고 설정한 횟수만큼 재생한다.
  * 마지막 pass에서는 chunk별로 반환한다. 선택적 context 선행 적재에서는
  * 다음 cache descriptor로 교체한 뒤 이전 context를 STREAM처럼 반환한다.
  *
  * Group의 의미와 공급 요청 생성은 상위 제어부가 결정한다.
  * userTag와 memory 공급의 lastInStream은 모든 pass에서 그대로 전달한다.
  * 최종 사용 완료는 groupDone으로 구분한다. 공급 마지막과 소비 완료는 다르다.
  */
class CircularBufferCore(
  val bufferCapacityBytes: Int = 16384,
  val maxRefillBytes: Int = 4096,
  val chunkEntryCountLimit: Int = 4,
  val contextIdWidth: Int = 8,
  val groupIndexWidth: Int = 16,
  val userTagWidth: Int = 1,
  val memoryReadLatencyCycles: Int = 1,
  val replayCountWidth: Int = 16,
  val enableStreaming: Boolean = false,
  val enableContextPrefill: Boolean = false,
  // UB는 같은 context의 다음 row를 현재 row의 마지막 사용 중에 먼저 채운다.
  val enableGroupPrefill: Boolean = false
) extends Module {
  require(bufferCapacityBytes == 16384)
  require(maxRefillBytes == 4096)
  require(chunkEntryCountLimit == 4)
  require(contextIdWidth > 0 && groupIndexWidth > 0 && userTagWidth > 0)
  require(memoryReadLatencyCycles == 1)
  require(replayCountWidth > 0)

  private val localPointerWidth = log2Ceil(bufferCapacityBytes) + 1
  private val byteCountWidth = log2Ceil(bufferCapacityBytes + 1)
  private val entryIndexWidth = log2Ceil(chunkEntryCountLimit)

  val io = IO(new Bundle {
    // 상위는 contextId를 context 시작 시 latch하고 실행 중 유지해야 한다.
    // Soft reset 전에 진행 중인 memory 응답과 read/output을 drain해야 한다.
    val contextId = Input(UInt(contextIdWidth.W))
    val softReset = Input(Bool())
    // 읽는 context만 전환한다. 다음 context의 예약과 SRAM 내용은 보존한다.
    val contextActivate = if (enableContextPrefill) Some(Input(Bool())) else None
    val preserveCacheOnActivate = if (enableContextPrefill) Some(Input(Bool())) else None

    // 긴 stream도 reserveRefill로 entry를 배정한다. 이후 실제 freeBytes 안에서
    // credit을 추가하며 기록된 부분부터 같은 reader로 소비한다.
    val streamCredit = if (enableStreaming) Some(Flipped(Decoupled(UInt(byteCountWidth.W)))) else None
    val streamReadEnable = if (enableStreaming) Some(Input(Bool())) else None
    val reservedBytes = Output(UInt(byteCountWidth.W))

    // Payload는 16B 정렬, 1..16384B이며 replayCount는 1 이상이어야 한다.
    // 설정 전에는 STREAM으로 동작한다. Cache 완료 후에는 다음 설정 또는
    // softReset까지 추가 refill을 막아 이전 group을 다시 공급받지 않는다.
    val cacheGroup = Flipped(Decoupled(new CircularBufferCacheGroupConfig(
      byteCountWidth, groupIndexWidth, replayCountWidth, contextIdWidth
    )))

    // AG/Arbiter의 logical refill 승인과 연결할 내부 예약 경계다.
    val reserveRefill = Flipped(Decoupled(
      new CircularBufferRefillReservation(byteCountWidth, groupIndexWidth, userTagWidth, contextIdWidth)
    ))
    val memoryDataValid = Input(Bool())
    val memoryDataReady = Output(Bool())
    val memoryData = Input(UInt(512.W))
    val memoryLaneValidMask = Input(UInt(4.W))
    val memoryChunkLast = Input(Bool())
    val memoryStreamLast = Input(Bool())
    val memoryContextId = Input(UInt(contextIdWidth.W))
    val memoryUserTag = Input(UInt(userTagWidth.W))

    // 새 SRAM read의 발행 허용이다. 이미 발행한 응답을 멈추지는 않는다.
    // Consumer를 정지하려면 output.ready를 낮춰야 한다.
    val readEnable = Input(Bool())
    val output = Decoupled(new CircularBufferReadBeat(
      entryIndexWidth, groupIndexWidth, userTagWidth, contextIdWidth
    ))

    val freeBytes = Output(UInt(byteCountWidth.W))
    val full = Output(Bool())
    val refillPending = Output(Bool())
    val refillContextId = Output(UInt(contextIdWidth.W))

    // Cache 설정 후 첫 refill을 기다리는 동안은 아직 실행 중이므로 false다.
    val idle = Output(Bool())

    // WB 연결부가 기존 상태를 중복 계산하지 않고 사용할 수 있도록 전달한다.
    // readPipelineIdle는 output 보관까지 포함하며 clear로 마스킹하지 않은 상태다.
    val readPipelineIdle = Output(Bool())
    val memoryPayloadBytes = Output(UInt(log2Ceil(64 + 1).W))
    val cacheFillComplete = Output(Bool())
    val readiness = Output(new CircularBufferReadiness(byteCountWidth))

    // Stream의 passIndex는 0이다. 완료 pulse는 마지막 출력 수락에서만 발생한다.
    // passDone은 group 한 번의 사용 완료, groupDone은 모든 사용의 완료다.
    val passIndex = Output(UInt(replayCountWidth.W))
    val passDone = Output(Bool())
    val groupDone = Output(Bool())
  })

  val writer = Module(new CircularBufferWritePath(
    bufferCapacityBytes = bufferCapacityBytes,
    maxRefillBytes = maxRefillBytes,
    chunkEntryCountLimit = chunkEntryCountLimit,
    contextIdWidth = contextIdWidth,
    groupIndexWidth = groupIndexWidth,
    userTagWidth = userTagWidth,
    enableStreaming = enableStreaming,
    enableContextPrefill = enableContextPrefill
  ))
  val storage = Module(new CircularBufferStorage(
    bufferCapacityBytes = bufferCapacityBytes,
    memoryReadLatencyCycles = memoryReadLatencyCycles
  ))
  val reader = Module(new CircularBufferReadPath(
    bufferCapacityBytes = bufferCapacityBytes,
    chunkEntryCountLimit = chunkEntryCountLimit,
    groupIndexWidth = groupIndexWidth,
    userTagWidth = userTagWidth,
    memoryReadLatencyCycles = memoryReadLatencyCycles,
    contextIdWidth = contextIdWidth
  ))

  val clear = io.softReset || reset.asBool
  val contextActivate = io.contextActivate.getOrElse(false.B)

  io.streamCredit.foreach { credit => writer.io.streamCredit.get <> credit }

  // 범위는 첫 예약 시 고정한다. 이후 write pointer를 따라 end를 늘리지 않는다.
  val cacheMode = RegInit(false.B)
  val cacheGroupComplete = RegInit(false.B)
  val cachePayloadBytes = RegInit(0.U(byteCountWidth.W))
  val cacheReplayCount = RegInit(1.U(replayCountWidth.W))
  val cacheContextId = RegInit(0.U(contextIdWidth.W))
  val cacheGroupIndex = RegInit(0.U(groupIndexWidth.W))
  val cacheStartPtr = RegInit(0.U(localPointerWidth.W))
  val cacheEndPtr = RegInit(0.U(localPointerWidth.W))
  val cacheRangeValid = RegInit(false.B)
  val cacheFillComplete = RegInit(false.B)
  val cacheBytesCommitted = RegInit(0.U(byteCountWidth.W))
  val cacheFirstChunkEntryIndex = RegInit(0.U(entryIndexWidth.W))
  val cachePassIndex = RegInit(0.U(replayCountWidth.W))
  val cachePassBytesConsumed = RegInit(0.U(byteCountWidth.W))

  val anyChunkAllocated = writer.io.chunkEntries.map(_.allocated).reduce(_ || _)
  val dataPathEmpty = !anyChunkAllocated && !writer.io.refillPending && reader.io.idle
  val cacheConfigurationValid = io.cacheGroup.bits.payloadBytes =/= 0.U &&
    io.cacheGroup.bits.payloadBytes <= bufferCapacityBytes.U &&
    io.cacheGroup.bits.payloadBytes(3, 0) === 0.U &&
    io.cacheGroup.bits.replayCount =/= 0.U
  // 마지막 사용 중인 이전 cache는 이후 STREAM처럼 반환할 수 있다.
  // 다음 cache 설정은 한 세트뿐인 descriptor를 교체하며 읽기 cursor는 유지한다.
  // 교체한 뒤 이전 context/group의 마지막 사용은 STREAM처럼 chunk별로 반환한다.
  val finalCachePass = cachePassIndex +& 1.U === cacheReplayCount
  val canReplaceCache = !cacheMode || cacheGroupComplete || (cacheFillComplete && finalCachePass)
  val cacheIdentityChanges =
    (if (enableContextPrefill) io.cacheGroup.bits.contextId =/= cacheContextId else false.B) ||
    (if (enableGroupPrefill) io.cacheGroup.bits.groupIndex =/= cacheGroupIndex else false.B)
  val cacheBoundaryAvailable = if (enableContextPrefill || enableGroupPrefill)
    !writer.io.refillPending && canReplaceCache &&
      (!cacheMode || cacheGroupComplete || cacheIdentityChanges)
    else dataPathEmpty && (!cacheMode || cacheGroupComplete)
  io.cacheGroup.ready := !clear && !contextActivate && cacheBoundaryAvailable && cacheConfigurationValid
  val cacheConfigurationFire = io.cacheGroup.fire

  // Cache에서 받을 것은 unique payload 한 벌뿐이다. 여유 공간이 생겨도
  // 다음 group이나 같은 group의 재공급을 자동 승인하지 않는다.
  val cacheBytesRemaining = cachePayloadBytes - cacheBytesCommitted
  val cacheReservationAllowed = !cacheFillComplete && !cacheGroupComplete &&
    io.reserveRefill.bits.groupIndex === cacheGroupIndex &&
    (io.reserveRefill.bits.payloadBytes === 0.U ||
      io.reserveRefill.bits.payloadBytes <= cacheBytesRemaining)
  val streamingReservation = if (enableStreaming) io.reserveRefill.bits.streaming else false.B
  val reservationUsesCache = cacheMode && !streamingReservation && (if (enableContextPrefill)
    io.reserveRefill.bits.contextId === cacheContextId else true.B) &&
    (if (enableGroupPrefill) io.reserveRefill.bits.groupIndex === cacheGroupIndex else true.B)
  val reservationAllowed = (!contextActivate || streamingReservation) &&
    !cacheConfigurationFire && (!reservationUsesCache || cacheReservationAllowed)

  // 외부 ingress를 쓰기 경로에 연결한다.
  writer.io.contextId := io.contextId
  writer.io.softReset := io.softReset
  writer.io.reserveRefill.valid := io.reserveRefill.valid && reservationAllowed
  writer.io.reserveRefill.bits := io.reserveRefill.bits
  io.reserveRefill.ready := writer.io.reserveRefill.ready && reservationAllowed

  // 수신 beat도 설정한 group 길이를 넘겨 기록하지 못하게 검사한다.
  // Mask의 byte 수 계산은 WritePath에서 수행하고, 여기서는 group 범위만 검사한다.
  val cacheBytesCommittedNext = cacheBytesCommitted +& writer.io.memoryPayloadBytes
  val ingressUsesCache = cacheMode && !writer.io.receivingStream && (if (enableContextPrefill)
    io.memoryContextId === cacheContextId else true.B) &&
    (if (enableGroupPrefill) writer.io.refillGroupIndex === cacheGroupIndex else true.B)
  val ingressAllowed = !ingressUsesCache || (!cacheFillComplete && !cacheGroupComplete &&
    cacheBytesCommittedNext <= cachePayloadBytes)
  writer.io.memoryDataValid := io.memoryDataValid && ingressAllowed
  io.memoryDataReady := writer.io.memoryDataReady && ingressAllowed
  writer.io.memoryData := io.memoryData
  writer.io.memoryLaneValidMask := io.memoryLaneValidMask
  writer.io.memoryChunkLast := io.memoryChunkLast
  writer.io.memoryStreamLast := io.memoryStreamLast
  writer.io.memoryContextId := io.memoryContextId
  writer.io.memoryUserTag := io.memoryUserTag

  // LUT/일반 payload 모두 같은 writer와 reader를 거쳐 SRAM에 접근한다.
  // 포트 owner mux나 별도 pointer 인계가 필요 없다.
  storage.io.writeEnable := writer.io.storageWriteEnable
  storage.io.writeBytePtr := writer.io.storageWriteBytePtr
  storage.io.writeData := writer.io.storageWriteData
  storage.io.writeLaneValidMask := writer.io.storageWriteLaneValidMask
  storage.io.readEnable := reader.io.storageReadEnable
  storage.io.readBytePtr := reader.io.storageReadBytePtr
  reader.io.storageReadDataValid := storage.io.readDataValid
  reader.io.storageReadData := storage.io.readData
  reader.io.softReset := io.softReset || contextActivate
  reader.io.writeCommitPtr := writer.io.writeCommitPtr
  io.output <> reader.io.output

  // Writer의 head와 같은 순서로 소비한다.
  // 모든 entry가 반환된 뒤에도 cursor를 유지하므로 다음 tail 할당과 이어진다.
  val currentChunkEntryIndex = RegInit(0.U(entryIndexWidth.W))
  val readPositioned = RegInit(false.B)
  val currentChunk = writer.io.chunkEntries(currentChunkEntryIndex)
  val readUsesCache = cacheMode && !currentChunk.streaming && (if (enableContextPrefill)
    currentChunk.contextId === cacheContextId else true.B) &&
    (if (enableGroupPrefill) currentChunk.groupIndex === cacheGroupIndex else true.B)

  val chunkConsumed = io.output.fire && io.output.bits.lastInChunk
  val isFinalCachePass = cachePassIndex +& 1.U === cacheReplayCount
  val cachePassBytesConsumedNext = cachePassBytesConsumed +& 16.U
  val cachePassFinished = io.output.fire && readUsesCache &&
    cachePassBytesConsumedNext === cachePayloadBytes
  val rewindAtPassEnd = cachePassFinished && !isFinalCachePass
  val finalCacheGroupConsumed = cachePassFinished && isFinalCachePass

  // 현재 출력의 metadata는 reader 내부에 이미 고정되어 있다.
  // 마지막 출력을 수락하는 cycle에는 다음 read용 metadata를 미리 선택해도
  // 현재 출력이 바뀌지 않는다. 반환에는 위의 기존 currentChunk를 계속 사용한다.
  val nextChunkEntryIndex = (currentChunkEntryIndex + 1.U)(entryIndexWidth - 1, 0)
  val readChunkEntryIndex = Mux(
    rewindAtPassEnd,
    cacheFirstChunkEntryIndex,
    Mux(chunkConsumed, nextChunkEntryIndex, currentChunkEntryIndex)
  )
  reader.io.currentChunkEntryIndex := readChunkEntryIndex
  reader.io.currentChunk := writer.io.chunkEntries(readChunkEntryIndex)
  reader.io.allowIncompleteChunk := writer.io.chunkEntries(readChunkEntryIndex).streaming

  // Status는 현재 register cursor/readPtr만 사용한다. output.fire로 미리 선택한
  // readChunkEntryIndex를 사용하면 impending -> ready -> fire의 조합 loop가 생긴다.
  // 최초 seek 전에는 아직 이전 위치인 reader.readPtr 대신 새 chunk 시작을 사용한다.
  val statusReadPtr = Mux(readPositioned, reader.io.readPtr, currentChunk.startPtr)
  val readyBytes = Wire(Vec(chunkEntryCountLimit, UInt(byteCountWidth.W)))
  val scanOpen = Wire(Vec(chunkEntryCountLimit + 1, Bool()))
  scanOpen(0) := true.B
  for (offset <- 0 until chunkEntryCountLimit) {
    val index = (currentChunkEntryIndex + offset.U)(entryIndexWidth - 1, 0)
    val entry = writer.io.chunkEntries(index)
    val start = if (offset == 0) statusReadPtr else entry.startPtr
    val span = (entry.endPtr - entry.startPtr)(localPointerWidth - 1, 0)
    val consumed = (start - entry.startPtr)(localPointerWidth - 1, 0)
    val remaining = (entry.endPtr - start)(localPointerWidth - 1, 0)
    val contextMatches = if (enableContextPrefill) entry.contextId === io.contextId else true.B
    val segmentReady = scanOpen(offset) && contextMatches && !entry.streaming && entry.allocated && entry.complete &&
      consumed +& 16.U <= span && remaining <= bufferCapacityBytes.U
    readyBytes(offset) := Mux(segmentReady, remaining, 0.U)
    val followingIndex = (index + 1.U)(entryIndexWidth - 1, 0)
    val following = writer.io.chunkEntries(followingIndex)
    // 다른 group이나 FIFO의 예전 pinned entry를 현재 pass 잔량에 더하지 않는다.
    scanOpen(offset + 1) := segmentReady && !entry.lastInGroup &&
      following.startPtr === entry.endPtr && following.groupIndex === entry.groupIndex &&
      following.contextId === entry.contextId
  }
  val readableBytesThisPass = readyBytes.reduce(_ +& _)
  val nextEntry = writer.io.chunkEntries(nextChunkEntryIndex)
  val replayEntry = writer.io.chunkEntries(cacheFirstChunkEntryIndex)
  val sequentialContinuationReady = nextEntry.allocated && nextEntry.complete && !nextEntry.streaming &&
    nextEntry.startPtr === currentChunk.endPtr && nextEntry.contextId === currentChunk.contextId
  val replayContinuationReady = !isFinalCachePass && cacheRangeValid &&
    replayEntry.allocated && replayEntry.complete && replayEntry.startPtr === cacheStartPtr
  io.readiness.readableBytesThisPass := Mux(clear, 0.U, readableBytesThisPass)
  io.readiness.nextRequiredChunkReady := !clear && readyBytes(0) =/= 0.U &&
    Mux(readUsesCache && currentChunk.lastInGroup, replayContinuationReady, sequentialContinuationReady)
  when(!clear) {
    assert(readableBytesThisPass <= bufferCapacityBytes.U, "readable pass bytes exceed resident capacity")
  }

  // 최초 seek와 첫 read를 같이 발행할 수 있다.
  // Cache의 최종 출력 수락에서는 다음 pass나 group의 read를 추가하지 않는다.
  val currentContextMatches = if (enableContextPrefill) currentChunk.contextId === io.contextId else true.B
  val issueContextMatches = if (enableContextPrefill)
    writer.io.chunkEntries(readChunkEntryIndex).contextId === io.contextId else true.B
  val initialSeekNeeded = !readPositioned && currentContextMatches &&
    currentChunk.allocated && (currentChunk.complete || currentChunk.streaming)
  val selectedStream = writer.io.chunkEntries(readChunkEntryIndex).streaming
  val selectedReadEnable = Mux(selectedStream, io.streamReadEnable.getOrElse(false.B), io.readEnable)
  reader.io.readEnable := selectedReadEnable && issueContextMatches &&
    (readPositioned || initialSeekNeeded) &&
    (!readUsesCache || !cacheGroupComplete) && !finalCacheGroupConsumed
  reader.io.seek.valid := !clear && (initialSeekNeeded || rewindAtPassEnd)
  reader.io.seek.bits := Mux(rewindAtPassEnd, cacheStartPtr, currentChunk.startPtr)
  when(reader.io.seek.fire) {
    readPositioned := true.B
  }

  when(rewindAtPassEnd && !clear) {
    assert(reader.io.seek.fire, "pass rewind must coincide with acceptance of its final output")
    when(selectedReadEnable) {
      assert(reader.io.storageReadEnable, "ready cache replay must issue its first read without a bubble")
    }
  }

  // 공간과 entry는 새 read 발행이 아니라 이전 chunk의 최종 소비에서 반환한다.
  val releaseConsumedChunk = chunkConsumed && (!readUsesCache || isFinalCachePass)

  // 긴 stream은 출력 수락마다 공간을 반환하고, entry는 최종 출력에서만 반환한다.
  // 일반 stream/cache는 기존 chunk 단위 반환 정책을 사용한다.
  val reclaimStreamBeat = io.output.fire && currentChunk.streaming
  writer.io.reclaim.valid := releaseConsumedChunk || reclaimStreamBeat
  writer.io.reclaim.bits := Mux(reclaimStreamBeat,
    (reader.io.readPtr + 16.U)(localPointerWidth - 1, 0), currentChunk.endPtr)
  writer.io.releaseChunk.valid := releaseConsumedChunk
  writer.io.releaseChunk.bits := io.output.bits.chunkEntryIndex

  when(chunkConsumed) {
    assert(io.output.bits.chunkEntryIndex === currentChunkEntryIndex,
      "consumed output must belong to the current FIFO chunk")
    assert(currentChunk.allocated && currentChunk.complete,
      "consumed chunk must be complete and allocated")
    assert((reader.io.readPtr + 16.U)(localPointerWidth - 1, 0) === currentChunk.endPtr,
      "chunk release must follow acceptance of its final payload")
    currentChunkEntryIndex := currentChunkEntryIndex + 1.U
  }

  // 설정은 idle 경계에서 고정한다. 첫 예약 위치를 0으로 가정하지 않는다.
  when(cacheConfigurationFire) {
    cacheMode := true.B
    cacheGroupComplete := false.B
    cachePayloadBytes := io.cacheGroup.bits.payloadBytes
    cacheReplayCount := io.cacheGroup.bits.replayCount
    cacheGroupIndex := io.cacheGroup.bits.groupIndex
    cacheContextId := (if (enableContextPrefill) io.cacheGroup.bits.contextId else io.contextId)
    cacheRangeValid := false.B
    cacheFillComplete := false.B
    cacheBytesCommitted := 0.U
    cachePassIndex := 0.U
    cachePassBytesConsumed := 0.U
    when(dataPathEmpty) {
      readPositioned := false.B
      currentChunkEntryIndex := writer.io.reservationEntryIndex
    }
  }

  when(io.reserveRefill.fire && reservationUsesCache) {
    when(!cacheRangeValid) {
      cacheStartPtr := writer.io.writeCommitPtr
      cacheEndPtr := (writer.io.writeCommitPtr + cachePayloadBytes)(localPointerWidth - 1, 0)
      cacheFirstChunkEntryIndex := writer.io.reservationEntryIndex
      cacheRangeValid := true.B
    }
  }

  // SRAM write enable은 WritePath가 확정한 실제 memory beat 수락 사건이다.
  val memoryWriteFire = writer.io.storageWriteEnable
  when(memoryWriteFire && ingressUsesCache) {
    cacheBytesCommitted := cacheBytesCommittedNext
    when(cacheBytesCommittedNext === cachePayloadBytes) {
      assert(io.memoryChunkLast, "final group payload must also finish its logical chunk")
      cacheFillComplete := true.B
    }
  }

  io.passIndex := Mux(readUsesCache, cachePassIndex, 0.U)
  io.passDone := io.output.fire && io.output.bits.lastInGroup
  io.groupDone := io.passDone && (!readUsesCache || isFinalCachePass)

  when(io.output.fire && readUsesCache && !cacheConfigurationFire) {
    assert(!cacheGroupComplete, "completed cache group must not produce additional output")
    assert(io.output.bits.groupIndex === cacheGroupIndex, "output belongs to another cache group")
    assert(cachePassBytesConsumedNext <= cachePayloadBytes, "read exceeded the fixed cache range")
    assert(io.output.bits.lastInGroup === (cachePassBytesConsumedNext === cachePayloadBytes),
      "lastInGroup must match the configured group payload boundary")
    cachePassBytesConsumed := cachePassBytesConsumedNext

    when(cachePassFinished) {
      assert(io.output.bits.lastInChunk, "group boundary must coincide with a chunk boundary")
      assert(cacheRangeValid && cacheFillComplete, "cannot replay an incomplete cache range")
      assert((reader.io.readPtr + 16.U)(localPointerWidth - 1, 0) === cacheEndPtr,
        "pass must end at the fixed cache end pointer")

      when(isFinalCachePass) {
        cacheGroupComplete := true.B
      }.otherwise {
        // 첫 entry를 보존했으므로 마지막 수락과 동시에 그 위치의 read를 발행한다.
        // 다음 cycle부터 새 pass의 출력이 이어진다.
        cachePassIndex := cachePassIndex + 1.U
        cachePassBytesConsumed := 0.U
        currentChunkEntryIndex := cacheFirstChunkEntryIndex
      }
    }
  }

  when(!clear) {
    when(io.cacheGroup.valid) {
      assert(cacheConfigurationValid, "cache group needs aligned nonzero bytes and a positive total replay count")
    }
  }

  io.freeBytes := writer.io.freeBytes
  io.full := writer.io.full
  io.refillPending := writer.io.refillPending
  io.refillContextId := writer.io.refillContextId
  io.reservedBytes := writer.io.reservedBytes
  io.readPipelineIdle := reader.io.idle
  io.memoryPayloadBytes := writer.io.memoryPayloadBytes
  io.cacheFillComplete := cacheFillComplete
  io.idle := dataPathEmpty && (!cacheMode || cacheGroupComplete)

  // Context 활성화는 읽기 파이프라인만 비운다. Writer의 FIFO/head/tail은 유지한다.
  when(contextActivate && !clear) {
    assert(reader.io.idle, "context activation requires the previous reader to be drained")
    readPositioned := false.B
    when(!io.preserveCacheOnActivate.getOrElse(false.B)) {
      cacheMode := false.B
      cacheGroupComplete := false.B
      cacheRangeValid := false.B
      cacheFillComplete := false.B
      cacheBytesCommitted := 0.U
      cachePassIndex := 0.U
      cachePassBytesConsumed := 0.U
    }
  }

  when(io.softReset && !reset.asBool) {
    assert(!writer.io.refillPending && reader.io.idle,
      "softReset requires memory and read/output responses to be drained")
  }
  when(clear) {
    currentChunkEntryIndex := 0.U
    readPositioned := false.B
    cacheMode := false.B
    cacheGroupComplete := false.B
    cachePayloadBytes := 0.U
    cacheReplayCount := 1.U
    cacheGroupIndex := 0.U
    cacheStartPtr := 0.U
    cacheEndPtr := 0.U
    cacheRangeValid := false.B
    cacheFillComplete := false.B
    cacheBytesCommitted := 0.U
    cacheFirstChunkEntryIndex := 0.U
    cachePassIndex := 0.U
    cachePassBytesConsumed := 0.U
  }
}
