import chisel3._
import chisel3.util._

/**
  * 8 KiB ping-pong weight buffer organized as four banks.
  *
  *   - ping/pong: 4 KiB x 2
  *   - four banks: 128 x 128 bits per bank
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
  val banks = Seq.fill(4)(SyncReadMem(128, UInt(128.W)))
  val writeAddr = RegInit(0.U(6.W))
  val readAddr  = RegInit(0.U(8.W))

  // load_reset is an address-reset cycle, so no DMA beat is accepted then.
  val dmaWordAddr = Cat(!activeReadBuffer, writeAddr)

  io.load_done := io.dma_valid && writeAddr === 63.U

  when(io.load_reset) {
    writeAddr := 0.U
  }.elsewhen(io.dma_valid) {
    writeAddr := Mux(writeAddr === 63.U, 0.U, writeAddr + 1.U)
  }

  // One DMA beat writes 16 adjacent bytes into each bank.
  for (bank <- 0 until 4) {
    val bankWord = VecInit(Seq.tabulate(16) { byte =>
      io.dma_data(bank * 16 + byte)
    }).asUInt

    when(io.dma_valid) {
      banks(bank).write(dmaWordAddr, bankWord)
    }
  }

  // read_reset is an address-reset cycle. Consecutive accepted reads visit
  // banks 0, 1, 2, 3 and then advance the shared word address.
  val lastCuRead = io.cu_read_en && readAddr === 255.U
  val selectedBank = readAddr(1, 0)
  val cuWordAddr = Cat(activeReadBuffer, readAddr(7, 2))
  val selectedBankReg = RegEnable(selectedBank, 0.U, io.cu_read_en)

  when(io.read_reset) {
    readAddr := 0.U
  }.elsewhen(io.cu_read_en) {
    readAddr := Mux(readAddr === 255.U, 0.U, readAddr + 1.U)
  }

  val bankReadData = Seq.tabulate(4) { bank =>
    banks(bank).read(cuWordAddr, io.cu_read_en && selectedBank === bank.U)
  }
  val selectedWord = Mux1H(Seq.tabulate(4) { bank =>
    (selectedBankReg === bank.U) -> bankReadData(bank)
  })

  io.cu_read_data := selectedWord.asTypeOf(Vec(16, UInt(8.W)))
  io.cu_read_valid := RegNext(io.cu_read_en, false.B)
  io.read_done := RegNext(lastCuRead, false.B)

  // swap performs the initial hand-off. Later read completions switch
  // automatically to the opposite ping-pong buffer.
  when(lastCuRead) {
    activeReadBuffer := !activeReadBuffer
  }
}
