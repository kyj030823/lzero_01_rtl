package npu.core.memory

import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec
import scala.language.reflectiveCalls
import scala.util.Random

/** 공통 SRAM과 단일 read pipeline을 사용하는 LUT/weight 통합 검증. */
class WeightBufferLutSpec extends AnyFlatSpec with ChiselScalatestTester {
  behavior of "WeightBufferDataPath LUT streaming"

  private case class Scenario(
    lutBytes: Int,
    weightBytes: Int = 0,
    passes: Int = 1,
    cache: Boolean = false,
    vpu: Boolean = false,
    enabled: Boolean = true,
    constant: Boolean = false,
    creditWindow: Int = 4096,
    firstCreditWindow: Int = 0,
    randomStalls: Boolean = false,
    initialLutPause: Int = 0,
    holdLastLut: Int = 0,
    computeHoldAfterLut: Int = 0,
    waitForCacheFill: Boolean = false,
    requireOverlap: Boolean = false,
    requireEarlyOutput: Boolean = false,
    requirePrefixEntryLimit: Boolean = false,
    id: Int = 1
  )
  private case class Request(bytes: Int, group: Int, offset: Int, var sent: Int = 0)
  private def yes(x: Bool): Boolean = x.peek().litToBoolean
  private def lutWord(i: Int, id: Int): BigInt =
    (BigInt(0xa5) << 120) | (BigInt(id) << 104) | (BigInt(i) << 64) |
      (BigInt("1234567800000000", 16) + i)
  private def weightWord(i: Int, id: Int): BigInt =
    (BigInt(0x5a) << 120) | (BigInt(id) << 104) | (BigInt(i) << 64) |
      (BigInt("8765432100000000", 16) + i)

  private def driveConfig(d: WeightBufferDataPath, s: Scenario): Unit = {
    d.io.config.bufferEnable.poke(s.enabled.B)
    d.io.config.operationMode.poke(
      if (s.vpu) WeightBufferOperationMode.VPU_DIRECT else WeightBufferOperationMode.GEMM)
    d.io.config.reuseMode.poke(
      if (s.cache) WeightBufferReuseMode.LOCAL_WEIGHT_CACHE else WeightBufferReuseMode.STREAM)
    d.io.config.fusionEnable.poke(false.B)
    d.io.config.weightSet0Bytes.poke((if (s.vpu) 0 else s.weightBytes).U)
    d.io.config.weightSet1Bytes.poke(0.U)
    d.io.config.weightReplayCount.poke(s.passes.U)
    d.io.config.inputRowCount.poke(s.passes.U)
    d.io.config.reductionTileCount.poke((if (s.vpu) 0 else s.weightBytes / 256).U)
    d.io.config.outputColumnCount.poke((if (s.vpu || s.weightBytes == 0) 0 else 1).U)
    d.io.config.operand2PayloadBytes.poke((if (s.vpu) s.weightBytes else 0).U)
    d.io.config.constantOperandEnable.poke(s.constant.B)
    d.io.config.lutLoadEnable.poke((s.lutBytes > 0).B)
    d.io.config.lutPayloadBytes.poke(s.lutBytes.U)
    d.io.config.lutTargetEnableMask.poke(21.U)
    d.io.config.normalImpendingThresholdBytes.poke(128.U)
    d.io.config.contextId.poke(s.id.U)
  }

  private def idleMemory(d: WeightBufferDataPath): Unit = {
    d.io.memoryDataValid.poke(false.B)
    d.io.memoryData.poke(0.U)
    d.io.memoryLaneValidMask.poke(15.U)
    d.io.memoryChunkLast.poke(false.B)
    d.io.memoryStreamLast.poke(false.B)
    d.io.memoryContextId.poke(0.U)
    d.io.memoryDataKind.poke(WeightBufferDataKind.LUT)
  }

