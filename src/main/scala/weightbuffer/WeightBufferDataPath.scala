package npu.core.memory

import chisel3._
import chisel3.util._
import scala.language.reflectiveCalls

/** 요청 당시 종류를 응답 adapter와 출력 staging이 끝까지 보존한다. */
object WeightBufferDataKind extends ChiselEnum {
  val LUT, WEIGHT, VECTOR_OPERAND = Value
}

/** 수신과 read phase를 분리해 LUT 출력 중에도 weight를 받을 수 있게 한다. */
object WeightBufferReceivePhase extends ChiselEnum {
  val LUT_RECEIVE, COMPUTE_RECEIVE, RECEIVE_DONE = Value
}
object WeightBufferReadPhase extends ChiselEnum {
  val LUT_STREAM, COMPUTE_STREAM, READ_DONE = Value
}

/** Compute 진행 상태. 수신/read phase와 독립적이며 전체 회로를 멈추지 않는다. */
object WeightBufferControllerState extends ChiselEnum {
  val DISABLED, INITIAL_FILL, ACTIVE, DRAINING, DONE = Value
}

/** WB의 context 관리부와 공통 버퍼를 연결한 LUT/weight/operand2 경로.
  *
  * STREAM은 GEMM sequence를 매 pass 다시 공급받고, CACHE는 원본 한 벌만 받는다.
  * W1/W2의 순서는 AG가 제공한 packed logical order를 그대로 사용한다.
  * 원본 주소/source resolve는 AG 소유이며 이 모듈은 byte 수와 group만 요청한다.
  *
  * LUT는 CCU credit으로 수신하고 기록된 부분부터 programming unit으로 출력한다.
  * LUT 수신 완료 후 weight를 뒤에 붙이며, LUT 출력이 끝난 뒤 compute read를 허용한다.
  * 실제 lutProgrammingDone과 중앙 holding은 programming unit/CCU가 관리한다.
  */
