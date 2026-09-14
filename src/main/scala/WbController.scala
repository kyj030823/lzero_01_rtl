package npu.core.memory

import chisel3._
import chisel3.util._



class AsymmetricSRAM(
  val writeWidthBytes: Int = 64,
  val readWidthBytes: Int = 16,
  val capacityBytes: Int = 4096 * 4
) extends Module {
  val writeWidth = writeWidthBytes * 8
  val readWidth  = readWidthBytes * 8
  val ratio      = writeWidth / readWidth
  val writeDepth = capacityBytes / writeWidthBytes
  val readDepth  = capacityBytes / readWidthBytes

  val io = IO(new Bundle {
    val wr_en   = Input(Bool())
    val wr_addr = Input(UInt(log2Ceil(writeDepth).W))
    val wr_data = Input(UInt(writeWidth.W))

    val rd_en   = Input(Bool())
    val rd_addr = Input(UInt(log2Ceil(readDepth).W))
    val rd_data = Output(UInt(readWidth.W))
  })

  val subBanks = Seq.fill(ratio)(SyncReadMem(writeDepth, UInt(readWidth.W)))
  val rdDataVec = Wire(Vec(ratio, UInt(readWidth.W)))

  val wordAddr = io.rd_addr(log2Ceil(readDepth) - 1, log2Ceil(ratio))
  val bankSel = io.rd_addr(log2Ceil(ratio) - 1, 0)

  for (i <- 0 until ratio) {
    val sliceData = io.wr_data((i + 1) * readWidth - 1, i * readWidth)
    when(io.wr_en) {
      subBanks(i).write(io.wr_addr, sliceData)
    }
    rdDataVec(i) := subBanks(i).read(wordAddr, io.rd_en && bankSel === i.U)
  }

  val bankSelD1 = RegEnable(bankSel, 0.U, io.rd_en)
  io.rd_data := rdDataVec(bankSelD1)
}

