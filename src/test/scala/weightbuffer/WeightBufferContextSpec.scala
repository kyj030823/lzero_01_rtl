package npu.core.memory

import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec
import scala.language.reflectiveCalls
import scala.util.Random

/** WB v3 명세의 설정/context 계약을 확인한다.
  * 데이터 경로는 아직 연결 전이므로 실제 데이터 수신 대신 내부 상태 입력을 구동한다.
  */
class WeightBufferContextSpec extends AnyFlatSpec with ChiselScalatestTester {
  behavior of "WeightBufferController context control"

  private case class Config(
    enabled: Boolean = true,
    vpu: Boolean = false,
    cache: Boolean = false,
    fusion: Boolean = false,
    weight0: BigInt = 256,
    weight1: BigInt = 0,
    passes: Int = 1,
    rows: Int = 1,
    k: Int = 1,
    n: Int = 1,
    operand: BigInt = 0,
    constant: Boolean = false,
    lut: Boolean = false,
    lutBytes: BigInt = 0,
    lutMask: Int = 0,
    threshold: BigInt = 128,
    id: Int = 1
  )

  private val zeroConfig = Config(
    enabled = false, weight0 = 0, passes = 0, rows = 0,
    k = 0, n = 0, threshold = 0, id = 0
  )

  private def driveConfig(d: WeightBufferController, c: Config): Unit = {
    d.io.config.bufferEnable.poke(c.enabled.B)
    d.io.config.operationMode.poke(
      if (c.vpu) WeightBufferOperationMode.VPU_DIRECT else WeightBufferOperationMode.GEMM)
    d.io.config.reuseMode.poke(
      if (c.cache) WeightBufferReuseMode.LOCAL_WEIGHT_CACHE else WeightBufferReuseMode.STREAM)
    d.io.config.fusionEnable.poke(c.fusion.B)
    d.io.config.weightSet0Bytes.poke(c.weight0.U)
    d.io.config.weightSet1Bytes.poke(c.weight1.U)
    d.io.config.weightReplayCount.poke(c.passes.U)
    d.io.config.inputRowCount.poke(c.rows.U)
    d.io.config.reductionTileCount.poke(c.k.U)
    d.io.config.outputColumnCount.poke(c.n.U)
    d.io.config.operand2PayloadBytes.poke(c.operand.U)
    d.io.config.constantOperandEnable.poke(c.constant.B)
    d.io.config.lutLoadEnable.poke(c.lut.B)
    d.io.config.lutPayloadBytes.poke(c.lutBytes.U)
    d.io.config.lutTargetEnableMask.poke(c.lutMask.U)
    d.io.config.normalImpendingThresholdBytes.poke(c.threshold.U)
    d.io.config.contextId.poke(c.id.U)
  }

  private def expectConfig(d: WeightBufferController, c: Config): Unit = {
    d.io.activeConfig.bufferEnable.expect(c.enabled.B)
    d.io.activeConfig.operationMode.expect(
      if (c.vpu) WeightBufferOperationMode.VPU_DIRECT else WeightBufferOperationMode.GEMM)
    d.io.activeConfig.reuseMode.expect(
      if (c.cache) WeightBufferReuseMode.LOCAL_WEIGHT_CACHE else WeightBufferReuseMode.STREAM)
    d.io.activeConfig.fusionEnable.expect(c.fusion.B)
    d.io.activeConfig.weightSet0Bytes.expect(c.weight0.U)
    d.io.activeConfig.weightSet1Bytes.expect(c.weight1.U)
    d.io.activeConfig.weightReplayCount.expect(c.passes.U)
    d.io.activeConfig.inputRowCount.expect(c.rows.U)
    d.io.activeConfig.reductionTileCount.expect(c.k.U)
    d.io.activeConfig.outputColumnCount.expect(c.n.U)
    d.io.activeConfig.operand2PayloadBytes.expect(c.operand.U)
    d.io.activeConfig.constantOperandEnable.expect(c.constant.B)
    d.io.activeConfig.lutLoadEnable.expect(c.lut.B)
    d.io.activeConfig.lutPayloadBytes.expect(c.lutBytes.U)
    d.io.activeConfig.lutTargetEnableMask.expect(c.lutMask.U)
    d.io.activeConfig.normalImpendingThresholdBytes.expect(c.threshold.U)
    d.io.activeConfig.contextId.expect(c.id.U)
  }