class WeightBufferDataPath(
  val contextIdWidth: Int = 8,
  val payloadByteWidth: Int = 32,
  val countWidth: Int = 16
) extends Module {
  require(contextIdWidth > 0 && payloadByteWidth >= 15 && countWidth > 0)

  private val localByteCountWidth = 15
  private val sequenceByteWidth = payloadByteWidth + 1
  private val maxRefillBytes = 4096

  val io = IO(new Bundle {
    val contextStart = Input(Bool())
    val contextReady = Output(Bool())
    val config = Input(new WeightBufferConfig(contextIdWidth, payloadByteWidth, countWidth))
    val configValid = Output(Bool())
    val softReset = Input(Bool())
    // config 버스로 다음 context를 먼저 승인한다. 실제 실행은 contextStart로 별도 전환한다.
    // LUT 선행 수신은 지원하지 않으므로 유효 LUT load가 있는 설정은 ready가 내려간다.
    val prefillStart = Input(Bool())
    val prefillReady = Output(Bool())
    val prefillAccepted = Output(Bool())
    val prefillPending = Output(Bool())
    val contextAccepted = Output(Bool())
    val contextActive = Output(Bool())
    val contextDone = Output(Bool())

    // 새 SRAM read의 허용이다. 이미 발행한 응답의 전달/보관은 계속 진행한다.
    // 실행 중 취소 시 이 입력을 내리고 기존 응답을 drain한 뒤 softReset한다.
    val readEnable = Input(Bool())

    val refillRequestValid = Output(Bool())
    val refillRequestReady = Input(Bool())
    val refillRequestBytes = Output(UInt(localByteCountWidth.W))
    val refillRequestGroupIndex = Output(UInt(countWidth.W))
    val refillRequestStartsNewGroup = Output(Bool())
    val refillRequestAllowsOverwrite = Output(Bool())
    // Adapter는 요청 수락 시 이 identity를 저장하고 응답에 다시 붙인다.
    val refillRequestContextId = Output(UInt(contextIdWidth.W))
    val refillRequestDataKind = Output(WeightBufferDataKind())
    val prefetchEligible = Output(Bool())
    val refillRequestIsPrefill = Output(Bool())

    // CCU/DMA가 승인받는 LUT response credit window다. 일반 refill 요청과 별개다.
    // 한 window는 현재 freeBytes 이내의 16B 정렬 길이이며 전체 LUT 길이 제한이 아니다.
    val lutCreditValid = Input(Bool())
    val lutCreditReady = Output(Bool())
    val lutCreditBytes = Input(UInt(localByteCountWidth.W))
    val lutData = Output(UInt(128.W))
    val lutDataValid = Output(Bool())
    val lutDataReady = Input(Bool())
    val lutDataLast = Output(Bool())
    val lutTargetEnableMask = Output(UInt(5.W))
    val lutReceiveDone = Output(Bool())
    val lutStreamDone = Output(Bool())
    val receivePhase = Output(WeightBufferReceivePhase())
    val readPhase = Output(WeightBufferReadPhase())

    val memoryDataValid = Input(Bool())
    val memoryDataReady = Output(Bool())
    val memoryData = Input(UInt(512.W))
    val memoryLaneValidMask = Input(UInt(4.W))
    val memoryChunkLast = Input(Bool())
    val memoryStreamLast = Input(Bool())
    val memoryContextId = Input(UInt(contextIdWidth.W))
    val memoryDataKind = Input(WeightBufferDataKind())

    val computeData = Output(UInt(128.W))
    val computeDataValid = Output(Bool())
    val computeDataReady = Input(Bool())
    val computeDataLast = Output(Bool())
    val operationDone = Output(Bool())

    val initialReady = Output(Bool())
    val hungry = Output(Bool())
    val starving = Output(Bool())
    val impending = Output(Bool())
    val controllerState = Output(WeightBufferControllerState())
    val weightCacheReady = Output(Bool())
    val weightSupplyComplete = Output(Bool())
    val freeBytes = Output(UInt(localByteCountWidth.W))
    val full = Output(Bool())
    val refillPending = Output(Bool())
    // passIndex는 현재 유효 출력/passDone에 귀속된 index다.
    val passIndex = Output(UInt(countWidth.W))
    val passDone = Output(Bool())
  })

  val context = Module(new WeightBufferController(contextIdWidth, payloadByteWidth, countWidth, enableBufferedContexts = true))
  val core = Module(new CircularBufferCore(
    contextIdWidth = contextIdWidth,
    groupIndexWidth = countWidth,
    userTagWidth = 2,
    replayCountWidth = countWidth,
    enableStreaming = true,
    enableContextPrefill = true
  ))

  context.io.config := io.config
  val nextConfig = RegInit(0.U.asTypeOf(new WeightBufferConfig(contextIdWidth, payloadByteWidth, countWidth)))
  val nextConfigValid = RegInit(false.B)
  // 미리 받은 context를 다른 설정으로 실행하면 저장된 길이/종류와 어긋난다.
  val activationMatches = !nextConfigValid || io.config.asUInt === nextConfig.asUInt
  context.io.contextStart := io.contextStart && activationMatches
  context.io.softReset := io.softReset
  io.configValid := context.io.configValid
  io.contextReady := context.io.contextReady && activationMatches
  io.contextAccepted := context.io.contextAccepted
  io.contextActive := context.io.contextActive
  io.contextDone := context.io.contextDone

  val clear = reset.asBool || context.io.dataPathClear
  core.io.softReset := context.io.bufferFlush
  core.io.contextActivate.get := context.io.contextAccepted
  val activatePrefilled = context.io.contextAccepted && nextConfigValid
  core.io.preserveCacheOnActivate.get := activatePrefilled &&
    nextConfig.reuseMode === WeightBufferReuseMode.LOCAL_WEIGHT_CACHE
  core.io.contextId := context.io.activeConfig.contextId

  val config = context.io.activeConfig
  val isGemm = config.operationMode === WeightBufferOperationMode.GEMM
  val isCache = context.io.localWeightCacheEnabled
  val computeRunning = context.io.computeStreamEnabled && !context.io.computeComplete
  val sequenceBytes = Mux(isGemm, context.io.weightWorkingSetBytes,
    config.operand2PayloadBytes.pad(sequenceByteWidth))
  val computePassCount = Mux(isGemm, config.weightReplayCount, 1.U(countWidth.W))
  val expectedKind = Mux(isGemm, WeightBufferDataKind.WEIGHT, WeightBufferDataKind.VECTOR_OPERAND)

  val cacheConfigured = RegInit(false.B)
  val requestedBytesThisPass = RegInit(0.U(sequenceByteWidth.W))
  val supplyPassIndex = RegInit(0.U(countWidth.W))
  val allRequestsAccepted = RegInit(false.B)
  val refillBytesRemaining = RegInit(0.U(localByteCountWidth.W))
  val activeRefillEndsSupply = RegInit(false.B)
  val fillInitialChunkReady = RegInit(false.B)
  // 다음 공급으로 counter를 넘기는 시점에는 이전 공급이 이미 완전히 끝나 있다.
  val initialChunkReady = nextConfigValid || fillInitialChunkReady
  val currentSupplyComplete = nextConfigValid || (allRequestsAccepted && !core.io.refillPending)
  val currentCacheReady = nextConfigValid || core.io.cacheFillComplete

  val proposedGemm = io.config.operationMode === WeightBufferOperationMode.GEMM
  val proposedSequenceBytes = Mux(proposedGemm,
    io.config.weightSet0Bytes +& Mux(io.config.fusionEnable, io.config.weightSet1Bytes, 0.U),
    io.config.operand2PayloadBytes.pad(sequenceByteWidth))
  val proposedComputeEnabled = io.config.bufferEnable && proposedSequenceBytes =/= 0.U &&
    !(io.config.operationMode === WeightBufferOperationMode.VPU_DIRECT && io.config.constantOperandEnable)
  val proposedCache = io.config.reuseMode === WeightBufferReuseMode.LOCAL_WEIGHT_CACHE
  val proposedLut = io.config.lutLoadEnable && io.config.lutPayloadBytes =/= 0.U

  // CACHE는 unique fill이 끝나고 최종 pass에 들어왔을 때 descriptor를 양도한다.
  // STREAM도 이전 공급이 끝난 뒤에만 다음 공급의 counter를 재사용한다.
  val currentFinalPass = !isCache || core.io.passIndex +& 1.U === config.weightReplayCount
  val prefillCandidate = !clear && !io.contextStart && computeRunning &&
    currentSupplyComplete && currentFinalPass && !nextConfigValid &&
    context.io.configValid && proposedComputeEnabled && !proposedLut &&
    io.config.contextId =/= config.contextId
  io.prefillReady := prefillCandidate && (!proposedCache || core.io.cacheGroup.ready)
  val prefillFire = io.prefillStart && io.prefillReady
  io.prefillAccepted := prefillFire
  io.prefillPending := nextConfigValid

  // 읽기 설정은 activeConfig, 공급 설정은 승인된 다음 context를 선택한다.
  // cache descriptor는 Core 안에 한 세트만 존재한다.
  val fillConfig = Mux(nextConfigValid, nextConfig, config)
  val fillGemm = fillConfig.operationMode === WeightBufferOperationMode.GEMM
  val fillCache = fillConfig.reuseMode === WeightBufferReuseMode.LOCAL_WEIGHT_CACHE
  val fillSequenceBytes = Mux(fillGemm,
    fillConfig.weightSet0Bytes +& Mux(fillConfig.fusionEnable, fillConfig.weightSet1Bytes, 0.U),
    fillConfig.operand2PayloadBytes.pad(sequenceByteWidth))
  val fillPassCount = Mux(fillCache, 1.U(countWidth.W),
    Mux(fillGemm, fillConfig.weightReplayCount, 1.U(countWidth.W)))
  val fillKind = Mux(fillGemm, WeightBufferDataKind.WEIGHT, WeightBufferDataKind.VECTOR_OPERAND)
  val fillRunning = nextConfigValid || computeRunning

  // LUT의 전체 길이/count/완료 조건은 WB 정책이다. 물리 pointer와 entry는
  // 공통 Core 한 곳에서 관리하므로 LUT 전용 reader와 저장소 metadata는 없다.
  val lutBytesCommitted = RegInit(0.U(payloadByteWidth.W))
  val lutBytesConsumed = RegInit(0.U(payloadByteWidth.W))
  val lutReceiveComplete = context.io.lutReceiveComplete
  val lutStreamComplete = context.io.lutStreamComplete
  val startsLut = io.config.lutLoadEnable && io.config.lutPayloadBytes =/= 0.U

  val lutCreditLengthValid = io.lutCreditBytes =/= 0.U &&
    io.lutCreditBytes(3, 0) === 0.U && io.lutCreditBytes <= 16384.U
  val lutCreditFits = lutBytesCommitted +& core.io.reservedBytes +& io.lutCreditBytes <= config.lutPayloadBytes
  core.io.streamCredit.get.valid := !clear && !lutReceiveComplete &&
    io.lutCreditValid && lutCreditFits && lutCreditLengthValid
  core.io.streamCredit.get.bits := io.lutCreditBytes
  io.lutCreditReady := !clear && !lutReceiveComplete &&
    lutCreditFits && lutCreditLengthValid && core.io.streamCredit.get.ready
  io.lutTargetEnableMask := config.lutTargetEnableMask
  core.io.streamReadEnable.get := true.B

  val weightRefillEnabled = fillRunning && lutReceiveComplete
  val weightSupplyReceived = currentSupplyComplete
  val phaseActive = context.io.contextActive && !clear
  io.receivePhase := Mux(phaseActive && !lutReceiveComplete,
    WeightBufferReceivePhase.LUT_RECEIVE,
    Mux(!clear && fillRunning && !(allRequestsAccepted && !core.io.refillPending),
      WeightBufferReceivePhase.COMPUTE_RECEIVE, WeightBufferReceivePhase.RECEIVE_DONE))
  io.readPhase := Mux(phaseActive && !lutStreamComplete,
    WeightBufferReadPhase.LUT_STREAM,
    Mux(phaseActive && computeRunning,
      WeightBufferReadPhase.COMPUTE_STREAM, WeightBufferReadPhase.READ_DONE))

  // CACHE 설정은 먼저 준비하되 실제 시작 위치는 첫 weight 예약에서 결정된다.
  // LUT 수신 중에는 weight 예약을 막고, 완료 후 같은 writeCommitPtr에서 이어 예약한다.
  // 다음 cache descriptor 설정과 prefill 승인을 같은 cycle에 확정한다.
  // 설정만 먼저 수락되어 현재 cache가 사라지는 일을 막는다.
  val prefillCacheSetup = prefillCandidate && proposedCache
  core.io.cacheGroup.valid := (io.prefillStart && prefillCacheSetup) ||
    (!clear && !prefillFire && fillRunning && fillCache && !cacheConfigured)
  core.io.cacheGroup.bits.payloadBytes := Mux(prefillCacheSetup,
    proposedSequenceBytes(localByteCountWidth - 1, 0), fillSequenceBytes(localByteCountWidth - 1, 0))
  core.io.cacheGroup.bits.replayCount := Mux(prefillCacheSetup,
    io.config.weightReplayCount, fillConfig.weightReplayCount)
  core.io.cacheGroup.bits.contextId := Mux(prefillCacheSetup, io.config.contextId, fillConfig.contextId)
  core.io.cacheGroup.bits.groupIndex := 0.U

  val remainingBytesThisPass = fillSequenceBytes - requestedBytesThisPass
  val requestBytes = Mux(remainingBytesThisPass > maxRefillBytes.U,
    maxRefillBytes.U(localByteCountWidth.W),
    remainingBytesThisPass(localByteCountWidth - 1, 0))
  val requestEndsGroup = remainingBytesThisPass <= maxRefillBytes.U
  val requestEndsSupply = requestEndsGroup && supplyPassIndex +& 1.U === fillPassCount
  val requestCandidate = !clear && !prefillFire && fillRunning && weightRefillEnabled &&
    !allRequestsAccepted && (!fillCache || cacheConfigured) && remainingBytesThisPass =/= 0.U

  // Context 수락과 동시에 LUT entry를 배정한다. 별도 외부 DMA grant는 없으며,
  // 실제 수신 예약은 이후 CCU credit handshake에서 같은 writer에 더해진다.
  val lutReservationNeeded = context.io.contextAccepted && startsLut
  core.io.reserveRefill.bits.payloadBytes := Mux(lutReservationNeeded, 0.U, requestBytes)
  core.io.reserveRefill.bits.streaming := lutReservationNeeded
  core.io.reserveRefill.bits.userTag := Mux(lutReservationNeeded, WeightBufferDataKind.LUT, fillKind).asUInt
  core.io.reserveRefill.bits.contextId := Mux(lutReservationNeeded,
    Mux(context.io.contextAccepted, io.config.contextId, config.contextId), fillConfig.contextId)
  core.io.reserveRefill.bits.groupIndex := Mux(lutReservationNeeded, 0.U, supplyPassIndex)
  core.io.reserveRefill.bits.lastInGroup := lutReservationNeeded || requestEndsGroup

  // AG grant와 일반 entry 예약은 atomic하다. LUT entry 배정은 AG 요청으로 내보내지 않는다.
  io.refillRequestValid := !lutReservationNeeded && requestCandidate && core.io.reserveRefill.ready
  core.io.reserveRefill.valid := lutReservationNeeded || (requestCandidate && io.refillRequestReady)
  val refillFire = io.refillRequestValid && io.refillRequestReady
  val lutReservationFire = core.io.reserveRefill.fire && lutReservationNeeded
  io.refillRequestBytes := requestBytes
  io.refillRequestGroupIndex := supplyPassIndex
  io.refillRequestStartsNewGroup := requestedBytesThisPass === 0.U
  // IB 교체/lifetime 연결 전에는 파괴 권한을 부여하지 않는 보수적인 기본값이다.
  io.refillRequestAllowsOverwrite := false.B
  io.refillRequestContextId := fillConfig.contextId
  io.refillRequestDataKind := fillKind
  io.prefetchEligible := io.refillRequestValid
  io.refillRequestIsPrefill := nextConfigValid

  // LUT/일반 응답은 같은 writer를 사용한다. 요청 당시 context/tag와 credit 검사는
  // 공통 writer가 맡고, WB는 bounded LUT의 전체 길이만 추가 검사한다.
  val memoryIsLut = io.memoryDataKind === WeightBufferDataKind.LUT
  val lutCommittedNext = lutBytesCommitted +& core.io.memoryPayloadBytes
  val lutIngressAllowed = !lutReceiveComplete && lutCommittedNext <= config.lutPayloadBytes
  val ingressAllowed = !memoryIsLut || lutIngressAllowed
  core.io.memoryDataValid := io.memoryDataValid && ingressAllowed
  core.io.memoryData := io.memoryData
  core.io.memoryLaneValidMask := io.memoryLaneValidMask
  core.io.memoryChunkLast := io.memoryChunkLast
  core.io.memoryStreamLast := Mux(memoryIsLut, io.memoryChunkLast, io.memoryStreamLast)
  core.io.memoryContextId := io.memoryContextId
  core.io.memoryUserTag := io.memoryDataKind.asUInt
  io.memoryDataReady := core.io.memoryDataReady && ingressAllowed
  val acceptedMemory = core.io.memoryDataValid && core.io.memoryDataReady
  val memoryFire = acceptedMemory && !memoryIsLut
  val lutMemoryFire = acceptedMemory && memoryIsLut
  io.lutReceiveDone := lutMemoryFire && io.memoryChunkLast

  // 출력의 last는 공급 stream marker와 분리한다. Cache의 마지막 공급 marker는
  // 매 pass에서 재생되지만 operationDone은 최종 pass의 최종 수락에서만 발생한다.
  // 출력 staging도 하나다. 보관된 tag로 목적지와 ready를 선택하며 LUT read는
  // compute readEnable과 무관하게 진행한다. 경계를 넘어도 data/tag가 함께 이동한다.
  core.io.readEnable := io.readEnable && computeRunning
  val outputIsLut = core.io.output.bits.userTag === WeightBufferDataKind.LUT.asUInt
  core.io.output.ready := Mux(outputIsLut, io.lutDataReady, io.computeDataReady && computeRunning)
  io.lutData := core.io.output.bits.data
  io.lutDataValid := core.io.output.valid && outputIsLut
  val lutOutputFire = io.lutDataValid && io.lutDataReady
  val lutConsumedNext = lutBytesConsumed +& 16.U
  io.lutDataLast := io.lutDataValid && lutConsumedNext === config.lutPayloadBytes
  io.lutStreamDone := lutOutputFire && io.lutDataLast
  io.computeData := core.io.output.bits.data
  io.computeDataValid := core.io.output.valid && !outputIsLut && computeRunning
  val outputPassIndex = Mux(isCache,
    Mux(nextConfigValid, config.weightReplayCount - 1.U, core.io.passIndex),
    core.io.output.bits.groupIndex)
  val finalOutput = core.io.output.bits.lastInGroup && outputPassIndex +& 1.U === computePassCount
  io.computeDataLast := io.computeDataValid && finalOutput
  io.operationDone := io.computeDataValid && io.computeDataReady && io.computeDataLast
  io.passIndex := outputPassIndex
  io.passDone := core.io.passDone && !outputIsLut

  // readPipelineIdle는 LUT/compute의 미수락 출력까지 포함한 단일 reader의 raw 상태다.
  // 이를 하나의 pending으로 합쳐 연결한다. clear로 마스킹되는 output.valid를
  // drain 판단에 다시 넣으면 reset/ready에 조합 loop가 생기므로 사용하지 않는다.
  // CCU가 아직 보낼 credit도 DMA pending에 포함한다. 취소 시 CCU는 추가 credit과
  // 공급을 먼저 멈추고, 예약된 응답과 reader 출력을 drain한 뒤 softReset한다.
  // 다음 context의 응답 대기는 현재 context의 완료를 막지 않는다.
  context.io.pathStatus.refillPending := core.io.refillPending &&
    core.io.refillContextId === config.contextId
  context.io.bufferDrained.get := !core.io.refillPending && core.io.readPipelineIdle
  context.io.pathStatus.readInFlight := !core.io.readPipelineIdle
  context.io.pathStatus.outputPending := false.B
  context.io.pathStatus.computeDone := io.operationDone
  context.io.pathStatus.lutReceiveDone := io.lutReceiveDone
  context.io.pathStatus.lutStreamDone := io.lutStreamDone

  io.initialReady := !context.io.computeStreamEnabled || initialChunkReady

  // Refill 허용은 실제 admission 결과다. Pending/full/entry/mode/LUT phase를
  // 무시한 별도 urgent 요청을 만들지 않으며 AG ready를 기다리는 동안도 유지한다.
  val refillAllowed = io.refillRequestValid
  val readableBytesThisPass = core.io.readiness.readableBytesThisPass
  val nextRequiredChunkReady = core.io.readiness.nextRequiredChunkReady
  val safeContinuationReady = nextRequiredChunkReady
  // Starving은 지금 consumer에게 전달할 유효 데이터가 없는 실제 상태다.
  val requiredPayloadAvailable = io.computeDataValid
  val allRemainingComputePayloadReady = Mux(isCache,
    currentCacheReady, weightSupplyReceived)
  io.hungry := !nextConfigValid && refillAllowed && (!initialChunkReady || !nextRequiredChunkReady ||
    readableBytesThisPass <= maxRefillBytes.U)
  io.starving := computeRunning && !requiredPayloadAvailable
  // 마지막 tail 또는 cache의 이후 replay가 이미 준비되었으면 threshold만으로
  // compute를 막지 않는다. LUT 점유량과 SRAM readIssuePtr는 이 잔량에 포함하지 않는다.
  io.impending := computeRunning && (!initialChunkReady ||
    (!allRemainingComputePayloadReady &&
      readableBytesThisPass <= config.normalImpendingThresholdBytes && !safeContinuationReady))

  // 완료된 activeConfig와 computeComplete는 다음 context까지 유지된다.
  // 별도 FSM register를 중복 저장하지 않고 DONE도 contextActive 해제 후 유지한다.
  val configuredComputeEnabled = config.bufferEnable &&
    !(config.operationMode === WeightBufferOperationMode.VPU_DIRECT && config.constantOperandEnable) &&
    sequenceBytes =/= 0.U
  io.controllerState := Mux(clear || !configuredComputeEnabled, WeightBufferControllerState.DISABLED,
    Mux(context.io.computeComplete, WeightBufferControllerState.DONE,
      Mux(!initialChunkReady, WeightBufferControllerState.INITIAL_FILL,
        Mux(weightSupplyReceived, WeightBufferControllerState.DRAINING,
          WeightBufferControllerState.ACTIVE))))
  io.weightCacheReady := isCache && currentCacheReady
  io.weightSupplyComplete := context.io.computeStreamEnabled && currentSupplyComplete
  // LUT와 일반 payload/reservation의 전체 점유량은 writer가 한 번만 계산한다.
  io.freeBytes := core.io.freeBytes
  io.full := core.io.full
  io.refillPending := core.io.refillPending

  when(context.io.bufferFlush) {
    lutBytesCommitted := 0.U
    lutBytesConsumed := 0.U
  }.elsewhen(context.io.contextAccepted) {
    lutBytesCommitted := 0.U
    lutBytesConsumed := 0.U
    when(startsLut) {
      assert(lutReservationFire, "a fresh LUT context must allocate its FIFO entry on acceptance")
    }
  }.otherwise {
    when(lutMemoryFire) {
      lutBytesCommitted := lutCommittedNext
    }
    when(lutOutputFire) {
      lutBytesConsumed := lutConsumedNext
    }
  }

  when(context.io.bufferFlush) {
    nextConfigValid := false.B
    nextConfig := 0.U.asTypeOf(nextConfig)
  }.elsewhen(prefillFire) {
    nextConfig := io.config
    nextConfigValid := true.B
  }.elsewhen(activatePrefilled) {
    nextConfigValid := false.B
  }

  // Prefill 상태는 활성화 시 지우지 않는다. 미도착 응답의 남은 byte 수도 보존한다.
  val resetFill = context.io.bufferFlush || prefillFire ||
    (context.io.contextAccepted && !activatePrefilled)
  when(resetFill) {
    cacheConfigured := prefillFire && proposedCache
    requestedBytesThisPass := 0.U
    supplyPassIndex := 0.U
    allRequestsAccepted := false.B
    refillBytesRemaining := 0.U
    activeRefillEndsSupply := false.B
    fillInitialChunkReady := false.B
  }.otherwise {
    when(core.io.cacheGroup.fire) {
      cacheConfigured := true.B
    }
    when(refillFire) {
      activeRefillEndsSupply := requestEndsSupply
      when(requestEndsGroup) {
        requestedBytesThisPass := 0.U
        when(requestEndsSupply) {
          allRequestsAccepted := true.B
        }.otherwise {
          supplyPassIndex := supplyPassIndex + 1.U
        }
      }.otherwise {
        requestedBytesThisPass := requestedBytesThisPass + requestBytes
      }
    }
    // Outstanding는 하나이므로 새 grant와 이전 response 수락은 겹치지 않는다.
    when(refillFire) {
      refillBytesRemaining := requestBytes
    }.elsewhen(memoryFire) {
      refillBytesRemaining := refillBytesRemaining - core.io.memoryPayloadBytes
    }
    when(memoryFire && io.memoryChunkLast) {
      fillInitialChunkReady := true.B
    }
  }

  when(!reset.asBool && !context.io.bufferFlush) {
    assert((refillFire || lutReservationFire) === core.io.reserveRefill.fire,
      "WB refill grant or LUT allocation must match its local reservation")
    when(!clear && io.lutCreditValid && !lutReceiveComplete) {
      assert(lutCreditLengthValid, "WB LUT credit must be a positive aligned window within ring capacity")
    }
    when(lutMemoryFire) {
      assert(io.memoryChunkLast === (lutCommittedNext === config.lutPayloadBytes),
        "WB bounded LUT last must match its configured length")
    }
    when(io.lutDataValid) {
      assert(core.io.output.bits.lastInChunk === io.lutDataLast,
        "WB LUT last must match the common entry boundary")
    }
    when(memoryFire) {
      assert(core.io.memoryPayloadBytes <= refillBytesRemaining, "WB response exceeds its requested chunk")
      assert(io.memoryChunkLast === (core.io.memoryPayloadBytes === refillBytesRemaining),
        "WB logical chunk last must match its requested byte count")
      assert(io.memoryStreamLast === (io.memoryChunkLast && activeRefillEndsSupply),
        "WB supply stream last must match the final requested payload")
    }
    when(io.computeDataValid) {
      assert(core.io.output.bits.userTag === expectedKind.asUInt, "WB compute output kind does not match context")
      assert(core.io.output.bits.contextId === config.contextId, "WB compute output belongs to another context")
    }
  }
}
