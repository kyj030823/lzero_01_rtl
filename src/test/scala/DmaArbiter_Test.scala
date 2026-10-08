package npu.core.memory

import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec
import scala.collection.mutable.ArrayBuffer

// Test-only visibility; the production interface remains unchanged.
class DmaArbiterProbe(params: DmaArbiterParams) extends DmaArbiter(params) {
  val debug = IO(Output(new Bundle {
    val ages = Vec(DmaTarget.Count, UInt(params.ageWidth.W))
    val dram_rr = UInt(DmaTarget.Width.W)
    val ib_rr = UInt(DmaTarget.Width.W)
    val target_busy = Vec(DmaTarget.Count, Bool())
  }))
  debug.ages := age
  debug.dram_rr := dramRrPtr
  debug.ib_rr := ibRrPtr
  debug.target_busy := targetBusy
}

class DmaArbiter_Test extends AnyFlatSpec with ChiselScalatestTester {
  behavior of "DmaArbiter"

  private def identity(id: DmaRequestIdentity, value: Int): Unit = {
    id.plan_id.poke(value.U)
    id.context_id.poke(7.U)
    id.epoch.poke(2.U)
    id.refill_id.poke((value + 100).U)
  }

  private def drivePlan(dut: DmaArbiterProbe, target: Int, source: DmaSource.Type, id: Int): Unit = {
    val plan = dut.io.plan_in.bits
    identity(plan.identity, id)
    plan.target.poke(target.U)
    plan.source.poke(source)
    plan.src_addr.poke((0x1000 + id * 64).U)
    plan.bytes.poke(64.U)
    plan.dst_offset.poke((id * 64).U)
    plan.logical_offset.poke((id * 64).U)
    plan.chunk_end.poke(true.B)
    plan.loop_end.poke(false.B)
    plan.final_supply.poke(false.B)
  }

  private def init(dut: DmaArbiterProbe): Unit = {
    dut.io.plan_in.valid.poke(false.B)
    drivePlan(dut, DmaTarget.UB, DmaSource.DRAM, 0)
    dut.io.dram_issue.ready.poke(false.B)
    dut.io.ib_issue.ready.poke(false.B)
    for (done <- Seq(dut.io.dram_done, dut.io.ib_done)) {
      done.valid.poke(false.B)
      identity(done.bits.identity, 0)
      done.bits.target.poke(0.U)
      done.bits.error.poke(false.B)
    }
    for (s <- dut.io.status) {
      s.enabled.poke(false.B)
      s.demand.poke(false.B)
      s.impending.poke(false.B)
      s.hungry.poke(false.B)
      s.free_credit.poke(4096.U)
      s.refill_pending.poke(false.B)
    }
    dut.reset.poke(true.B)
    dut.clock.step(2)
    dut.reset.poke(false.B)
  }

  private def step(dut: DmaArbiterProbe, notices: ArrayBuffer[Int], cycles: Int = 1): Unit = {
    for (_ <- 0 until cycles) {
      if (dut.io.plan_accept.valid.peek().litToBoolean)
        notices += dut.io.plan_accept.bits.peek().litValue.toInt
      dut.clock.step()
    }
  }

  private def enqueue(dut: DmaArbiterProbe, target: Int, source: DmaSource.Type,
                      id: Int, notices: ArrayBuffer[Int]): Unit = {
    drivePlan(dut, target, source, id)
    dut.io.plan_in.valid.poke(true.B)
    dut.io.plan_in.ready.expect(true.B)
    step(dut, notices)
    dut.io.plan_in.valid.poke(false.B)
  }

  private def complete(dut: DmaArbiterProbe, target: Int, source: DmaSource.Type,
                       id: Int, notices: ArrayBuffer[Int], error: Boolean = false): Unit = {
    val done = if (source == DmaSource.DRAM) dut.io.dram_done else dut.io.ib_done
    identity(done.bits.identity, id)
    done.bits.target.poke(target.U)
    done.bits.error.poke(error.B)
    done.valid.poke(true.B)
    step(dut, notices)
    done.valid.poke(false.B)
  }