  private def initialize(d: WeightBufferDataPath): Unit = {
    d.clock.setTimeout(100000)
    driveConfig(d, Scenario(0))
    idleMemory(d)
    d.io.contextStart.poke(false.B)
    d.io.prefillStart.poke(false.B)
    d.io.softReset.poke(false.B)
    d.io.readEnable.poke(false.B)
    d.io.computeDataReady.poke(false.B)
    d.io.refillRequestReady.poke(false.B)
    d.io.lutCreditValid.poke(false.B)
    d.io.lutCreditBytes.poke(16.U)
    d.io.lutDataReady.poke(false.B)
    d.reset.poke(true.B)
    d.clock.step(2)
    d.reset.poke(false.B)
    d.clock.step()
    d.io.contextReady.expect(true.B)
    d.io.freeBytes.expect(16384.U)
  }

  private def begin(d: WeightBufferDataPath, s: Scenario): Unit = {
    driveConfig(d, s)
    idleMemory(d)
    d.io.lutCreditValid.poke(false.B)
    d.io.refillRequestReady.poke(false.B)
    d.io.readEnable.poke(false.B)
    d.io.computeDataReady.poke(false.B)
    d.io.lutDataReady.poke(false.B)
    d.io.contextStart.poke(true.B)
    d.io.configValid.expect(true.B)
    d.io.contextReady.expect(true.B)
    d.io.contextAccepted.expect(true.B)
    d.clock.step()
    d.io.contextStart.poke(false.B)
    d.io.contextActive.expect(true.B)
    d.io.contextReady.expect(false.B)
  }

