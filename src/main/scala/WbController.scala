package npu.core.memory

import chisel3._
import chisel3.util._

/**
 * WB controller using four logical 4KB slots as a circular queue.
 *
 * slot 0: Ping addr 0..63   / read addr 0..255
 * slot 1: Ping addr 64..127 / read addr 256..511
 * slot 2: Pong addr 0..63   / read addr 0..255
 * slot 3: Pong addr 64..127 / read addr 256..511
 *
 * i points to the slot currently being written.
 * j points to the slot currently being read.
 */
class WbController extends Module {
  val io = IO(new Bundle {
    val ctrl = new OcmCommonIo()

    val lut_prog_mode = Input(Bool())

    val rd_addr       = Output(UInt(9.W))
    val rd_en         = Output(Bool())
    val active_bank   = Output(UInt(1.W))
    val rd_data       = Input(UInt(128.W))
    val rd_data_to_cu = Output(UInt(128.W))
    val rd_data_to_lut = Output(UInt(128.W))

    val wr_en         = Output(Bool())
    val wr_addr       = Output(UInt(7.W))
    val write_bank    = Output(UInt(1.W))
  })

  val state = RegInit(OcmState.S_IDLE)

  val i = RegInit(0.U(2.W))
  val j = RegInit(0.U(2.W))

  val writePtr = RegInit(0.U(6.W))
  val readPtr  = RegInit(0.U(8.W))
  val validCnt = RegInit(0.U(3.W))
  val gotDmaLast = RegInit(false.B)

  val isIdle    = state === OcmState.S_IDLE
  val isReady   = state === OcmState.S_READY
  val isWorking = state === OcmState.S_WORKING

  val queueFull  = validCnt === 4.U
  val queueEmpty = validCnt === 0.U

  val readActive = isWorking && !queueEmpty
  val readLast   = readActive && readPtr === 255.U

  val writeActive = !isIdle && io.ctrl.dma_data_valid && (!queueFull || readLast)
  val writeLast   = writeActive && (io.ctrl.rlast || io.ctrl.dma_data_last || writePtr === 63.U)

  val writeSlotBank = i(1)
  val writeSlotBase = i(0)
  val readSlotBank  = j(1)
  val readSlotBase  = j(0)

  switch(state) {
    is(OcmState.S_IDLE) {
      when(io.ctrl.enable && !io.ctrl.soft_reset) {
        state := OcmState.S_PRELOAD
      }
    }

    is(OcmState.S_PRELOAD) {
      when(writeLast) {
        state := OcmState.S_READY
      }
    }

    is(OcmState.S_READY) {
      when(io.ctrl.shoot) {
        state := OcmState.S_WORKING
      }
    }

    is(OcmState.S_WORKING) {
      when(readLast) {
        when(validCnt > 1.U || writeLast) {
          state := OcmState.S_WORKING
        }.otherwise {
          state := OcmState.S_STALL
        }
      }
    }

    is(OcmState.S_STALL) {
      when(writeLast) {
        state := OcmState.S_WORKING
      }
    }
  }

  when(writeActive) {
    when(writeLast) {
      writePtr := 0.U
      i := i + 1.U
    }.otherwise {
      writePtr := writePtr + 1.U
    }

    when(io.ctrl.dma_data_last) {
      gotDmaLast := true.B
    }
  }

  when(readActive) {
    when(readLast) {
      readPtr := 0.U
      j := j + 1.U
    }.otherwise {
      readPtr := readPtr + 1.U
    }
  }

  when(writeLast && !readLast) {
    validCnt := validCnt + 1.U
  }.elsewhen(readLast && !writeLast) {
    validCnt := validCnt - 1.U
  }

  when(io.ctrl.soft_reset || !io.ctrl.enable) {
    state := OcmState.S_IDLE
    i := 0.U
    j := 0.U
    writePtr := 0.U
    readPtr := 0.U
    validCnt := 0.U
    gotDmaLast := false.B
  }

  io.wr_en := writeActive
  io.wr_addr := Cat(writeSlotBase, writePtr)
  io.write_bank := writeSlotBank

  io.rd_en := readActive
  io.rd_addr := Cat(readSlotBase, readPtr)
  io.active_bank := readSlotBank

  when(io.lut_prog_mode) {
    io.rd_data_to_cu := 0.U
    io.rd_data_to_lut := io.rd_data
  }.otherwise {
    io.rd_data_to_cu := io.rd_data
    io.rd_data_to_lut := 0.U
  }

