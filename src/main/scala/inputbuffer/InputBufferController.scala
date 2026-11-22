package npu.core.memory

import chisel3._
import chisel3.util._
import scala.language.reflectiveCalls

object InputBufferOperationMode extends ChiselEnum {
  val GEMM, VPU_DIRECT = Value
}
object InputBufferReuseMode extends ChiselEnum {
  val STREAM, LOCAL_ROW_CACHE = Value
}
object InputBufferControllerState extends ChiselEnum {
  val DISABLED, INITIAL_FILL, ACTIVE, DRAINING, DONE = Value
}

/** UB 명세서 v3의 context 설정.
  *
  * GEMM row는 K tile당 dense 256B 또는 compact 16B다.
  * fusionEnable은 일반 연산의 replay=N 검사와 상위가 명시한 fusion 총 pass를
  * 구분하는 통합용 필드다. Fusion block/phase 순서와 물리 주소는 AG가 관리한다.
  */
class InputBufferConfig(
  val contextIdWidth: Int = 8,
  val payloadByteWidth: Int = 32,
  val countWidth: Int = 16
) extends Bundle {
  require(contextIdWidth > 0 && payloadByteWidth >= 15 && countWidth > 0)
  val bufferEnable = Bool()
  val operationMode = InputBufferOperationMode()
  val reuseMode = InputBufferReuseMode()
  val compactInputEnable = Bool()
  val fusionEnable = Bool()
  val inputRowCount = UInt(countWidth.W)
  val reductionTileCount = UInt(countWidth.W)
  val outputColumnCount = UInt(countWidth.W)
  val rowReplayCount = UInt(countWidth.W)
  val vectorPayloadBytes = UInt(payloadByteWidth.W)
  val normalImpendingThresholdBytes = UInt(payloadByteWidth.W)
  val compactImpendingThresholdBytes = UInt(payloadByteWidth.W)
  val contextId = UInt(contextIdWidth.W)
}

/** 완료와 drain은 서로 다르다. Read pending에는 미수락 SRAM 응답도 포함한다. */
class InputBufferContextStatus extends Bundle {
  val refillPending = Bool()
  val readPending = Bool()
  val operationDone = Bool()
}

/** 설정 검증·latch 및 안전한 context 생명주기 관리.
  *
  * WB와 동일하게 실제 입출력 연결은 InputBufferDataPath가 담당한다.
  * 공급 종료나 잠깐의 idle을 연산 완료로 취급하지 않는다.
  */
