package npu.core.memory

import chisel3._
import chisel3.util._

// ====================================================================
// [0] 공통 상수 및 FSM State 정의
// ====================================================================
object OcmState {
  val S_IDLE    = 0.U(3.W)
  val S_PRELOAD = 1.U(3.W)
  val S_READY   = 2.U(3.W)
  val S_WORKING = 3.U(3.W)
  val S_STALL   = 4.U(3.W)
}

// 4KB 뱅크 기준 카운트 (16Byte 소비 시 256회)
object OcmConst {
  val BANK_MAX_READS = 255.U(8.W) 
  val WATERMARK      = 8.U(8.W)
  val BANK_MAX_WRITES = 63.U(6.W) // 64B Write 기준
}

// 공통 I/O 인터페이스 Trait
class OcmCommonIo extends Bundle {
  val soft_reset         = Input(Bool())
  val enable             = Input(Bool())
  val shoot              = Input(Bool())
  
  val dma_data_valid     = Input(Bool())
  val dma_data_last      = Input(Bool())
  val dma_write_ready    = Input(Bool())

  val ready              = Output(Bool())
  val hungry             = Output(Bool())
  val impending          = Output(Bool())
  val working            = Output(Bool())
}

// ====================================================================
// [1] 비대칭 대역폭 Ping-Pong SRAM (64B Write / 16B Read)
// ====================================================================
class AsymmetricPingPongSRAM(
  val writeWidthBytes: Int = 64, // DMA Write: 64 Byte (512-bit) / cycle
  val readWidthBytes: Int = 16,  // CU Read: 16 Byte (128-bit) / cycle
  val capacityBytes: Int = 4096  // Bank당 용량: 4 KB
) extends Module {
  
  val writeWidth = writeWidthBytes * 8 // 512 bits
  val readWidth  = readWidthBytes * 8  // 128 bits
  
  // 대역폭 비율 (Ratio) = 4
  val ratio = writeWidth / readWidth 
  
  // 깊이(Depth) 계산
  val writeDepth = capacityBytes / writeWidthBytes // 64 (0 ~ 63)
  val readDepth  = capacityBytes / readWidthBytes  // 256 (0 ~ 255)

  val io = IO(new Bundle {
    // ----------------------------------------------------
    // Ping Bank Ports
    // ----------------------------------------------------
    val ping_wr_en   = Input(Bool())
    val ping_wr_addr = Input(UInt(log2Ceil(writeDepth).W)) // 6 bits
    val ping_wr_data = Input(UInt(writeWidth.W))           // 512 bits
    
    val ping_rd_en   = Input(Bool())
    val ping_rd_addr = Input(UInt(log2Ceil(readDepth).W))  // 8 bits
    val ping_rd_data = Output(UInt(readWidth.W))           // 128 bits

    // ----------------------------------------------------
    // Pong Bank Ports
    // ----------------------------------------------------
    val pong_wr_en   = Input(Bool())
    val pong_wr_addr = Input(UInt(log2Ceil(writeDepth).W)) // 6 bits
    val pong_wr_data = Input(UInt(writeWidth.W))           // 512 bits
    
    val pong_rd_en   = Input(Bool())
    val pong_rd_addr = Input(UInt(log2Ceil(readDepth).W))  // 8 bits
    val pong_rd_data = Output(UInt(readWidth.W))           // 128 bits
  })

  // ----------------------------------------------------------------
  // Helper Method: 서브 뱅크 생성 및 라우팅 로직
  // ----------------------------------------------------------------
  def buildAsymmetricBank(
    wr_en: Bool, wr_addr: UInt, wr_data: UInt,
    rd_en: Bool, rd_addr: UInt
  ): UInt = {
    // 4개의 서브 뱅크(SyncReadMem) 생성: 각각 128-bit 너비, 깊이 64
    val sub_banks = Seq.fill(ratio)(SyncReadMem(writeDepth, UInt(readWidth.W)))
    val rd_data_vec = Wire(Vec(ratio, UInt(readWidth.W)))

    // 상위 비트: 서브 뱅크의 공통 어드레스 (rd_addr >> 2)
    val word_addr = rd_addr(log2Ceil(readDepth) - 1, log2Ceil(ratio)) 

    // 하위 비트: 4개의 서브 뱅크 중 어떤 것을 선택할지 결정 (rd_addr의 LSB 2 bits)
    val bank_sel = rd_addr(log2Ceil(ratio) - 1, 0)

    for (i <- 0 until ratio) {
      // Write: 512-bit 데이터를 128-bit씩 4조각으로 잘라서 4개 뱅크에 동시에 씀
      val slice_data = wr_data((i + 1) * readWidth - 1, i * readWidth)
      when(wr_en) {
        sub_banks(i).write(wr_addr, slice_data)
      }
      //읽을 bank enable 결정 -> 필요한 data만 가져올 수 있음
      val bankReadEnable = rd_en && bank_sel === i.U
      // Read: 공통 word_addr를 주고 데이터를 읽어옴 (1클럭 지연 발생)
      rd_data_vec(i) := sub_banks(i).read(word_addr, bankReadEnable)
    }
    
    // SyncReadMem은 1클럭 딜레이가 있으므로, 선택 신호(bank_sel)도 똑같이 1클럭 지연시킴
    val bank_sel_d1 = RegEnable(bank_sel, 0.U, rd_en)

    // 최종 128-bit 데이터 출력 MUX
    rd_data_vec(bank_sel_d1)
  }

  // 인스턴스화 및 포트 연결
  io.ping_rd_data := buildAsymmetricBank(io.ping_wr_en, io.ping_wr_addr, io.ping_wr_data, io.ping_rd_en, io.ping_rd_addr)
  io.pong_rd_data := buildAsymmetricBank(io.pong_wr_en, io.pong_wr_addr, io.pong_wr_data, io.pong_rd_en, io.pong_rd_addr)
}

