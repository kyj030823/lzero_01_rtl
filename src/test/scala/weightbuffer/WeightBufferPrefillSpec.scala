package npu.core.memory

import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec
import scala.language.reflectiveCalls

/** SRAM 데이터, replay 순서, 예약 identity를 실제 출력과 대조한다. */
class WeightBufferPrefillSpec extends AnyFlatSpec with ChiselScalatestTester {
  behavior of "WB context prefill"

  private case class Job(id: Int, bytes: Int = 256, passes: Int = 1,
    cache: Boolean = false, lutBytes: Int = 0)
  private def yes(x: Bool) = x.peek().litToBoolean
  private def word(j: Job, i: Int): BigInt =
    (BigInt(j.id) << 96) | (BigInt(i + 1) << 32) | BigInt(0x12340000L + i)
  private def configure(d: WeightBufferDataPath, j: Job): Unit = {
    d.io.config.bufferEnable.poke(true.B)
    d.io.config.operationMode.poke(WeightBufferOperationMode.GEMM)
    d.io.config.reuseMode.poke(if (j.cache) WeightBufferReuseMode.LOCAL_WEIGHT_CACHE else WeightBufferReuseMode.STREAM)
    d.io.config.fusionEnable.poke(false.B)
    d.io.config.weightSet0Bytes.poke(j.bytes.U)
    d.io.config.weightSet1Bytes.poke(0.U)
    d.io.config.weightReplayCount.poke(j.passes.U)
    d.io.config.inputRowCount.poke(j.passes.U)
    d.io.config.reductionTileCount.poke((j.bytes / 256).U)
    d.io.config.outputColumnCount.poke(1.U)
    d.io.config.operand2PayloadBytes.poke(0.U)
    d.io.config.constantOperandEnable.poke(false.B)
    d.io.config.lutLoadEnable.poke((j.lutBytes > 0).B)
    d.io.config.lutPayloadBytes.poke(j.lutBytes.U)
    d.io.config.lutTargetEnableMask.poke(3.U)
    d.io.config.normalImpendingThresholdBytes.poke(128.U)
    d.io.config.contextId.poke(j.id.U)
  }
  private def init(d: WeightBufferDataPath): Unit = {
    d.clock.setTimeout(30000)
    configure(d, Job(1))
    d.io.contextStart.poke(false.B); d.io.prefillStart.poke(false.B)
    d.io.softReset.poke(false.B); d.io.readEnable.poke(false.B)
    d.io.computeDataReady.poke(false.B); d.io.refillRequestReady.poke(false.B)
    d.io.lutCreditValid.poke(false.B); d.io.lutCreditBytes.poke(16.U)
    d.io.lutDataReady.poke(false.B)
    d.io.memoryDataValid.poke(false.B); d.io.memoryData.poke(0.U)
    d.io.memoryLaneValidMask.poke(15.U)
    d.io.memoryChunkLast.poke(false.B); d.io.memoryStreamLast.poke(false.B)
    d.io.memoryContextId.poke(1.U); d.io.memoryDataKind.poke(WeightBufferDataKind.WEIGHT)
    d.reset.poke(true.B); d.clock.step(2); d.reset.poke(false.B); d.clock.step()
  }
  private def begin(d: WeightBufferDataPath, j: Job): Unit = {
    configure(d, j)
    d.io.contextStart.poke(true.B)
    d.io.contextReady.expect(true.B); d.io.contextAccepted.expect(true.B)
    d.clock.step(); d.io.contextStart.poke(false.B)
    d.io.contextActive.expect(true.B)
  }
  private def prefill(d: WeightBufferDataPath, j: Job): Unit = {
    configure(d, j)
    d.io.prefillReady.expect(true.B) // ready는 start를 올리기 전에도 확인할 수 있어야 한다.
    d.io.prefillStart.poke(true.B)
    d.io.prefillReady.expect(true.B); d.io.prefillAccepted.expect(true.B)
    d.clock.step(); d.io.prefillStart.poke(false.B)
    d.io.prefillPending.expect(true.B)
  }
  private def grant(d: WeightBufferDataPath, j: Job, bytes: Int, group: Int,
    ahead: Boolean = false): Unit = {
    d.io.refillRequestReady.poke(true.B)
    var n = 0
    while (!yes(d.io.refillRequestValid) && n < 10) { d.clock.step(); n += 1 }
    d.io.refillRequestValid.expect(true.B)
    d.io.refillRequestBytes.expect(bytes.U)
    d.io.refillRequestContextId.expect(j.id.U)
    d.io.refillRequestGroupIndex.expect(group.U)
    d.io.refillRequestIsPrefill.expect(ahead.B)
    d.clock.step(); d.io.refillRequestReady.poke(false.B)
  }
  private def send(d: WeightBufferDataPath, j: Job, bytes: Int, offset: Int,
    end: Boolean, lut: Boolean = false): Unit = {
    for (sent <- 0 until bytes by 64) {
      val size = math.min(64, bytes - sent)
      val data = (0 until size / 16).foldLeft(BigInt(0))((v, lane) =>
        v | (word(j, (offset + sent) / 16 + lane) << (128 * lane)))
      d.io.memoryDataValid.poke(true.B); d.io.memoryData.poke(data.U)
      d.io.memoryLaneValidMask.poke(((1 << (size / 16)) - 1).U)
      d.io.memoryChunkLast.poke((sent + size == bytes).B)
      d.io.memoryStreamLast.poke((sent + size == bytes && end).B)
      d.io.memoryContextId.poke(j.id.U)
      d.io.memoryDataKind.poke(if (lut) WeightBufferDataKind.LUT else WeightBufferDataKind.WEIGHT)
      d.io.memoryDataReady.expect(true.B); d.clock.step()
    }
    d.io.memoryDataValid.poke(false.B)
  }
  private def take(d: WeightBufferDataPath, j: Job, start: Int, count: Int): Unit = {
    d.io.readEnable.poke(true.B); d.io.computeDataReady.poke(true.B)
    for (i <- start until start + count) {
      var n = 0
      while (!yes(d.io.computeDataValid) && n < 8) { d.clock.step(); n += 1 }
      assert(n == 0 || i == start, "prepared output must remain continuous within a take")
      val pass = i / (j.bytes / 16)
      val last = i == j.bytes / 16 * j.passes - 1
      d.io.computeDataValid.expect(true.B)
      d.io.computeData.expect(word(j, i % (j.bytes / 16)).U)
      d.io.passIndex.expect(pass.U)
      d.io.computeDataLast.expect(last.B); d.io.operationDone.expect(last.B)
      d.io.passDone.expect((i % (j.bytes / 16) == j.bytes / 16 - 1).B)
      d.clock.step()
    }
    d.io.computeDataReady.poke(false.B)
  }
  private def finish(d: WeightBufferDataPath): Unit = {
    var n = 0
    while (yes(d.io.contextActive) && n < 8) { d.clock.step(); n += 1 }
    d.io.contextActive.expect(false.B)
    d.io.computeDataValid.expect(false.B)
  }

