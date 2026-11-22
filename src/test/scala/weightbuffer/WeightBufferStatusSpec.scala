package npu.core.memory

import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec
import scala.language.reflectiveCalls

/** Impending을 실제 ready에 연결해도 tail이 완료되는지 확인하는 작은 통합 회로. */
class WeightBufferStatusFeedbackHarness extends Module {
  val io = IO(new Bundle {
    val start = Input(Bool())
    val grant = Input(Bool())
    val memoryValid = Input(Bool())
    val memoryData = Input(UInt(128.W))
    val contextReady = Output(Bool())
    val requestValid = Output(Bool())
    val memoryReady = Output(Bool())
    val dataValid = Output(Bool())
    val data = Output(UInt(128.W))
    val last = Output(Bool())
    val done = Output(Bool())
    val impending = Output(Bool())
    val state = Output(WeightBufferControllerState())
  })
  val path = Module(new WeightBufferDataPath)
  path.io.config := 0.U.asTypeOf(path.io.config)
  path.io.config.bufferEnable := true.B
  path.io.config.operationMode := WeightBufferOperationMode.VPU_DIRECT
  path.io.config.reuseMode := WeightBufferReuseMode.STREAM
  path.io.config.operand2PayloadBytes := 16.U
  path.io.config.normalImpendingThresholdBytes := 128.U
  path.io.config.contextId := 1.U
  path.io.prefillStart := false.B
  path.io.contextStart := io.start
  path.io.softReset := false.B
  path.io.readEnable := true.B
  path.io.refillRequestReady := io.grant
  path.io.lutCreditValid := false.B
  path.io.lutCreditBytes := 16.U
  path.io.lutDataReady := true.B
  path.io.memoryDataValid := io.memoryValid
  path.io.memoryData := io.memoryData
  path.io.memoryLaneValidMask := 1.U
  path.io.memoryChunkLast := true.B
  path.io.memoryStreamLast := true.B
  path.io.memoryContextId := 1.U
  path.io.memoryDataKind := WeightBufferDataKind.VECTOR_OPERAND
  path.io.computeDataReady := !path.io.impending
  io.contextReady := path.io.contextReady
  io.requestValid := path.io.refillRequestValid
  io.memoryReady := path.io.memoryDataReady
  io.dataValid := path.io.computeDataValid
  io.data := path.io.computeData
  io.last := path.io.computeDataLast
  io.done := path.io.operationDone
  io.impending := path.io.impending
  io.state := path.io.controllerState
}

class WeightBufferStatusSpec extends AnyFlatSpec with ChiselScalatestTester {
  behavior of "WB status and completion"

  private case class Job(
    bytes: Int = 256, passes: Int = 1, cache: Boolean = false,
    vpu: Boolean = false, enabled: Boolean = true, constant: Boolean = false,
    lutBytes: Int = 0, threshold: Int = 128, id: Int = 1
  )
  private def yes(x: Bool) = x.peek().litToBoolean
  private def word(i: Int): BigInt = (BigInt(i + 1) << 64) | BigInt(i + 0x1234)