  private def status(
    d: WeightBufferController,
    refill: Boolean = false,
    read: Boolean = false,
    output: Boolean = false,
    computeDone: Boolean = false,
    receiveDone: Boolean = false,
    streamDone: Boolean = false
  ): Unit = {
    d.io.pathStatus.refillPending.poke(refill.B)
    d.io.pathStatus.readInFlight.poke(read.B)
    d.io.pathStatus.outputPending.poke(output.B)
    d.io.pathStatus.computeDone.poke(computeDone.B)
    d.io.pathStatus.lutReceiveDone.poke(receiveDone.B)
    d.io.pathStatus.lutStreamDone.poke(streamDone.B)
  }

  private def initialize(d: WeightBufferController): Unit = {
    d.clock.setTimeout(20000)
    driveConfig(d, Config())
    status(d)
    d.io.contextStart.poke(false.B)
    d.io.softReset.poke(false.B)
    d.reset.poke(true.B)
    d.clock.step(2)
    d.reset.poke(false.B)
    d.clock.step()
    d.io.contextActive.expect(false.B)
    d.io.contextReady.expect(true.B)
    d.io.contextAccepted.expect(false.B)
    d.io.contextDone.expect(false.B)
    d.io.dataPathClear.expect(false.B)
    expectConfig(d, zeroConfig)
  }

  private def begin(d: WeightBufferController, c: Config): Unit = {
    status(d)
    driveConfig(d, c)
    d.io.contextStart.poke(true.B)
    d.io.configValid.expect(true.B)
    d.io.contextReady.expect(true.B)
    d.io.contextAccepted.expect(true.B)
    d.io.dataPathClear.expect(true.B)
    d.clock.step()
    d.io.contextStart.poke(false.B)
    d.io.contextActive.expect(true.B)
    d.io.contextReady.expect(false.B)
    d.io.contextAccepted.expect(false.B)
    d.io.dataPathClear.expect(false.B)
    expectConfig(d, c)
  }

  private def finish(d: WeightBufferController): Unit = {
    status(d, computeDone = true, receiveDone = true, streamDone = true)
    d.io.contextDone.expect(true.B)
    d.io.contextReady.expect(false.B)
    d.clock.step()
    status(d)
    d.io.contextActive.expect(false.B)
    d.io.contextDone.expect(false.B)
    d.io.contextReady.expect(true.B)
    d.io.computeStreamEnabled.expect(false.B)
    d.io.lutTransferEnabled.expect(false.B)
    d.io.localWeightCacheEnabled.expect(false.B)
    d.clock.step(2)
    d.io.contextDone.expect(false.B)
  }