  it should "keep LUT, final-use CACHE and prefetched CACHE in one FIFO without mixing outputs" in {
    test(new WeightBufferDataPath) { d =>
      init(d)
      val a = Job(22, cache = true, lutBytes = 80)
      val b = Job(23, bytes = 512, passes = 2, cache = true)
      begin(d, a)
      d.io.lutCreditBytes.poke(80.U); d.io.lutCreditValid.poke(true.B)
      d.io.lutCreditReady.expect(true.B); d.clock.step(); d.io.lutCreditValid.poke(false.B)
      send(d, a, 80, 1008, end = true, lut = true)
      grant(d, a, 256, 0); send(d, a, 256, 0, end = true)
      d.io.lutDataValid.expect(true.B)
      d.io.lutData.expect(word(a, 63).U)
      d.io.computeDataValid.expect(false.B)
      // LUT가 head에 남아 있어도 마지막 한 번 쓸 A cache의 descriptor를 B에 양도한다.
      prefill(d, b)
      grant(d, b, 512, 0, ahead = true); send(d, b, 512, 0, end = true)
      d.io.lutData.expect(word(a, 63).U)
      d.io.computeDataValid.expect(false.B)
      d.io.lutDataReady.poke(true.B)
      for (i <- 0 until 5) {
        d.io.lutDataValid.expect(true.B)
        d.io.lutData.expect(word(a, 63 + i).U)
        d.io.lutDataLast.expect((i == 4).B)
        d.io.passDone.expect(false.B) // LUT 종료를 weight pass 완료로 내보내지 않는다.
        d.io.operationDone.expect(false.B)
        d.clock.step()
      }
      d.io.lutDataValid.expect(false.B)
      take(d, a, 0, 16); finish(d)
      begin(d, b)
      d.io.initialReady.expect(true.B); d.io.weightCacheReady.expect(true.B)
      take(d, b, 0, 64); finish(d)
      d.io.freeBytes.expect(16384.U)
    }
  }


