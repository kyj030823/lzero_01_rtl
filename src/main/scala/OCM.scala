package npu.core.memory

import chisel3._
import chisel3.util._

object OcmState {
  val S_IDLE    = 0.U(3.W)
  val S_PRELOAD = 1.U(3.W)
  val S_READY   = 2.U(3.W)
  val S_WORKING = 3.U(3.W)
  val S_STALL   = 4.U(3.W)
}

object OcmConst {
  val BANK_MAX_READS  = 511.U(9.W) // 8KB / 16B - 1
  val WATERMARK       = 8.U(8.W)
  val BANK_MAX_WRITES = 127.U(7.W)  // 8KB / 64B - 1
  val BANK_HALF_WRITES = 63.U(7.W)   // 4KB / 64B - 1
}

class OcmCommonIo extends Bundle {
  val soft_reset      = Input(Bool())
  val enable          = Input(Bool())
  val shoot           = Input(Bool())

  val rlast           = Input(Bool()) //4KB 데이터 마지막
  val dma_data_valid  = Input(Bool())
  val dma_data_last   = Input(Bool()) //matmul 데이터 마지막

  val last_data_out   = Output(Bool())

  val ready           = Output(Bool())
  val hungry          = Output(Bool())
  val impending       = Output(Bool())
  val full            = Output(Bool())
}

class AsymmetricPingPongSRAM(
  val writeWidthBytes: Int = 64,
  val readWidthBytes: Int = 16,
  val capacityBytes: Int = 8192 // 4KB + 4KB
) extends Module {
  val writeWidth = writeWidthBytes * 8
  val readWidth  = readWidthBytes * 8
  val ratio      = writeWidth / readWidth
  val writeDepth = capacityBytes / writeWidthBytes
  val readDepth  = capacityBytes / readWidthBytes

  val io = IO(new Bundle {
    val ping_wr_en   = Input(Bool())
    val ping_wr_addr = Input(UInt(log2Ceil(writeDepth).W))
    val ping_wr_data = Input(UInt(writeWidth.W))

    val ping_rd_en   = Input(Bool())
    val ping_rd_addr = Input(UInt(log2Ceil(readDepth).W))
    val ping_rd_data = Output(UInt(readWidth.W))

    val pong_wr_en   = Input(Bool())
    val pong_wr_addr = Input(UInt(log2Ceil(writeDepth).W))
    val pong_wr_data = Input(UInt(writeWidth.W))

    val pong_rd_en   = Input(Bool())
    val pong_rd_addr = Input(UInt(log2Ceil(readDepth).W))
    val pong_rd_data = Output(UInt(readWidth.W))
  })

  def buildAsymmetricBank(
      wr_en: Bool,
      wr_addr: UInt,
      wr_data: UInt,
      rd_en: Bool,
      rd_addr: UInt
  ): UInt = {
    val subBanks = Seq.fill(ratio)(SyncReadMem(writeDepth, UInt(readWidth.W)))
    val rdDataVec = Wire(Vec(ratio, UInt(readWidth.W)))

    val wordAddr = rd_addr(log2Ceil(readDepth) - 1, log2Ceil(ratio))
    val bankSel = rd_addr(log2Ceil(ratio) - 1, 0)

    for (i <- 0 until ratio) {
      val sliceData = wr_data((i + 1) * readWidth - 1, i * readWidth)
      when(wr_en) {
        subBanks(i).write(wr_addr, sliceData)
      }
      rdDataVec(i) := subBanks(i).read(wordAddr, rd_en && bankSel === i.U)
    }

    val bankSelD1 = RegEnable(bankSel, 0.U, rd_en)
    rdDataVec(bankSelD1)
  }

  io.ping_rd_data := buildAsymmetricBank(
    io.ping_wr_en,
    io.ping_wr_addr,
    io.ping_wr_data,
    io.ping_rd_en,
    io.ping_rd_addr
  )
  io.pong_rd_data := buildAsymmetricBank(
    io.pong_wr_en,
    io.pong_wr_addr,
    io.pong_wr_data,
    io.pong_rd_en,
    io.pong_rd_addr
  )
}

class VbSram extends Module {
  val io = IO(new Bundle {
    val wr_en   = Input(Bool())
    val wr_addr = Input(UInt(8.W))
    val wr_data = Input(UInt(128.W))

    val rd_en    = Input(Bool())
    val rd_addr  = Input(UInt(8.W))
    val rd_data  = Output(UInt(128.W))
    val rd_valid = Output(Bool())
  })

  val lanes = Seq.tabulate(2) { lane =>
    SyncReadMem(256, UInt(64.W)).suggestName(s"vb_lane$lane")
  }

