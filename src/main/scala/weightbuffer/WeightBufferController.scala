package npu.core.memory

import chisel3._
import scala.language.reflectiveCalls

/** 명세서 §2의 연산 종류. VPU_DIRECT에서는 weight cache를 사용하지 않는다. */
object WeightBufferOperationMode extends ChiselEnum {
  val GEMM, VPU_DIRECT = Value
}

/** 재사용 방식은 상위가 명시적으로 지정하며, WB가 크기로 추측하지 않는다. */
object WeightBufferReuseMode extends ChiselEnum {
  val STREAM, LOCAL_WEIGHT_CACHE = Value
}

/** Context 시작 시 한 번 저장하는 WB 설정.
  *
  * 전체 transfer 길이는 16KiB보다 클 수 있으므로 저장소의 15bit count와 구분한다.
  * 기본 폭은 임시 RTL interface 기준이며 기존 host/CCU ABI를 확정하는 값이 아니다.
  * lutTargetEnableMask의 목적지 해석은 기존 LUT programming unit이 담당한다.
  */
class WeightBufferConfig(
  val contextIdWidth: Int = 8,
  val payloadByteWidth: Int = 32, //전체 전송 길이(transfer 길이)
  val countWidth: Int = 16
) extends Bundle {
  require(contextIdWidth > 0)
  require(payloadByteWidth >= 15)
  require(countWidth > 0)

  val bufferEnable = Bool()
  val operationMode = WeightBufferOperationMode()
  val reuseMode = WeightBufferReuseMode()
  val fusionEnable = Bool()

  val weightSet0Bytes = UInt(payloadByteWidth.W)
  val weightSet1Bytes = UInt(payloadByteWidth.W)
  val weightReplayCount = UInt(countWidth.W)
  val inputRowCount = UInt(countWidth.W)
  val reductionTileCount = UInt(countWidth.W)
  val outputColumnCount = UInt(countWidth.W)

  val operand2PayloadBytes = UInt(payloadByteWidth.W)
  val constantOperandEnable = Bool()

  val lutLoadEnable = Bool()
  val lutPayloadBytes = UInt(payloadByteWidth.W)
  val lutTargetEnableMask = UInt(5.W)

  // 실제 stall 전달 지연을 반영한 값을 상위가 설정한다. 128B 등으로 고정하지 않는다.
  val normalImpendingThresholdBytes = UInt(payloadByteWidth.W)
  val contextId = UInt(contextIdWidth.W)
}

/** 나중에 연결할 데이터 경로가 context 관리부에 알려 줄 내부 상태.
  *
  * pending은 이전 요청에서 앞으로 도착할 응답까지 포함해야 한다.
  * done은 현재 context에 속한 실제 handshake에서 발생한 1cycle pulse다.
  * computeDone은 마지막 compute 출력 수락이며 memoryStreamLast가 아니다.
  * lutStreamDone은 LUT 출력 수락 완료이며 실제 lutProgrammingDone과 구분한다.
  */
class WeightBufferContextStatus extends Bundle {
  val refillPending = Bool()
  val readInFlight = Bool()
  val outputPending = Bool()
  val computeDone = Bool()
  val lutReceiveDone = Bool()
  val lutStreamDone = Bool()
}

/** WB Controller 명세서 v3의 설정 수락과 context 생명주기 관리부.
  *
  * 이번 단계는 context 제어만 구현한다. SRAM/refill/compute/LUT 데이터 경로는
  * 아직 인스턴스화하지 않으며, pathStatus는 그 경로와 연결할 내부 interface다.
  * 따라서 이 모듈만으로 weight/LUT를 수신하거나 출력하지는 않는다.
  *
  * 설정은 contextStart && contextReady에서 저장한다. 실행 중 config 입력이
  * 변해도 activeConfig는 유지된다. 작업 완료와 응답 drain을 모두 확인한 뒤
  * 다음 context를 받으며, globalStall 입력은 두지 않는다.
  */