  it should "prefill CACHE behind STREAM and preserve ready data across activation with wide identities" in {
    test(new WeightBufferDataPath(contextIdWidth = 12, payloadByteWidth = 20, countWidth = 8)) { d =>
      init(d)
      val a = Job(300, passes = 2); val b = Job(701, bytes = 512, passes = 3, cache = true)
      begin(d, a)
      grant(d, a, 256, 0); send(d, a, 256, 0, end = false)
      configure(d, b); d.io.prefillReady.expect(false.B)
      grant(d, a, 256, 1); send(d, a, 256, 0, end = true)
      prefill(d, b)
      grant(d, b, 512, 0, ahead = true); send(d, b, 512, 0, end = true)
      // 아직 A를 읽는다. B descriptor의 replayCount/passIndex를 사용하면 안 된다.
      d.io.initialReady.expect(true.B); d.io.weightSupplyComplete.expect(true.B)
      take(d, a, 0, 32); finish(d)
      d.io.freeBytes.expect((16384 - 512).U)
      begin(d, b); d.io.prefillPending.expect(false.B)
      d.io.initialReady.expect(true.B); d.io.weightCacheReady.expect(true.B)
      d.io.weightSupplyComplete.expect(true.B); d.io.refillRequestValid.expect(false.B)
      take(d, b, 0, 96); finish(d)
      d.io.freeBytes.expect(16384.U)
    }
  }

  it should "hand the single cache descriptor to the next CACHE only on the final pass" in {
    test(new WeightBufferDataPath) { d =>
      init(d)
      val a = Job(1, bytes = 512, passes = 3, cache = true)
      val b = Job(2, passes = 2, cache = true)
      begin(d, a); grant(d, a, 512, 0); send(d, a, 512, 0, end = true)
      configure(d, b); d.io.prefillStart.poke(true.B)
      d.io.prefillReady.expect(false.B); d.clock.step(2); d.io.prefillStart.poke(false.B)
      take(d, a, 0, 32); configure(d, b); d.io.prefillReady.expect(false.B)
      take(d, a, 32, 32)
      prefill(d, b)
      // A의 출력이 stall된 상태에서 B를 수신해도 보관된 data/metadata는 변하지 않는다.
      val held = d.io.computeData.peek().litValue
      grant(d, b, 256, 0, ahead = true); send(d, b, 256, 0, end = true)
      d.io.computeData.expect(held.U)
      take(d, a, 64, 32); finish(d)
      begin(d, b); take(d, b, 0, 32); finish(d)
      d.io.freeBytes.expect(16384.U)
    }
  }

  it should "activate a prefetched STREAM with a response outstanding and reject stale context responses" in {
    test(new WeightBufferDataPath) { d =>
      init(d)
      val a = Job(3, bytes = 8192, cache = true)
      val b = Job(4, bytes = 8192, passes = 2)
      begin(d, a)
      grant(d, a, 4096, 0); send(d, a, 4096, 0, end = false)
      configure(d, b); d.io.prefillReady.expect(false.B) // final pass라도 원본 수신 중에는 불가
      grant(d, a, 4096, 0); send(d, a, 4096, 4096, end = true)
      take(d, a, 0, 256)
      prefill(d, b)
      grant(d, b, 4096, 0, ahead = true); send(d, b, 4096, 0, end = false)
      grant(d, b, 4096, 0, ahead = true) // B 두 번째 chunk는 미도착
      take(d, a, 256, 256); finish(d)
      d.io.refillPending.expect(true.B)
      begin(d, b) // A의 drain 판단에 B의 outstanding을 포함하면 여기서 막힌다.
      d.io.refillPending.expect(true.B); d.io.initialReady.expect(true.B)
      d.io.memoryDataValid.poke(true.B); d.io.memoryContextId.poke(a.id.U)
      d.io.memoryChunkLast.poke(false.B); d.io.memoryStreamLast.poke(false.B)
      d.io.memoryDataReady.expect(false.B); d.clock.step(3)
      send(d, b, 4096, 4096, end = false)
      // B의 STREAM 공급 counter도 활성화 전에 승인된 부분부터 이어진다.
      grant(d, b, 4096, 1); send(d, b, 4096, 0, end = false)
      grant(d, b, 4096, 1); send(d, b, 4096, 4096, end = true)
      take(d, b, 0, 1024); finish(d)
      d.io.freeBytes.expect(16384.U)
    }
  }

