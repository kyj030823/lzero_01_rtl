package npu.core.memory

import chisel3._
import chisel3.util._


object DmaTarget {
  val UB = 0
  val WB = 1
  val FB = 2
  val NB = 3
  val QB = 4
  val Count = 5
  val Width = log2Ceil(Count)
}

object DmaSource extends ChiselEnum {
  val DRAM, IB = Value
}

// 임시 ABI: 실제 AG/engine 연결 시 주소와 identity 폭을 확정한다.
case class DmaArbiterParams(
  addressWidth: Int = 64,
  byteCountWidth: Int = 32,
  offsetWidth: Int = 32,
  idWidth: Int = 16,
  epochWidth: Int = 8,
  ageWidth: Int = 8
) {
  require(Seq(addressWidth, byteCountWidth, offsetWidth, idWidth, epochWidth, ageWidth).forall(_ > 0))
}

class DmaRequestIdentity(p: DmaArbiterParams) extends Bundle {
  val plan_id = UInt(p.idWidth.W)
  val context_id = UInt(p.idWidth.W)
  val epoch = UInt(p.epochWidth.W)
  val refill_id = UInt(p.idWidth.W)
}

/** AG + Resolver가 주소와 source를 확정해서 전달하는 요청.
  * 한 요청 전체는 IB 또는 DRAM 한 곳에서만 읽는다.
  * 초기 골격은 요청 전체 완료 후 source를 재중재하는 보수적인 구조다.
  * 명세의 segment 단위 재중재는 segment identity/progress 추가 후 구현한다.
  */
class DmaReadPlan(p: DmaArbiterParams) extends Bundle {
  val identity = new DmaRequestIdentity(p)
  val target = UInt(DmaTarget.Width.W)
  val source = DmaSource()
  val src_addr = UInt(p.addressWidth.W)
  val bytes = UInt(p.byteCountWidth.W)
  val dst_offset = UInt(p.offsetWidth.W)
  val logical_offset = UInt(p.offsetWidth.W)
  val chunk_end = Bool()
  val loop_end = Bool()
  val final_supply = Bool()
}

/** 저장된 plan과 별도로 매 cycle 갱신되는 상태. */
class DmaTargetStatus(p: DmaArbiterParams) extends Bundle {
  val enabled = Bool()
  val demand = Bool()
  val impending = Bool()
  val hungry = Bool()
  val free_credit = UInt(p.byteCountWidth.W)
  val refill_pending = Bool()
}

/** 주소 명령 발행 완료가 아니라, 요청 데이터의 최종 sink commit/drain 통지.
  * identity는 해당 source의 active plan과 일치해야 한다.
  * error이면 정상 refill 완료로 publish하지 않는다.
  */
class DmaReadCompletion(p: DmaArbiterParams) extends Bundle {
  val identity = new DmaRequestIdentity(p)
  val target = UInt(DmaTarget.Width.W)
  val error = Bool()
}

/** DMA arbiter 구조 초안. 기존 DmaScheduler와는 아직 연결하지 않는다.
  *
  * AG/Resolver -> target별 pending plan -> DRAM/IB 독립 선택 -> read engine
  *                     ^                       |
  *               최신 OCM 상태             completion
  *
  * source별 독립 priority/age/RR 중재, 공통 target age, 보류 중인 issue 유지,
  * request 단위 source/target 점유 및 완료 처리, 단일 승인 통지를 구현한다.
  * bank/return 자원 확보는 engine.ready의 계약이며, segment 재중재는 추후 확장한다.
  */
class DmaArbiter(val p: DmaArbiterParams = DmaArbiterParams()) extends Module {
  val io = IO(new Bundle {
    // AG에서 요청 하나를 받고, plan.target에 해당하는 pending 슬롯에 저장한다.
    // plan_in.fire는 저장 수락일 뿐 engine의 실행 승인이 아니다.
    val plan_in = Flipped(Decoupled(new DmaReadPlan(p))) // AG/Resolver -> Arbiter
    val status = Input(Vec(DmaTarget.Count, new DmaTargetStatus(p))) // OCM -> Arbiter

    val dram_issue = Decoupled(new DmaReadPlan(p)) // DRAM read engine로 발행
    val ib_issue = Decoupled(new DmaReadPlan(p))  // IB read engine로 발행
    val dram_done = Flipped(Valid(new DmaReadCompletion(p))) // DRAM read engine 완료 통지
    val ib_done = Flipped(Valid(new DmaReadCompletion(p))) // IB read engine 완료 통지

    // AG cursor 진행 등에 사용할 실제 engine 승인 통지.
    val plan_accept = Valid(UInt(DmaTarget.Width.W)) // valid: 승인 통지, bits: 승인된 target
  })

  // 1. target별 대기 요청
  val pendingValid = RegInit(VecInit(Seq.fill(DmaTarget.Count)(false.B)))
  val pendingPlan = Reg(Vec(DmaTarget.Count, new DmaReadPlan(p)))