  it should "serve IB while DRAM is stalled and preserve the offered descriptor" in {
    test(new DmaArbiterProbe(DmaArbiterParams())) { dut =>
      init(dut)
      val notices = ArrayBuffer.empty[Int]
      enqueue(dut, DmaTarget.UB, DmaSource.DRAM, 1, notices)
      enqueue(dut, DmaTarget.WB, DmaSource.IB, 2, notices)
      dut.io.status(DmaTarget.UB).enabled.poke(true.B)
      dut.io.status(DmaTarget.WB).enabled.poke(true.B)
      dut.io.ib_issue.ready.poke(true.B)
      step(dut, notices) // Independent selection.
      dut.io.dram_issue.valid.expect(true.B)
      dut.io.ib_issue.valid.expect(true.B)
      step(dut, notices) // Only IB accepts.
      dut.io.ib_issue.valid.expect(false.B)
      dut.debug.dram_rr.expect(0.U)
      dut.debug.ib_rr.expect(2.U)
      enqueue(dut, DmaTarget.FB, DmaSource.DRAM, 3, notices)
      dut.io.status(DmaTarget.FB).enabled.poke(true.B)
      dut.io.status(DmaTarget.FB).demand.poke(true.B)
      step(dut, notices, 3)
      dut.io.dram_issue.valid.expect(true.B)
      dut.io.dram_issue.bits.target.expect(DmaTarget.UB.U)
      dut.io.dram_issue.bits.identity.plan_id.expect(1.U)
      dut.io.dram_issue.bits.src_addr.expect(0x1040.U)
      dut.io.dram_issue.bits.dst_offset.expect(64.U)
      complete(dut, DmaTarget.WB, DmaSource.IB, 2, notices)
      enqueue(dut, DmaTarget.QB, DmaSource.IB, 4, notices)
      dut.io.status(DmaTarget.QB).enabled.poke(true.B)
      step(dut, notices, 3) // Another IB request completes its acceptance.
      assert(notices.toSeq == Seq(DmaTarget.WB, DmaTarget.QB))
      dut.io.dram_issue.ready.poke(true.B)
      step(dut, notices, 2)
      assert(notices.toSeq == Seq(DmaTarget.WB, DmaTarget.QB, DmaTarget.UB))
      dut.debug.target_busy(DmaTarget.UB).expect(true.B)
      dut.io.dram_issue.valid.expect(false.B)
    }
  }

  it should "serialize simultaneous accepts without loss and reserve targets until completion" in {
    test(new DmaArbiterProbe(DmaArbiterParams())) { dut =>
      init(dut)
      val notices = ArrayBuffer.empty[Int]
      enqueue(dut, DmaTarget.UB, DmaSource.DRAM, 1, notices)
      enqueue(dut, DmaTarget.WB, DmaSource.IB, 2, notices)
      dut.io.status(DmaTarget.UB).enabled.poke(true.B)
      dut.io.status(DmaTarget.WB).enabled.poke(true.B)
      dut.io.dram_issue.ready.poke(true.B)
      dut.io.ib_issue.ready.poke(true.B)
      step(dut, notices)
      dut.io.dram_issue.valid.expect(true.B)
      dut.io.ib_issue.valid.expect(true.B)
      step(dut, notices)
      drivePlan(dut, DmaTarget.UB, DmaSource.IB, 3)
      dut.io.plan_in.ready.expect(false.B) // Even the other source cannot reuse UB.
      step(dut, notices, 4)
      assert(notices.sorted.toSeq == Seq(DmaTarget.UB, DmaTarget.WB))
      dut.io.dram_issue.valid.expect(false.B)
      dut.io.ib_issue.valid.expect(false.B)
      complete(dut, DmaTarget.UB, DmaSource.DRAM, 1, notices)
      dut.io.plan_in.ready.expect(true.B)
      dut.debug.target_busy(DmaTarget.UB).expect(false.B)
      dut.debug.target_busy(DmaTarget.WB).expect(true.B)
      // Error means the engine has drained the request; release only that reservation.
      complete(dut, DmaTarget.WB, DmaSource.IB, 2, notices, error = true)
      dut.debug.target_busy(DmaTarget.WB).expect(false.B)
    }
  }

  it should "increment common ages under stable status, reset accepted targets, and saturate" in {
    test(new DmaArbiterProbe(DmaArbiterParams(ageWidth = 3))) { dut =>
      init(dut)
      val notices = ArrayBuffer.empty[Int]
      enqueue(dut, DmaTarget.UB, DmaSource.DRAM, 1, notices)
      enqueue(dut, DmaTarget.WB, DmaSource.IB, 2, notices)
      dut.io.status(DmaTarget.UB).enabled.poke(true.B)
      dut.io.status(DmaTarget.WB).enabled.poke(true.B)
      step(dut, notices, 3)
      dut.debug.ages(DmaTarget.UB).expect(2.U)
      dut.debug.ages(DmaTarget.WB).expect(2.U)
      dut.io.dram_issue.ready.poke(true.B)
      step(dut, notices)
      dut.debug.ages(DmaTarget.UB).expect(0.U)
      dut.debug.ages(DmaTarget.WB).expect(3.U)
      step(dut, notices, 10)
      dut.debug.ages(DmaTarget.WB).expect(7.U)
      dut.io.ib_issue.ready.poke(true.B)
      step(dut, notices)
      dut.debug.ages(DmaTarget.WB).expect(0.U)
    }
  }

