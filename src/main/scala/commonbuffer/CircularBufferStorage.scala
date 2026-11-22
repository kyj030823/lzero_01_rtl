package npu.core.memory

import chisel3._
import chisel3.util._

/** WB 명세서 v3의 16KiB 원형 저장소.
  *
  * 16B 단위로 읽고 쓰는 bank 네 개를 사용한다. 각 bank는 256 x 128bit이며,
  * 한 cycle에 write 한 번과 read 한 번을 동시에 처리할 수 있다.
  *
  * 포인터 갱신, 빈 공간 계산, refill 예약, 데이터 종류와 chunk 경계는
  * 상위 제어부가 관리한다. 이 모듈은 전달받은 주소와 mask에 따라 접근한다.
  */
class CircularBufferStorage(
  val bufferCapacityBytes: Int = 16384,
  val memoryReadLatencyCycles: Int = 1
) extends Module {
  require(bufferCapacityBytes == 16384, "현재 구현은 명세서의 16KiB 저장소를 지원합니다.")
  require(memoryReadLatencyCycles == 1, "현재 구현은 1cycle 동기식 SRAM 읽기를 지원합니다.")

  private val memoryBeatBytes = 64 //입력 최대 바이트
  private val consumerBeatBytes = 16 //출력 바이트
  private val bankCount = memoryBeatBytes / consumerBeatBytes //bank 개수
  private val bankDepth = bufferCapacityBytes / memoryBeatBytes //bank당 depth
  private val physicalOffsetWidth = log2Ceil(bufferCapacityBytes) // 16KiB 저장소의 물리적 오프셋 비트 수
  private val localPointerWidth = physicalOffsetWidth + 1 // 16KiB 저장소의 wrap bit를 포함한 로컬 포인터 비트 수
  private val laneOffsetWidth = log2Ceil(consumerBeatBytes) // 16B lane 내의 오프셋 비트 수
  private val bankIndexWidth = log2Ceil(bankCount) // bank 선택 비트 수
  private val physicalLaneWidth = physicalOffsetWidth - laneOffsetWidth // 16B lane 단위의 물리적 오프셋 비트 수

  val io = IO(new Bundle {
    // 제어부의 memoryDataValid && memoryDataReady를 연결한다.
    val writeEnable = Input(Bool())

    // 15bit extended byte pointer. SRAM 접근에는 하위 14bit만 사용한다.
    // 시작 주소는 16B 정렬이어야 한다.
    val writeBytePtr = Input(UInt(localPointerWidth.W))

    // lane 0이 하위 128bit다. 각 lane은 연속된 16B payload를 담는다.
    val writeData = Input(UInt((memoryBeatBytes * 8).W))

    // 하위 lane부터 연속된 0001, 0011, 0111, 1111만 지원한다.
    // writeEnable이 false이면 mask와 writeData는 사용하지 않는다.
    val writeLaneValidMask = Input(UInt(bankCount.W))

    // 제어부가 응답 보관 공간을 확보한 경우에만 read를 발행한다.
    val readEnable = Input(Bool())
    val readBytePtr = Input(UInt(localPointerWidth.W))

    // readEnable을 올린 다음 cycle에 해당 주소의 16B가 유효하다.
    // readDataValid가 false일 때 readData 값은 보장하지 않는다.
    val readData = Output(UInt((consumerBeatBytes * 8).W))
    val readDataValid = Output(Bool())
  })

  // 메모리 내용은 reset으로 지우지 않는다.
  // 제어부는 현재 context에서 기록된 유효 범위만 읽어야 한다.
  private val banks = Seq.tabulate(bankCount) { bank =>
    SyncReadMem(bankDepth, UInt((consumerBeatBytes * 8).W))
      .suggestName(s"dataBank$bank")
  }

  // Byte 주소를 16B lane 위치로 바꾸고, 입력 lane마다 목적지를 계산한다.
  // 상위 wrap bit는 제외하며 16KiB 끝을 넘으면 물리 위치 0으로 돌아간다.
  val firstWriteLane = io.writeBytePtr(physicalOffsetWidth - 1, laneOffsetWidth) // 16B 단위로 맞춤 -> 0~1023중 몇번째에 쓸 것인지 결정
  val writeLanePositions = Wire(Vec(bankCount, UInt(physicalLaneWidth.W)))
  for (lane <- 0 until bankCount) {
    writeLanePositions(lane) := (firstWriteLane + lane.U)(physicalLaneWidth - 1, 0) //lane 0이 5면 lane 1은 6, lane 2는 7, lane 3은 8
  }

// 읽기 bank 선택과 주소 계산
  val readBank = io.readBytePtr(laneOffsetWidth + bankIndexWidth - 1, laneOffsetWidth)
  val readWordAddress = io.readBytePtr(
    physicalOffsetWidth - 1,
    laneOffsetWidth + bankIndexWidth
  )
  val bankReadData = Wire(Vec(bankCount, UInt((consumerBeatBytes * 8).W)))

// bank당 쓰기와 읽기 수행.
  for (bank <- 0 until bankCount) {
    // 인접한 네 lane은 서로 다른 bank로 향하므로 bank마다 최대 한 lane이 선택된다.
    val selectedLanes = (0 until bankCount).map { lane =>
      io.writeLaneValidMask(lane) &&
        writeLanePositions(lane)(bankIndexWidth - 1, 0) === bank.U
    }

    // 주소와 데이터를 먼저 선택해 bank별 write port가 하나만 만들어지게 한다.
    // 예: offset 80부터 64B를 쓰면 bank 1, 2, 3, 0 순서로 기록한다.
    val writeWordAddress = Mux1H(selectedLanes, (0 until bankCount).map { lane =>
      writeLanePositions(lane)(physicalLaneWidth - 1, bankIndexWidth)
    })
    val writeWordData = Mux1H(selectedLanes, (0 until bankCount).map { lane =>
      io.writeData((lane + 1) * consumerBeatBytes * 8 - 1, lane * consumerBeatBytes * 8)
    })
    val bankWriteEnable = io.writeEnable && selectedLanes.reduce(_ || _)

    when(bankWriteEnable) {
      banks(bank).write(writeWordAddress, writeWordData)
    }

    // 전체 저장소에서 한 cycle에 선택한 bank의 16B 하나만 읽는다.
    bankReadData(bank) := banks(bank).read(
      readWordAddress,
      io.readEnable && readBank === bank.U
    )
  }

  // SRAM 응답과 같은 cycle의 bank 선택을 사용하도록 선택 신호도 1cycle 지연한다.
  val readBankD1 = RegEnable(readBank, 0.U(bankIndexWidth.W), io.readEnable)
  io.readData := bankReadData(readBankD1)
  io.readDataValid := RegNext(io.readEnable, false.B)

  // 아래 assertion은 제어부와 저장소 사이의 접근 계약을 확인한다.
  // 실제 commit/free-space 검사와 충돌 예방은 상위 제어부의 책임이다.
  when(io.writeEnable) {
    assert(io.writeBytePtr(laneOffsetWidth - 1, 0) === 0.U,
      "writeBytePtr must be aligned to 16 bytes")
    assert(
      io.writeLaneValidMask === "b0001".U ||
        io.writeLaneValidMask === "b0011".U ||
        io.writeLaneValidMask === "b0111".U ||
        io.writeLaneValidMask === "b1111".U,
      "writeLaneValidMask must be a nonempty low-lane prefix"
    )
  }

  when(io.readEnable) {
    assert(io.readBytePtr(laneOffsetWidth - 1, 0) === 0.U,
      "readBytePtr must be aligned to 16 bytes")
  }

  // 동일한 16B 위치를 동시에 읽고 쓸 때의 SRAM primitive 동작에 의존하지 않는다.
  // Wrap bit가 달라도 하위 물리 주소가 같으면 동일 위치다.
  when(io.writeEnable && io.readEnable) {
    for (lane <- 0 until bankCount) {
      when(io.writeLaneValidMask(lane)) {
        assert(
          writeLanePositions(lane) =/=
            io.readBytePtr(physicalOffsetWidth - 1, laneOffsetWidth),
          "simultaneous read and write to the same physical lane"
        )
      }
    }
  }
}