  private def runScenario(d: WeightBufferDataPath, s: Scenario): Unit = {
    begin(d, s)
    val random = new Random(0x4c5554L + s.id)
    val computeEnabled = s.enabled && !(s.vpu && s.constant) && s.weightBytes > 0
    val passes = if (s.vpu) 1 else s.passes
    val supplyPasses = if (s.cache) 1 else passes
    val totalWeightInput = if (computeEnabled) s.weightBytes * supplyPasses else 0
    val totalWeightOutput = if (computeEnabled) s.weightBytes / 16 * passes else 0
    var lutReceived = 0
    var lutOutputs = 0
    var creditsGranted = 0
    var creditRemaining = 0
    var creditOffer: Option[Int] = None
    var active: Option[Request] = None
    var nextGroup = 0
    var nextOffset = 0
    var weightReceived = 0
    var weightOutputs = 0
    var weightReserved = 0
    var weightReclaimed = 0
    var weightChunksReceived = 0
    var requestCount = 0
    var receivePulses = 0
    var streamPulses = 0
    var operationPulses = 0
    var passPulses = 0
    var contextPulses = 0
    var receiveCycle = -1
    var streamCycle = if (s.lutBytes == 0) -s.computeHoldAfterLut else -1
    var firstLutReceivedBytes = -1
    var overlappedWeightInput = false
    var handoffWithOutput = false
    var smallFreeCredit = false
    var normalInputWhileFull = false
    var prefixEntryBlocked = false
    var heldLut: Option[(BigInt, Boolean)] = None
    var heldCompute: Option[(BigInt, Boolean, BigInt)] = None
    var heldRequest: Option[(BigInt, BigInt, Boolean)] = None
    var heldMemory = false
    var lastLutPauseCycles = 0
    var ended = false
    var cycles = 0

    while (!ended && cycles < 80000) {
      val free = 16384 - lutReceived + lutOutputs * 16 - weightReceived +
        weightReclaimed - creditRemaining - weightReserved
      assert(free >= 0 && free <= 16384)
      val lutFinished = lutOutputs * 16 == s.lutBytes
      val canCompute = lutFinished && cycles >= streamCycle + s.computeHoldAfterLut &&
        (!s.waitForCacheFill || weightReceived == totalWeightInput)
      d.io.readEnable.poke(canCompute.B)
      d.io.computeDataReady.poke((canCompute && (!s.randomStalls || random.nextInt(5) != 0)).B)
      val holdLutEnd = lutOutputs == s.lutBytes / 16 - 1 && lastLutPauseCycles < s.holdLastLut
      d.io.lutDataReady.poke((cycles >= s.initialLutPause && !holdLutEnd &&
        (!s.randomStalls || random.nextInt(4) != 0)).B)
      d.io.refillRequestReady.poke((!s.randomStalls || random.nextInt(4) != 0).B)

      if (creditOffer.isEmpty && creditsGranted < s.lutBytes &&
        (!s.randomStalls || random.nextInt(4) != 0)) {
        val window = if (creditsGranted == 0 && s.firstCreditWindow > 0)
          s.firstCreditWindow else s.creditWindow
        creditOffer = Some(math.min(window, s.lutBytes - creditsGranted))
      }
      d.io.lutCreditValid.poke(creditOffer.nonEmpty.B)
      d.io.lutCreditBytes.poke(creditOffer.getOrElse(16).U)

      var memoryLut = false
      var memoryBytes = 0
      if (lutReceived < s.lutBytes && creditRemaining > 0) {
        memoryLut = true
        memoryBytes = math.min(64, math.min(creditRemaining, s.lutBytes - lutReceived))
        if (!heldMemory) heldMemory = !s.randomStalls || random.nextInt(4) != 0
        val lanes = memoryBytes / 16
        val data = (0 until lanes).foldLeft(BigInt(0))((acc, lane) =>
          acc | (lutWord(lutReceived / 16 + lane, s.id) << (lane * 128)))
        d.io.memoryDataValid.poke(heldMemory.B)
        d.io.memoryData.poke(data.U)
        d.io.memoryLaneValidMask.poke(((1 << lanes) - 1).U)
        d.io.memoryChunkLast.poke((lutReceived + memoryBytes == s.lutBytes).B)
        d.io.memoryStreamLast.poke((lutReceived + memoryBytes == s.lutBytes).B)
        d.io.memoryContextId.poke(s.id.U)
        d.io.memoryDataKind.poke(WeightBufferDataKind.LUT)
      } else active match {
        case Some(r) =>
          memoryBytes = math.min(64, r.bytes - r.sent)
          if (!heldMemory) heldMemory = !s.randomStalls || random.nextInt(4) != 0
          val lanes = memoryBytes / 16
          val data = (0 until lanes).foldLeft(BigInt(0))((acc, lane) =>
            acc | (weightWord((r.offset + r.sent) / 16 + lane, s.id) << (lane * 128)))
          d.io.memoryDataValid.poke(heldMemory.B)
          d.io.memoryData.poke(data.U)
          d.io.memoryLaneValidMask.poke(((1 << lanes) - 1).U)
          val chunkLast = r.sent + memoryBytes == r.bytes
          d.io.memoryChunkLast.poke(chunkLast.B)
          d.io.memoryStreamLast.poke((chunkLast && r.offset + r.bytes == s.weightBytes &&
            r.group == supplyPasses - 1).B)
          d.io.memoryContextId.poke(s.id.U)
          d.io.memoryDataKind.poke(if (s.vpu) WeightBufferDataKind.VECTOR_OPERAND else WeightBufferDataKind.WEIGHT)
        case None =>
          idleMemory(d)
          heldMemory = false
      }

      d.io.freeBytes.expect(free.U)
      d.io.full.expect((free < 4096).B)
      d.io.refillPending.expect((creditRemaining > 0 || active.nonEmpty).B)
      d.io.initialReady.expect((!computeEnabled || weightChunksReceived > 0).B)
      d.io.weightCacheReady.expect((computeEnabled && s.cache && weightReceived == s.weightBytes).B)
      d.io.weightSupplyComplete.expect((computeEnabled && weightReceived == totalWeightInput).B)
      d.io.lutTargetEnableMask.expect(21.U)
      d.io.receivePhase.expect(
        if (lutReceived < s.lutBytes) WeightBufferReceivePhase.LUT_RECEIVE
        else if (computeEnabled && weightReceived < totalWeightInput) WeightBufferReceivePhase.COMPUTE_RECEIVE
        else WeightBufferReceivePhase.RECEIVE_DONE)
      d.io.readPhase.expect(
        if (!lutFinished) WeightBufferReadPhase.LUT_STREAM
        else if (computeEnabled && weightOutputs < totalWeightOutput) WeightBufferReadPhase.COMPUTE_STREAM
        else WeightBufferReadPhase.READ_DONE)
      if (lutReceived < s.lutBytes) d.io.refillRequestValid.expect(false.B)
      if (!lutFinished) d.io.computeDataValid.expect(false.B)

      if (s.requirePrefixEntryLimit && !lutFinished && requestCount == 3 && active.isEmpty) {
        assert(free >= 4096, "entry-budget case must have enough byte space")
        d.io.full.expect(false.B)
        d.io.refillRequestValid.expect(false.B)
        prefixEntryBlocked = true
      }

      val creditFire = yes(d.io.lutCreditValid) && yes(d.io.lutCreditReady)
      val reqValid = yes(d.io.refillRequestValid)
      val reqFire = reqValid && yes(d.io.refillRequestReady)
      val memFire = yes(d.io.memoryDataValid) && yes(d.io.memoryDataReady)
      if (yes(d.io.memoryDataValid)) d.io.memoryDataReady.expect(true.B)
      val lutValid = yes(d.io.lutDataValid)
      val lutFire = lutValid && yes(d.io.lutDataReady)
      val computeValid = yes(d.io.computeDataValid)
      val computeFire = computeValid && yes(d.io.computeDataReady)
      assert(!(reqFire && memFire), "new normal grant must not overlap the previous response")

      heldLut.foreach { case (data, last) =>
        d.io.lutDataValid.expect(true.B)
        d.io.lutData.expect(data.U)
        d.io.lutDataLast.expect(last.B)
      }
      if (lutValid) {
        assert(lutOutputs < s.lutBytes / 16)
        assert((lutOutputs + 1) * 16 <= lutReceived, "read exceeded committed LUT bytes")
        d.io.lutData.expect(lutWord(lutOutputs, s.id).U)
        d.io.lutDataLast.expect((lutOutputs == s.lutBytes / 16 - 1).B)
      }
      heldLut = if (lutValid && !yes(d.io.lutDataReady))
        Some((d.io.lutData.peek().litValue, yes(d.io.lutDataLast))) else None
      if (holdLutEnd && lutValid) lastLutPauseCycles += 1
      heldCompute.foreach { case (data, last, pass) =>
        d.io.computeDataValid.expect(true.B)
        d.io.computeData.expect(data.U)
        d.io.computeDataLast.expect(last.B)
        d.io.passIndex.expect(pass.U)
      }
      if (computeValid) {
        assert(computeEnabled && weightOutputs < totalWeightOutput)
        val local = weightOutputs % (s.weightBytes / 16)
        d.io.computeData.expect(weightWord(local, s.id).U)
        d.io.computeDataLast.expect((weightOutputs == totalWeightOutput - 1).B)
        d.io.passIndex.expect((weightOutputs / (s.weightBytes / 16)).U)
      }
      heldCompute = if (computeValid && !yes(d.io.computeDataReady))
        Some((d.io.computeData.peek().litValue, yes(d.io.computeDataLast), d.io.passIndex.peek().litValue)) else None
      heldRequest.foreach { case (bytes, group, starts) =>
        d.io.refillRequestValid.expect(true.B)
        d.io.refillRequestBytes.expect(bytes.U)
        d.io.refillRequestGroupIndex.expect(group.U)
        d.io.refillRequestStartsNewGroup.expect(starts.B)
      }
      heldRequest = if (reqValid && !yes(d.io.refillRequestReady))
        Some((d.io.refillRequestBytes.peek().litValue, d.io.refillRequestGroupIndex.peek().litValue,
          yes(d.io.refillRequestStartsNewGroup))) else None

      val receiveDone = memFire && memoryLut && lutReceived + memoryBytes == s.lutBytes
      val streamDone = lutFire && lutOutputs == s.lutBytes / 16 - 1
      val operationDone = computeFire && weightOutputs == totalWeightOutput - 1
      val passDone = computeFire && (weightOutputs + 1) % (s.weightBytes / 16) == 0
      d.io.lutReceiveDone.expect(receiveDone.B)
      d.io.lutStreamDone.expect(streamDone.B)
      d.io.operationDone.expect(operationDone.B)
      d.io.passDone.expect(passDone.B)

      if (creditFire) {
        val bytes = creditOffer.get
        assert(bytes <= free && creditsGranted + bytes <= s.lutBytes)
        if (free < 4096) smallFreeCredit = true
        creditRemaining += bytes
        creditsGranted += bytes
        creditOffer = None
      }
      if (reqFire) {
        assert(lutReceived == s.lutBytes && active.isEmpty && computeEnabled)
        val bytes = math.min(4096, s.weightBytes - nextOffset)
        d.io.refillRequestBytes.expect(bytes.U)
        d.io.refillRequestGroupIndex.expect(nextGroup.U)
        d.io.refillRequestStartsNewGroup.expect((nextOffset == 0).B)
        d.io.refillRequestContextId.expect(s.id.U)
        d.io.refillRequestDataKind.expect(
          if (s.vpu) WeightBufferDataKind.VECTOR_OPERAND else WeightBufferDataKind.WEIGHT)
        active = Some(Request(bytes, nextGroup, nextOffset))
        weightReserved += bytes
        requestCount += 1
        nextOffset += bytes
        if (nextOffset == s.weightBytes) { nextOffset = 0; nextGroup += 1 }
      }
      if (memFire) {
        heldMemory = false
        if (memoryLut) {
          creditRemaining -= memoryBytes
          lutReceived += memoryBytes
        } else {
          val r = active.get
          r.sent += memoryBytes
          weightReserved -= memoryBytes
          weightReceived += memoryBytes
          if (!lutFinished) overlappedWeightInput = true
          if (free < 4096) normalInputWhileFull = true
          if (r.sent == r.bytes) { active = None; weightChunksReceived += 1 }
        }
      }
      if (lutFire) {
        if (firstLutReceivedBytes < 0) firstLutReceivedBytes = lutReceived
        lutOutputs += 1
      }
      if (computeFire) {
        val perPass = s.weightBytes / 16
        val localByte = (weightOutputs % perPass) * 16
        val chunkLast = (localByte + 16) % 4096 == 0 || localByte + 16 == s.weightBytes
        val finalPass = weightOutputs / perPass == passes - 1
        if (chunkLast && (!s.cache || finalPass))
          weightReclaimed += math.min(4096, s.weightBytes - localByte / 4096 * 4096)
        weightOutputs += 1
      }
      if (receiveDone) { receivePulses += 1; receiveCycle = cycles; if (lutFire) handoffWithOutput = true }
      if (streamDone) { streamPulses += 1; streamCycle = cycles }
      if (operationDone) operationPulses += 1
      if (passDone) passPulses += 1
      if (yes(d.io.contextDone)) {
        assert(lutReceived == s.lutBytes && lutOutputs * 16 == s.lutBytes)
        assert(weightReceived == totalWeightInput && weightOutputs == totalWeightOutput)
        assert(creditRemaining == 0 && weightReserved == 0 && active.isEmpty)
        contextPulses += 1
        ended = true
      }
      d.clock.step()
      cycles += 1
    }
    assert(ended, "LUT/weight scenario timed out")
    assert(receivePulses == (if (s.lutBytes > 0) 1 else 0))
    assert(streamPulses == receivePulses && contextPulses == 1)
    assert(operationPulses == (if (computeEnabled) 1 else 0))
    assert(passPulses == (if (computeEnabled) passes else 0))
    assert(creditsGranted == s.lutBytes && weightReclaimed == totalWeightInput)
    if (s.requireOverlap) assert(overlappedWeightInput, "weight input did not overlap LUT output")
    if (s.requirePrefixEntryLimit)
      assert(prefixEntryBlocked, "LUT entry plus three normal entries was not exercised")
    if (s.requireEarlyOutput) assert(firstLutReceivedBytes < s.lutBytes, "LUT output waited for full reception")
    if (s.initialLutPause > 0 && s.lutBytes > 16384)
      assert(smallFreeCredit, "small LUT credit did not proceed while normal full was asserted")
    idleMemory(d)
    d.io.lutCreditValid.poke(false.B)
    d.io.refillRequestReady.poke(false.B)
    d.io.contextActive.expect(false.B)
    d.io.contextReady.expect(true.B)
    d.io.freeBytes.expect(16384.U)
    d.io.lutDataValid.expect(false.B)
    d.io.computeDataValid.expect(false.B)
    d.clock.step(2)
    d.io.lutReceiveDone.expect(false.B)
    d.io.lutStreamDone.expect(false.B)
    d.io.operationDone.expect(false.B)
    println("LUT CASE: lut=" + s.lutBytes + "B weight=" + s.weightBytes + "B passes=" + passes +
      " cache=" + s.cache + " cycles=" + cycles + " LUT beats=" + lutOutputs +
      " compute beats=" + weightOutputs + " weight requests=" + requestCount +
      " overlap=" + overlappedWeightInput + " handoff/output=" + handoffWithOutput +
      " reserved-response-while-full=" + normalInputWhileFull)
  }