class WeightBufferController(
  val contextIdWidth: Int = 8,
  val payloadByteWidth: Int = 32,
  val countWidth: Int = 16,
  val enableBufferedContexts: Boolean = false
) extends Module {
  require(contextIdWidth > 0)
  require(payloadByteWidth >= 15)
  require(countWidth > 0)

  private val bufferCapacityBytes = 16384

  val io = IO(new Bundle {
    // 상위는 contextStart를 올린 뒤 수락될 때까지 config 전체를 유지한다.
    val contextStart = Input(Bool())
    val contextReady = Output(Bool())
    val config = Input(new WeightBufferConfig(contextIdWidth, payloadByteWidth, countWidth))
    val softReset = Input(Bool())

    val pathStatus = Input(new WeightBufferContextStatus)
    // 다음 context의 미도착 응답까지 포함한다. 전체 취소 때만 사용한다.
    val bufferDrained = if (enableBufferedContexts) Some(Input(Bool())) else None

    // 데이터 경로에는 live config 대신 저장된 activeConfig를 연결한다.
    val activeConfig = Output(new WeightBufferConfig(contextIdWidth, payloadByteWidth, countWidth))
    // configValid는 새 입력 설정의 유효성이다. 실행 중인 설정은 activeConfig에 있다.
    val configValid = Output(Bool())
    val contextAccepted = Output(Bool())
    val contextActive = Output(Bool())

    // contextDone은 compute와 LUT의 종료 및 drain을 모두 확인한 pulse다.
    // 명세의 operationDone이나 lutProgrammingDone을 대신하지 않는다.
    val contextDone = Output(Bool())

    // 활성 context의 제어 상태 초기화와 전체 저장소 폐기를 구분한다.
    val dataPathClear = Output(Bool())
    val bufferFlush = Output(Bool())

    // 아래 enable은 현재 context가 해당 경로를 사용하는지를 뜻한다.
    // refill 필요 여부와 initialReady/impending은 다음 단계에서 별도로 계산한다.
    val computeStreamEnabled = Output(Bool())
    val lutTransferEnabled = Output(Bool())
    val localWeightCacheEnabled = Output(Bool())
    val weightWorkingSetBytes = Output(UInt((payloadByteWidth + 1).W))

    val computeComplete = Output(Bool())
    val lutReceiveComplete = Output(Bool())
    val lutStreamComplete = Output(Bool())
  })

  val activeConfig = RegInit(0.U.asTypeOf(
    new WeightBufferConfig(contextIdWidth, payloadByteWidth, countWidth)
  ))
  val contextActive = RegInit(false.B)
  val computeComplete = RegInit(true.B)
  val lutReceiveComplete = RegInit(true.B)
  val lutStreamComplete = RegInit(true.B)

  // 수락 전 config를 검사한다. W1+W2 합산에서 carry를 버리지 않는다.
  val proposedIsGemm = io.config.operationMode === WeightBufferOperationMode.GEMM
  val proposedIsVpu = io.config.operationMode === WeightBufferOperationMode.VPU_DIRECT
  val proposedIsCache = io.config.reuseMode === WeightBufferReuseMode.LOCAL_WEIGHT_CACHE
  val proposedWeightBytes = io.config.weightSet0Bytes +&
    Mux(io.config.fusionEnable, io.config.weightSet1Bytes, 0.U(payloadByteWidth.W))
  val proposedComputeBytes = Mux(
    proposedIsGemm,
    proposedWeightBytes,
    io.config.operand2PayloadBytes.pad(payloadByteWidth + 1)
  )
  val proposedConstantBypass = proposedIsVpu && io.config.constantOperandEnable
  val proposedComputeEnabled = io.config.bufferEnable &&
    !proposedConstantBypass && proposedComputeBytes =/= 0.U
  val proposedLutEnabled = io.config.lutLoadEnable && io.config.lutPayloadBytes =/= 0.U

  val modesValid = (proposedIsGemm || proposedIsVpu) &&
    (io.config.reuseMode === WeightBufferReuseMode.STREAM || proposedIsCache)
  val vpuModeValid = !proposedIsVpu || io.config.reuseMode === WeightBufferReuseMode.STREAM
  val weightSetsValid = !proposedIsGemm || io.config.fusionEnable ||
    io.config.weightSet1Bytes === 0.U

  // Disabled/constant/0B의 미사용 compute 필드는 검사 대상에서 제외한다.
  // LUT는 compute disable과 독립적으로 유효 길이를 검사한다.
  val computeAlignmentValid = !proposedComputeEnabled || Mux(
    proposedIsGemm,
    io.config.weightSet0Bytes(3, 0) === 0.U &&
      (!io.config.fusionEnable || io.config.weightSet1Bytes(3, 0) === 0.U),
    io.config.operand2PayloadBytes(3, 0) === 0.U
  )
  val lutAlignmentValid = !proposedLutEnabled || io.config.lutPayloadBytes(3, 0) === 0.U
  val thresholdValid = !proposedComputeEnabled ||
    io.config.normalImpendingThresholdBytes(3, 0) === 0.U

  // Dense 단일 weight의 식만 검사한다. Fusion block 순서는 명세에서도 미확정이다.
  // 곱셈과 shift의 전체 폭을 유지해 큰 shape가 잘려서 통과하지 않게 한다.
  val denseWeightBytes = (io.config.reductionTileCount * io.config.outputColumnCount) << 8
  val gemmShapeValid = !proposedComputeEnabled || !proposedIsGemm ||
    (io.config.weightReplayCount =/= 0.U &&
      io.config.weightReplayCount === io.config.inputRowCount &&
      (io.config.fusionEnable || io.config.weightSet0Bytes === denseWeightBytes))
  val cacheCapacityValid = !proposedComputeEnabled || !proposedIsCache ||
    (proposedIsGemm && proposedWeightBytes <= bufferCapacityBytes.U)

  val configurationValid = modesValid && vpuModeValid && weightSetsValid &&
    computeAlignmentValid && lutAlignmentValid && thresholdValid &&
    gemmShapeValid && cacheCapacityValid

  // 순간적으로 응답이 없는 것만으로 context를 바꾸지 않는다.
  // 현재 작업 자체가 끝나 contextActive가 내려간 뒤 drain 여부를 검사한다.
  val pathsDrained = !io.pathStatus.refillPending &&
    !io.pathStatus.readInFlight && !io.pathStatus.outputPending
  val boundaryAvailable = !reset.asBool && !io.softReset && !contextActive && pathsDrained
  io.configValid := configurationValid
  io.contextReady := boundaryAvailable && configurationValid
  val contextAccepted = io.contextStart && io.contextReady
  io.contextAccepted := contextAccepted

  // 실행 중 softReset은 상위가 새 요청을 막고 cancel/drain을 보장한 뒤에만 허용한다.
  // 이 신호 자체가 DMA 취소를 수행하지는 않으며, 미도착 응답이 있으면 수락하지 않는다.
  val allPathsDrained = io.bufferDrained.getOrElse(pathsDrained)
  val softResetAccepted = !reset.asBool && io.softReset && allPathsDrained
  io.bufferFlush := softResetAccepted
  io.dataPathClear := contextAccepted || softResetAccepted

  val activeIsGemm = activeConfig.operationMode === WeightBufferOperationMode.GEMM
  val activeIsVpu = activeConfig.operationMode === WeightBufferOperationMode.VPU_DIRECT
  val activeWeightBytes = activeConfig.weightSet0Bytes +&
    Mux(activeConfig.fusionEnable, activeConfig.weightSet1Bytes, 0.U(payloadByteWidth.W))
  val activeComputeBytes = Mux(
    activeIsGemm,
    activeWeightBytes,
    activeConfig.operand2PayloadBytes.pad(payloadByteWidth + 1)
  )
  val activeComputeEnabled = activeConfig.bufferEnable &&
    !(activeIsVpu && activeConfig.constantOperandEnable) && activeComputeBytes =/= 0.U
  val activeLutEnabled = activeConfig.lutLoadEnable && activeConfig.lutPayloadBytes =/= 0.U

  // 완료 pulse는 별도로 기억한다. 예를 들어 compute가 먼저 끝나도 LUT가 남아 있으면
  // context는 유지한다. 반대로 LUT 수신 완료만으로 LUT 출력 완료를 만들지 않는다.
  val computeFinished = computeComplete || io.pathStatus.computeDone
  val lutReceiveFinished = lutReceiveComplete || io.pathStatus.lutReceiveDone
  val lutStreamFinished = lutStreamComplete || io.pathStatus.lutStreamDone
  val contextFinished = contextActive && computeFinished &&
    lutReceiveFinished && lutStreamFinished && pathsDrained

  io.activeConfig := activeConfig
  io.contextActive := !reset.asBool && contextActive
  io.contextDone := !reset.asBool && !io.softReset && contextFinished
  io.computeStreamEnabled := !reset.asBool && !io.softReset && contextActive && activeComputeEnabled
  io.lutTransferEnabled := !reset.asBool && !io.softReset && contextActive && activeLutEnabled
  io.localWeightCacheEnabled := io.computeStreamEnabled &&
    activeConfig.reuseMode === WeightBufferReuseMode.LOCAL_WEIGHT_CACHE
  io.weightWorkingSetBytes := activeWeightBytes
  io.computeComplete := computeComplete
  io.lutReceiveComplete := lutReceiveComplete
  io.lutStreamComplete := lutStreamComplete

  when(softResetAccepted) {
    activeConfig := 0.U.asTypeOf(activeConfig)
    contextActive := false.B
    computeComplete := true.B
    lutReceiveComplete := true.B
    lutStreamComplete := true.B
  }.elsewhen(contextAccepted) {
    activeConfig := io.config
    contextActive := true.B
    // Disabled/constant/0B는 데이터 없이 완료 처리한다. 가상의 operationDone은 만들지 않는다.
    computeComplete := !proposedComputeEnabled
    lutReceiveComplete := !proposedLutEnabled
    lutStreamComplete := !proposedLutEnabled
  }.elsewhen(contextActive) {
    computeComplete := computeFinished
    lutReceiveComplete := lutReceiveFinished
    lutStreamComplete := lutStreamFinished
    when(contextFinished) {
      contextActive := false.B
    }
  }

  // 잘못된 설정은 ready를 내리고 시뮬레이션 assertion으로 원인을 구분한다.
  // Busy 중의 start는 수락하지 않으며, 상위는 ready까지 start/config를 유지한다.
  when(io.contextStart && boundaryAvailable) {
    assert(modesValid, "WB operationMode/reuseMode must be valid")
    assert(vpuModeValid, "WB VPU_DIRECT requires STREAM")
    assert(weightSetsValid, "WB non-fusion requires weightSet1Bytes == 0")
    assert(computeAlignmentValid, "WB compute payload must be 16B aligned")
    assert(lutAlignmentValid, "WB LUT payload must be 16B aligned")
    assert(thresholdValid, "WB impending threshold must be 16B aligned")
    assert(gemmShapeValid, "WB GEMM shape/replay count does not match its payload")
    assert(cacheCapacityValid, "WB local weight cache must fit in 16KiB")
  }
  when(io.softReset && !reset.asBool) {
    assert(allPathsDrained, "WB softReset requires DMA/read/output responses to be drained")
  }
}