  // 2. 진행 중인 요청: source당 하나, target당 하나를 기준으로 시작한다.
  // source busy는 engine acceptance부터 마지막 sink commit/drain까지 유지한다.
  val dramBusy = RegInit(false.B)
  val ibBusy = RegInit(false.B)
  val dramActivePlan = Reg(new DmaReadPlan(p))
  val ibActivePlan = Reg(new DmaReadPlan(p))
  // Target당 요청 하나만 허용하므로 busy로 완료까지 추가 발행을 차단한다.
  val targetBusy = RegInit(VecInit(Seq.fill(DmaTarget.Count)(false.B)))

  // 단일 입력의 target으로 저장할 슬롯과 해당 슬롯의 수락 가능 여부를 선택한다.
  val incomingTarget = io.plan_in.bits.target
  val incomingTargetValid = incomingTarget < DmaTarget.Count.U
  io.plan_in.ready := Mux(incomingTargetValid,
    !pendingValid(incomingTarget) && !targetBusy(incomingTarget), false.B)

  when(io.plan_in.fire) {
    assert(io.plan_in.bits.bytes =/= 0.U, "DMA request must not be empty")
    pendingPlan(incomingTarget) := io.plan_in.bits
    pendingValid(incomingTarget) := true.B
  }

  // 3. 공통 후보/age: engine busy와 무관하게 실행 자격을 갖춘 대기 시간을 센다.
  // free_credit의 단위는 byte이며, 외부에서 이 target에 동시에 공간을 예약하지 않는다.
  val eligible = Wire(Vec(DmaTarget.Count, Bool()))
  val dramCandidate = Wire(Vec(DmaTarget.Count, Bool()))
  val ibCandidate = Wire(Vec(DmaTarget.Count, Bool()))
  val age = RegInit(VecInit(Seq.fill(DmaTarget.Count)(0.U(p.ageWidth.W))))
  // Status의 모든 필드(free_credit 포함)를 비교한다. 변경 cycle에는 age를 0으로 본다.
  val statusChanged = Wire(Vec(DmaTarget.Count, Bool()))
  val schedulingAge = Wire(Vec(DmaTarget.Count, UInt(p.ageWidth.W)))
  val priority = Wire(Vec(DmaTarget.Count, UInt(2.W)))
  for (target <- 0 until DmaTarget.Count) {
    val status = io.status(target)
    val previousStatus = RegNext(status.asUInt, 0.U(status.getWidth.W))
    statusChanged(target) := status.asUInt =/= previousStatus
    schedulingAge(target) := Mux(statusChanged(target), 0.U, age(target))
    val plan = pendingPlan(target)
    eligible(target) := pendingValid(target) && !targetBusy(target) &&
      status.enabled && !status.refill_pending && (status.free_credit >= plan.bytes)
    dramCandidate(target) := eligible(target) && (plan.source === DmaSource.DRAM) && !dramBusy
    ibCandidate(target) := eligible(target) && (plan.source === DmaSource.IB) && !ibBusy

    // 긴급도로 등급을 정하고, 동일 등급에서는 status 변경 이후 대기 시간을 비교한다.
    priority(target) := Mux(status.demand || status.impending, 0.U,
      Mux(status.hungry, 1.U, 2.U))
  }

  // 4. source별 독립 선택. priority -> age -> 해당 source의 RR 순서.
  val dramRrPtr = RegInit(0.U(DmaTarget.Width.W))
  val ibRrPtr = RegInit(0.U(DmaTarget.Width.W))

  private def nextTarget(target: UInt): UInt =
    Mux(target === (DmaTarget.Count - 1).U, 0.U, target + 1.U)

  private def select(candidates: Vec[Bool], start: UInt): (Bool, UInt) = {
    // Scala fold로 비교 체인을 생성한다. 같은 priority/age이면 RR 순서의 첫 후보 유지.
    val initial = (false.B, 0.U(DmaTarget.Width.W), 3.U(2.W), 0.U(p.ageWidth.W))
    val (found, winner, _, _) = (0 until DmaTarget.Count).foldLeft(initial) {
      case ((found, winner, bestPriority, bestAge), offset) =>
        val sum = start +& offset.U
        val target = Mux(sum >= DmaTarget.Count.U, sum - DmaTarget.Count.U, sum)(
          DmaTarget.Width - 1, 0)
        val better = candidates(target) && (!found ||
          priority(target) < bestPriority ||
          ((priority(target) === bestPriority) && (schedulingAge(target) > bestAge)))
        (found || candidates(target),
          Mux(better, target, winner),
          Mux(better, priority(target), bestPriority),
          Mux(better, schedulingAge(target), bestAge))
    }
    (found, winner)
  }

  val (dramFound, dramWinner) = select(dramCandidate, dramRrPtr)
  val (ibFound, ibWinner) = select(ibCandidate, ibRrPtr)