  it should "stream LUT tail masks and restart without stale data" in {
    test(new WeightBufferDataPath) { d =>
      initialize(d)
      for ((bytes, index) <- Seq(16, 32, 48, 80).zipWithIndex)
        runScenario(d, Scenario(bytes, enabled = false, creditWindow = 48,
          randomStalls = true, holdLastLut = 3, id = index + 1))
    }
  }

  it should "overlap LUT output with a packed non-64B-aligned cache and replay weight only" taggedAs WbExtendedLut in {
    test(new WeightBufferDataPath) { d =>
      initialize(d)
      runScenario(d, Scenario(80, weightBytes = 12288, passes = 3, cache = true,
        holdLastLut = 8, computeHoldAfterLut = 80, waitForCacheFill = true,
        requireOverlap = true, id = 11))
    }
  }

  it should "start programming before all LUT data arrives while compute is held" taggedAs WbExtendedLut in {
    test(new WeightBufferDataPath) { d =>
      initialize(d)
      runScenario(d, Scenario(4096, weightBytes = 16384, passes = 2, cache = true,
        randomStalls = true, computeHoldAfterLut = 80, waitForCacheFill = true,
        requireOverlap = true, requireEarlyOutput = true, id = 12))
    }
  }

  it should "stream a LUT beyond both ring and extended-pointer capacity with repeated credit" taggedAs WbExtendedLut in {
    test(new WeightBufferDataPath) { d =>
      initialize(d)
      runScenario(d, Scenario(40 * 1024 + 48, weightBytes = 16384, passes = 2, cache = true,
        firstCreditWindow = 16384, creditWindow = 64, initialLutPause = 300,
        randomStalls = true, holdLastLut = 5, computeHoldAfterLut = 16,
        requireOverlap = true, requireEarlyOutput = true, id = 13))
    }
  }