//vector buffer용 sram
//4KB SRAM, 16B Read / 16B Write
// BRAM 2개를 사용하여 각각 8B(64bit)씩 담당. 총 16B 읽고쓰기 가능
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

  // lane 0 stores bytes 0~7; lane 1 stores bytes 8~15.
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


// ====================================================================
// [1] UB / WB Controller (Front-end: Push 패러다임)
// ====================================================================
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
  val enable     = Input(Bool())
  val working    = Output(Bool())
}

class VbController extends Module {
  val io = IO(new Bundle {
    val ctrl          = new VbCtrlIo()
    val fusion_req_in = Input(Bool()) // In-band 태그 (VPU 진입 1클럭 전)
    
    val rd_addr       = Output(UInt(8.W))
    val rd_en         = Output(Bool())

    val wr_en         = Output(Bool())
    val wr_addr       = Output(UInt(8.W))
    val wr_valid      = Input(Bool())
    val last_write    = Input(Bool())
  })

  val state       = RegInit(OcmState.S_IDLE)
  val read_ptr    = RegInit(0.U(8.W))
  val write_ptr  = RegInit(0.U(8.W))
  val last_write_ptr = RegInit(0.U(8.W))

  val is_working = (state === OcmState.S_WORKING)

  switch(state) {
    is(OcmState.S_IDLE)    { when(io.ctrl.enable && !io.ctrl.soft_reset) { state := OcmState.S_WORKING } }
    is(OcmState.S_WORKING) {
      when(io.wr_valid) { 
        //직전 write_ptr 저장
        last_write_ptr := write_ptr
        write_ptr := write_ptr + 1.U
        when(io.last_write) {
          write_ptr := 0.U
        } 
      }
      when(io.fusion_req_in) {
        read_ptr := read_ptr + 1.U
        when(read_ptr === last_write_ptr) {
          read_ptr := 0.U
        }
      }
    }
  }
  when(io.ctrl.soft_reset || !io.ctrl.enable) { state := OcmState.S_IDLE; read_ptr := 0.U; write_ptr := 0.U; last_write_ptr := 0.U }

  io.ctrl.working   := is_working

  io.rd_addr     := read_ptr
  // 1-Cycle Lookahead: 외부에서 fusion_req_in을 찌르면 즉시 rd_en 활성화
  io.rd_en       := is_working && io.fusion_req_in

  io.wr_en       := io.wr_valid && state === OcmState.S_WORKING
  io.wr_addr     := write_ptr
}