  io.ctrl.working := isWorking
  io.ctrl.ready := isReady || !io.ctrl.enable
  io.ctrl.hungry := !isIdle && !queueFull
  io.ctrl.impending := isWorking && validCnt <= 1.U && !queueFull
  io.ctrl.full := validCnt > 1.U
  io.ctrl.last_data_out := gotDmaLast
}

/** Connects the four-slot WB controller to the asymmetric ping-pong BRAM. */
class WbControllerWithBram extends Module {
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
    val full = Output(Bool())
    val dma_last_data_out = Output(Bool())

    val rd_data_to_cu  = Output(UInt(128.W))
    val rd_data_to_lut = Output(UInt(128.W))
    val rd_data_valid  = Output(Bool())

    // Debug visibility for tests.
    val dbg_active_bank = Output(UInt(1.W))
    val dbg_write_bank  = Output(UInt(1.W))
    val dbg_rd_addr     = Output(UInt(9.W))
    val dbg_wr_addr     = Output(UInt(7.W))
    val dbg_ping_wr_en   = Output(Bool())
    val dbg_pong_wr_en   = Output(Bool())
    val dbg_ping_wr_addr = Output(UInt(7.W))
    val dbg_pong_wr_addr = Output(UInt(7.W))
    val dbg_ping_wr_data = Output(UInt(512.W))
    val dbg_pong_wr_data = Output(UInt(512.W))
  })

  val controller = Module(new WbController())
  val bram = Module(new AsymmetricPingPongSRAM())

  controller.io.ctrl.soft_reset      := io.soft_reset
  controller.io.ctrl.enable          := io.enable
  controller.io.ctrl.shoot           := io.shoot
  controller.io.ctrl.rlast           := io.rlast
  controller.io.ctrl.dma_data_valid  := io.dma_data_valid && io.dma_write_ready
  controller.io.ctrl.dma_data_last   := io.dma_data_last
  controller.io.ctrl.dma_write_ready := io.dma_write_ready
  controller.io.lut_prog_mode        := io.lut_prog_mode

  val readPing  = controller.io.active_bank === 0.U
  val writePing = controller.io.write_bank === 0.U

  bram.io.ping_wr_en   := controller.io.wr_en && writePing
  bram.io.pong_wr_en   := controller.io.wr_en && !writePing
  bram.io.ping_wr_addr := controller.io.wr_addr
  bram.io.pong_wr_addr := controller.io.wr_addr
  bram.io.ping_wr_data := io.dma_data
  bram.io.pong_wr_data := io.dma_data

  bram.io.ping_rd_en   := controller.io.rd_en && readPing
  bram.io.pong_rd_en   := controller.io.rd_en && !readPing
  bram.io.ping_rd_addr := controller.io.rd_addr
  bram.io.pong_rd_addr := controller.io.rd_addr

  val readPingD1 = RegEnable(readPing, true.B, controller.io.rd_en)
  controller.io.rd_data := Mux(readPingD1, bram.io.ping_rd_data, bram.io.pong_rd_data)

  io.ready     := controller.io.ctrl.ready
  io.hungry    := controller.io.ctrl.hungry
  io.impending := controller.io.ctrl.impending
  io.working   := controller.io.ctrl.working
  io.full := controller.io.ctrl.full
  io.dma_last_data_out := controller.io.ctrl.last_data_out

  io.rd_data_to_cu  := controller.io.rd_data_to_cu
  io.rd_data_to_lut := controller.io.rd_data_to_lut
  io.rd_data_valid  := RegNext(controller.io.rd_en, false.B)

  io.dbg_active_bank := controller.io.active_bank
  io.dbg_write_bank  := controller.io.write_bank
  io.dbg_rd_addr     := controller.io.rd_addr
  io.dbg_wr_addr     := controller.io.wr_addr
  io.dbg_ping_wr_en   := bram.io.ping_wr_en
  io.dbg_pong_wr_en   := bram.io.pong_wr_en
  io.dbg_ping_wr_addr := bram.io.ping_wr_addr
  io.dbg_pong_wr_addr := bram.io.pong_wr_addr
  io.dbg_ping_wr_data := bram.io.ping_wr_data
  io.dbg_pong_wr_data := bram.io.pong_wr_data
}

