package npu.core.memory

import chisel3._
import chisel3.util._

/** Connects the WB controller to its 64B-write/16B-read ping-pong SRAM. */
class WbControllerWithSram extends Module {
  val io = IO(new Bundle {
    val soft_reset    = Input(Bool())
    val enable        = Input(Bool())
    val shoot         = Input(Bool())
    val lut_prog_mode = Input(Bool())
    val rlast         = Input(Bool())

    val dma_data        = Input(UInt(512.W))
    val dma_data_valid  = Input(Bool())
    val dma_data_last   = Input(Bool())
    val dma_write_ready = Input(Bool())

    val ready     = Output(Bool())
    val hungry    = Output(Bool())
    val impending = Output(Bool())
    val working   = Output(Bool())
    val write_buffer_has_space = Output(Bool())
    val full = Output(Bool())
    val dma_last_data_out = Output(Bool())

    val rd_data_to_cu  = Output(UInt(128.W))
    val rd_data_to_lut = Output(UInt(128.W))
    val rd_data_valid  = Output(Bool())

    // Debug-only visibility for tests: which physical SRAM bank receives DMA writes.
    val dbg_ping_wr_en   = Output(Bool())
    val dbg_pong_wr_en   = Output(Bool())
    val dbg_ping_wr_addr = Output(UInt(7.W))
    val dbg_pong_wr_addr = Output(UInt(7.W))
    val dbg_ping_wr_data = Output(UInt(512.W))
    val dbg_pong_wr_data = Output(UInt(512.W))
  })

  val controller = Module(new UbWbController(is_ub = false))
  val sram = Module(new AsymmetricPingPongSRAM())

  controller.io.ctrl.soft_reset      := io.soft_reset
  controller.io.ctrl.enable          := io.enable
  controller.io.ctrl.shoot           := io.shoot
  controller.io.ctrl.rlast           := io.rlast
  controller.io.ctrl.dma_data_valid  := io.dma_data_valid
  controller.io.ctrl.dma_data_last   := io.dma_data_last
  controller.io.ctrl.dma_write_ready := io.dma_write_ready
  controller.io.is_lut_load.get      := io.lut_prog_mode

  val readPing  = controller.io.active_bank === 0.U
  val writePing = !readPing

  // DMA fills the bank opposite to the active CU read bank.
  sram.io.ping_wr_en   := controller.io.wr_en && writePing
  sram.io.pong_wr_en   := controller.io.wr_en && !writePing
  sram.io.ping_wr_addr := controller.io.wr_addr
  sram.io.pong_wr_addr := controller.io.wr_addr
  sram.io.ping_wr_data := io.dma_data
  sram.io.pong_wr_data := io.dma_data

  // CU reads only the controller-selected active bank.
  sram.io.ping_rd_en   := controller.io.rd_en && readPing
  sram.io.pong_rd_en   := controller.io.rd_en && !readPing
  sram.io.ping_rd_addr := controller.io.rd_addr
  sram.io.pong_rd_addr := controller.io.rd_addr

  // SRAM is synchronous, so select its response with the delayed bank ID.
  val readPingD1 = RegEnable(readPing, true.B, controller.io.rd_en)
  controller.io.rd_data := Mux(
    readPingD1,
    sram.io.ping_rd_data,
    sram.io.pong_rd_data
  )

  io.ready          := controller.io.ctrl.ready
  io.hungry         := controller.io.ctrl.hungry
  io.impending      := controller.io.ctrl.impending
  io.working        := controller.io.ctrl.working
  io.write_buffer_has_space := io.hungry
  io.full := controller.io.ctrl.full
  io.dma_last_data_out := io.dma_data_valid && io.dma_data_last
  io.rd_data_to_cu  := controller.io.mxu_data_out
  io.rd_data_to_lut := controller.io.lut_data_out.get
  io.rd_data_valid  := RegNext(controller.io.rd_en, false.B)

  io.dbg_ping_wr_en   := sram.io.ping_wr_en
  io.dbg_pong_wr_en   := sram.io.pong_wr_en
  io.dbg_ping_wr_addr := sram.io.ping_wr_addr
  io.dbg_pong_wr_addr := sram.io.pong_wr_addr
  io.dbg_ping_wr_data := sram.io.ping_wr_data
  io.dbg_pong_wr_data := sram.io.pong_wr_data
}