  private def configure(d: WeightBufferDataPath, j: Job): Unit = {
    d.io.config.bufferEnable.poke(j.enabled.B)
    d.io.config.operationMode.poke(if (j.vpu) WeightBufferOperationMode.VPU_DIRECT else WeightBufferOperationMode.GEMM)
    d.io.config.reuseMode.poke(if (j.cache) WeightBufferReuseMode.LOCAL_WEIGHT_CACHE else WeightBufferReuseMode.STREAM)
    d.io.config.fusionEnable.poke(false.B)
    d.io.config.weightSet0Bytes.poke((if (j.vpu) 0 else j.bytes).U)
    d.io.config.weightSet1Bytes.poke(0.U)
    d.io.config.weightReplayCount.poke(j.passes.U)
    d.io.config.inputRowCount.poke(j.passes.U)
    d.io.config.reductionTileCount.poke((if (j.vpu) 0 else j.bytes / 256).U)
    d.io.config.outputColumnCount.poke((if (j.vpu || j.bytes == 0) 0 else 1).U)
    d.io.config.operand2PayloadBytes.poke((if (j.vpu) j.bytes else 0).U)
    d.io.config.constantOperandEnable.poke(j.constant.B)
    d.io.config.lutLoadEnable.poke((j.lutBytes > 0).B)
    d.io.config.lutPayloadBytes.poke(j.lutBytes.U)
    d.io.config.lutTargetEnableMask.poke(1.U)
    d.io.config.normalImpendingThresholdBytes.poke(j.threshold.U)
    d.io.config.contextId.poke(j.id.U)
  }
  private def initialize(d: WeightBufferDataPath): Unit = {
    d.clock.setTimeout(20000)
    configure(d, Job())
    d.io.contextStart.poke(false.B)
    d.io.prefillStart.poke(false.B)
    d.io.softReset.poke(false.B)
    d.io.readEnable.poke(false.B)
    d.io.computeDataReady.poke(false.B)
    d.io.refillRequestReady.poke(false.B)
    d.io.lutCreditValid.poke(false.B)
    d.io.lutCreditBytes.poke(16.U)
    d.io.lutDataReady.poke(false.B)
    d.io.memoryDataValid.poke(false.B)
    d.io.memoryData.poke(0.U)
    d.io.memoryLaneValidMask.poke(15.U)
    d.io.memoryChunkLast.poke(false.B)
    d.io.memoryStreamLast.poke(false.B)
    d.io.memoryContextId.poke(1.U)
    d.io.memoryDataKind.poke(WeightBufferDataKind.WEIGHT)
    d.reset.poke(true.B); d.clock.step(2); d.reset.poke(false.B); d.clock.step()
    d.io.controllerState.expect(WeightBufferControllerState.DISABLED)
  }
  private def begin(d: WeightBufferDataPath, j: Job): Unit = {
    configure(d, j)
    d.io.contextStart.poke(true.B)
    d.io.contextReady.expect(true.B)
    d.clock.step()
    d.io.contextStart.poke(false.B)
    d.io.contextActive.expect(true.B)
  }
  private def grant(d: WeightBufferDataPath, bytes: Int, group: Int): Unit = {
    d.io.refillRequestReady.poke(true.B)
    var wait = 0
    while (!yes(d.io.refillRequestValid) && wait < 8) { d.clock.step(); wait += 1 }
    d.io.refillRequestValid.expect(true.B)
    d.io.refillRequestBytes.expect(bytes.U)
    d.io.refillRequestGroupIndex.expect(group.U)
    d.clock.step()
    d.io.refillRequestReady.poke(false.B)
  }
  private def send(
    d: WeightBufferDataPath, j: Job, bytes: Int, offset: Int,
    finalSupply: Boolean, lut: Boolean = false
  ): Unit = {
    for (sent <- 0 until bytes by 64) {
      val n = math.min(64, bytes - sent)
      val data = (0 until n / 16).foldLeft(BigInt(0))((a, lane) =>
        a | (word(offset / 16 + sent / 16 + lane) << (lane * 128)))
      d.io.memoryDataValid.poke(true.B)
      d.io.memoryData.poke(data.U)
      d.io.memoryLaneValidMask.poke(((1 << (n / 16)) - 1).U)
      d.io.memoryChunkLast.poke((sent + n == bytes).B)
      d.io.memoryStreamLast.poke((sent + n == bytes && finalSupply).B)
      d.io.memoryContextId.poke(j.id.U)
      d.io.memoryDataKind.poke(if (lut) WeightBufferDataKind.LUT
        else if (j.vpu) WeightBufferDataKind.VECTOR_OPERAND else WeightBufferDataKind.WEIGHT)
      d.io.memoryDataReady.expect(true.B)
      d.clock.step()
    }
    d.io.memoryDataValid.poke(false.B)
  }
  private def take(d: WeightBufferDataPath, index: Int, finalOutput: Boolean): Unit = {
    d.io.computeDataReady.poke(true.B)
    var wait = 0
    while (!yes(d.io.computeDataValid) && wait < 8) { d.clock.step(); wait += 1 }
    d.io.computeDataValid.expect(true.B)
    d.io.computeData.expect(word(index).U)
    d.io.computeDataLast.expect(finalOutput.B)
    d.io.operationDone.expect(finalOutput.B)
    d.clock.step()
  }
  private def noWarnings(d: WeightBufferDataPath): Unit = {
    d.io.hungry.expect(false.B)
    d.io.starving.expect(false.B)
    d.io.impending.expect(false.B)
  }
  private def finished(d: WeightBufferDataPath): Unit = {
    d.io.controllerState.expect(WeightBufferControllerState.DONE)
    noWarnings(d)
    d.io.contextDone.expect(true.B)
    d.clock.step()
    d.io.contextActive.expect(false.B)
    d.io.controllerState.expect(WeightBufferControllerState.DONE)
    for (_ <- 0 until 3) {
      noWarnings(d)
      d.io.operationDone.expect(false.B)
      d.io.refillRequestValid.expect(false.B)
      d.clock.step()
    }
  }