  // 선택 후 backpressure가 걸려도 valid/payload는 유지한다.
  // pending 슬롯을 fire까지 유지하므로 같은 target에 새 plan을 덮어쓸 수 없다.
  val dramOfferValid = RegInit(false.B)
  val ibOfferValid = RegInit(false.B)
  val dramOffer = Reg(new DmaReadPlan(p))
  val ibOffer = Reg(new DmaReadPlan(p))
  io.dram_issue.valid := dramOfferValid
  io.dram_issue.bits := dramOffer
  io.ib_issue.valid := ibOfferValid
  io.ib_issue.bits := ibOffer

  // 각 source 전용 1-entry 통지 큐. 슬롯 확보 후 offer하므로 stalled offer에도
  // 통지 공간이 보장된다. plan_accept는 fire보다 1~2 cycle 늦게 나올 수 있다.
  val dramNotices = Module(new Queue(UInt(DmaTarget.Width.W), 1))
  val ibNotices = Module(new Queue(UInt(DmaTarget.Width.W), 1))
  dramNotices.io.enq.valid := io.dram_issue.fire
  dramNotices.io.enq.bits := io.dram_issue.bits.target
  ibNotices.io.enq.valid := io.ib_issue.fire
  ibNotices.io.enq.bits := io.ib_issue.bits.target
  val noticeArbiter = Module(new RRArbiter(UInt(DmaTarget.Width.W), 2))
  noticeArbiter.io.in(0) <> dramNotices.io.deq
  noticeArbiter.io.in(1) <> ibNotices.io.deq
  noticeArbiter.io.out.ready := true.B
  io.plan_accept.valid := noticeArbiter.io.out.valid
  io.plan_accept.bits := noticeArbiter.io.out.bits

  when(!dramBusy && !dramOfferValid && dramFound && dramNotices.io.enq.ready) {
    dramOffer := pendingPlan(dramWinner)
    dramOfferValid := true.B
  }
  when(!ibBusy && !ibOfferValid && ibFound && ibNotices.io.enq.ready) {
    ibOffer := pendingPlan(ibWinner)
    ibOfferValid := true.B
  }

  // 5. 실제 engine 승인에서만 active/busy/RR을 갱신한다.
  // Offer된 요청의 enabled/credit은 acceptance까지 유지해야 한다.
  // engine.ready는 bank/return-path 자원까지 확보한 경우에만 올리는 계약이다.
  when(io.dram_issue.fire) {
    assert(dramNotices.io.enq.ready, "DRAM acceptance notification overflow")
    assert(eligible(dramOffer.target), "DRAM offered plan lost destination eligibility")
    dramOfferValid := false.B
    dramBusy := true.B
    dramActivePlan := dramOffer
    dramRrPtr := nextTarget(dramOffer.target)
  }
  when(io.ib_issue.fire) {
    assert(ibNotices.io.enq.ready, "IB acceptance notification overflow")
    assert(eligible(ibOffer.target), "IB offered plan lost destination eligibility")
    ibOfferValid := false.B
    ibBusy := true.B
    ibActivePlan := ibOffer
    ibRrPtr := nextTarget(ibOffer.target)
  }

  // 6. 완료는 acceptance 다음 cycle부터 가능하며, identity가 일치하는 요청만 해제한다.
  val dramCompleted = io.dram_done.valid && dramBusy &&
    (io.dram_done.bits.target === dramActivePlan.target) &&
    (io.dram_done.bits.identity.asUInt === dramActivePlan.identity.asUInt)
  val ibCompleted = io.ib_done.valid && ibBusy &&
    (io.ib_done.bits.target === ibActivePlan.target) &&
    (io.ib_done.bits.identity.asUInt === ibActivePlan.identity.asUInt)
  when(io.dram_done.valid) {
    assert(dramCompleted, "DRAM completion must match its active request")
  }
  when(io.ib_done.valid) {
    assert(ibCompleted, "IB completion must match its active request")
  }
  when(dramCompleted) { dramBusy := false.B }
  when(ibCompleted) { ibBusy := false.B }

  // 공통 age 갱신 블록: source별로 중복 증가시키거나 다른 target 승인 때 초기화하지 않는다.
  for (target <- 0 until DmaTarget.Count) {
    val dramAccepted = io.dram_issue.fire && (dramOffer.target === target.U)
    val ibAccepted = io.ib_issue.fire && (ibOffer.target === target.U)
    val accepted = dramAccepted || ibAccepted
    val completed = (dramCompleted && (dramActivePlan.target === target.U)) ||
      (ibCompleted && (ibActivePlan.target === target.U))

    when(statusChanged(target) || !pendingValid(target) || accepted) {
      age(target) := 0.U
    }.elsewhen(eligible(target) && !age(target).andR) {
      age(target) := age(target) + 1.U
    }

    when(accepted) {
      pendingValid(target) := false.B
      targetBusy(target) := true.B
    }.elsewhen(completed) {
      targetBusy(target) := false.B
    }
  }

  // error done도 engine이 drain을 마쳤을 때만 보낸다. 여기서는 예약만 해제하며,
  // 정상 refill publication 및 error 보고는 engine/OCM에서 처리한다.
  // TODO: segment 단위 재중재, byte mask/fill-through metadata,
  //       context 변경/soft reset의 drain 계약 및 bank 예약 상세 ABI.
}