class WbController(
  val writeWidthBytes: Int = 64,
  val readWidthBytes: Int = 16,
  val capacityBytes: Int = 4096 * 4,
  val dataBlockBytes: Int = 4096
) extends Module {
  val writeWidth = writeWidthBytes * 8
  val readWidth  = readWidthBytes * 8
  val writeDepth = capacityBytes / writeWidthBytes
  val readDepth  = capacityBytes / readWidthBytes

  val io = IO(new Bundle {
    val ctrl = new OcmCommonIo()

    val is_lut_load = Input(Bool())

    val rd_addr       = Output(UInt(log2Ceil(readDepth).W))
    val rd_en         = Output(Bool())
    val rd_data       = Input(UInt(readWidth.W))
    val rd_data_to_cu = Output(UInt(readWidth.W))
    val rd_data_to_lut = Output(UInt(readWidth.W))

    val wr_en         = Output(Bool())
    val wr_addr       = Output(UInt(log2Ceil(writeDepth).W))
  })

  // state와 state상태 변수
  val state = RegInit(OcmState.S_IDLE)
  val isIdle = state === OcmState.S_IDLE
  val isReady = state === OcmState.S_READY
  val isWorking = state === OcmState.S_WORKING

  // Circular-buffer 포인터
  val writePtr = RegInit(0.U(log2Ceil(writeDepth).W))
  val readPtr = RegInit(0.U(log2Ceil(readDepth).W))
  val isempty = RegInit(true.B)

  // block단위를 관리하는 큐(원형 큐)
  val blockLastqueue = RegInit(VecInit(Seq.fill(capacityBytes / dataBlockBytes * 2)(0.U(log2Ceil(writeDepth).W))))
  val blFront = RegInit(0.U(log2Ceil(capacityBytes / dataBlockBytes * 2).W))
  val blNum = RegInit(0.U(log2Ceil(capacityBytes / dataBlockBytes * 2).W))
  val hasBlockData = blNum > 1.U

  // DMA progress and routing
  val gotDmaLast = RegInit(false.B)
  val dataToLut = RegInit(false.B)
  val dataToLutD1 = RegNext(dataToLut, false.B)

  //lut data가 들어오면 이전 blockLastqueue index에 1 표시. 다음 block이 lut data인 것을 표시하기 위함. 만약 이전 block이 없다면 바로 lut mode로 전환
  val nextBlockIsLut = RegInit(VecInit(Seq.fill(capacityBytes / dataBlockBytes * 2)(false.B)))
  when(io.is_lut_load) {
    when(blNum > 0.U) {
      nextBlockIsLut(blFront + blNum - 1.U) := true.B
    }.otherwise {
      dataToLut := true.B
    }
  }

  // 빈공간과 사용공간 확인 변수 & 큐 상태 확인
  val ptrBits = log2Ceil(capacityBytes)
  val writeBytePtr = writePtr << log2Ceil(writeWidthBytes)
  val readBytePtr  = readPtr  << log2Ceil(readWidthBytes)
  val emptyBytes = (readBytePtr -% writeBytePtr)(ptrBits - 1, 0)
  val usedBytes = (writeBytePtr -% readBytePtr)(ptrBits - 1, 0)
  val soonempty =  (usedBytes =/= 0.U) && (usedBytes <= (16 * 8).U)
  val queueFull = emptyBytes < dataBlockBytes.U && !isempty

  // 읽기 쓰기 마지막 상태 관련 변수
  val writeActive = io.ctrl.dma_data_valid && !isIdle
  val writeLast = (io.ctrl.rlast || io.ctrl.dma_data_last) && io.ctrl.dma_data_valid
  // writeptr에 readptr과 bit가 맞도록 1을 채워서 비교. blnum으로 실제 block이 존재할때만 ture
  val readLast = readPtr === Cat(blockLastqueue(blFront),Fill(readPtr.getWidth - blockLastqueue(blFront).getWidth, 1.U(1.W))) && blNum > 0.U
  val blpop = isWorking && readLast
  val blpush = writeActive && writeLast

  // readLast 지연
  val readLastD1 = RegNext(isWorking && readLast, false.B)

  // FSM
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
        //다음 block이 존재하거나 막 block 끝이 들어왔을 때
        when(hasBlockData || blpush) {
          state := OcmState.S_WORKING
          }.otherwise {
          when (gotDmaLast) {
            state := OcmState.S_IDLE
          }.otherwise {
            state := OcmState.S_STALL
          }
        }
      }
    }

    is(OcmState.S_STALL) {
      when(writeActive) {
        state := OcmState.S_WORKING
      }
    }
  }

  // 쓰기 시
  when(writeActive) {
    writePtr := writePtr + 1.U
    when(writeLast) {
      blockLastqueue(blFront + blNum) := writePtr
    }
    when(io.ctrl.dma_data_last) {
      gotDmaLast := true.B
    }.otherwise {
      gotDmaLast := false.B
    }
    isempty := false.B
  }

  // 읽기 시
  when(isWorking) {
    readPtr := readPtr + 1.U
    // readLast는 readPtr이 blocklastdata에 도달했을때 true
    when(readLast) {
      blFront := blFront + 1.U
      dataToLut := nextBlockIsLut(blFront)
      nextBlockIsLut(blFront) := false.B
    }
    when((usedBytes === readWidthBytes.U) && !writeActive) {
      isempty := true.B
    }
  }

  // block 큐 관리
  when(blpush && !blpop) {
    blNum := blNum + 1.U
  }.elsewhen(blpop && !blpush) {
    blNum := blNum - 1.U
  }

  // 리셋
  when(io.ctrl.soft_reset || !io.ctrl.enable) {
    state := OcmState.S_IDLE
  }

  when(state === OcmState.S_IDLE || io.ctrl.soft_reset || !io.ctrl.enable) {
    writePtr := 0.U
    readPtr := 0.U
    blFront := 0.U
    blNum := 0.U
    gotDmaLast := false.B
    isempty := true.B
    dataToLut := false.B
  }

  // SRAM outputs
  io.wr_en := writeActive
  io.wr_addr := writePtr

  io.rd_en := isWorking
  io.rd_addr := readPtr

  // Read-data routing
  when(dataToLutD1) {
    io.rd_data_to_cu := 0.U
    io.rd_data_to_lut := io.rd_data
  }.otherwise {
    io.rd_data_to_cu := io.rd_data
    io.rd_data_to_lut := 0.U
  }

  // Controller status outputs
  io.ctrl.ready := isReady || !io.ctrl.enable
  io.ctrl.hungry := !isIdle && !hasBlockData && !gotDmaLast
  io.ctrl.impending := isWorking && soonempty && !gotDmaLast
  io.ctrl.full := !isIdle && !queueFull
  io.ctrl.last_data_out := readLastD1
}
