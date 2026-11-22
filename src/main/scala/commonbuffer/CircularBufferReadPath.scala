package npu.core.memory

import chisel3._
import chisel3.util._

/** Consumer에게 전달하는 16B와 해당 read에 귀속된 metadata.
  *
  * lastInStream은 memory 공급 stream의 마지막이라는 뜻이다.
  * Cache의 최종 pass인지, 전체 연산이 끝났는지는 UB/WB 제어부가 별도로 판단한다.
  */
class CircularBufferReadBeat(
  val entryIndexWidth: Int = 2,
  val groupIndexWidth: Int = 16,
  val userTagWidth: Int = 1,
  val contextIdWidth: Int = 8
) extends Bundle {
  val data = UInt(128.W)
  val contextId = UInt(contextIdWidth.W)
  val userTag = UInt(userTagWidth.W)
  val chunkEntryIndex = UInt(entryIndexWidth.W)
  val groupIndex = UInt(groupIndexWidth.W)
  val lastInChunk = Bool()
  val lastInGroup = Bool()
  val lastInStream = Bool()
}

/** UB/WB 공통 SRAM read 및 consumer 전달 경로.
  *
  * 상위는 현재 chunk와 읽기 허용 여부를 제공한다. 이 모듈은 byte 범위를 검사하고
  * SRAM read를 발행한 뒤 data, tag, 경계 marker를 함께 consumer에게 전달한다.
  * 다음 chunk 선택, cache replay 횟수, reclaim 및 entry 반환은 상위 정책이다.
  *
  * SRAM read는 1cycle이며 in-flight read는 최대 하나다.
  * Consumer가 바로 수락하면 SRAM 응답을 직접 전달해 연속 16B/cycle을 처리하고,
  * 수락하지 않으면 응답을 register에 보관해 data와 metadata를 유지한다.
  */