  it should "respect the common four-entry budget while LUT output is held" taggedAs WbExtendedLut in {
    test(new WeightBufferDataPath) { d =>
      initialize(d)
      runScenario(d, Scenario(4096, weightBytes = 256, passes = 8,
        initialLutPause = 128, requireOverlap = true, requirePrefixEntryLimit = true, id = 16))
    }
  }

  it should "keep STREAM supply repeats and VPU operand tails separate from LUT" taggedAs WbExtendedLut in {
    test(new WeightBufferDataPath) { d =>
      initialize(d)
      runScenario(d, Scenario(48, weightBytes = 20480, passes = 2,
        randomStalls = true, holdLastLut = 6, requireOverlap = true, id = 14))
      runScenario(d, Scenario(80, weightBytes = 16384 + 80, vpu = true,
        randomStalls = true, holdLastLut = 6, requireOverlap = true, id = 15))
    }
  }

  it should "retain no-LUT, constant and zero-length behavior after a LUT context" taggedAs WbExtendedLut in {
    test(new WeightBufferDataPath) { d =>
      initialize(d)
      runScenario(d, Scenario(112, weightBytes = 80, vpu = true, constant = true, id = 21))
      runScenario(d, Scenario(0, weightBytes = 4096, passes = 2, cache = true, id = 22))
      runScenario(d, Scenario(0, weightBytes = 80, vpu = true, id = 23))
      runScenario(d, Scenario(0, weightBytes = 0, id = 24))
    }
  }