  it should "prefer urgent requests then hungry requests over opportunistic requests" in {
    test(new DmaArbiterProbe(DmaArbiterParams())) { dut =>
      init(dut)
      val notices = ArrayBuffer.empty[Int]
      enqueue(dut, DmaTarget.UB, DmaSource.DRAM, 1, notices)
      enqueue(dut, DmaTarget.NB, DmaSource.DRAM, 2, notices)
      enqueue(dut, DmaTarget.FB, DmaSource.DRAM, 3, notices)
      for (target <- Seq(DmaTarget.UB, DmaTarget.NB, DmaTarget.FB))
        dut.io.status(target).enabled.poke(true.B)
      dut.io.status(DmaTarget.NB).hungry.poke(true.B)
      dut.io.status(DmaTarget.FB).impending.poke(true.B)
      dut.io.dram_issue.ready.poke(true.B)
      step(dut, notices)
      dut.io.dram_issue.bits.target.expect(DmaTarget.FB.U)
      step(dut, notices)
      complete(dut, DmaTarget.FB, DmaSource.DRAM, 3, notices)
      step(dut, notices)
      dut.io.dram_issue.valid.expect(true.B)
      dut.io.dram_issue.bits.target.expect(DmaTarget.NB.U)
    }
  }

  it should "use source round robin for equal ages and update its pointer only on acceptance" in {
    test(new DmaArbiterProbe(DmaArbiterParams(ageWidth = 3))) { dut =>
      init(dut)
      val notices = ArrayBuffer.empty[Int]
      enqueue(dut, DmaTarget.WB, DmaSource.DRAM, 1, notices)
      dut.io.status(DmaTarget.WB).enabled.poke(true.B)
      step(dut, notices, 3)
      dut.debug.dram_rr.expect(0.U)
      dut.io.dram_issue.ready.poke(true.B)
      step(dut, notices)
      dut.debug.dram_rr.expect(2.U)
      dut.debug.ib_rr.expect(0.U)
      enqueue(dut, DmaTarget.UB, DmaSource.DRAM, 2, notices)
      enqueue(dut, DmaTarget.NB, DmaSource.DRAM, 3, notices)
      for (target <- Seq(DmaTarget.UB, DmaTarget.NB))
        dut.io.status(target).enabled.poke(true.B)
      step(dut, notices, 10) // Age continues to run while the DRAM source is busy.
      dut.debug.ages(DmaTarget.UB).expect(7.U)
      dut.debug.ages(DmaTarget.NB).expect(7.U)
      complete(dut, DmaTarget.WB, DmaSource.DRAM, 1, notices)
      step(dut, notices)
      dut.io.dram_issue.bits.target.expect(DmaTarget.NB.U) // RR starts at FB (2).
    }
  }

  it should "keep urgent traffic above lower priority traffic even when its age saturates" in {
    test(new DmaArbiterProbe(DmaArbiterParams(ageWidth = 3))) { dut =>
      init(dut)
      val notices = ArrayBuffer.empty[Int]
      enqueue(dut, DmaTarget.WB, DmaSource.DRAM, 1, notices)
      dut.io.status(DmaTarget.WB).enabled.poke(true.B)
      dut.io.dram_issue.ready.poke(true.B)
      step(dut, notices, 2)
      enqueue(dut, DmaTarget.UB, DmaSource.DRAM, 2, notices)
      dut.io.status(DmaTarget.UB).enabled.poke(true.B)
      step(dut, notices, 8)
      enqueue(dut, DmaTarget.FB, DmaSource.DRAM, 3, notices)
      dut.io.status(DmaTarget.FB).enabled.poke(true.B)
      dut.io.status(DmaTarget.FB).demand.poke(true.B)
      complete(dut, DmaTarget.WB, DmaSource.DRAM, 1, notices)
      step(dut, notices)
      dut.io.dram_issue.valid.expect(true.B)
      dut.io.dram_issue.bits.target.expect(DmaTarget.FB.U)
    }
  }