  it should "report initial fill, threshold crossing, pending refill and final draining" in {
    test(new WeightBufferDataPath) { d =>
      initialize(d)
      val j = Job(bytes = 8192, id = 1)
      begin(d, j)
      d.io.controllerState.expect(WeightBufferControllerState.INITIAL_FILL)
      d.io.initialReady.expect(false.B)
      d.io.hungry.expect(true.B)
      d.io.starving.expect(true.B)
      d.io.impending.expect(true.B)
      grant(d, 4096, 0)
      d.io.hungry.expect(false.B)
      send(d, j, 4096, 0, finalSupply = false)
      d.io.controllerState.expect(WeightBufferControllerState.ACTIVE)
      d.io.initialReady.expect(true.B)
      d.io.impending.expect(false.B)
      d.io.starving.expect(true.B) // readEnable is still low
      d.io.readEnable.poke(true.B)
      for (i <- 0 until 247) take(d, i, finalOutput = false)
      d.io.impending.expect(false.B) // 144B remain
      take(d, 247, finalOutput = false)
      d.io.impending.expect(true.B) // threshold is inclusive at 128B
      d.io.starving.expect(false.B) // the output is present despite the safety warning
      d.io.computeDataReady.poke(false.B)
      d.io.hungry.expect(true.B)
      val held = d.io.computeData.peek().litValue
      grant(d, 4096, 0)
      d.io.hungry.expect(false.B)
      d.io.impending.expect(true.B)
      send(d, j, 4096, 4096, finalSupply = true)
      d.io.computeData.expect(held.U)
      d.io.controllerState.expect(WeightBufferControllerState.DRAINING)
      d.io.impending.expect(false.B)
      for (i <- 248 until 512) {
        d.io.impending.expect(false.B)
        take(d, i, finalOutput = i == 511)
      }
      finished(d)
    }
  }

  it should "recognize a ready next group and never stall the final prepared tail" in {
    test(new WeightBufferDataPath) { d =>
      initialize(d)
      val j = Job(bytes = 256, passes = 3, threshold = 512, id = 2)
      begin(d, j)
      grant(d, 256, 0); send(d, j, 256, 0, finalSupply = false)
      d.io.impending.expect(true.B)
      grant(d, 256, 1); send(d, j, 256, 0, finalSupply = false)
      d.io.impending.expect(false.B) // current pass is only 256B, but its continuation is ready
      d.io.readEnable.poke(true.B)
      for (i <- 0 until 16) take(d, i, finalOutput = false)
      d.io.computeDataReady.poke(false.B)
      d.io.impending.expect(true.B) // next group is now missing
      grant(d, 256, 2); send(d, j, 256, 0, finalSupply = true)
      d.io.controllerState.expect(WeightBufferControllerState.DRAINING)
      for (i <- 0 until 32) {
        d.io.impending.expect(false.B)
        take(d, i % 16, finalOutput = i == 31)
      }
      finished(d)
    }
  }

  it should "exclude LUT bytes, suppress replay refill, and retain DONE after the last accepted output" in {
    test(new WeightBufferDataPath) { d =>
      initialize(d)
      val j = Job(bytes = 256, passes = 2, cache = true, lutBytes = 16, id = 3)
      begin(d, j)
      d.io.hungry.expect(false.B)
      d.io.impending.expect(true.B)
      d.io.controllerState.expect(WeightBufferControllerState.INITIAL_FILL)
      d.io.lutCreditValid.poke(true.B); d.io.lutCreditBytes.poke(16.U)
      d.io.lutCreditReady.expect(true.B); d.clock.step(); d.io.lutCreditValid.poke(false.B)
      send(d, j, 16, 0, finalSupply = true, lut = true)
      d.io.initialReady.expect(false.B)
      d.io.impending.expect(true.B)
      grant(d, 256, 0); send(d, j, 256, 0, finalSupply = true)
      d.io.initialReady.expect(true.B)
      d.io.weightCacheReady.expect(true.B)
      d.io.controllerState.expect(WeightBufferControllerState.DRAINING)
      d.io.hungry.expect(false.B)
      d.io.impending.expect(false.B)
      d.io.starving.expect(true.B) // weight is ready but the read port still belongs to LUT
      d.io.lutDataValid.expect(true.B)
      d.io.lutDataReady.poke(true.B); d.io.lutStreamDone.expect(true.B); d.clock.step()
      d.io.readEnable.poke(true.B)
      for (i <- 0 until 31) {
        d.io.hungry.expect(false.B)
        d.io.impending.expect(false.B)
        take(d, i % 16, finalOutput = false)
      }
      d.io.computeDataReady.poke(false.B)
      d.io.computeDataValid.expect(true.B)
      d.io.computeDataLast.expect(true.B)
      val held = d.io.computeData.peek().litValue
      for (_ <- 0 until 3) {
        noWarnings(d)
        d.io.computeData.expect(held.U)
        d.io.computeDataLast.expect(true.B)
        d.io.operationDone.expect(false.B)
        d.io.controllerState.expect(WeightBufferControllerState.DRAINING)
        d.clock.step()
      }
      take(d, 15, finalOutput = true)
      finished(d)
    }
  }