  when(io.wr_en) {
    lanes(0).write(io.wr_addr, io.wr_data(63, 0))
    lanes(1).write(io.wr_addr, io.wr_data(127, 64))
  }

  val lane0Read = lanes(0).read(io.rd_addr, io.rd_en)
  val lane1Read = lanes(1).read(io.rd_addr, io.rd_en)

  io.rd_data  := Cat(lane1Read, lane0Read)
  io.rd_valid := RegNext(io.rd_en, false.B)
}

class UbWbController(val is_ub: Boolean) extends Module {
  val io = IO(new Bundle {
    val ctrl = new OcmCommonIo()
    
    // Configs
    val compact_mode  = if (is_ub) Some(Input(Bool())) else None
    val is_lut_load = if (!is_ub) Some(Input(Bool())) else None
    
    // SRAM Interface
    val rd_addr       = Output(UInt(9.W))
    val rd_en         = Output(Bool())
    val active_bank   = Output(UInt(1.W)) // 0: Ping, 1: Pong
    //데이터를 cu나 lut로 연결
    val rd_data       = Input(UInt(128.W))
    val mxu_data_out = Output(UInt(128.W))
    val lut_data_out = if (!is_ub) Some(Output(UInt(128.W))) else None
    //write flag와 주소
    val wr_en         = Output(Bool())
    val wr_addr       = Output(UInt(7.W))
  })

  val state = RegInit(OcmState.S_IDLE)
  val get_dma_last = RegInit(false.B)

  val active_bank = RegInit(0.U(1.W))
  val read_ptr    = RegInit(0.U(9.W))
  val write_ptr   = RegInit(0.U(7.W))
  val ping_last_write_ptr = RegInit(0.U(7.W)) // 지금 read하고 있는 bank의 마지막 write_ptr
  val pong_last_write_ptr = RegInit(0.U(7.W)) // 지금 write하고 있는 bank의 마지막 write_ptr
  val bank_lut_mode = if (!is_ub) Some(RegInit(VecInit(Seq.fill(2)(false.B)))) else None

  val compact_cnt = RegInit(0.U(4.W)) // UB 1/16 speed용
  //마지막 주소에 쓸 때 1로 바뀜 -> 다음 clock에 바로 buffer 전환할 수 있음
  val last_write  = ((write_ptr >= OcmConst.BANK_HALF_WRITES && io.ctrl.rlast) || io.ctrl.dma_data_last) && io.ctrl.dma_data_valid //pong data 준비 완료. 1. rlast가 들어오고 4KB 이상의 데이터일때. 2. dma_data_last가 들어올때
  val pong_valid  = RegInit(false.B)

  when(last_write) { pong_valid := true.B }

  val can_get_4KB = pong_valid && pong_last_write_ptr === OcmConst.BANK_HALF_WRITES
  val getting_4KB = RegInit(false.B)
  when(can_get_4KB && io.ctrl.dma_data_valid) { getting_4KB := true.B }
  when(getting_4KB && io.ctrl.rlast) { getting_4KB := false.B }

    // Pointer & Compact Counter Logic
  val is_working = (state === OcmState.S_WORKING)

  
  when(is_working) { read_ptr := read_ptr + 1.U }

  if (!is_ub) {
    val write_bank = ~active_bank
    when(state =/= OcmState.S_IDLE && io.ctrl.dma_data_valid && write_ptr === 0.U) {
      bank_lut_mode.get(write_bank) := io.is_lut_load.get
    }
  }

  // DMA Write 주소 계산(마지막 주소까지 1씩 올리기)
  when(state =/= OcmState.S_IDLE && io.ctrl.dma_data_valid) {
    write_ptr := write_ptr + 1.U
    pong_last_write_ptr := write_ptr //마지막으로 쓴 주소 저장
    when(io.ctrl.dma_data_valid && io.ctrl.dma_data_last) { 
      //write_ptr이 마지막 주소가 아니지만 dma_data_last가 들어오면 pong_valid = ture
      pong_valid := true.B
      get_dma_last := true.B
    }
  }

