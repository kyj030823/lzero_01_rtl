package npu.core.memory

import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec
import WbAcceptanceSupport._

/** 명세 acceptance 중 fusion 순서를 제외한 부족한 경계 조건을 검증한다. */
class WeightBufferAcceptanceSpec extends AnyFlatSpec with ChiselScalatestTester {
  behavior of "WB v3 acceptance"

  it should "stop at committed LUT bytes then request weight on the next clock and overlap both ports" in {
    WbEvidence.run("lut-commit-transition", Seq(5, 6), "부분 LUT 출력, RLAST 다음 clock 요청, 실제 동시 수락") { log =>
      test(new ObservedWeightBuffer) { d =>
        val x = new Driver(d, log); x.initialize(); x.begin(Job(10, lut = 256))
        x.credit(64); x.sendLut(0, 64)
        d.io.lutDataReady.poke(true.B)
        x.waitUntil(x.lutOut == 4)
        val issues = x.readIssues
        for (_ <- 0 until 8) {
          d.io.lutDataValid.expect(false.B); d.observedReadIssue.expect(false.B); x.tick()
        }
        assert(x.readIssues == issues)
        d.io.lutDataReady.poke(false.B)
        // 마지막 valid만으로 완료하면 안 된다. Credit이 없을 때 수락을 지연시킨다.
        x.offer(lut = true, 64, 64, last = false, streamLast = false)
        for (_ <- 0 until 3) { d.io.memoryDataReady.expect(false.B); x.tick() }
        x.idleMemory(); x.credit(192); x.sendLut(64, 128)
        x.offer(lut = true, 192, 64, last = true, streamLast = true)
        d.io.refillRequestValid.expect(false.B); d.io.lutReceiveDone.expect(true.B)
        val lastReceive = x.cycle
        x.tick(); x.idleMemory()
        d.io.refillRequestValid.expect(true.B)
        log.metrics("receiveCycle") = lastReceive
        log.metrics("eligibleCycle") = x.cycle
        for (_ <- 0 until 3) {
          d.io.refillRequestBytes.expect(256.U); d.io.refillRequestValid.expect(true.B); x.tick()
        }
        x.grant()
        d.io.lutDataReady.poke(true.B)
        x.sendActive()
        assert(x.overlapCount > 0, "LUT output.fire and weight input.fire must coincide")
        x.waitUntil(x.lutOut == 16)
        x.consumeAll(); x.finish()
        log.metrics("earlyOutputBeats") = 4
        log.metrics("guardPauseCycles") = 8
      }
    }
  }

  it should "preserve every LUT tail at ordinary physical and extended wrap boundaries" in {
    WbEvidence.run("lut-tail-wrap", Seq(7, 11), "4종 tail과 실제 traffic으로 만든 16KiB/32KiB wrap") { log =>
      test(new ObservedWeightBuffer) { d =>
        val x = new Driver(d, log); x.initialize()
        var id = 20
        def one(lut: Int): Unit = {
          val start = x.writtenAbsolute
          x.begin(Job(id, lut = lut)); id += 1
          x.credit(lut); x.sendLut(0, lut)
          d.io.initialReady.expect(false.B); d.io.impending.expect(true.B)
          x.grant(); x.sendActive()
          d.io.initialReady.expect(true.B)
          d.io.computeDataValid.expect(false.B) // LUT tail을 앞질러 출력할 수 없다.
          for (_ <- 0 until 3) x.tick()
          d.io.lutDataReady.poke(true.B); x.waitUntil(x.lutOut == lut / 16, lut / 16 + 8)
          x.consumeAll(); x.finish()
          log.metrics("boundary-" + (id - 1)) = Map("startAbsolute" -> start,
            "lutEndAbsolute" -> (start + lut), "endLane" -> ((start + lut) % 64 / 16))
        }
        for (lut <- Seq(80, 96, 112, 128)) {
          x.padTo((x.writtenAbsolute + 63) / 64 * 64, id); id += 1
          one(lut)
        }
        x.padTo(16320, id); id += 1; one(80)
        x.padTo(32704, id); id += 1; one(112)
        log.metrics("tailCases") = 6
        log.metrics("finalWriteAbsolute") = x.writtenAbsolute
      }
    }
  }