class CircularBufferReadPath(
  val bufferCapacityBytes: Int = 16384,
  val chunkEntryCountLimit: Int = 4,
  val groupIndexWidth: Int = 16,
  val userTagWidth: Int = 1,
  val memoryReadLatencyCycles: Int = 1,
  val contextIdWidth: Int = 8
) extends Module {
  require(bufferCapacityBytes == 16384)
  require(chunkEntryCountLimit == 4)
  require(groupIndexWidth > 0 && userTagWidth > 0)
  require(memoryReadLatencyCycles == 1, "현재 구현은 1cycle SRAM 응답을 지원합니다.")

  private val consumerBeatBytes = 16
  private val localPointerWidth = log2Ceil(bufferCapacityBytes) + 1
  private val byteCountWidth = log2Ceil(bufferCapacityBytes + 1)
  private val entryIndexWidth = log2Ceil(chunkEntryCountLimit)

  val io = IO(new Bundle {
    // 실행 중 초기화가 필요하면 먼저 SRAM 응답과 consumer 출력을 drain해야 한다.
    val softReset = Input(Bool())

    // Context 시작, cache rewind, 다음 범위 시작 시 두 read pointer를 설정한다.
    // 비어 있거나 기존 output을 수락하는 cycle에 적용한다.
    // readEnable이면 seek 수락과 새 위치의 첫 read를 같은 cycle에 처리한다.
    // 상위는 새 위치에 해당하는 chunk metadata도 함께 제공해야 한다.
    val seek = Flipped(Decoupled(UInt(localPointerWidth.W)))

    // 상위가 첫 compute chunk 준비 여부와 현재 mode에 따라 설정한다.
    // false여도 이미 발행한 SRAM 응답과 consumer 출력은 계속 처리한다.
    val readEnable = Input(Bool())

    // 현재 읽을 chunk의 live metadata다. 입력 순서는 상위가 정한다.
    // Array index가 물리 주소나 다음 소비 순서를 뜻하지는 않는다.
    val currentChunkEntryIndex = Input(UInt(entryIndexWidth.W))
    val currentChunk = Input(new CircularBufferChunkEntry(
      localPointerWidth, byteCountWidth, groupIndexWidth, userTagWidth, contextIdWidth
    ))

    // 일반 compute chunk는 complete된 뒤 읽는다.
    // LUT streaming 등은 이 입력을 true로 두고 기록된 구간부터 읽을 수 있다.
    val allowIncompleteChunk = Input(Bool())
    val writeCommitPtr = Input(UInt(localPointerWidth.W))

    // CircularBufferStorage의 read 포트와 직접 연결한다.
    val storageReadEnable = Output(Bool())
    val storageReadBytePtr = Output(UInt(localPointerWidth.W))
    val storageReadData = Input(UInt(128.W))
    val storageReadDataValid = Input(Bool())

    // 상위가 tag를 해석해 CU 또는 LUT consumer에 연결한다.
    // output.fire && output.bits.lastInChunk가 chunk 최종 소비 event다.
    val output = Decoupled(new CircularBufferReadBeat(
      entryIndexWidth, groupIndexWidth, userTagWidth, contextIdWidth
    ))

    // 상위의 잔여 payload 계산에 사용한다. 출력 수락 시에만 16B 전진한다.
    // seek를 수락할 때에는 새 범위의 시작 위치로 변경된다.
    val readPtr = Output(UInt(localPointerWidth.W))

    // SRAM in-flight와 보관 중인 output이 모두 없을 때 true다.
    // Context 전환 시 상위는 새 read 발행도 막아야 한다.
    val idle = Output(Bool())
  })

  val positioned = RegInit(false.B)
  val readIssuePtr = RegInit(0.U(localPointerWidth.W))
  val readPtr = RegInit(0.U(localPointerWidth.W))
  val readInFlight = RegInit(false.B)
  val outputValidReg = RegInit(false.B)
  val outputReg = RegInit(0.U.asTypeOf(new CircularBufferReadBeat(
    entryIndexWidth, groupIndexWidth, userTagWidth, contextIdWidth
  )))

  val clear = io.softReset || reset.asBool
  val responseValid = readInFlight && io.storageReadDataValid
  val outputAvailable = outputValidReg || responseValid

  io.output.valid := !clear && outputAvailable
  io.output.bits := outputReg
  io.output.bits.data := Mux(outputValidReg, outputReg.data, io.storageReadData)
  val outputFire = io.output.fire

  io.idle := !readInFlight && !outputValidReg

  // 기존 output이 수락되면 그 cycle의 응답 자리를 새 read에 사용할 수 있다.
  // Seek도 같은 조건에서 수락해 pointer 변경 때문에 별도 대기 cycle이 생기지 않게 한다.
  val responseSlotAvailable = !readInFlight || responseValid
  val outputSlotAvailable = !outputAvailable || outputFire
  io.seek.ready := !clear && responseSlotAvailable && outputSlotAvailable
  val seekFire = io.seek.fire
  val readAddress = Mux(seekFire, io.seek.bits, readIssuePtr)
  io.readPtr := readPtr

  // 차이는 wrap bit를 포함한 15bit modulus로 계산한다.
  val chunkBytesCommitted =
    (io.currentChunk.endPtr - io.currentChunk.startPtr)(localPointerWidth - 1, 0)
  val offsetInChunk =
    (readAddress - io.currentChunk.startPtr)(localPointerWidth - 1, 0)
  val bytesToChunkEnd =
    (io.currentChunk.endPtr - readAddress)(localPointerWidth - 1, 0)
  val committedBytesAhead =
    (io.writeCommitPtr - readAddress)(localPointerWidth - 1, 0)

  // 일반 chunk는 start/end 범위를 검사한다.
  // 수신 중 LUT는 순차 진행 중인 미소비 구간을 live end/commit까지 읽는다.
  // 이때 전체 LUT 길이를 저장소 용량 이하로 제한하지 않는다.
  val insideCompleteChunk = offsetInChunk +& consumerBeatBytes.U <= chunkBytesCommitted
  val currentChunkReadable = io.currentChunk.allocated &&
    (io.allowIncompleteChunk || io.currentChunk.complete) &&
    (io.allowIncompleteChunk || insideCompleteChunk)
  val chunkPayloadAvailable = bytesToChunkEnd >= consumerBeatBytes.U &&
    bytesToChunkEnd <= bufferCapacityBytes.U
  val committedPayloadAvailable = committedBytesAhead >= consumerBeatBytes.U &&
    committedBytesAhead <= bufferCapacityBytes.U

  // 아직 응답이 도착하지 않은 read를 새 read로 덮어쓰지 않는다.
  // 보관 중인 output 또는 이번 SRAM 응답이 있으면, 그것이 수락되는 cycle에만
  // 다음 read를 발행한다. 따라서 정지 시 새 응답을 보관할 공간이 항상 있다.
  val readIssueFire = !clear && (positioned || seekFire) && io.readEnable &&
    (!io.seek.valid || seekFire) &&
    currentChunkReadable && chunkPayloadAvailable && committedPayloadAvailable &&
    responseSlotAvailable && outputSlotAvailable

  val readIssuePtrNext =
    (readAddress + consumerBeatBytes.U)(localPointerWidth - 1, 0)
  val lastInChunk = io.currentChunk.complete && readIssuePtrNext === io.currentChunk.endPtr

  io.storageReadEnable := readIssueFire
  io.storageReadBytePtr := readAddress

  when(seekFire) {
    assert(io.seek.bits(3, 0) === 0.U, "seek pointer must be 16-byte aligned")
    readIssuePtr := io.seek.bits
    readPtr := io.seek.bits
    positioned := true.B
  }

  // SRAM 응답은 consumer ready와 무관하게 처리한다.
  // 바로 전달할 수 없을 때에만 보관 상태를 유지한다.
  when(responseValid && !clear) {
    readInFlight := false.B
    outputReg.data := io.storageReadData
    outputValidReg := !io.output.ready
  }

  when(outputFire) {
    // 마지막 출력 수락과 seek가 겹치면 새 pass의 시작 위치가 우선한다.
    when(!seekFire) {
      readPtr := (readPtr + consumerBeatBytes.U)(localPointerWidth - 1, 0)
    }
    outputValidReg := false.B
  }

  // Metadata는 read 발행 시 고정한다. 입력 chunk나 tag가 나중에 바뀌어도
  // 미수락 output의 목적지와 last marker는 변하지 않는다.
  when(readIssueFire) {
    readIssuePtr := readIssuePtrNext
    readInFlight := true.B
    outputReg.contextId := io.currentChunk.contextId
    outputReg.userTag := io.currentChunk.userTag
    outputReg.chunkEntryIndex := io.currentChunkEntryIndex
    outputReg.groupIndex := io.currentChunk.groupIndex
    outputReg.lastInChunk := lastInChunk
    outputReg.lastInGroup := lastInChunk && io.currentChunk.lastInGroup
    outputReg.lastInStream := lastInChunk && io.currentChunk.lastInStream
  }

  when(!clear) {
    assert(io.storageReadDataValid === readInFlight,
      "storage read valid must match the configured 1-cycle response")
    assert(!(readInFlight && outputValidReg),
      "cannot have an unbuffered response while the output register is occupied")
    when(seekFire && !io.idle) {
      assert(outputFire, "seek may overlap only the acceptance of the previous output")
    }
    when(readIssueFire) {
      assert(readAddress(3, 0) === 0.U, "read issue address must be 16-byte aligned")
      assert(io.currentChunk.startPtr(3, 0) === 0.U, "chunk start must be 16-byte aligned")
      assert(io.currentChunk.endPtr(3, 0) === 0.U, "chunk end must be 16-byte aligned")
      assert(io.writeCommitPtr(3, 0) === 0.U, "write commit pointer must be 16-byte aligned")
    }
  }

  when(io.softReset && !reset.asBool) {
    assert(io.idle, "softReset requires the read pipeline to be drained")
  }

  when(clear) {
    positioned := false.B
    readIssuePtr := 0.U
    readPtr := 0.U
    readInFlight := false.B
    outputValidReg := false.B
    outputReg := 0.U.asTypeOf(outputReg)
  }
}
