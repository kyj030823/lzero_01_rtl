package npu.core.memory

import chisel3._
import chisel3.util._

/** Connects VbController's address control to the 4 KiB VbSram. */
class VbControllerWithSram extends Module {
  val io = IO(new Bundle {
    val ctrl          = new VbCtrlIo()
    val fusion_req_in = Input(Bool())

    val wr_valid   = Input(Bool())
    val last_write = Input(Bool())
    val wr_data    = Input(UInt(128.W))

    val rd_data  = Output(UInt(128.W))
    val rd_valid = Output(Bool())
  })

  val controller = Module(new VbController())
  val sram = Module(new VbSram())

  controller.io.ctrl.soft_reset      := io.ctrl.soft_reset
  controller.io.ctrl.enable          := io.ctrl.enable
  controller.io.fusion_req_in        := io.fusion_req_in
  controller.io.wr_valid             := io.wr_valid
  controller.io.last_write           := io.last_write

  sram.io.wr_en   := controller.io.wr_en
  sram.io.wr_addr := controller.io.wr_addr
  sram.io.wr_data := io.wr_data
  sram.io.rd_en   := controller.io.rd_en
  sram.io.rd_addr := controller.io.rd_addr

  io.ctrl.working   := controller.io.ctrl.working
  io.rd_data        := sram.io.rd_data
  io.rd_valid       := sram.io.rd_valid
}