  it should "validate explicit modes, shape, alignment and capacity without truncating arithmetic" in {
    test(new WeightBufferController) { d =>
      initialize(d)
      val truncatedDense = ((BigInt(65535) * 65535) << 8) & ((BigInt(1) << 32) - 1)
      val cases = Seq(
        ("GEMM STREAM", Config(), true),
        ("GEMM cache exactly 16KiB", Config(cache = true, weight0 = 16384, k = 8, n = 8), true),
        ("GEMM STREAM above 16KiB", Config(weight0 = 20480, k = 80), true),
        ("fusion cache 12KiB", Config(cache = true, fusion = true, weight0 = 3072, weight1 = 9216), true),
        ("fusion cache exactly 16KiB", Config(cache = true, fusion = true, weight0 = 8192, weight1 = 8192), true),
        ("fusion STREAM 24KiB", Config(fusion = true, weight0 = 12288, weight1 = 12288), true),
        ("large dense product", Config(weight0 = BigInt(1280000000), k = 50000, n = 100), true),
        ("VPU STREAM 20KiB", Config(vpu = true, operand = 20480), true),
        ("VPU ignores GEMM replay", Config(vpu = true, operand = 16, passes = 0, rows = 91), true),
        ("constant VPU ignores unused operand alignment", Config(vpu = true, operand = 17, constant = true, threshold = 3), true),
        ("disabled compute ignores unused payload alignment", Config(enabled = false, weight0 = 17, threshold = 3), true),
        ("zero-byte GEMM cache", Config(cache = true, weight0 = 0, passes = 0, rows = 0, k = 0, n = 0), true),
        ("zero-byte VPU", Config(vpu = true, operand = 0, passes = 0, rows = 9), true),
        ("zero-byte LUT", Config(lut = true, lutBytes = 0, lutMask = 31), true),
        ("LUT transfer above capacity", Config(lut = true, lutBytes = 20480, lutMask = 31), true),
        ("LUT does not permanently reduce cache capacity", Config(cache = true, weight0 = 16384, k = 8, n = 8, lut = true, lutBytes = 20480), true),
        ("zero configured threshold", Config(threshold = 0), true),
        ("maximum replay count", Config(passes = 65535, rows = 65535), true),
        ("cache 16KiB plus 256B", Config(cache = true, weight0 = 16640, k = 65), false),
        ("fusion combined 24KiB", Config(cache = true, fusion = true, weight0 = 12288, weight1 = 12288), false),
        ("cache sum wraps to 16 if carry is lost", Config(cache = true, fusion = true, weight0 = BigInt("fffffff0", 16), weight1 = 32), false),
        ("non-fusion set1 is not zero", Config(weight1 = 256), false),
        ("VPU cache", Config(vpu = true, cache = true, operand = 16), false),
        ("constant VPU still requires STREAM mode", Config(vpu = true, cache = true, operand = 16, constant = true), false),
        ("zero active GEMM replay", Config(passes = 0, rows = 0), false),
        ("row/replay mismatch", Config(passes = 3, rows = 2), false),
        ("dense byte/shape mismatch", Config(weight0 = 768, k = 2, n = 2), false),
        ("dense product truncation", Config(weight0 = truncatedDense, k = 65535, n = 65535), false),
        ("unaligned W1", Config(fusion = true, weight0 = 17, weight1 = 256), false),
        ("unaligned W2", Config(fusion = true, weight0 = 256, weight1 = 17), false),
        ("unaligned VPU operand", Config(vpu = true, operand = 17), false),
        ("unaligned LUT", Config(lut = true, lutBytes = 17), false),
        ("unaligned LUT remains invalid with compute disabled", Config(enabled = false, lut = true, lutBytes = 17), false),
        ("unaligned threshold", Config(threshold = 17), false)
      )
      for ((name, config, valid) <- cases) {
        withClue(name + ": ") {
          driveConfig(d, config)
          d.io.configValid.expect(valid.B)
          d.io.contextReady.expect(valid.B)
          d.io.contextAccepted.expect(false.B)
          d.io.dataPathClear.expect(false.B)
          d.io.computeStreamEnabled.expect(false.B)
          d.io.lutTransferEnabled.expect(false.B)
          d.clock.step()
          expectConfig(d, zeroConfig)
        }
      }
      println("CONFIG MATRIX: " + cases.size + " explicit specification cases")
    }
  }

  it should "latch all settings and accept a held next request only after the current context ends" in {
    test(new WeightBufferController) { d =>
      initialize(d)
      val first = Config(cache = true, fusion = true, weight0 = 4096, weight1 = 8192,
        passes = 3, rows = 3, k = 7, n = 9, operand = 80, constant = true,
        lut = true, lutBytes = 112, lutMask = 21, threshold = 144, id = 173)
      begin(d, first)
      d.io.weightWorkingSetBytes.expect(12288.U)
      d.io.computeStreamEnabled.expect(true.B)
      d.io.localWeightCacheEnabled.expect(true.B)
      val next = Config(vpu = true, operand = 20480, lutMask = 10, id = 219)
      driveConfig(d, next)
      d.io.contextStart.poke(true.B)
      for (_ <- 0 until 5) {
        d.io.contextReady.expect(false.B)
        d.io.contextAccepted.expect(false.B)
        d.io.dataPathClear.expect(false.B)
        d.io.contextDone.expect(false.B)
        d.clock.step()
        expectConfig(d, first)
      }
      status(d, computeDone = true, receiveDone = true, streamDone = true)
      d.io.contextDone.expect(true.B)
      d.io.contextAccepted.expect(false.B)
      d.clock.step()
      status(d)
      d.io.contextActive.expect(false.B)
      d.io.contextReady.expect(true.B)
      d.io.contextAccepted.expect(true.B)
      d.io.dataPathClear.expect(true.B)
      d.clock.step()
      d.io.contextStart.poke(false.B)
      expectConfig(d, next)
      d.io.computeComplete.expect(false.B)
      d.io.lutReceiveComplete.expect(true.B)
      d.io.lutStreamComplete.expect(true.B)
      d.io.localWeightCacheEnabled.expect(false.B)
      finish(d)
    }
  }