  it should "resume next CACHE refill after final drain returns at least 4KiB" in {
    test(new WeightBufferDataPath) { d =>
      init(d)
      val a = Job(5, bytes = 12288, passes = 2, cache = true)
      val b = Job(6, bytes = 8192, passes = 2, cache = true)
      begin(d, a)
      // A의 pinned cache entry 세 개와 B의 첫 entry로 전체 SRAM을 채운다.
      for (i <- 0 until 3) {
        grant(d, a, 4096, 0); send(d, a, 4096, i * 4096, end = i == 2)
      }
      take(d, a, 0, 768); prefill(d, b)
      grant(d, b, 4096, 0, ahead = true); send(d, b, 4096, 0, end = false)
      d.io.freeBytes.expect(0.U); d.io.full.expect(true.B)
      d.io.refillRequestValid.expect(false.B)
      take(d, a, 768, 255)
      d.io.refillRequestValid.expect(false.B) // chunk의 마지막 16B도 수락하기 전에는 반환하지 않는다.
      take(d, a, 1023, 1)
      grant(d, b, 4096, 0, ahead = true); send(d, b, 4096, 4096, end = true)
      take(d, a, 1024, 512); finish(d)
      begin(d, b); take(d, b, 0, 1024); finish(d)
      d.io.freeBytes.expect(16384.U)
    }
  }

  it should "reject unsupported or ambiguous prefill and require the approved configuration at activation" in {
    test(new WeightBufferDataPath) { d =>
      init(d)
      val a = Job(7); val b = Job(8, cache = true)
      begin(d, a); grant(d, a, 256, 0); send(d, a, 256, 0, end = true)
      d.io.prefillStart.poke(true.B)
      for (j <- Seq(b.copy(lutBytes = 16), b.copy(id = a.id), b.copy(bytes = 0))) {
        configure(d, j); d.io.prefillReady.expect(false.B)
        d.io.prefillAccepted.expect(false.B); d.clock.step()
      }
      configure(d, b); d.io.config.inputRowCount.poke(2.U)
      d.io.configValid.expect(false.B); d.io.prefillReady.expect(false.B); d.clock.step()
      d.io.prefillStart.poke(false.B); prefill(d, b)
      grant(d, b, 256, 0, ahead = true); send(d, b, 256, 0, end = true)
      take(d, a, 0, 16); finish(d)
      configure(d, b.copy(bytes = 512)); d.io.contextStart.poke(true.B)
      d.io.contextReady.expect(false.B); d.io.contextAccepted.expect(false.B); d.clock.step(2)
      d.io.contextStart.poke(false.B)
      begin(d, b); take(d, b, 0, 16); finish(d)
    }
  }

  it should "keep a next CACHE descriptor when prefill coincides with the previous final output" in {
    test(new WeightBufferDataPath) { d =>
      init(d)
      val a = Job(9, cache = true); val b = Job(10, passes = 2, cache = true)
      begin(d, a); grant(d, a, 256, 0); send(d, a, 256, 0, end = true)
      take(d, a, 0, 15)
      configure(d, b); d.io.prefillStart.poke(true.B); d.io.computeDataReady.poke(true.B)
      d.io.operationDone.expect(true.B); d.io.prefillAccepted.expect(true.B)
      d.clock.step(); d.io.prefillStart.poke(false.B); d.io.computeDataReady.poke(false.B)
      finish(d)
      grant(d, b, 256, 0, ahead = true); send(d, b, 256, 0, end = true)
      begin(d, b); d.io.weightCacheReady.expect(true.B)
      take(d, b, 0, 32); finish(d)
    }
  }

  it should "start a fresh LUT at the previous tail without resetting the normal FIFO" in {
    test(new WeightBufferDataPath) { d =>
      init(d)
      val a = Job(11); val b = Job(12, passes = 2, cache = true, lutBytes = 16)
      begin(d, a); grant(d, a, 256, 0); send(d, a, 256, 0, end = true)
      take(d, a, 0, 16); finish(d)
      begin(d, b)
      d.io.lutCreditValid.poke(true.B); d.io.lutCreditReady.expect(true.B)
      d.clock.step(); d.io.lutCreditValid.poke(false.B)
      send(d, b, 16, 1008, end = true, lut = true)
      grant(d, b, 256, 0); send(d, b, 256, 0, end = true)
      d.io.lutDataReady.poke(true.B)
      var n = 0
      while (!yes(d.io.lutDataValid) && n < 8) { d.clock.step(); n += 1 }
      d.io.lutDataValid.expect(true.B); d.io.lutData.expect(word(b, 63).U)
      d.io.lutDataLast.expect(true.B); d.clock.step()
      take(d, b, 0, 32); finish(d)
      d.io.freeBytes.expect(16384.U)
    }
  }

