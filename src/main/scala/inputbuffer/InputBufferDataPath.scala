package npu.core.memory

import chisel3._
import chisel3.util._
import scala.language.reflectiveCalls

/** UB 명세서 v3의 공개 데이터 경로.
  *
  * 공통 Core가 SRAM·예약·metadata·read staging을 관리하고, 여기서는 row/pass와
  * 공급 순서만 관리한다. 주소 생성, IB residency, 실제 overwrite 허가는 AG 소유다.
  * STREAM은 m→pass→k로 매번 재공급받고 CACHE는 row 한 벌을 총 replay 횟수만큼 쓴다.
  */
class InputBufferDataPath(
  val contextIdWidth: Int = 8,
  val payloadByteWidth: Int = 32,
  val countWidth: Int = 16
) extends Module {
  require(contextIdWidth > 0 && payloadByteWidth >= 15 && countWidth > 0)
  private val localByteCountWidth = 15
  private val rowByteWidth = math.max(payloadByteWidth, countWidth + 8)
  // STREAM의 모든 row/pass를 구분한다. M*pass를 countWidth로 잘라 쓰지 않는다.
  private val groupIndexWidth = 2 * countWidth
  private val maxRefillBytes = 4096

  val io = IO(new Bundle {
    val contextStart = Input(Bool())
    val contextReady = Output(Bool())
    val config = Input(new InputBufferConfig(contextIdWidth, payloadByteWidth, countWidth))
    val configValid = Output(Bool())
    val softReset = Input(Bool())
    val contextAccepted = Output(Bool())
    val contextActive = Output(Bool())
    val contextDone = Output(Bool())
    // 새 read만 막는다. 이미 발행한 응답의 capture와 DMA 수신은 계속된다.
    val readEnable = Input(Bool())

    val refillRequestValid = Output(Bool())
    val refillRequestReady = Input(Bool())
    val refillRequestBytes = Output(UInt(localByteCountWidth.W))
    val refillRequestGroupIndex = Output(UInt(groupIndexWidth.W))
    val refillRequestStartsNewGroup = Output(Bool())
    val refillRequestAllowsOverwrite = Output(Bool())
    val refillRequestContextId = Output(UInt(contextIdWidth.W))
    // AG가 groupIndex를 나눗셈으로 복원할 필요 없이 row/pass를 직접 받는다.
    val refillRequestRowIndex = Output(UInt(countWidth.W))
    val refillRequestRowPassIndex = Output(UInt(countWidth.W))
    val prefetchEligible = Output(Bool())

    val memoryDataValid = Input(Bool())
    val memoryDataReady = Output(Bool())
    val memoryData = Input(UInt(512.W))
    val memoryLaneValidMask = Input(UInt(4.W))
    val memoryChunkLast = Input(Bool())
    val memoryStreamLast = Input(Bool())
    val memoryContextId = Input(UInt(contextIdWidth.W))

    // Compact일 때 ZeroPadder가 실제 CU step에 맞춰 ready를 제공한다.
    // 별도 wall-clock 분주기나 padding zero 재출력은 두지 않는다.
    val computeData = Output(UInt(128.W))
    val computeDataValid = Output(Bool())
    val computeDataReady = Input(Bool())
    val computeDataLast = Output(Bool())
    val operationDone = Output(Bool())
    // GEMM row marker다. VPU_DIRECT에서는 두 marker와 index를 사용하지 않는다.
    val rowPassDone = Output(Bool())
    val inputRowDone = Output(Bool())
    val rowPassIndex = Output(UInt(countWidth.W))
    val inputRowIndex = Output(UInt(countWidth.W))

    val initialReady = Output(Bool())
    val hungry = Output(Bool())
    val starving = Output(Bool())
    val impending = Output(Bool())
    val controllerState = Output(InputBufferControllerState())
    // 현재 소비 row의 unique fill 완료다. 다음 row descriptor의 상태와 구분한다.
    val rowCacheReady = Output(Bool())
    val supplyStreamComplete = Output(Bool())
    val fillRowIndex = Output(UInt(countWidth.W))
    val freeBytes = Output(UInt(localByteCountWidth.W))
    val full = Output(Bool())
    val refillPending = Output(Bool())
  })

  val context = Module(new InputBufferController(contextIdWidth, payloadByteWidth, countWidth))
  val core = Module(new CircularBufferCore(
    contextIdWidth = contextIdWidth,
    groupIndexWidth = groupIndexWidth,
    replayCountWidth = countWidth,
    userTagWidth = 1,
    enableGroupPrefill = true
  ))
  context.io.contextStart := io.contextStart
  context.io.config := io.config
  context.io.softReset := io.softReset
  io.contextReady := context.io.contextReady
  io.configValid := context.io.configValid
  io.contextAccepted := context.io.contextAccepted
  io.contextActive := context.io.contextActive
  io.contextDone := context.io.contextDone

  val config = context.io.activeConfig
  val isGemm = config.operationMode === InputBufferOperationMode.GEMM
  val isCache = config.reuseMode === InputBufferReuseMode.LOCAL_ROW_CACHE
  val enabled = config.bufferEnable
  val computeStreamEnabled = context.io.computeStreamEnabled && !context.io.computeComplete
  val clear = reset.asBool || context.io.dataPathClear
  val rowBytes = Mux(isGemm, context.io.inputRowBytes, config.vectorPayloadBytes.pad(rowByteWidth))
  val rowCount = Mux(isGemm, config.inputRowCount, 1.U(countWidth.W))
  val passCount = Mux(isGemm, config.rowReplayCount, 1.U(countWidth.W))

  // 실제 소비가 진행할 때만 변하는 상태다. SRAM read 발행으로 전진시키지 않는다.
  val inputRowIndex = RegInit(0.U(countWidth.W))
  val rowPassIndex = RegInit(0.U(countWidth.W))
  val rowPassBytesConsumed = RegInit(0.U(rowByteWidth.W))
  val consumeGroupIndex = RegInit(0.U(groupIndexWidth.W))
  val isFinalRowPass = rowPassIndex +& 1.U === passCount
  val isLastInputRow = inputRowIndex +& 1.U === rowCount

  // 공급은 소비보다 앞설 수 있다. CACHE에서는 다음 row 하나까지만 허용한다.
  val fillRowIndex = RegInit(0.U(countWidth.W))
  val fillPassIndex = RegInit(0.U(countWidth.W))
  val supplyGroupIndex = RegInit(0.U(groupIndexWidth.W))
  val requestedBytesThisGroup = RegInit(0.U(rowByteWidth.W))
  val allRequestsAccepted = RegInit(false.B)
  val supplyStreamComplete = RegInit(false.B)
  val initialChunkReady = RegInit(false.B)
  val receivedRowCount = RegInit(0.U((countWidth + 1).W))

  // Core의 cache descriptor는 한 벌이다. 마지막 pass에서는 이전 row를
  // STREAM처럼 반환할 수 있으므로 다음 row로 descriptor를 넘겨도 안전하다.
  val cacheConfigured = RegInit(false.B)
  val configuredCacheRow = RegInit(0.U(countWidth.W))
  val fillRowAllowed = !isCache || fillRowIndex === inputRowIndex ||
    (isFinalRowPass && inputRowIndex +& 1.U === fillRowIndex)
  val cacheSetupNeeded = isCache && (!cacheConfigured || configuredCacheRow =/= fillRowIndex)
  val modeNeedsMoreSupply = computeStreamEnabled && !allRequestsAccepted &&
    !supplyStreamComplete && fillRowAllowed

  core.io.contextId := config.contextId
  // UB는 다음 context를 선행 수신하지 않는다. 안전한 context 수락/취소 때만 비운다.
  core.io.softReset := context.io.dataPathClear
  core.io.cacheGroup.valid := !clear && modeNeedsMoreSupply && cacheSetupNeeded
  core.io.cacheGroup.bits.contextId := config.contextId
  core.io.cacheGroup.bits.payloadBytes := rowBytes(localByteCountWidth - 1, 0)
  core.io.cacheGroup.bits.replayCount := passCount
  core.io.cacheGroup.bits.groupIndex := fillRowIndex.pad(groupIndexWidth)

  val remainingBytesThisGroup = rowBytes - requestedBytesThisGroup
  val requestBytes = Mux(remainingBytesThisGroup > maxRefillBytes.U,
    maxRefillBytes.U(localByteCountWidth.W), remainingBytesThisGroup(localByteCountWidth - 1, 0))
  val requestEndsGroup = remainingBytesThisGroup <= maxRefillBytes.U
  val requestEndsRow = requestEndsGroup && (isCache || fillPassIndex +& 1.U === passCount)
  val requestEndsSupply = requestEndsRow && fillRowIndex +& 1.U === rowCount
  val requestCandidate = !clear && enabled && modeNeedsMoreSupply &&
    !cacheSetupNeeded && remainingBytesThisGroup =/= 0.U

  // AG grant와 local entry/byte 예약을 원자적으로 수락한다.
  io.refillRequestValid := requestCandidate && core.io.reserveRefill.ready
  core.io.reserveRefill.valid := requestCandidate && io.refillRequestReady
  core.io.reserveRefill.bits.payloadBytes := requestBytes
  core.io.reserveRefill.bits.streaming := false.B
  core.io.reserveRefill.bits.contextId := config.contextId
  core.io.reserveRefill.bits.userTag := !isGemm
  core.io.reserveRefill.bits.groupIndex := supplyGroupIndex
  core.io.reserveRefill.bits.lastInGroup := requestEndsGroup
  val refillFire = io.refillRequestValid && io.refillRequestReady

  io.refillRequestBytes := requestBytes
  io.refillRequestGroupIndex := supplyGroupIndex
  io.refillRequestStartsNewGroup := requestedBytesThisGroup === 0.U
  io.refillRequestContextId := config.contextId
  io.refillRequestRowIndex := fillRowIndex
  io.refillRequestRowPassIndex := Mux(isCache, 0.U, fillPassIndex)
  // 새 row의 IB rolling-region 교체를 요청할 수 있다는 뜻이다.
  // 실제 파괴/epoch 교체 허가는 AG/IB가 남은 reader와 backing을 확인해 결정한다.
  io.refillRequestAllowsOverwrite := requestedBytesThisGroup === 0.U &&
    fillRowIndex =/= 0.U && (isCache || fillPassIndex === 0.U)
  io.prefetchEligible := io.refillRequestValid

  // Outstanding은 logical refill 하나이며 그 요청의 끝 의미를 보관한다.
  val refillBytesRemaining = RegInit(0.U(localByteCountWidth.W))
  val activeRefillEndsRow = RegInit(false.B)
  val activeRefillEndsSupply = RegInit(false.B)
  core.io.memoryDataValid := io.memoryDataValid
  core.io.memoryData := io.memoryData
  core.io.memoryLaneValidMask := io.memoryLaneValidMask
  core.io.memoryChunkLast := io.memoryChunkLast
  core.io.memoryStreamLast := io.memoryStreamLast
  core.io.memoryContextId := io.memoryContextId
  core.io.memoryUserTag := !isGemm
  io.memoryDataReady := core.io.memoryDataReady
  val memoryWriteFire = io.memoryDataValid && io.memoryDataReady

  core.io.readEnable := io.readEnable && computeStreamEnabled
  core.io.output.ready := io.computeDataReady && computeStreamEnabled
  io.computeData := core.io.output.bits.data
  io.computeDataValid := core.io.output.valid && computeStreamEnabled
  val computeReadFire = io.computeDataValid && io.computeDataReady
  val rowPassBytesConsumedNext = rowPassBytesConsumed +& 16.U
  val passFinished = computeReadFire && core.io.output.bits.lastInGroup
  val finalOutput = core.io.output.bits.lastInGroup && isFinalRowPass && isLastInputRow
  io.computeDataLast := io.computeDataValid && finalOutput
  io.operationDone := computeReadFire && finalOutput
  io.rowPassDone := isGemm && passFinished
  io.inputRowDone := isGemm && passFinished && isFinalRowPass
  io.rowPassIndex := rowPassIndex
  io.inputRowIndex := inputRowIndex
  io.fillRowIndex := fillRowIndex

  context.io.pathStatus.refillPending := core.io.refillPending
  context.io.pathStatus.readPending := !core.io.readPipelineIdle
  context.io.pathStatus.operationDone := io.operationDone

  val readableBytesThisPass = core.io.readiness.readableBytesThisPass
  val nextRequiredChunkReady = core.io.readiness.nextRequiredChunkReady
  val safeContinuationReady = nextRequiredChunkReady
  // 현재 row의 남은 사용분이 모두 공급됐으면 그 tail을 threshold로 막지 않는다.
  // 다음 row가 아직 없으면 실제 row 전환 뒤 새 readable 상태로 기다린다.
  val allRemainingComputePayloadReady = receivedRowCount > inputRowIndex
  val requiredPayloadAvailable = io.computeDataValid
  val activeImpendingThresholdBytes = context.io.activeImpendingThresholdBytes
  val refillAllowed = io.refillRequestValid
  io.initialReady := !context.io.computeStreamEnabled || initialChunkReady
  io.hungry := refillAllowed && (!initialChunkReady || !nextRequiredChunkReady ||
    readableBytesThisPass <= maxRefillBytes.U)
  io.starving := computeStreamEnabled && !requiredPayloadAvailable
  io.impending := computeStreamEnabled && (!initialChunkReady ||
    (!allRemainingComputePayloadReady && readableBytesThisPass <= activeImpendingThresholdBytes &&
      !safeContinuationReady))
  io.rowCacheReady := isCache && receivedRowCount > inputRowIndex
  io.supplyStreamComplete := supplyStreamComplete
  io.freeBytes := core.io.freeBytes
  io.full := core.io.full
  io.refillPending := core.io.refillPending

  val configuredComputeEnabled = config.bufferEnable && Mux(isGemm,
    config.inputRowCount =/= 0.U && config.reductionTileCount =/= 0.U && config.outputColumnCount =/= 0.U,
    config.vectorPayloadBytes =/= 0.U)
  io.controllerState := Mux(clear || !configuredComputeEnabled, InputBufferControllerState.DISABLED,
    Mux(context.io.computeComplete, InputBufferControllerState.DONE,
      Mux(!initialChunkReady, InputBufferControllerState.INITIAL_FILL,
        Mux(supplyStreamComplete, InputBufferControllerState.DRAINING, InputBufferControllerState.ACTIVE))))

  when(clear) {
    inputRowIndex := 0.U
    rowPassIndex := 0.U
    rowPassBytesConsumed := 0.U
    consumeGroupIndex := 0.U
    fillRowIndex := 0.U
    fillPassIndex := 0.U
    supplyGroupIndex := 0.U
    requestedBytesThisGroup := 0.U
    allRequestsAccepted := false.B
    supplyStreamComplete := false.B
    initialChunkReady := false.B
    receivedRowCount := 0.U
    cacheConfigured := false.B
    configuredCacheRow := 0.U
    refillBytesRemaining := 0.U
    activeRefillEndsRow := false.B
    activeRefillEndsSupply := false.B
  }.otherwise {
    when(core.io.cacheGroup.fire) {
      cacheConfigured := true.B
      configuredCacheRow := fillRowIndex
    }
    when(refillFire) {
      refillBytesRemaining := requestBytes
      activeRefillEndsRow := requestEndsRow
      activeRefillEndsSupply := requestEndsSupply
      when(requestEndsGroup) {
        requestedBytesThisGroup := 0.U
        when(requestEndsSupply) {
          allRequestsAccepted := true.B
        }.otherwise {
          supplyGroupIndex := supplyGroupIndex + 1.U
          when(requestEndsRow) {
            fillRowIndex := fillRowIndex + 1.U
            fillPassIndex := 0.U
          }.otherwise {
            fillPassIndex := fillPassIndex + 1.U
          }
        }
      }.otherwise {
        requestedBytesThisGroup := requestedBytesThisGroup + requestBytes
      }
    }.elsewhen(memoryWriteFire) {
      refillBytesRemaining := refillBytesRemaining - core.io.memoryPayloadBytes
    }
    when(memoryWriteFire && io.memoryChunkLast) {
      initialChunkReady := true.B
      when(activeRefillEndsRow) { receivedRowCount := receivedRowCount + 1.U }
    }
    when(memoryWriteFire && io.memoryStreamLast) { supplyStreamComplete := true.B }

    when(computeReadFire) {
      rowPassBytesConsumed := rowPassBytesConsumedNext
      when(passFinished) {
        rowPassBytesConsumed := 0.U
        when(isGemm && !io.operationDone) {
          consumeGroupIndex := consumeGroupIndex + 1.U
          when(isFinalRowPass) {
            inputRowIndex := inputRowIndex + 1.U
            rowPassIndex := 0.U
          }.otherwise {
            rowPassIndex := rowPassIndex + 1.U
          }
        }
      }
    }
  }

  when(!clear) {
    assert(refillFire === core.io.reserveRefill.fire, "UB AG grant must match local reservation")
    when(memoryWriteFire) {
      assert(core.io.memoryPayloadBytes <= refillBytesRemaining, "UB response exceeds the granted logical chunk")
      assert(io.memoryChunkLast === (core.io.memoryPayloadBytes === refillBytesRemaining),
        "UB logical chunk last must include exactly the requested payload")
      assert(io.memoryStreamLast === (io.memoryChunkLast && activeRefillEndsSupply),
        "UB supply last must match the final row/pass request")
    }
    when(io.computeDataValid) {
      assert(core.io.output.bits.contextId === config.contextId, "UB output context mismatch")
      assert(core.io.output.bits.userTag === (!isGemm).asUInt, "UB output operand kind mismatch")
      assert(core.io.output.bits.groupIndex === Mux(isCache, inputRowIndex.pad(groupIndexWidth), consumeGroupIndex),
        "UB output must follow the row/pass supply order")
      assert(core.io.output.bits.lastInGroup === (rowPassBytesConsumedNext === rowBytes),
        "UB row/pass boundary must match its actual payload length")
    }
    when(refillFire && isCache) {
      assert(fillRowAllowed, "UB next row may refill only during the current final pass")
    }
  }
}