  it should "count a held LUT in the same four-entry budget and resume after its release" in {
    WbEvidence.run("lut-entry-budget", Seq(6, 10), "LUT 1개와 weight 3개가 공통 entry 4개를 채움") { log =>
      test(new ObservedWeightBuffer) { d =>
        val x = new Driver(d, log); x.initialize(); x.begin(Job(40, passes = 4, lut = 48))
        x.credit(48); x.sendLut(0, 48)
        for (_ <- 0 until 3) { x.grant(); x.sendActive() }
        assert(x.entries == 4 && number(d.io.freeBytes) >= 4096)
        for (_ <- 0 until 4) {
          d.io.full.expect(false.B); d.io.refillRequestValid.expect(false.B); x.tick()
        }
        d.io.lutDataReady.poke(true.B)
        x.waitUntil(x.lutOut == 3)
        d.io.refillRequestValid.expect(true.B)
        x.grant(); x.sendActive()
        x.consumeAll(); x.finish()
        log.metrics("blockedWithFreeBytes") = 16384 - 48 - 3 * 256
      }
    }
  }

  it should "fill exactly sixteen KiB once and replay three passes continuously until final acceptance" in {
    WbEvidence.run("full-cache-final", Seq(2, 13), "16KiB unique fill, 3회 replay, 마지막 출력 backpressure") { log =>
      test(new ObservedWeightBuffer) { d =>
        val x = new Driver(d, log); x.initialize()
        x.begin(Job(50, bytes = 16384, passes = 3, cache = true))
        x.grant(); x.sendActive()
        d.io.initialReady.expect(true.B); d.io.weightCacheReady.expect(false.B)
        d.io.readEnable.poke(true.B); d.io.computeDataReady.poke(true.B)
        for (_ <- 0 until 3) { x.grant(); x.sendActive() }
        d.io.weightCacheReady.expect(true.B); d.io.weightSupplyComplete.expect(true.B)
        d.io.freeBytes.expect(0.U)
        while (x.weightOut < x.job.outputs - 1) {
          d.io.computeDataValid.expect(true.B); d.io.impending.expect(false.B)
          if (x.weightOut < 2048) d.io.freeBytes.expect(0.U)
          x.tick()
        }
        d.io.computeDataReady.poke(false.B)
        for (_ <- 0 until 5) {
          d.io.computeDataValid.expect(true.B); d.io.computeDataLast.expect(true.B)
          d.io.operationDone.expect(false.B); x.tick()
        }
        d.io.computeDataReady.poke(true.B); x.tick(); x.finish()
        assert(x.passCount == 3 && x.requestCount == 4)
        assert(x.lastOutputCycle - x.firstOutputCycle + 1 == 3072 + 5)
        log.metrics("expectedInputBytes") = 16384
        log.metrics("expectedOutputBeats") = 3072
        log.metrics("finalHoldCycles") = 5
      }
    }
  }

  it should "keep disabled constant and zero-length contexts independent of LUT-only initialization" in {
    WbEvidence.run("special-contexts", Seq(11, 12), "3종 무연산 context × LUT 유무와 다음 정상 context") { log =>
      test(new ObservedWeightBuffer) { d =>
        val x = new Driver(d, log); x.initialize()
        val jobs = for (lut <- Seq(0, 80); mode <- 0 until 3) yield mode match {
          case 0 => Job(60 + lut / 10, enabled = false, lut = lut)
          case 1 => Job(61 + lut / 10, bytes = 80, vpu = true, constant = true, lut = lut)
          case _ => Job(62 + lut / 10, bytes = 0, lut = lut)
        }
        for (j <- jobs) {
          x.begin(j)
          if (j.lut > 0) {
            x.credit(j.lut); d.io.lutDataReady.poke(true.B); x.sendLut(0, j.lut)
            x.waitUntil(x.lutOut == j.lut / 16, j.lut / 16 + 8)
          }
          x.finish()
        }
        x.begin(Job(75)); x.grant(); x.sendActive(); x.consumeAll(); x.finish()
        log.metrics("specialCases") = 6
      }
    }
  }

