package npu.core.memory

import chisel3._
import chisel3.util._

class bstate extends Bundle {
  val hungry    = Input(Bool())
  val impending = Input(Bool())
  val full      = Input(Bool())
}

class nbstate extends Bundle {
  val hungry    = Input(Bool())
  val impending = Input(Bool())
  val starving  = Input(Bool())
  val full      = Input(Bool())
}

/**
  * DMA scheduler.
  *
  * target_ocm:
  *   0: UB, 1: WB, 2: FB, 3: NB, 4: PB
  *
  * Priority:
  *   1. impending: fixed priority, lower OCM number wins
  *   2. hungry   : round-robin
  *   3. starving : NB only
  *   4. not full : round-robin
  */
class DmaScheduler extends Module {
  val io = IO(new Bundle {
    val ub_status = new bstate()
    val wb_status = new bstate()
    val fb_status = new bstate()
    val nb_status = new nbstate()
    val pb_status = new bstate()

    val tl_gen_ready = Input(Bool())

    val target_ocm = Output(UInt(3.W))
    val trigger    = Output(Bool())
  })

  private def nextTarget(target: UInt): UInt = {
    Mux(target === 4.U, 0.U, target + 1.U)
  }

  private def pickFixed(req: Seq[Bool]): (Bool, UInt) = {
    val valid = req.reduce(_ || _)
    val grant = WireDefault(0.U(3.W))

    when(req(0))      { grant := 0.U }
      .elsewhen(req(1)) { grant := 1.U }
      .elsewhen(req(2)) { grant := 2.U }
      .elsewhen(req(3)) { grant := 3.U }
      .elsewhen(req(4)) { grant := 4.U }

    (valid, grant)
  }

  private def pickRoundRobin(req: Seq[Bool], start: UInt): (Bool, UInt) = {
    val valid = req.reduce(_ || _)
    val grant = WireDefault(0.U(3.W))

    switch(start) {
      is(0.U) {
        when(req(0))      { grant := 0.U }
          .elsewhen(req(1)) { grant := 1.U }
          .elsewhen(req(2)) { grant := 2.U }
          .elsewhen(req(3)) { grant := 3.U }
          .elsewhen(req(4)) { grant := 4.U }
      }
      is(1.U) {
        when(req(1))      { grant := 1.U }
          .elsewhen(req(2)) { grant := 2.U }
          .elsewhen(req(3)) { grant := 3.U }
          .elsewhen(req(4)) { grant := 4.U }
          .elsewhen(req(0)) { grant := 0.U }
      }
      is(2.U) {
        when(req(2))      { grant := 2.U }
          .elsewhen(req(3)) { grant := 3.U }
          .elsewhen(req(4)) { grant := 4.U }
          .elsewhen(req(0)) { grant := 0.U }
          .elsewhen(req(1)) { grant := 1.U }
      }
      is(3.U) {
        when(req(3))      { grant := 3.U }
          .elsewhen(req(4)) { grant := 4.U }
          .elsewhen(req(0)) { grant := 0.U }
          .elsewhen(req(1)) { grant := 1.U }
          .elsewhen(req(2)) { grant := 2.U }
      }
      is(4.U) {
        when(req(4))      { grant := 4.U }
          .elsewhen(req(0)) { grant := 0.U }
          .elsewhen(req(1)) { grant := 1.U }
          .elsewhen(req(2)) { grant := 2.U }
          .elsewhen(req(3)) { grant := 3.U }
      }
    }

    (valid, grant)
  }

  val ubNotFull = !io.ub_status.full
  val wbNotFull = !io.wb_status.full
  val fbNotFull = !io.fb_status.full
  val nbNotFull = !io.nb_status.full
  val pbNotFull = !io.pb_status.full

  val impendingReq = Seq(
    io.ub_status.impending && ubNotFull,
    io.wb_status.impending && wbNotFull,
    io.fb_status.impending && fbNotFull,
    io.nb_status.impending && nbNotFull,
    io.pb_status.impending && pbNotFull
  )

  val hungryReq = Seq(
    io.ub_status.hungry && ubNotFull,
    io.wb_status.hungry && wbNotFull,
    io.fb_status.hungry && fbNotFull,
    (io.nb_status.hungry || io.nb_status.starving) && nbNotFull,
    io.pb_status.hungry && pbNotFull
  )

  val notFullReq = Seq(
    ubNotFull,
    wbNotFull,
    fbNotFull,
    nbNotFull,
    pbNotFull
  )

  val hungryRrPtr  = RegInit(0.U(3.W))
  val notFullRrPtr = RegInit(0.U(3.W))

  val (impendingValid, impendingGrant) = pickFixed(impendingReq)
  val (hungryValid, hungryGrant)       = pickRoundRobin(hungryReq, hungryRrPtr)
  val (notFullValid, notFullGrant)     = pickRoundRobin(notFullReq, notFullRrPtr)

  val selectHungry   = !impendingValid && hungryValid
  val selectNotFull  = !impendingValid && !hungryValid && notFullValid

  val selectedValid = impendingValid || hungryValid || notFullValid
  val selectedGrant = Mux(impendingValid, impendingGrant,
                      Mux(hungryValid, hungryGrant, notFullGrant))

  io.target_ocm := selectedGrant
  io.trigger    := io.tl_gen_ready && selectedValid

  when(io.trigger && selectHungry) {
    hungryRrPtr := nextTarget(selectedGrant)
  }

  when(io.trigger && selectNotFull) {
    notFullRrPtr := nextTarget(selectedGrant)
  }
}