  it should "leave compute warnings disabled for LUT-only, constant and zero-length contexts" in {
    test(new WeightBufferDataPath) { d =>
      initialize(d)
      val j = Job(bytes = 0, enabled = false, lutBytes = 16, id = 4)
      begin(d, j)
      d.io.controllerState.expect(WeightBufferControllerState.DISABLED)
      noWarnings(d)
      d.io.lutCreditValid.poke(true.B); d.io.lutCreditBytes.poke(16.U); d.clock.step()
      d.io.lutCreditValid.poke(false.B)
      send(d, j, 16, 0, finalSupply = true, lut = true)
      noWarnings(d)
      d.io.lutDataReady.poke(true.B)
      while (!yes(d.io.lutDataValid)) d.clock.step()
      d.io.lutStreamDone.expect(true.B); d.io.operationDone.expect(false.B); d.clock.step()
      d.io.contextDone.expect(true.B); d.clock.step()
      for (empty <- Seq(Job(bytes = 80, vpu = true, constant = true, id = 5), Job(bytes = 0, id = 6))) {
        begin(d, empty)
        noWarnings(d)
        d.io.initialReady.expect(true.B)
        d.io.controllerState.expect(WeightBufferControllerState.DISABLED)
        d.io.contextDone.expect(true.B)
        d.io.operationDone.expect(false.B)
        d.clock.step()
      }
      d.io.softReset.poke(true.B)
      d.io.controllerState.expect(WeightBufferControllerState.DISABLED)
      noWarnings(d)
      d.clock.step(); d.io.softReset.poke(false.B)
      begin(d, Job(id = 7))
      d.io.controllerState.expect(WeightBufferControllerState.INITIAL_FILL)
      d.io.impending.expect(true.B)
    }
  }