  it should "reject uncredited, over-credited, stale, wrong-kind and sparse-mask input without progress" in {
    test(new WeightBufferDataPath) { d =>
      initialize(d)
      begin(d, Scenario(80, enabled = false, id = 31))
      d.io.memoryDataValid.poke(true.B)
      d.io.memoryData.poke((0 until 4).foldLeft(BigInt(0))((a, lane) =>
        a | (lutWord(lane, 31) << (lane * 128))).U)
      d.io.memoryLaneValidMask.poke(15.U)
      d.io.memoryContextId.poke(31.U)
      d.io.memoryDataKind.poke(WeightBufferDataKind.LUT)
      d.io.memoryDataReady.expect(false.B)
      d.clock.step(3)
      d.io.freeBytes.expect(16384.U)
      d.io.lutCreditValid.poke(true.B)
      d.io.lutCreditBytes.poke(96.U)
      d.io.lutCreditReady.expect(false.B)
      d.clock.step(2)
      d.io.freeBytes.expect(16384.U)
      d.io.lutCreditBytes.poke(64.U)
      d.io.lutCreditReady.expect(true.B)
      d.clock.step()
      d.io.lutCreditValid.poke(false.B)
      d.io.memoryContextId.poke(30.U)
      d.io.memoryDataReady.expect(false.B)
      d.clock.step()
      d.io.memoryContextId.poke(31.U)
      d.io.memoryDataKind.poke(WeightBufferDataKind.WEIGHT)
      d.io.memoryDataReady.expect(false.B)
      d.clock.step()
      d.io.memoryDataKind.poke(WeightBufferDataKind.LUT)
      for (mask <- Seq(0, 5, 10)) {
        d.io.memoryLaneValidMask.poke(mask.U)
        d.io.memoryDataReady.expect(false.B)
        d.clock.step()
      }
      d.io.memoryLaneValidMask.poke(15.U)
      d.io.memoryDataReady.expect(true.B)
      d.clock.step()
      d.io.memoryLaneValidMask.poke(1.U)
      d.io.memoryData.poke(lutWord(4, 31).U)
      d.io.memoryChunkLast.poke(true.B)
      d.io.memoryStreamLast.poke(true.B)
      d.io.memoryDataReady.expect(false.B)
      d.io.lutCreditValid.poke(true.B)
      d.io.lutCreditBytes.poke(16.U)
      d.io.lutCreditReady.expect(true.B)
      d.clock.step()
      d.io.lutCreditValid.poke(false.B)
      d.io.memoryDataReady.expect(true.B)
      d.io.lutReceiveDone.expect(true.B)
      d.clock.step()
      d.io.memoryDataReady.expect(false.B)
      d.io.lutCreditValid.poke(true.B)
      d.io.lutCreditBytes.poke(16.U)
      d.io.lutCreditReady.expect(false.B)
      d.clock.step()
      idleMemory(d)
      d.io.lutCreditValid.poke(false.B)
      d.io.lutDataReady.poke(true.B)
      var count = 0
      for (_ <- 0 until 12) {
        if (yes(d.io.lutDataValid)) {
          d.io.lutData.expect(lutWord(count, 31).U)
          d.io.lutDataLast.expect((count == 4).B)
          d.io.lutStreamDone.expect((count == 4).B)
          count += 1
        }
        d.io.operationDone.expect(false.B)
        d.clock.step()
      }
      assert(count == 5)
      d.io.contextReady.expect(true.B)
      d.io.freeBytes.expect(16384.U)
    }
  }

