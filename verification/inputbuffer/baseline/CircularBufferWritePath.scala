package npu.core.memory

import chisel3._
import chisel3.util._

/** 상위 제어부가 logical refill 승인 시 쓰기 경로에 전달할 예약 정보. */
class CircularBufferRefillReservation(
  val byteCountWidth: Int = 15,
  val groupIndexWidth: Int = 16,
  val userTagWidth: Int = 1,
  val contextIdWidth: Int = 8
) extends Bundle {
  // 일반 요청의 0은 길이 미확정(4096B 예약)이다. Streaming의 0은 entry만 먼저 배정한다.
  val payloadBytes = UInt(byteCountWidth.W)
  // 긴 stream은 entry 하나를 배정하고 credit을 반복해서 추가한다.
  val streaming = Bool()
  // UB/WB별 의미를 가진 부가 정보. 공통 경로에서는 그대로 보관한다.
  // 요청 시점의 context를 보관한다. 다음 context 활성화 후에도 응답 identity는 유지된다.
  val contextId = UInt(contextIdWidth.W)
  val userTag = UInt(userTagWidth.W)
  val groupIndex = UInt(groupIndexWidth.W)
  val lastInGroup = Bool()
}

/** Logical chunk 경계 정보. endPtr는 마지막 payload 바로 다음 위치다. */
class CircularBufferChunkEntry(
  val localPointerWidth: Int = 15,
  val byteCountWidth: Int = 15,
  val groupIndexWidth: Int = 16,
  val userTagWidth: Int = 1,
  val contextIdWidth: Int = 8
) extends Bundle {
  val allocated = Bool()
  val complete = Bool()
  // 기록된 부분부터 읽고, 소비한 16B를 즉시 반환하는 entry다.
  val streaming = Bool()
  val startPtr = UInt(localPointerWidth.W)
  val endPtr = UInt(localPointerWidth.W)
  val payloadBytes = UInt(byteCountWidth.W)
  // UB/WB별 의미를 가진 부가 정보. 공통 경로에서는 그대로 보관한다.
  // 요청 시점의 context를 보관한다. 다음 context 활성화 후에도 응답 identity는 유지된다.
  val contextId = UInt(contextIdWidth.W)
  val userTag = UInt(userTagWidth.W)
  val groupIndex = UInt(groupIndexWidth.W)
  val lastInGroup = Bool()
  val lastInStream = Bool()
}

/** UB와 WB가 각각 인스턴스화하는 공통 logical refill/stream 쓰기 경로.
  *
  * 공간 예약, 최대 4KiB refill commit, 4개 chunk entry의 수명을 관리한다.
  * 각 인스턴스의 pointer, reservation, metadata는 서로 독립적이다.
  *
  * userTag는 상위 제어부가 정한 값이다. UB는 0으로 고정해 사용할 수 있고,
  * WB는 LUT/WEIGHT/VECTOR 종류를 넣을 수 있다. 이 모듈은 그 의미를 해석하지 않고
  * 예약 당시 값의 보관과 응답 일치 여부만 확인한다.
  *
  * 공급 순서, cache replay, reclaim 시점은 UB/WB 제어부가 결정한다.
  * 요청 당시 contextId를 entry에 저장하므로 읽는 context와 공급 context를 분리할 수 있다.
  * Bounded stream도 같은 queue와 pointer를 사용하며 긴 길이 검사는 상위가 맡는다.
  */
