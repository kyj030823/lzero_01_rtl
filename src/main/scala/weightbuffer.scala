import chisel3._
import chisel3.util._

/**
  * 8 KiB ping-pong weight buffer.
  *
  *   - ping/pong: 4 KiB x 2
  *   - 2 buffers x 4 banks x 2 lanes = 16 independent memories
  *   - each lane: 64 x 64 bits (8 bytes/port)
  *   - DMA write: 16 bytes/bank, 64 bytes/cycle total
  *   - CU read: one bank, 16 bytes/cycle, one-cycle latency
  */
class WeightBuffer extends Module {
  val io = IO(new Bundle {
    val dma_valid = Input(Bool())
    val dma_data  = Input(Vec(64, UInt(8.W)))
    val load_reset = Input(Bool())
    val load_done  = Output(Bool())

    val cu_read_en    = Input(Bool())
    val cu_read_data  = Output(Vec(16, UInt(8.W)))
    val cu_read_valid = Output(Bool())
    val read_reset    = Input(Bool())
    val read_done     = Output(Bool())
  })

  val activeReadBuffer = RegInit(false.B)
  val banks = Seq.tabulate(2, 4, 2) { (buffer, bank, lane) =>
    SyncReadMem(64, UInt(64.W))
      .suggestName(s"wb_b${buffer}_bank${bank}_lane${lane}")
  }
  val writeAddr = RegInit(0.U(6.W))
  val readAddr  = RegInit(0.U(8.W))

  val writeBuffer = !activeReadBuffer

  io.load_done := io.dma_valid && writeAddr === 63.U

  when(io.load_reset) {
    writeAddr := 0.U
  }.elsewhen(io.dma_valid) {
    writeAddr := Mux(writeAddr === 63.U, 0.U, writeAddr + 1.U)
  }

  // A 64-byte DMA beat writes two 8-byte lanes in every logical bank.
  for (buffer <- 0 until 2; bank <- 0 until 4; lane <- 0 until 2) {
    val laneWord = VecInit(Seq.tabulate(8) { byte =>
      io.dma_data(bank * 16 + lane * 8 + byte)
    }).asUInt

    when(io.dma_valid && writeBuffer === (buffer == 1).B) {
      banks(buffer)(bank)(lane).write(writeAddr, laneWord)
    }
  }

  // Consecutive reads visit logical banks 0, 1, 2, 3 and then advance
  // the address shared by the four banks.
  val lastCuRead = io.cu_read_en && readAddr === 255.U
  val selectedBank = readAddr(1, 0)
  val cuWordAddr = readAddr(7, 2)
  val selectedBankReg = RegEnable(selectedBank, 0.U, io.cu_read_en)
  val selectedBufferReg = RegEnable(activeReadBuffer, false.B, io.cu_read_en)

  when(io.read_reset) {
    readAddr := 0.U
  }.elsewhen(io.cu_read_en) {
    readAddr := Mux(readAddr === 255.U, 0.U, readAddr + 1.U)
  }

  val bankReadData = Seq.tabulate(2, 4) { (buffer, bank) =>
    val readEnable = io.cu_read_en &&
      activeReadBuffer === (buffer == 1).B && selectedBank === bank.U
    val lane0 = banks(buffer)(bank)(0).read(cuWordAddr, readEnable)
    val lane1 = banks(buffer)(bank)(1).read(cuWordAddr, readEnable)
    Cat(lane1, lane0)
  }

  val selectedWord = Mux1H(Seq.tabulate(2, 4) { (buffer, bank) =>
    val selected = selectedBufferReg === (buffer == 1).B &&
      selectedBankReg === bank.U
    selected -> bankReadData(buffer)(bank)
  }.flatten)

  io.cu_read_data := selectedWord.asTypeOf(Vec(16, UInt(8.W)))
  io.cu_read_valid := RegNext(io.cu_read_en, false.B)
  io.read_done := RegNext(lastCuRead, false.B)

  // Completing all 256 CU reads selects the opposite ping-pong buffer.
  when(lastCuRead) {
    activeReadBuffer := !activeReadBuffer
  }
}