  it should "cancel a partially received LUT after credits and read responses drain" in {
    test(new WeightBufferDataPath) { d =>
      initialize(d)
      begin(d, Scenario(256, enabled = false, id = 41))
      d.io.lutCreditValid.poke(true.B)
      d.io.lutCreditBytes.poke(64.U)
      d.clock.step()
      d.io.lutCreditValid.poke(false.B)
      d.io.memoryDataValid.poke(true.B)
      d.io.memoryDataKind.poke(WeightBufferDataKind.LUT)
      d.io.memoryContextId.poke(41.U)
      d.io.memoryData.poke((0 until 4).foldLeft(BigInt(0))((a, lane) =>
        a | (lutWord(lane, 41) << (lane * 128))).U)
      d.io.memoryDataReady.expect(true.B)
      d.clock.step()
      idleMemory(d)
      d.io.lutDataReady.poke(true.B)
      var count = 0
      for (_ <- 0 until 10) {
        if (yes(d.io.lutDataValid)) {
          d.io.lutData.expect(lutWord(count, 41).U)
          d.io.lutDataLast.expect(false.B)
          count += 1
        }
        d.io.lutReceiveDone.expect(false.B)
        d.io.lutStreamDone.expect(false.B)
        d.clock.step()
      }
      assert(count == 4)
      d.io.contextActive.expect(true.B)
      d.io.refillPending.expect(false.B)
      d.io.softReset.poke(true.B)
      d.clock.step()
      d.io.softReset.poke(false.B)
      d.io.contextActive.expect(false.B)
      d.io.contextReady.expect(true.B)
      d.io.freeBytes.expect(16384.U)
      runScenario(d, Scenario(48, weightBytes = 256, id = 42))
    }
  }

  it should "reject softReset while a LUT credit still promises incoming data" in {
    assertThrows[ChiselAssertionError] {
      test(new WeightBufferDataPath) { d =>
        initialize(d)
        begin(d, Scenario(80, enabled = false, id = 51))
        d.io.lutCreditValid.poke(true.B)
        d.io.lutCreditBytes.poke(80.U)
        d.clock.step()
        d.io.lutCreditValid.poke(false.B)
        d.io.refillPending.expect(true.B)
        d.io.softReset.poke(true.B)
        d.clock.step()
      }
    }
  }

  for (bytes <- Seq(0, 17, 16400)) {
    it should ("assert for an invalid LUT credit window of " + bytes + " bytes") in {
      assertThrows[ChiselAssertionError] {
        test(new WeightBufferDataPath) { d =>
          initialize(d)
          begin(d, Scenario(32768, enabled = false, id = 52))
          d.io.lutCreditValid.poke(true.B)
          d.io.lutCreditBytes.poke(bytes.U)
          d.io.lutCreditReady.expect(false.B)
          d.clock.step()
        }
      }
    }
  }
}