  it should "keep an active context through idle gaps and every pending-response combination" in {
    test(new WeightBufferController) { d =>
      initialize(d)
      begin(d, Config(lut = true, lutBytes = 80))
      for (_ <- 0 until 8) {
        d.io.contextDone.expect(false.B)
        d.io.contextReady.expect(false.B)
        d.clock.step()
      }
      status(d, refill = true, computeDone = true, receiveDone = true, streamDone = true)
      d.io.contextDone.expect(false.B)
      d.clock.step()
      for (mask <- 1 until 8) {
        status(d, refill = (mask & 1) != 0, read = (mask & 2) != 0, output = (mask & 4) != 0)
        d.io.computeComplete.expect(true.B)
        d.io.lutReceiveComplete.expect(true.B)
        d.io.lutStreamComplete.expect(true.B)
        d.io.contextDone.expect(false.B)
        d.io.contextReady.expect(false.B)
        d.clock.step()
        d.io.contextActive.expect(true.B)
      }
      status(d)
      d.io.contextDone.expect(true.B)
      d.clock.step()
      d.io.contextDone.expect(false.B)
      d.io.contextReady.expect(true.B)
      for (mask <- 1 until 8) {
        status(d, refill = (mask & 1) != 0, read = (mask & 2) != 0, output = (mask & 4) != 0)
        d.io.contextReady.expect(false.B)
        d.io.contextDone.expect(false.B)
      }
      status(d)
      d.io.contextReady.expect(true.B)
    }
  }

  it should "remember independent compute and LUT completion pulses in all legal relative orders" in {
    test(new WeightBufferController) { d =>
      initialize(d)
      val orders = Seq(Seq("C", "R", "S"), Seq("R", "C", "S"), Seq("R", "S", "C"),
        Seq("RS", "C"), Seq("C", "RS"), Seq("CRS"))
      for ((order, index) <- orders.zipWithIndex) {
        begin(d, Config(lut = true, lutBytes = 80, id = index + 1))
        for ((events, pos) <- order.zipWithIndex) {
          status(d, computeDone = events.contains("C"), receiveDone = events.contains("R"),
            streamDone = events.contains("S"))
          d.io.contextDone.expect((pos == order.size - 1).B)
          d.clock.step()
          status(d)
          if (pos < order.size - 1) {
            d.io.contextActive.expect(true.B)
            d.io.contextDone.expect(false.B)
            d.clock.step(2)
          }
        }
        d.io.contextActive.expect(false.B)
        d.io.contextDone.expect(false.B)
        d.io.contextReady.expect(true.B)
      }
      println("COMPLETION ORDERS: " + orders.size + " legal sequences")
    }
  }

  it should "handle disabled, constant, zero-length and LUT-only contexts without waiting for absent data" in {
    test(new WeightBufferController) { d =>
      initialize(d)
      val noCompute = Seq(
        Config(enabled = false),
        Config(vpu = true, operand = 80, constant = true),
        Config(weight0 = 0, passes = 0, rows = 0, k = 0, n = 0),
        Config(vpu = true, operand = 0)
      )
      for ((config, index) <- noCompute.zipWithIndex) {
        begin(d, config.copy(id = index + 1))
        d.io.computeStreamEnabled.expect(false.B)
        d.io.localWeightCacheEnabled.expect(false.B)
        d.io.computeComplete.expect(true.B)
        d.io.lutTransferEnabled.expect(false.B)
        d.io.contextDone.expect(true.B)
        d.clock.step()
        d.io.contextActive.expect(false.B)
        d.io.contextDone.expect(false.B)
      }
      for ((config, index) <- noCompute.zipWithIndex) {
        begin(d, config.copy(lut = true, lutBytes = 80, lutMask = 31, id = index + 10))
        d.io.computeStreamEnabled.expect(false.B)
        d.io.computeComplete.expect(true.B)
        d.io.lutTransferEnabled.expect(true.B)
        status(d, receiveDone = true)
        d.io.contextDone.expect(false.B)
        d.clock.step()
        status(d)
        d.io.lutReceiveComplete.expect(true.B)
        d.io.lutStreamComplete.expect(false.B)
        d.io.contextDone.expect(false.B)
        d.clock.step(3)
        status(d, streamDone = true)
        d.io.contextDone.expect(true.B)
        d.clock.step()
        status(d)
        d.io.contextActive.expect(false.B)
      }
      begin(d, Config(lut = true, lutBytes = 0, lutMask = 31))
      d.io.lutTransferEnabled.expect(false.B)
      d.io.lutReceiveComplete.expect(true.B)
      d.io.lutStreamComplete.expect(true.B)
      d.io.contextDone.expect(false.B)
      finish(d)
    }
  }