  it should "gate eligibility on enable, credit and refill state and reject invalid targets" in {
    test(new DmaArbiterProbe(DmaArbiterParams())) { dut =>
      init(dut)
      val notices = ArrayBuffer.empty[Int]
      drivePlan(dut, 7, DmaSource.IB, 1)
      dut.io.plan_in.valid.poke(true.B)
      dut.io.plan_in.ready.expect(false.B)
      step(dut, notices)
      dut.io.plan_in.valid.poke(false.B)
      enqueue(dut, DmaTarget.QB, DmaSource.IB, 2, notices)
      step(dut, notices, 2)
      dut.io.ib_issue.valid.expect(false.B)
      dut.io.status(DmaTarget.QB).enabled.poke(true.B)
      dut.io.status(DmaTarget.QB).free_credit.poke(32.U)
      step(dut, notices, 2)
      dut.debug.ages(DmaTarget.QB).expect(0.U)
      dut.io.ib_issue.valid.expect(false.B)
      dut.io.status(DmaTarget.QB).free_credit.poke(64.U)
      dut.io.status(DmaTarget.QB).refill_pending.poke(true.B)
      step(dut, notices, 2)
      dut.io.ib_issue.valid.expect(false.B)
      dut.io.status(DmaTarget.QB).refill_pending.poke(false.B)
      step(dut, notices)
      dut.io.ib_issue.valid.expect(true.B)
      dut.io.ib_issue.bits.identity.plan_id.expect(2.U)
      dut.io.plan_in.ready.expect(false.B)
    }
  }

  it should "reset only the changed target age for every status field" in {
    test(new DmaArbiterProbe(DmaArbiterParams())) { dut =>
      init(dut)
      val notices = ArrayBuffer.empty[Int]
      enqueue(dut, DmaTarget.UB, DmaSource.DRAM, 1, notices)
      enqueue(dut, DmaTarget.WB, DmaSource.IB, 2, notices)
      val status = dut.io.status(DmaTarget.UB)
      status.enabled.poke(true.B)
      dut.io.status(DmaTarget.WB).enabled.poke(true.B)
      step(dut, notices) // Enabling is itself a status change.
      dut.debug.ages(DmaTarget.UB).expect(0.U)
      dut.debug.ages(DmaTarget.WB).expect(0.U)

      val changes = Seq[(String, () => Unit, () => Unit)](
        ("enabled", () => status.enabled.poke(false.B), () => status.enabled.poke(true.B)),
        ("demand", () => status.demand.poke(true.B), () => status.demand.poke(false.B)),
        ("impending", () => status.impending.poke(true.B), () => status.impending.poke(false.B)),
        ("hungry", () => status.hungry.poke(true.B), () => status.hungry.poke(false.B)),
        ("free_credit", () => status.free_credit.poke(4000.U), () => status.free_credit.poke(4096.U)),
        ("refill_pending", () => status.refill_pending.poke(true.B), () => status.refill_pending.poke(false.B))
      )
      for ((name, change, restore) <- changes) {
        step(dut, notices, 3)
        assert(dut.debug.ages(DmaTarget.UB).peek().litValue > 0, name)
        val otherAge = dut.debug.ages(DmaTarget.WB).peek().litValue
        change()
        step(dut, notices)
        dut.debug.ages(DmaTarget.UB).expect(0.U, name)
        dut.debug.ages(DmaTarget.WB).expect((otherAge + 1).U, name)
        // Age reset must not retract or replace an already offered request.
        dut.io.dram_issue.valid.expect(true.B)
        dut.io.dram_issue.bits.identity.plan_id.expect(1.U)
        restore()
        step(dut, notices)
        dut.debug.ages(DmaTarget.UB).expect(0.U, name + " restored")
        step(dut, notices)
        dut.debug.ages(DmaTarget.UB).expect(1.U, name + " stable")
      }
    }
  }

  it should "use the reset age when selecting in the cycle of a status change" in {
    test(new DmaArbiterProbe(DmaArbiterParams())) { dut =>
      init(dut)
      val notices = ArrayBuffer.empty[Int]
      enqueue(dut, DmaTarget.WB, DmaSource.DRAM, 1, notices)
      dut.io.status(DmaTarget.WB).enabled.poke(true.B)
      dut.io.dram_issue.ready.poke(true.B)
      step(dut, notices, 2)

      enqueue(dut, DmaTarget.UB, DmaSource.DRAM, 2, notices)
      dut.io.status(DmaTarget.UB).enabled.poke(true.B)
      step(dut, notices, 6)
      enqueue(dut, DmaTarget.FB, DmaSource.DRAM, 3, notices)
      dut.io.status(DmaTarget.FB).enabled.poke(true.B)
      step(dut, notices, 3)
      complete(dut, DmaTarget.WB, DmaSource.DRAM, 1, notices)
      assert(dut.debug.ages(DmaTarget.UB).peek().litValue >
        dut.debug.ages(DmaTarget.FB).peek().litValue)

      // Both remain eligible and in the same priority tier; only UB's age resets.
      dut.io.status(DmaTarget.UB).free_credit.poke(4000.U)
      step(dut, notices)
      dut.debug.ages(DmaTarget.UB).expect(0.U)
      dut.io.dram_issue.valid.expect(true.B)
      dut.io.dram_issue.bits.target.expect(DmaTarget.FB.U)
    }
  }}