  // FSM Logic
  switch(state) {
    is(OcmState.S_IDLE) {
      when(io.ctrl.enable && !io.ctrl.soft_reset) { state := OcmState.S_PRELOAD }
    }
    is(OcmState.S_PRELOAD) {
      when(pong_valid || last_write) {
        state := OcmState.S_READY
        active_bank := ~active_bank
        ping_last_write_ptr := Mux(getting_4KB || last_write, pong_last_write_ptr + 1.U, pong_last_write_ptr)
        write_ptr := 0.U
        pong_valid := false.B
      }
    }
    is(OcmState.S_READY) {
      when(io.ctrl.shoot) { state := OcmState.S_WORKING }
    }
    is(OcmState.S_WORKING) {
      val active_read_last = Cat(ping_last_write_ptr, 3.U(2.W))
      when(read_ptr === active_read_last) {
        when(pong_valid || last_write) {
          active_bank := ~active_bank
          ping_last_write_ptr := Mux(getting_4KB || last_write, pong_last_write_ptr + 1.U, pong_last_write_ptr)
          read_ptr := 0.U
          write_ptr := 0.U
          pong_valid := false.B
        }.otherwise {
          state := OcmState.S_STALL
        }
      }
    }
    is(OcmState.S_STALL) {
      when(pong_valid || last_write) { 
        state := OcmState.S_WORKING 
        active_bank := ~active_bank
        read_ptr := 0.U
        write_ptr := 0.U
        pong_valid := false.B
      }
    }
  }

  when(io.ctrl.soft_reset || !io.ctrl.enable) {
    state := OcmState.S_IDLE
    active_bank := 0.U
    read_ptr := 0.U
    write_ptr := 0.U
    ping_last_write_ptr := 0.U
    pong_last_write_ptr := 0.U
    pong_valid := false.B
    if (!is_ub) {
      bank_lut_mode.get := VecInit(Seq.fill(2)(false.B))
    }
  }


  // Signal Extraction
  val active_bank_cnt = OcmConst.BANK_MAX_READS - read_ptr

  io.ctrl.ready     := (state === OcmState.S_READY) || !io.ctrl.enable
  io.ctrl.hungry    := (state === OcmState.S_WORKING || state === OcmState.S_PRELOAD) && !(pong_valid || last_write)
  io.ctrl.impending := is_working && (active_bank_cnt <= OcmConst.WATERMARK) && !(pong_valid || last_write)
  io.ctrl.full := !((pong_valid || last_write) && can_get_4KB)

  io.rd_addr     := read_ptr
  io.rd_en       := is_working
  io.active_bank := active_bank


  if (is_ub) {
    io.mxu_data_out := io.rd_data
  } else {
    val readLutMode = bank_lut_mode.get(active_bank)
    val readLutModeD1 = RegEnable(readLutMode, false.B, io.rd_en)

    when(readLutModeD1) {
      io.mxu_data_out := 0.U
      io.lut_data_out.get := io.rd_data
    }.otherwise {
      io.mxu_data_out := io.rd_data
      io.lut_data_out.get := 0.U
    }
  }

  io.ctrl.last_data_out := read_ptr === Cat(ping_last_write_ptr, 3.U(2.W)) && is_working

  // write flag와 address 연결
  io.wr_en   := io.ctrl.dma_data_valid
  io.wr_addr := write_ptr
}


class VbCtrlIo extends Bundle {
  val soft_reset = Input(Bool())
  val enable = Input(Bool())
  val working = Output(Bool())
}

class VbController extends Module {
  val io = IO(new Bundle {
    val ctrl = new VbCtrlIo()
    val fusion_req_in = Input(Bool())

    val rd_addr = Output(UInt(8.W))
    val rd_en = Output(Bool())

    val wr_en = Output(Bool())
    val wr_addr = Output(UInt(8.W))
    val wr_valid = Input(Bool())
    val last_write = Input(Bool())
  })

  val state = RegInit(OcmState.S_IDLE)
  val readPtr = RegInit(0.U(8.W))
  val writePtr = RegInit(0.U(8.W))
  val lastWritePtr = RegInit(0.U(8.W))

  val isWorking = state === OcmState.S_WORKING

  switch(state) {
    is(OcmState.S_IDLE) {
      when(io.ctrl.enable && !io.ctrl.soft_reset) {
        state := OcmState.S_WORKING
      }
    }
    is(OcmState.S_WORKING) {
      when(io.wr_valid) {
        lastWritePtr := writePtr
        writePtr := writePtr + 1.U
        when(io.last_write) {
          writePtr := 0.U
        }
      }
      when(io.fusion_req_in) {
        readPtr := readPtr + 1.U
        when(readPtr === lastWritePtr) {
          readPtr := 0.U
        }
      }
    }
  }

  when(io.ctrl.soft_reset || !io.ctrl.enable) {
    state := OcmState.S_IDLE
    readPtr := 0.U
    writePtr := 0.U
    lastWritePtr := 0.U
  }

  io.rd_addr := readPtr
  io.rd_en := isWorking && io.fusion_req_in
  io.wr_en := io.wr_valid && state === OcmState.S_WORKING
  io.wr_addr := writePtr
}
