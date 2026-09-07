package npu.core.memory

import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec

class DmaScheduler_Test extends AnyFlatSpec with ChiselScalatestTester {
  behavior of "DmaScheduler"

  private val UB = 0
  private val WB = 1
  private val FB = 2
  private val NB = 3
  private val PB = 4

  private def init(dut: DmaScheduler): Unit = {
    dut.io.tl_gen_ready.poke(false.B)

    dut.io.ub_status.impending.poke(false.B)
    dut.io.ub_status.hungry.poke(false.B)
    dut.io.ub_status.full.poke(true.B)

    dut.io.wb_status.impending.poke(false.B)
    dut.io.wb_status.hungry.poke(false.B)
    dut.io.wb_status.full.poke(true.B)

    dut.io.fb_status.impending.poke(false.B)
    dut.io.fb_status.hungry.poke(false.B)
    dut.io.fb_status.full.poke(true.B)

    dut.io.nb_status.impending.poke(false.B)
    dut.io.nb_status.hungry.poke(false.B)
    dut.io.nb_status.starving.poke(false.B)
    dut.io.nb_status.full.poke(true.B)

    dut.io.pb_status.impending.poke(false.B)
    dut.io.pb_status.hungry.poke(false.B)
    dut.io.pb_status.full.poke(true.B)

    dut.reset.poke(true.B)
    dut.clock.step(2)
    dut.reset.poke(false.B)
  }

  private def expectGrant(dut: DmaScheduler, target: Int, note: String): Unit = {
    dut.io.trigger.expect(true.B, note + ": trigger")
    dut.io.target_ocm.expect(target.U, note + ": target_ocm")
    println(f"$note%-48s -> trigger=1 target=$target")
  }

  private def expectNoTrigger(dut: DmaScheduler, note: String): Unit = {
    dut.io.trigger.expect(false.B, note + ": trigger")
    println(f"$note%-48s -> trigger=0")
  }

  private def setAllNotFull(dut: DmaScheduler): Unit = {
    dut.io.ub_status.full.poke(false.B)
    dut.io.wb_status.full.poke(false.B)
    dut.io.fb_status.full.poke(false.B)
    dut.io.nb_status.full.poke(false.B)
    dut.io.pb_status.full.poke(false.B)
  }

  private def setAllHungry(dut: DmaScheduler): Unit = {
    dut.io.ub_status.hungry.poke(true.B)
    dut.io.wb_status.hungry.poke(true.B)
    dut.io.fb_status.hungry.poke(true.B)
    dut.io.nb_status.hungry.poke(true.B)
    dut.io.pb_status.hungry.poke(true.B)
  }

  it should "1. choose impending over hungry" in {
    test(new DmaScheduler()).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
      init(dut)

      dut.io.ub_status.full.poke(false.B)
      dut.io.wb_status.full.poke(false.B)
      dut.io.ub_status.impending.poke(true.B)
      dut.io.wb_status.hungry.poke(true.B)
      dut.io.tl_gen_ready.poke(true.B)

      println("\n=== case 1: impending priority over hungry ===")
      expectGrant(dut, UB, "UB impending + WB hungry")
    }
  }

  it should "2. round-robin among five hungry requests" in {
    test(new DmaScheduler()).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
      init(dut)
      setAllNotFull(dut)
      setAllHungry(dut)
      dut.io.tl_gen_ready.poke(true.B)

      println("\n=== case 2: hungry round-robin, all five hungry ===")
      expectGrant(dut, UB, "hungry attempt 0")
      dut.clock.step()
      expectGrant(dut, WB, "hungry attempt 1")
    }
  }

  it should "3. choose starving over not full" in {
    test(new DmaScheduler()).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
      init(dut)
      setAllNotFull(dut)
      dut.io.nb_status.starving.poke(true.B)
      dut.io.tl_gen_ready.poke(true.B)

      println("\n=== case 3: starving priority over not full ===")
      expectGrant(dut, NB, "NB starving + all not full")
    }
  }

  it should "4. round-robin among not-full requests" in {
    test(new DmaScheduler()).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
      init(dut)
      setAllNotFull(dut)
      dut.io.tl_gen_ready.poke(true.B)

      println("\n=== case 4: not-full round-robin, all five not full ===")
      expectGrant(dut, UB, "notFull attempt 0")
      dut.clock.step()
      expectGrant(dut, WB, "notFull attempt 1")
    }
  }

  it should "5. catch impending asserted just before tl_gen_ready" in {
    test(new DmaScheduler()).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
      init(dut)

      dut.io.fb_status.full.poke(false.B)
      dut.io.fb_status.impending.poke(true.B)
      dut.io.tl_gen_ready.poke(false.B)

      println("\n=== case 5: impending before tl_gen_ready ===")
      expectNoTrigger(dut, "FB impending, tl_gen_ready=0")
      dut.clock.step()

      dut.io.tl_gen_ready.poke(true.B)
      expectGrant(dut, FB, "FB impending, tl_gen_ready=1")
    }
  }
}