  it should "flush both queued contexts after all responses are drained" in {
    test(new WeightBufferDataPath) { d =>
      init(d)
      val a = Job(13); val b = Job(14, cache = true)
      begin(d, a); grant(d, a, 256, 0); send(d, a, 256, 0, end = true)
      prefill(d, b); grant(d, b, 256, 0, ahead = true); send(d, b, 256, 0, end = true)
      d.io.softReset.poke(true.B); d.clock.step(); d.io.softReset.poke(false.B)
      d.io.prefillPending.expect(false.B); d.io.contextActive.expect(false.B)
      d.io.freeBytes.expect(16384.U); d.io.refillPending.expect(false.B)
      val c = Job(15, passes = 2, cache = true)
      begin(d, c); grant(d, c, 256, 0); send(d, c, 256, 0, end = true)
      take(d, c, 0, 32); finish(d)
    }
  }

  it should "block the fifth metadata entry even when more than 4KiB of byte space is free" in {
    test(new WeightBufferDataPath) { d =>
      init(d)
      val a = Job(16, passes = 4); val b = Job(17, cache = true, passes = 2)
      begin(d, a)
      for (g <- 0 until 4) {
        grant(d, a, 256, g); send(d, a, 256, 0, end = g == 3)
      }
      prefill(d, b)
      d.io.freeBytes.expect(15360.U); d.io.full.expect(false.B)
      d.io.refillRequestReady.poke(true.B)
      d.io.refillRequestValid.expect(false.B); d.clock.step(3)
      d.io.refillRequestReady.poke(false.B)
      // A 첫 entry가 최종 소비된 다음 cycle부터 B를 예약할 수 있다.
      take(d, a, 0, 16)
      grant(d, b, 256, 0, ahead = true); send(d, b, 256, 0, end = true)
      take(d, a, 16, 48); finish(d)
      begin(d, b); take(d, b, 0, 32); finish(d)
      d.io.freeBytes.expect(16384.U)
    }
  }

  it should "commit the final prefetched response on the context activation cycle" in {
    test(new WeightBufferDataPath) { d =>
      init(d)
      val a = Job(18); val b = Job(19, cache = true, passes = 2)
      begin(d, a); grant(d, a, 256, 0); send(d, a, 256, 0, end = true)
      prefill(d, b); grant(d, b, 256, 0, ahead = true)
      for (offset <- 0 until 192 by 64) {
        val data = (0 until 4).foldLeft(BigInt(0))((v, lane) =>
          v | (word(b, offset / 16 + lane) << (128 * lane)))
        d.io.memoryDataValid.poke(true.B); d.io.memoryData.poke(data.U)
        d.io.memoryLaneValidMask.poke(15.U); d.io.memoryContextId.poke(b.id.U)
        d.io.memoryChunkLast.poke(false.B); d.io.memoryStreamLast.poke(false.B)
        d.io.memoryDataReady.expect(true.B); d.clock.step()
      }
      d.io.memoryDataValid.poke(false.B)
      take(d, a, 0, 16); finish(d)
      val tail = (0 until 4).foldLeft(BigInt(0))((v, lane) =>
        v | (word(b, 12 + lane) << (128 * lane)))
      d.io.memoryDataValid.poke(true.B); d.io.memoryData.poke(tail.U)
      d.io.memoryChunkLast.poke(true.B); d.io.memoryStreamLast.poke(true.B)
      d.io.memoryDataReady.expect(true.B)
      begin(d, b) // 이 clock edge에서 context 수락과 마지막 응답 commit이 동시에 일어난다.
      d.io.memoryDataValid.poke(false.B)
      d.io.initialReady.expect(true.B); d.io.weightCacheReady.expect(true.B)
      d.io.weightSupplyComplete.expect(true.B); d.io.refillPending.expect(false.B)
      take(d, b, 0, 32); finish(d)
    }
  }


  it should "reject a global reset while the next context still has an outstanding response" in {
    assertThrows[ChiselAssertionError] {
      test(new WeightBufferDataPath) { d =>
        init(d)
        val a = Job(20); val b = Job(21, cache = true)
        begin(d, a); grant(d, a, 256, 0); send(d, a, 256, 0, end = true)
        prefill(d, b); grant(d, b, 256, 0, ahead = true)
        // A reader와 A 응답은 idle이어도 B의 미도착 응답을 폐기할 수 없다.
        d.io.softReset.poke(true.B); d.clock.step()
      }
    }
  }


}