  it should "clear safely on softReset and give reset priority over a simultaneous contextStart" in {
    test(new WeightBufferController) { d =>
      initialize(d)
      begin(d, Config(lut = true, lutBytes = 80, id = 211))
      driveConfig(d, Config(vpu = true, operand = 64, id = 99))
      d.io.contextStart.poke(true.B)
      d.io.softReset.poke(true.B)
      d.io.contextReady.expect(false.B)
      d.io.contextAccepted.expect(false.B)
      d.io.dataPathClear.expect(true.B)
      d.io.contextDone.expect(false.B)
      d.clock.step()
      d.io.contextStart.poke(false.B)
      d.io.softReset.poke(false.B)
      expectConfig(d, zeroConfig)
      d.io.contextActive.expect(false.B)
      d.io.computeComplete.expect(true.B)
      d.io.lutReceiveComplete.expect(true.B)
      d.io.lutStreamComplete.expect(true.B)
      d.io.contextReady.expect(true.B)
      begin(d, Config(id = 99))
      d.io.computeComplete.expect(false.B)
      d.io.contextDone.expect(false.B)
      finish(d)
    }
  }

  it should "honor system reset and ignore old completion pulses while no context is active" in {
    test(new WeightBufferController) { d =>
      initialize(d)
      begin(d, Config(lut = true, lutBytes = 80))
      status(d, refill = true, read = true, output = true,
        computeDone = true, receiveDone = true, streamDone = true)
      d.reset.poke(true.B)
      d.io.contextReady.expect(false.B)
      d.io.contextActive.expect(false.B)
      d.io.contextDone.expect(false.B)
      d.io.dataPathClear.expect(false.B)
      d.clock.step(2)
      d.reset.poke(false.B)
      d.io.contextReady.expect(false.B)
      expectConfig(d, zeroConfig)
      status(d, computeDone = true, receiveDone = true, streamDone = true)
      d.clock.step(2)
      d.io.contextDone.expect(false.B)
      d.io.contextReady.expect(true.B)
      driveConfig(d, Config(id = 222, lut = true, lutBytes = 80))
      d.io.contextStart.poke(true.B)
      d.clock.step()
      d.io.contextStart.poke(false.B)
      status(d)
      d.io.computeComplete.expect(false.B)
      d.io.lutReceiveComplete.expect(false.B)
      d.io.lutStreamComplete.expect(false.B)
      d.io.contextDone.expect(false.B)
      finish(d)
    }
  }

  it should "preserve sum carry in a legal STREAM context above the default 32-bit payload range" in {
    test(new WeightBufferController) { d =>
      initialize(d)
      begin(d, Config(fusion = true, weight0 = BigInt("fffffff0", 16), weight1 = 32))
      d.io.weightWorkingSetBytes.expect(BigInt("100000010", 16).U)
      d.io.localWeightCacheEnabled.expect(false.B)
      finish(d)
    }
  }

  it should "support wider payload, count and identity parameters" in {
    test(new WeightBufferController(contextIdWidth = 12, payloadByteWidth = 40, countWidth = 20)) { d =>
      initialize(d)
      val config = Config(vpu = true, operand = (BigInt(1) << 36) + 16,
        lut = true, lutBytes = (BigInt(1) << 35) + 32, lutMask = 27,
        passes = 700000, rows = 800000, k = 600000, n = 900000,
        threshold = (BigInt(1) << 34) + 16, id = 4095)
      begin(d, config)
      d.io.computeStreamEnabled.expect(true.B)
      d.io.lutTransferEnabled.expect(true.B)
      finish(d)
      begin(d, Config(passes = 700000, rows = 700000, id = 4094))
      finish(d)
    }
  }

  it should "preserve carry with the minimum payload width" in {
    test(new WeightBufferController(contextIdWidth = 4, payloadByteWidth = 15, countWidth = 8)) { d =>
      initialize(d)
      begin(d, Config(fusion = true, weight0 = 16384, weight1 = 16384, id = 15))
      d.io.weightWorkingSetBytes.expect(32768.U)
      finish(d)
      driveConfig(d, Config(cache = true, fusion = true, weight0 = 16384, weight1 = 16384))
      d.io.configValid.expect(false.B)
      d.io.contextReady.expect(false.B)
    }
  }