class CircularBufferWritePath(
  val bufferCapacityBytes: Int = 16384,
  val maxRefillBytes: Int = 4096,
  val chunkEntryCountLimit: Int = 4,
  val contextIdWidth: Int = 8,
  val groupIndexWidth: Int = 16,
  val userTagWidth: Int = 1,
  val enableStreaming: Boolean = false,
  val enableContextPrefill: Boolean = false
) extends Module {
  require(bufferCapacityBytes == 16384)
  require(maxRefillBytes == 4096)
  require(chunkEntryCountLimit == 4)
  require(contextIdWidth > 0 && groupIndexWidth > 0 && userTagWidth > 0)

  private val consumerBeatBytes = 16
  private val memoryPayloadByteCountWidth = log2Ceil(4 * consumerBeatBytes + 1)
  private val localPointerWidth = log2Ceil(bufferCapacityBytes) + 1
  private val byteCountWidth = log2Ceil(bufferCapacityBytes + 1)
  private val entryIndexWidth = log2Ceil(chunkEntryCountLimit)

  val io = IO(new Bundle {
    // 실행 중 softReset을 사용하려면 상위가 먼저 cancel/drain을 보장해야 한다.
    val softReset = Input(Bool())
    val contextId = Input(UInt(contextIdWidth.W))

    // 일반 refill과 같은 공간/entry를 사용하되, 긴 stream의 credit만 따로 승인한다.
    val streamCredit = if (enableStreaming) Some(Flipped(Decoupled(UInt(byteCountWidth.W)))) else None
    val reservedBytes = Output(UInt(byteCountWidth.W))
    val receivingStream = Output(Bool())

    // valid && ready에서 공간과 entry를 동시에 예약한다.
    // 예약 길이가 미확정이면 payloadBytes=0으로 전달한다.
    val reserveRefill = Flipped(Decoupled(
      new CircularBufferRefillReservation(byteCountWidth, groupIndexWidth, userTagWidth, contextIdWidth)
    ))
    // reserveRefill이 수락되는 cycle에 할당할 entry의 번호다.
    val reservationEntryIndex = Output(UInt(entryIndexWidth.W))

    val memoryDataValid = Input(Bool())
    val memoryDataReady = Output(Bool())
    val memoryData = Input(UInt(512.W))
    val memoryLaneValidMask = Input(UInt(4.W))
    val memoryChunkLast = Input(Bool())
    val memoryStreamLast = Input(Bool())
    val memoryContextId = Input(UInt(contextIdWidth.W))
    val memoryUserTag = Input(UInt(userTagWidth.W))

    // 현재 입력 mask의 유효 byte 수다. Core의 group 범위 검사에서도 사용한다.
    // Valid/ready와 무관하게 계산해야 수락 조건에 조합 경로가 되먹임되지 않는다.
    val memoryPayloadBytes = Output(UInt(memoryPayloadByteCountWidth.W))

    // CircularBufferStorage의 같은 의미를 가진 write 입력에 연결한다.
    val storageWriteEnable = Output(Bool())
    val storageWriteBytePtr = Output(UInt(localPointerWidth.W))
    val storageWriteData = Output(UInt(512.W))
    val storageWriteLaneValidMask = Output(UInt(4.W))

    // 다음 단계의 읽기 제어부가 안전하게 반환한 새 경계를 전달한다.
    // cache의 재사용이 남아 있는 구간은 반환하면 안 된다.
    val reclaim = Flipped(Valid(UInt(localPointerWidth.W)))

    // 데이터 반환과 entry 반환은 별도다. 상위 정책에 따라 byte 공간은 먼저 반환해도,
    // entry는 해당 chunk의 수신과 최종 사용이 모두 끝난 뒤에 반환한다.
    // 반환 번호는 현재 head와 같아야 한다. Cache 중간 pass에서는 반환하지 않는다.
    val releaseChunk = Flipped(Valid(UInt(entryIndexWidth.W)))

    // 이후 읽기/상태 제어부가 참고할 쓰기 경로의 상태다.
    val writeCommitPtr = Output(UInt(localPointerWidth.W))
    val freeBytes = Output(UInt(byteCountWidth.W))
    val full = Output(Bool())
    val refillPending = Output(Bool())
    val refillContextId = Output(UInt(contextIdWidth.W))
    val chunkEntries = Output(Vec(chunkEntryCountLimit,
      new CircularBufferChunkEntry(localPointerWidth, byteCountWidth, groupIndexWidth, userTagWidth, contextIdWidth)
    ))
  })

  val writeCommitPtr = RegInit(0.U(localPointerWidth.W))
  val reclaimPtr = RegInit(0.U(localPointerWidth.W))
  val reservedRefillBytes = RegInit(0.U(byteCountWidth.W))
  val refillPending = RegInit(false.B)
  val activeRefillEntryIndex = RegInit(0.U(entryIndexWidth.W))

  // Metadata도 요청 순서를 유지하는 원형 큐로 관리한다.
  // head는 최종 사용 후 반환할 가장 오래된 entry, tail은 다음 할당 위치다.
  // Cache replay의 읽기 cursor는 이 head와 별도로 상위에서 관리한다.
  val entryHead = RegInit(0.U(entryIndexWidth.W))
  val entryTail = RegInit(0.U(entryIndexWidth.W))
  val entryCount = RegInit(0.U(log2Ceil(chunkEntryCountLimit + 1).W))

  val chunkEntries = RegInit(VecInit(Seq.fill(chunkEntryCountLimit)(
    0.U.asTypeOf(new CircularBufferChunkEntry(
      localPointerWidth, byteCountWidth, groupIndexWidth, userTagWidth, contextIdWidth
    ))
  )))

  val clear = io.softReset || reset.asBool

  // Pointer 차이는 2 x capacity modulus의 byte 거리다.
  // readPtr는 replay 중 되돌아가므로 공간 계산에 사용하지 않는다.
  val residentBytes = (writeCommitPtr - reclaimPtr)(localPointerWidth - 1, 0)
  val usedAndReservedBytes = residentBytes +& reservedRefillBytes

  // 잘못된 상위 입력으로 음수가 되는 경우에도 freeBytes가 큰 값으로 wrap되지 않게 한다.
  // 아래 invariant assertion으로 실제 점유량 초과도 함께 검출한다.
  val freeBytes = Mux(
    usedAndReservedBytes <= bufferCapacityBytes.U,
    (bufferCapacityBytes.U - usedAndReservedBytes)(byteCountWidth - 1, 0),
    0.U(byteCountWidth.W)
  )
  val full = freeBytes < maxRefillBytes.U

  // 빈 번호를 다시 검색하지 않고 tail에만 할당한다.
  // 따라서 entry 번호가 0 -> 1 -> 2 -> 3 -> 0 순서로 이어진다.
  val freeEntryAvailable = entryCount < chunkEntryCountLimit.U

  // 일반 refill은 16B 정렬, 최대 4096B다. 길이 미확정 요청에는 4096B를 예약한다.
  val requestedPayloadBytes = io.reserveRefill.bits.payloadBytes
  val reservationBytes = Mux(
    requestedPayloadBytes === 0.U, maxRefillBytes.U, requestedPayloadBytes
  )
  val reservationLengthValid = requestedPayloadBytes <= maxRefillBytes.U &&
    requestedPayloadBytes(3, 0) === 0.U

  // 일반 refill은 full일 때 짧은 tail도 승인하지 않는다. Stream은 entry만 배정한 뒤
  // 각 credit을 실제 freeBytes로 검사하므로 4KiB보다 작은 여유 공간도 사용한다.
  // 동시 reclaim/release로 생길 공간은 다음 cycle부터 admission에 반영한다.
  val streamingReservation = if (enableStreaming) io.reserveRefill.bits.streaming else false.B
  io.reserveRefill.ready := !clear && !refillPending && freeEntryAvailable &&
    Mux(streamingReservation, requestedPayloadBytes === 0.U, !full && reservationLengthValid)
  io.reservationEntryIndex := entryTail
  val reservationFire = io.reserveRefill.fire
  val receivingStream = refillPending && chunkEntries(activeRefillEntryIndex).streaming
  io.receivingStream := receivingStream
  io.reservedBytes := reservedRefillBytes
  val creditFire = io.streamCredit.map(_.fire).getOrElse(false.B)
  val creditBytes = io.streamCredit.map(_.bits).getOrElse(0.U(byteCountWidth.W))
  io.streamCredit.foreach { credit =>
    credit.ready := !clear && receivingStream && credit.bits =/= 0.U &&
      credit.bits(3, 0) === 0.U && credit.bits <= freeBytes
  }
  val releaseFire = io.releaseChunk.valid && !clear

  val acceptedPayloadBytes = PopCount(io.memoryLaneValidMask) << log2Ceil(consumerBeatBytes)
  io.memoryPayloadBytes := acceptedPayloadBytes
  val laneMaskValid = io.memoryLaneValidMask === "b0001".U ||
    io.memoryLaneValidMask === "b0011".U ||
    io.memoryLaneValidMask === "b0111".U ||
    io.memoryLaneValidMask === "b1111".U
  val memoryContextMatches = io.memoryContextId === chunkEntries(activeRefillEntryIndex).contextId
  val memoryTagMatches = io.memoryUserTag === chunkEntries(activeRefillEntryIndex).userTag
  val responseFitsReservation = acceptedPayloadBytes <= reservedRefillBytes

  // full은 새 요청만 막는다. 이미 예약한 응답은 자신의 reservation으로 수신한다.
  io.memoryDataReady := !clear && refillPending && memoryContextMatches &&
    memoryTagMatches && laneMaskValid && responseFitsReservation &&
    reservedRefillBytes =/= 0.U
  val memoryWriteFire = io.memoryDataValid && io.memoryDataReady
  val writeCommitPtrNext = (writeCommitPtr + acceptedPayloadBytes)(localPointerWidth - 1, 0)

  io.storageWriteEnable := memoryWriteFire
  io.storageWriteBytePtr := writeCommitPtr
  io.storageWriteData := io.memoryData
  io.storageWriteLaneValidMask := io.memoryLaneValidMask

  when(reservationFire) {
    refillPending := true.B
    reservedRefillBytes := Mux(streamingReservation, 0.U, reservationBytes)
    activeRefillEntryIndex := entryTail
    entryTail := entryTail + 1.U

    chunkEntries(entryTail).allocated := true.B
    chunkEntries(entryTail).complete := false.B
    chunkEntries(entryTail).streaming := streamingReservation
    chunkEntries(entryTail).startPtr := writeCommitPtr
    chunkEntries(entryTail).endPtr := writeCommitPtr
    chunkEntries(entryTail).payloadBytes := 0.U
    chunkEntries(entryTail).contextId := (if (enableContextPrefill) io.reserveRefill.bits.contextId else io.contextId)
    chunkEntries(entryTail).userTag := io.reserveRefill.bits.userTag
    chunkEntries(entryTail).groupIndex := io.reserveRefill.bits.groupIndex
    chunkEntries(entryTail).lastInGroup := io.reserveRefill.bits.lastInGroup
    chunkEntries(entryTail).lastInStream := false.B
  }

  when(memoryWriteFire) {
    writeCommitPtr := writeCommitPtrNext
    chunkEntries(activeRefillEntryIndex).endPtr := writeCommitPtrNext
    chunkEntries(activeRefillEntryIndex).payloadBytes :=
      chunkEntries(activeRefillEntryIndex).payloadBytes + acceptedPayloadBytes

    when(io.memoryChunkLast) {
      refillPending := false.B
      chunkEntries(activeRefillEntryIndex).complete := true.B
      chunkEntries(activeRefillEntryIndex).lastInStream := io.memoryStreamLast
    }
  }

  // Credit 추가와 수신은 같은 cycle에 일어날 수 있으므로 delta를 한 번만 반영한다.
  when(!reservationFire) {
    reservedRefillBytes := reservedRefillBytes +
      Mux(creditFire, creditBytes, 0.U) - Mux(memoryWriteFire, acceptedPayloadBytes, 0.U)
    when(memoryWriteFire && io.memoryChunkLast) {
      reservedRefillBytes := 0.U
    }
  }

  // Write와 reclaim은 서로 다른 pointer를 갱신하므로 같은 cycle에도 모두 반영된다.
  val reclaimedBytes = (io.reclaim.bits - reclaimPtr)(localPointerWidth - 1, 0)
  when(io.reclaim.valid && !clear) {
    assert(io.reclaim.bits(3, 0) === 0.U, "reclaim pointer must be 16-byte aligned")
    assert(reclaimedBytes <= residentBytes, "cannot reclaim uncommitted payload")
    reclaimPtr := io.reclaim.bits
  }
  // Stream entry의 startPtr는 미소비 구간의 시작이다. 전체 길이가 32KiB를 넘어도
  // 물리 범위와 payloadBytes는 현재 resident 구간만 나타내므로 wrap에 안전하다.
  when(chunkEntries(entryHead).allocated && chunkEntries(entryHead).streaming) {
    val streamWrite = memoryWriteFire && activeRefillEntryIndex === entryHead
    val streamReclaim = io.reclaim.valid && !clear
    when(streamReclaim) { chunkEntries(entryHead).startPtr := io.reclaim.bits }
    when(streamWrite || streamReclaim) {
      chunkEntries(entryHead).payloadBytes := chunkEntries(entryHead).payloadBytes +
        Mux(streamWrite, acceptedPayloadBytes, 0.U) - Mux(streamReclaim, reclaimedBytes, 0.U)
    }
  }

  // 최종 사용이 끝난 entry를 요청 순서대로 반환한다.
  // 소비 도중이거나 재사용이 남아 있으면 상위가 release를 보류해야 한다.
  when(releaseFire) {
    assert(entryCount =/= 0.U, "cannot release from an empty metadata queue")
    assert(io.releaseChunk.bits === entryHead, "metadata entries must be released in FIFO order")
    assert(chunkEntries(entryHead).allocated, "released entry must be allocated")
    assert(chunkEntries(entryHead).complete, "cannot release an incomplete refill")
    chunkEntries(entryHead) := 0.U.asTypeOf(new CircularBufferChunkEntry(
      localPointerWidth, byteCountWidth, groupIndexWidth, userTagWidth, contextIdWidth
    ))
    entryHead := entryHead + 1.U
  }

  // 할당과 반환이 동시에 발생하면 개수는 유지한다.
  // 같은 register를 두 블록에서 덮어쓰지 않고 모든 증감을 한 번에 반영한다.
  when(reservationFire && !releaseFire) {
    entryCount := entryCount + 1.U
  }.elsewhen(releaseFire && !reservationFire) {
    entryCount := entryCount - 1.U
  }

  io.writeCommitPtr := writeCommitPtr
  io.freeBytes := freeBytes
  io.full := full
  // 긴 stream은 아직 추가 credit을 기다리더라도 미도착 예약이 없으면 pending이 아니다.
  io.refillPending := refillPending && (!receivingStream || reservedRefillBytes =/= 0.U)
  io.refillContextId := chunkEntries(activeRefillEntryIndex).contextId
  io.chunkEntries := chunkEntries

  when(!clear) {
    assert(entryCount <= chunkEntryCountLimit.U, "metadata queue count exceeds its capacity")
    assert(PopCount(chunkEntries.map(_.allocated)) === entryCount,
      "metadata queue count must match allocated entries")
    when(freeEntryAvailable) {
      assert(!chunkEntries(entryTail).allocated, "metadata tail must point to a free entry")
    }
    assert(residentBytes <= bufferCapacityBytes.U, "resident payload exceeds storage capacity")
    assert(usedAndReservedBytes <= bufferCapacityBytes.U, "reservation exceeds storage capacity")
    when(io.reserveRefill.valid) {
      assert(Mux(streamingReservation, requestedPayloadBytes === 0.U, reservationLengthValid),
        "normal refill needs aligned bytes up to 4KiB; streaming refill starts without credit")
    }
    when(memoryWriteFire) {
      assert(!io.memoryStreamLast || io.memoryChunkLast, "stream last must also end its logical chunk")
      when(!io.memoryChunkLast && !receivingStream) {
        assert(acceptedPayloadBytes < reservedRefillBytes, "reservation exhausted before chunk last")
      }
      when(io.memoryChunkLast && receivingStream) {
        assert(acceptedPayloadBytes === reservedRefillBytes && !creditFire,
          "bounded stream must finish with no promised credit left")
      }
    }
  }

  // 명세의 안전한 context 경계에서 사용하는 초기화다.
  // 저장소 데이터는 지우지 않고, 이 제어부가 소유한 pointer와 metadata만 초기화한다.
  when(clear) {
    writeCommitPtr := 0.U
    reclaimPtr := 0.U
    reservedRefillBytes := 0.U
    refillPending := false.B
    activeRefillEntryIndex := 0.U
    entryHead := 0.U
    entryTail := 0.U
    entryCount := 0.U
    chunkEntries := 0.U.asTypeOf(chunkEntries)
  }
}