class InputBufferController(
  val contextIdWidth: Int = 8,
  val payloadByteWidth: Int = 32,
  val countWidth: Int = 16
) extends Module {
  require(contextIdWidth > 0 && payloadByteWidth >= 15 && countWidth > 0)
  private val rowByteWidth = math.max(payloadByteWidth, countWidth + 8)

  val io = IO(new Bundle {
    val contextStart = Input(Bool())
    val contextReady = Output(Bool())
    val config = Input(new InputBufferConfig(contextIdWidth, payloadByteWidth, countWidth))
    val configValid = Output(Bool())
    val softReset = Input(Bool())
    val pathStatus = Input(new InputBufferContextStatus)
    val activeConfig = Output(new InputBufferConfig(contextIdWidth, payloadByteWidth, countWidth))
    val contextAccepted = Output(Bool())
    val contextActive = Output(Bool())
    val contextDone = Output(Bool())
    val dataPathClear = Output(Bool())
    val computeStreamEnabled = Output(Bool())
    val computeComplete = Output(Bool())
    val localRowCacheEnabled = Output(Bool())
    val inputRowBytes = Output(UInt(rowByteWidth.W))
    val activeImpendingThresholdBytes = Output(UInt(payloadByteWidth.W))
  })

  val activeConfig = RegInit(0.U.asTypeOf(new InputBufferConfig(contextIdWidth, payloadByteWidth, countWidth)))
  val active = RegInit(false.B)
  val complete = RegInit(true.B)

  val proposedGemm = io.config.operationMode === InputBufferOperationMode.GEMM
  val proposedVpu = io.config.operationMode === InputBufferOperationMode.VPU_DIRECT
  val proposedCache = io.config.reuseMode === InputBufferReuseMode.LOCAL_ROW_CACHE
  // Shift 앞의 폭을 줄이지 않는다. payloadByteWidth=15여도 K*256을 잘라서는 안 된다.
  val proposedRowBytes = Mux(io.config.compactInputEnable,
    (io.config.reductionTileCount << 4).pad(rowByteWidth),
    (io.config.reductionTileCount << 8).pad(rowByteWidth))
  val proposedNonzero = Mux(proposedGemm,
    io.config.inputRowCount =/= 0.U && io.config.reductionTileCount =/= 0.U &&
      io.config.outputColumnCount =/= 0.U,
    io.config.vectorPayloadBytes =/= 0.U)
  val proposedComputeEnabled = io.config.bufferEnable && proposedNonzero
  val proposedThreshold = Mux(proposedGemm && io.config.compactInputEnable,
    io.config.compactImpendingThresholdBytes, io.config.normalImpendingThresholdBytes)

  val modesValid = (proposedGemm || proposedVpu) &&
    (io.config.reuseMode === InputBufferReuseMode.STREAM || proposedCache)
  val vpuModeValid = !proposedVpu || !proposedCache
  val replayValid = !proposedComputeEnabled || !proposedGemm ||
    (io.config.rowReplayCount =/= 0.U &&
      (io.config.fusionEnable || io.config.rowReplayCount === io.config.outputColumnCount))
  val cacheCapacityValid = !proposedComputeEnabled || !proposedCache ||
    (proposedGemm && proposedRowBytes =/= 0.U && proposedRowBytes <= 16384.U)
  val vectorAlignmentValid = !proposedComputeEnabled || !proposedVpu ||
    io.config.vectorPayloadBytes(3, 0) === 0.U
  val thresholdValid = !proposedComputeEnabled || proposedThreshold(3, 0) === 0.U
  val configurationValid = modesValid && vpuModeValid && replayValid &&
    cacheCapacityValid && vectorAlignmentValid && thresholdValid

  val drained = !io.pathStatus.refillPending && !io.pathStatus.readPending
  val boundaryAvailable = !reset.asBool && !io.softReset && !active && drained
  val accepted = io.contextStart && boundaryAvailable && configurationValid
  val safeReset = !reset.asBool && io.softReset && drained
  val finished = active && (complete || io.pathStatus.operationDone) && drained

  val activeGemm = activeConfig.operationMode === InputBufferOperationMode.GEMM
  val activeNonzero = Mux(activeGemm,
    activeConfig.inputRowCount =/= 0.U && activeConfig.reductionTileCount =/= 0.U &&
      activeConfig.outputColumnCount =/= 0.U,
    activeConfig.vectorPayloadBytes =/= 0.U)
  val enabled = activeConfig.bufferEnable && activeNonzero

  io.configValid := configurationValid
  io.contextReady := boundaryAvailable && configurationValid
  io.contextAccepted := accepted
  io.contextActive := !reset.asBool && active
  io.contextDone := !reset.asBool && !io.softReset && finished
  io.dataPathClear := accepted || safeReset
  io.activeConfig := activeConfig
  io.computeStreamEnabled := !reset.asBool && !io.softReset && active && enabled
  io.computeComplete := complete
  io.localRowCacheEnabled := io.computeStreamEnabled &&
    activeConfig.reuseMode === InputBufferReuseMode.LOCAL_ROW_CACHE
  io.inputRowBytes := Mux(activeConfig.compactInputEnable,
    (activeConfig.reductionTileCount << 4).pad(rowByteWidth),
    (activeConfig.reductionTileCount << 8).pad(rowByteWidth))
  io.activeImpendingThresholdBytes := Mux(activeGemm && activeConfig.compactInputEnable,
    activeConfig.compactImpendingThresholdBytes, activeConfig.normalImpendingThresholdBytes)

  when(safeReset) {
    activeConfig := 0.U.asTypeOf(activeConfig)
    active := false.B
    complete := true.B
  }.elsewhen(accepted) {
    activeConfig := io.config
    active := true.B
    // Disabled/zero-length에서는 가짜 operationDone을 만들지 않는다.
    complete := !proposedComputeEnabled
  }.elsewhen(active) {
    when(io.pathStatus.operationDone) { complete := true.B }
    when(finished) { active := false.B }
  }

  when(io.contextStart && boundaryAvailable) {
    assert(modesValid, "UB operation/reuse mode must be valid")
    assert(vpuModeValid, "UB VPU_DIRECT requires STREAM")
    assert(replayValid, "UB normal GEMM requires rowReplayCount=outputColumnCount; fusion needs a positive explicit count")
    assert(cacheCapacityValid, "UB row cache must fit a nonzero row in 16KiB")
    assert(vectorAlignmentValid, "UB vector payload must be 16B aligned")
    assert(thresholdValid, "UB active impending threshold must be 16B aligned")
  }
  when(io.softReset && !reset.asBool) {
    assert(drained, "UB softReset requires DMA and read/output responses to be drained")
  }
}