  it should "match a seeded context-lifecycle scoreboard across completion and drain timing" in {
    test(new WeightBufferController) { d =>
      initialize(d)
      val random = new Random(0x57424354L)
      var checkedCycles = 0
      for (trial <- 0 until 100) {
        val vpu = random.nextBoolean()
        val noCompute = random.nextInt(4) == 0
        val hasLut = random.nextBoolean()
        val config = Config(enabled = !noCompute, vpu = vpu,
          cache = !vpu && random.nextBoolean(),
          operand = if (vpu) 80 else 0,
          lut = hasLut, lutBytes = if (hasLut) 112 else 0, lutMask = random.nextInt(32),
          passes = if (vpu) 7 else 3, rows = if (vpu) 11 else 3, id = trial + 1)
        begin(d, config)
        var doneC = noCompute
        var doneR = !hasLut
        var doneS = !hasLut
        var ended = false
        var cycle = 0
        while (!ended && cycle < 50) {
          val force = cycle >= 40
          val c = !doneC && (force || random.nextInt(4) == 0)
          val r = !doneR && (force || random.nextInt(4) == 0)
          val s = !doneS && (doneR || r) && (force || random.nextInt(4) == 0)
          val pending = if (force) 0 else random.nextInt(8)
          status(d, refill = (pending & 1) != 0, read = (pending & 2) != 0,
            output = (pending & 4) != 0, computeDone = c, receiveDone = r, streamDone = s)
          driveConfig(d, Config(vpu = true, operand = 16, id = 250))
          expectConfig(d, config)
          d.io.contextActive.expect(true.B)
          d.io.contextReady.expect(false.B)
          d.io.contextAccepted.expect(false.B)
          d.io.dataPathClear.expect(false.B)
          d.io.computeComplete.expect(doneC.B)
          d.io.lutReceiveComplete.expect(doneR.B)
          d.io.lutStreamComplete.expect(doneS.B)
          doneC ||= c
          doneR ||= r
          doneS ||= s
          ended = doneC && doneR && doneS && pending == 0
          d.io.contextDone.expect(ended.B)
          d.clock.step()
          checkedCycles += 1
          cycle += 1
          if (ended) {
            status(d)
            d.io.contextActive.expect(false.B)
            d.io.contextDone.expect(false.B)
            d.io.contextReady.expect(true.B)
          }
        }
        assert(ended, "context did not finish within the bounded scenario")
      }
      println("LIFECYCLE SCOREBOARD: 100 contexts, " + checkedCycles + " checked cycles")
    }
  }

  private val invalidStarts = Seq(
    ("VPU cache", Config(vpu = true, cache = true, operand = 16)),
    ("non-fusion set1", Config(weight1 = 256)),
    ("compute alignment", Config(vpu = true, operand = 17)),
    ("LUT alignment", Config(lut = true, lutBytes = 17)),
    ("threshold alignment", Config(threshold = 17)),
    ("GEMM replay", Config(passes = 2, rows = 1)),
    ("GEMM dense shape", Config(weight0 = 512)),
    ("cache capacity", Config(cache = true, weight0 = 16640, k = 65))
  )

  for ((name, invalid) <- invalidStarts) {
    it should ("assert rather than accept an invalid start: " + name) in {
      assertThrows[ChiselAssertionError] {
        test(new WeightBufferController) { d =>
          initialize(d)
          driveConfig(d, invalid)
          d.io.contextStart.poke(true.B)
          d.io.configValid.expect(false.B)
          d.io.contextReady.expect(false.B)
          d.io.contextAccepted.expect(false.B)
          d.io.dataPathClear.expect(false.B)
          d.clock.step()
        }
      }
    }
  }

  for (pending <- Seq("DMA", "SRAM", "output")) {
    it should ("reject softReset with an outstanding " + pending + " response") in {
      assertThrows[ChiselAssertionError] {
        test(new WeightBufferController) { d =>
          initialize(d)
          begin(d, Config(lut = true, lutBytes = 80))
          status(d, refill = pending == "DMA", read = pending == "SRAM", output = pending == "output")
          d.io.softReset.poke(true.B)
          d.io.contextReady.expect(false.B)
          d.io.contextAccepted.expect(false.B)
          d.io.dataPathClear.expect(false.B)
          d.io.contextActive.expect(true.B)
          d.clock.step()
        }
      }
    }
  }
}