  it should "count only the current pass from the accepted read pointer across extended wrap" in {
    test(new CircularBufferCore(userTagWidth = 2)) { d =>
      d.clock.setTimeout(10000)
      d.io.softReset.poke(false.B); d.io.contextId.poke(1.U)
      d.io.readEnable.poke(false.B); d.io.output.ready.poke(false.B)
      d.io.cacheGroup.valid.poke(false.B)
      d.io.cacheGroup.bits.payloadBytes.poke(16.U)
      d.io.cacheGroup.bits.replayCount.poke(1.U); d.io.cacheGroup.bits.groupIndex.poke(0.U)
      d.io.reserveRefill.valid.poke(false.B)
      d.io.reserveRefill.bits.payloadBytes.poke(16.U)
      d.io.reserveRefill.bits.userTag.poke(0.U)
      d.io.reserveRefill.bits.groupIndex.poke(0.U)
      d.io.reserveRefill.bits.lastInGroup.poke(false.B)
      d.io.memoryDataValid.poke(false.B); d.io.memoryData.poke(0.U)
      d.io.memoryLaneValidMask.poke(15.U); d.io.memoryChunkLast.poke(false.B)
      d.io.memoryStreamLast.poke(false.B); d.io.memoryContextId.poke(1.U); d.io.memoryUserTag.poke(0.U)
      d.io.reserveRefill.bits.streaming.poke(false.B)
      d.reset.poke(true.B); d.clock.step(2); d.reset.poke(false.B)
      // 포인터를 외부에서 주입하지 않고 실제 쓰기/소비로 wrap 직전까지 진행한다.
      for (base <- 0 until 32752 by 4096) {
        val bytes = math.min(4096, 32752 - base)
        d.io.reserveRefill.valid.poke(true.B)
        d.io.reserveRefill.bits.payloadBytes.poke(bytes.U)
        d.io.reserveRefill.bits.lastInGroup.poke(true.B)
        d.io.reserveRefill.ready.expect(true.B); d.clock.step()
        d.io.reserveRefill.valid.poke(false.B)
        for (offset <- 0 until bytes by 64) {
          val size = math.min(64, bytes - offset)
          d.io.memoryDataValid.poke(true.B); d.io.memoryData.poke(0.U)
          d.io.memoryLaneValidMask.poke(((1 << (size / 16)) - 1).U)
          d.io.memoryChunkLast.poke((offset + size == bytes).B)
          d.io.memoryDataReady.expect(true.B); d.clock.step()
        }
        d.io.memoryDataValid.poke(false.B)
        d.io.readEnable.poke(true.B); d.io.output.ready.poke(true.B)
        var count = 0; var cycles = 0
        while (count < bytes / 16 && cycles < bytes / 16 + 8) {
          if (yes(d.io.output.valid)) {
            d.io.output.bits.data.expect(0.U)
            count += 1
          }
          d.clock.step(); cycles += 1
        }
        assert(count == bytes / 16)
        d.io.readEnable.poke(false.B); d.io.output.ready.poke(false.B)
      }
      def fill(bytes: Int, group: Int, last: Boolean, firstWord: Int, streamLast: Boolean): Unit = {
        d.io.reserveRefill.valid.poke(true.B)
        d.io.reserveRefill.bits.payloadBytes.poke(bytes.U)
        d.io.reserveRefill.bits.groupIndex.poke(group.U)
        d.io.reserveRefill.bits.lastInGroup.poke(last.B)
        d.io.reserveRefill.ready.expect(true.B); d.clock.step()
        d.io.reserveRefill.valid.poke(false.B)
        val data = (0 until bytes / 16).foldLeft(BigInt(0))((a, lane) =>
          a | (word(firstWord + lane) << (lane * 128)))
        d.io.memoryDataValid.poke(true.B); d.io.memoryData.poke(data.U)
        d.io.memoryLaneValidMask.poke(((1 << (bytes / 16)) - 1).U)
        d.io.memoryChunkLast.poke(true.B); d.io.memoryStreamLast.poke(streamLast.B)
        d.io.memoryDataReady.expect(true.B); d.clock.step(); d.io.memoryDataValid.poke(false.B)
      }
      fill(48, 0, false, 0, false)
      d.io.readiness.readableBytesThisPass.expect(48.U)
      fill(32, 0, true, 3, false)
      d.io.readiness.readableBytesThisPass.expect(80.U)
      fill(16, 1, true, 5, true)
      d.io.readiness.readableBytesThisPass.expect(80.U) // exclude next group
      d.io.readiness.nextRequiredChunkReady.expect(true.B)
      d.io.readEnable.poke(true.B); d.clock.step()
      d.io.output.valid.expect(true.B)
      d.io.readiness.readableBytesThisPass.expect(80.U) // issued but not accepted
      d.clock.step(2)
      d.io.readiness.readableBytesThisPass.expect(80.U)
      d.io.output.ready.poke(true.B)
      val afterEach = Seq(64, 48, 32, 16, 16, 0)
      for (i <- 0 until 6) {
        d.io.output.valid.expect(true.B)
        d.io.output.bits.data.expect(word(i).U)
        d.clock.step()
        d.io.readiness.readableBytesThisPass.expect(afterEach(i).U)
      }
      d.io.idle.expect(true.B)
    }
  }

  it should "finish a prepared 16B tail with compute ready driven by impending in hardware" in {
    test(new WeightBufferStatusFeedbackHarness) { d =>
      d.io.start.poke(false.B); d.io.grant.poke(false.B)
      d.io.memoryValid.poke(false.B); d.io.memoryData.poke(word(0).U)
      d.reset.poke(true.B); d.clock.step(2); d.reset.poke(false.B); d.clock.step()
      d.io.contextReady.expect(true.B)
      d.io.start.poke(true.B); d.clock.step(); d.io.start.poke(false.B)
      d.io.impending.expect(true.B)
      d.io.grant.poke(true.B); d.io.requestValid.expect(true.B); d.clock.step()
      d.io.grant.poke(false.B)
      d.io.memoryValid.poke(true.B); d.io.memoryReady.expect(true.B); d.clock.step()
      d.io.memoryValid.poke(false.B)
      d.io.impending.expect(false.B)
      var done = 0
      for (_ <- 0 until 8) {
        if (yes(d.io.done)) {
          d.io.dataValid.expect(true.B); d.io.data.expect(word(0).U); d.io.last.expect(true.B)
          done += 1
        }
        d.io.impending.expect(false.B)
        d.clock.step()
      }
      assert(done == 1)
      d.io.state.expect(WeightBufferControllerState.DONE)
    }
  }
}
