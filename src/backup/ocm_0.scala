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
  val BANK_MAX_READS  = 255.U(8.W) // 4KB / 16B - 1
  val WATERMARK       = 8.U(8.W)
  val BANK_MAX_WRITES = 63.U(6.W)  // 4KB / 64B - 1
}

class OcmCommonIo extends Bundle {
  val soft_reset      = Input(Bool())
  val enable          = Input(Bool())
  val shoot           = Input(Bool())

  val dma_data_valid  = Input(Bool())
  val dma_data_last   = Input(Bool())
  val dma_write_ready = Input(Bool())

  val ready           = Output(Bool())
  val hungry          = Output(Bool())
  val impending       = Output(Bool())
  val working         = Output(Bool())
}

class AsymmetricPingPongSRAM(
  val writeWidthBytes: Int = 64,
  val readWidthBytes: Int = 16,
  val capacityBytes: Int = 4096
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
    val lut_prog_mode = if (!is_ub) Some(Input(Bool())) else None
    
    // SRAM Interface
    val rd_addr       = Output(UInt(8.W))
    val rd_en         = Output(Bool())
    val active_bank   = Output(UInt(1.W)) // 0: Ping, 1: Pong
    //데이터를 cu나 lut로 연결
    val rd_data       = Input(UInt(128.W))
    val rd_data_to_cu = Output(UInt(128.W))
    val rd_data_to_lut = if (!is_ub) Some(Output(UInt(128.W))) else None
    //write flag와 주소
    val wr_en         = Output(Bool())
    val wr_addr       = Output(UInt(6.W))
  })

  val state = RegInit(OcmState.S_IDLE)
  
  val active_bank = RegInit(0.U(1.W))
  val read_ptr    = RegInit(0.U(8.W))
  val write_ptr   = RegInit(0.U(6.W))
  val compact_cnt = RegInit(0.U(4.W)) // UB 1/16 speed용
  //마지막 주소에 쓸 때 1로 바뀜 -> 다음 clock에 바로 buffer 전환할 수 있음
  val last_write  = write_ptr === OcmConst.BANK_MAX_WRITES && io.ctrl.dma_data_valid
  val pong_valid  = RegInit(false.B)

  when(last_write) { pong_valid := true.B }

  // FSM Logic
  switch(state) {
    is(OcmState.S_IDLE) {
      when(io.ctrl.enable && !io.ctrl.soft_reset) { state := OcmState.S_PRELOAD }
    }
    is(OcmState.S_PRELOAD) {
      when(pong_valid || last_write) {
        state := OcmState.S_READY
        active_bank := ~active_bank
        write_ptr := 0.U
        pong_valid := false.B
      }
    }
    is(OcmState.S_READY) {
      when(io.ctrl.shoot) { state := OcmState.S_WORKING }
    }
    is(OcmState.S_WORKING) {
      val ptr_advance = if (is_ub) (!io.compact_mode.get || compact_cnt === 15.U) else true.B
      
      when(read_ptr === OcmConst.BANK_MAX_READS && ptr_advance) {
        when(pong_valid || last_write) {
          active_bank := ~active_bank
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
  }

  // Pointer & Compact Counter Logic
  val is_working = (state === OcmState.S_WORKING)
  val advance_cond = if (is_ub) (!io.compact_mode.get || compact_cnt === 15.U) else true.B

  
  when(is_working) {
    if (is_ub) {
      when(io.compact_mode.get) { compact_cnt := compact_cnt + 1.U }
    }
    when(advance_cond) { read_ptr := read_ptr + 1.U }
  }

  // DMA Write 주소 계산(마지막 주소까지 1씩 올리기)
  when(state =/= OcmState.S_IDLE && io.ctrl.dma_data_valid && !(pong_valid || last_write)) {
    write_ptr := write_ptr + 1.U
  }.elsewhen(io.ctrl.dma_data_valid && io.ctrl.dma_data_last) { 
    //write_ptr이 마지막 주소가 아니지만 dma_data_last가 들어오면 pong_valid = ture
    pong_valid := true.B
  }


  // Signal Extraction
  val active_bank_cnt = OcmConst.BANK_MAX_READS - read_ptr
  
  io.ctrl.working   := is_working
  io.ctrl.ready     := (state === OcmState.S_READY) || !io.ctrl.enable
  io.ctrl.hungry    := (state === OcmState.S_WORKING || state === OcmState.S_PRELOAD) && !(pong_valid || last_write)
  io.ctrl.impending := is_working && (active_bank_cnt <= OcmConst.WATERMARK) && !(pong_valid || last_write)

  io.rd_addr     := read_ptr
  io.rd_en       := is_working
  io.active_bank := active_bank


  if (is_ub) {
    io.rd_data_to_cu := io.rd_data
  } else {
    val lutMode = io.lut_prog_mode.get

    when(lutMode) {
      io.rd_data_to_cu := 0.U
      io.rd_data_to_lut.get := io.rd_data
    }.otherwise {
      io.rd_data_to_cu := io.rd_data
      io.rd_data_to_lut.get := 0.U
    }
  }

  // write flag와 address 연결
  io.wr_en   := io.ctrl.dma_data_valid && !pong_valid
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

  io.ctrl.working := isWorking
  io.rd_addr := readPtr
  io.rd_en := isWorking && io.fusion_req_in
  io.wr_en := io.wr_valid && state === OcmState.S_WORKING
  io.wr_addr := writePtr
}