  it should "drain a held SRAM response before accepting a different context" in {
    WbEvidence.run("reader-context-drain", Seq(14), "발행 후 readEnable 해제, 응답 hold, 다음 context 분리") { log =>
      test(new ObservedWeightBuffer) { d =>
        val x = new Driver(d, log); x.initialize(); x.begin(Job(80, bytes = 16, vpu = true))
        x.grant(); x.sendActive()
        d.io.readEnable.poke(true.B)
        x.waitUntil(yes(d.observedReadIssue))
        x.tick() // 1cycle SRAM 응답이 올 때부터 새로운 read는 막는다.
        d.io.readEnable.poke(false.B)
        configure(d, Job(81, bytes = 16, vpu = true))
        for (_ <- 0 until 5) {
          d.io.computeDataValid.expect(true.B); d.io.contextReady.expect(false.B)
          d.observedReadIdle.expect(false.B); d.observedReadIssue.expect(false.B)
          x.tick()
        }
        d.io.computeDataReady.poke(true.B); x.tick(); x.finish()
        x.begin(Job(81, bytes = 16, vpu = true))
        x.grant(); x.sendActive(); x.consumeAll(); x.finish()
        log.metrics("responseHoldCycles") = 5
      }
    }
  }

  it should "separate real WB completion from modeled programming and central holding in five timing orders" in {
    WbEvidence.run("programming-timings", Seq(8, 9), "실제 WB + CCU/programming 동작 모형; 실제 unit 통합은 별도") { log =>
      test(new ObservedWeightBuffer) { d =>
        val x = new Driver(d, log); x.initialize()
        val orders = Seq("W-S-P", "S-W-P", "S-P-W", "S-W=P", "S=W-P")
        for ((order, index) <- orders.zipWithIndex) {
          var programmed = false
          var ubReady = true
          def controls(): Unit = {
            log.extra = Map("timingOrder" -> order, "modelProgrammed" -> programmed,
              "modelHolding" -> !programmed, "modelUbReady" -> ubReady)
            d.io.readEnable.poke(programmed.B)
            d.io.computeDataReady.poke((programmed && ubReady && !yes(d.io.impending)).B)
          }
          x.begin(Job(90 + index, lut = 256)); controls()
          x.credit(256); x.sendLut(0, 256)
          def stream(): Unit = {
            d.io.lutDataReady.poke(true.B)
            x.waitUntil(x.lutOut == 16, 24)
          }
          def weight(): Unit = { x.grant(); x.sendActive() }
          def finishProgramming(): Unit = {
            assert(x.lutOut == 16)
            for (_ <- 0 until 4) { controls(); x.tick() }
            programmed = true; controls()
          }
          order match {
            case "W-S-P" => weight(); stream(); finishProgramming()
            case "S-W-P" => stream(); weight(); finishProgramming()
            case "S-P-W" =>
              stream(); finishProgramming()
              d.io.initialReady.expect(false.B); d.io.impending.expect(true.B)
              x.tick(); weight()
            case "S-W=P" =>
              stream(); x.grant()
              for (offset <- Seq(0, 64, 128)) {
                x.offer(lut = false, offset, 64, last = false, streamLast = false); x.tick()
              }
              programmed = true; controls()
              x.offer(lut = false, 192, 64, last = true, streamLast = true); x.tick(); x.idleMemory()
            case "S=W-P" =>
              x.grant()
              for (offset <- Seq(0, 64, 128)) {
                x.offer(lut = false, offset, 64, last = false, streamLast = false); x.tick()
              }
              x.idleMemory(); d.io.lutDataReady.poke(true.B)
              x.waitUntil(x.lutOut == 15, 24)
              x.offer(lut = false, 192, 64, last = true, streamLast = true)
              d.io.lutStreamDone.expect(true.B); x.tick(); x.idleMemory(); finishProgramming()
          }
          controls()
          assert(x.weightIn == 256 && x.lutOut == 16 && x.weightOut == 0)
          d.io.initialReady.expect(true.B); d.io.impending.expect(false.B)
          // Programming이 끝나도 다른 buffer가 준비되지 않으면 compute는 대기한다.
          ubReady = false; controls()
          for (_ <- 0 until 3) { x.tick(); controls() }
          assert(x.weightOut == 0)
          ubReady = true; controls(); x.consumeAll(); x.finish()
          log.metrics("timing-" + order) = Map("verified" -> true, "scope" -> "external behavioral model")
        }
        log.extra = Map.empty
        log.metrics("timingCases") = 5
        log.metrics("realCcuAndProgrammerConnected") = false
      }
    }
  }
}
