class UbWbController(val is_ub: Boolean) extends Module {
  val io = IO(new Bundle {
    val ctrl = new OcmCommonIo()

    val compact_mode  = if (is_ub) Some(Input(Bool())) else None
    val lut_prog_mode = if (!is_ub) Some(Input(Bool())) else None

    val rd_addr = Output(UInt(8.W))
    val rd_en = Output(Bool())
    val active_bank = Output(UInt(1.W))
    val write_bank = Output(UInt(1.W))
    val write_buffer_has_space = Output(Bool())

    val rd_data = Input(UInt(128.W))
    val rd_data_to_cu = Output(UInt(128.W))
    val rd_data_to_lut = if (!is_ub) Some(Output(UInt(128.W))) else None

    val wr_en = Output(Bool())
    val wr_addr = Output(UInt(6.W))
  })

  val state = RegInit(OcmState.S_IDLE)
  val activeBank = RegInit(0.U(1.W))
  val writeBank = RegInit(1.U(1.W))
  val readPtr = RegInit(0.U(8.W))
  val writePtr = RegInit(0.U(6.W))
  val compactCnt = RegInit(0.U(4.W))
  val bufferValid = RegInit(VecInit(Seq.fill(2)(false.B)))
  val validEnd = RegInit(VecInit(Seq.fill(2)(0.U(6.W))))

  val isWorking = state === OcmState.S_WORKING
  val advanceCond = if (is_ub) (!io.compact_mode.get || compactCnt === 15.U) else true.B
  val readEndWord = Cat(validEnd(activeBank), 3.U(2.W))
  val readLast = isWorking && advanceCond && bufferValid(activeBank) && readPtr === readEndWord

  val currentWriteFull = bufferValid(writeBank) && validEnd(writeBank) === OcmConst.BANK_MAX_WRITES
  val writePortBank = Mux(readLast, activeBank, writeBank)
  val writePortAddr = Mux(readLast, 0.U, writePtr)
  val writeHasSpace = state =/= OcmState.S_IDLE && (!currentWriteFull || readLast)
  val acceptWrite = writeHasSpace && io.ctrl.dma_write_ready && io.ctrl.dma_data_valid
  val writeEndsSegment = acceptWrite && (writePortAddr === OcmConst.BANK_MAX_WRITES || io.ctrl.dma_data_last)

  when(acceptWrite) {
    bufferValid(writePortBank) := true.B
    validEnd(writePortBank) := writePortAddr

    when(readLast) {
      writePtr := 1.U
    }.elsewhen(writePortAddr === OcmConst.BANK_MAX_WRITES || io.ctrl.dma_data_last) {
      writePtr := 0.U
    }.otherwise {
      writePtr := writePtr + 1.U
    }
  }

  switch(state) {
    is(OcmState.S_IDLE) {
      when(io.ctrl.enable && !io.ctrl.soft_reset) {
        state := OcmState.S_PRELOAD
      }
    }

    is(OcmState.S_PRELOAD) {
      when(writeEndsSegment) {
        state := OcmState.S_READY
        activeBank := writeBank
        writeBank := activeBank
        writePtr := 0.U
      }
    }

    is(OcmState.S_READY) {
      when(io.ctrl.shoot) {
        state := OcmState.S_WORKING
      }
    }

    is(OcmState.S_WORKING) {
      if (is_ub) {
        when(io.compact_mode.get) { compactCnt := compactCnt + 1.U }
      }
      when(advanceCond) { readPtr := readPtr + 1.U }

      when(readLast) {
        when(!acceptWrite) {
          bufferValid(activeBank) := false.B
        }

        when(bufferValid(writeBank)) {
          activeBank := writeBank
          writeBank := activeBank
          readPtr := 0.U
          writePtr := Mux(acceptWrite, 1.U, 0.U)
        }.otherwise {
          state := OcmState.S_STALL
          writeBank := activeBank
          readPtr := 0.U
          writePtr := Mux(acceptWrite, 1.U, 0.U)
        }
      }
    }

    is(OcmState.S_STALL) {
      when(writeEndsSegment) {
        state := OcmState.S_WORKING
        activeBank := writeBank
        writeBank := ~writeBank
        readPtr := 0.U
        writePtr := 0.U
      }
    }
  }

  when(io.ctrl.soft_reset || !io.ctrl.enable) {
    state := OcmState.S_IDLE
    activeBank := 0.U
    writeBank := 1.U
    readPtr := 0.U
    writePtr := 0.U
    compactCnt := 0.U
    bufferValid(0) := false.B
    bufferValid(1) := false.B
    validEnd(0) := 0.U
    validEnd(1) := 0.U
  }

  val activeBankCnt = readEndWord - readPtr

  io.ctrl.working := isWorking
  io.ctrl.ready := state === OcmState.S_READY || !io.ctrl.enable
  io.ctrl.hungry := state =/= OcmState.S_IDLE && writeHasSpace
  io.ctrl.impending := isWorking && activeBankCnt <= OcmConst.WATERMARK && writeHasSpace

  io.rd_addr := readPtr
  io.rd_en := isWorking && bufferValid(activeBank)
  io.active_bank := activeBank
  io.write_bank := writePortBank
  io.write_buffer_has_space := writeHasSpace

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

  io.wr_en := acceptWrite
  io.wr_addr := writePortAddr
}