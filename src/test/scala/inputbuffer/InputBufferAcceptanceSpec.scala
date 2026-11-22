package npu.core.memory

import chisel3._
import chiseltest._
import chiseltest.experimental.expose
import org.scalatest.flatspec.AnyFlatSpec
import scala.collection.mutable
import java.security.MessageDigest
import java.nio.charset.StandardCharsets
import InputBufferTestSupport._

/** 이번 시험에서만 사용하는 관측 포트다. 제품 IO는 바꾸지 않는다. */
class InputBufferAcceptanceProbe extends ObservedInputBuffer {
  val reclaimObserved = expose(core.writer.io.reclaim.valid)
  val readInFlightObserved = expose(core.reader.readInFlight)
  val outputHeldObserved = expose(core.reader.outputValidReg)
  val activeEntryObserved = expose(core.writer.activeRefillEntryIndex)
  val chunksObserved = expose(core.writer.io.chunkEntries)
}

class InputBufferAcceptanceSpec extends AnyFlatSpec with ChiselScalatestTester {
  behavior of "UB remaining acceptance"

  private def offerBytes(x: Driver, bytes: Int): Unit = {
    val r = x.pending.get
    assert(bytes > 0 && bytes <= 64 && bytes % 16 == 0 && bytes <= r.bytes - x.sent)
    val lanes = bytes / 16
    val data = (0 until 4).foldLeft(BigInt(0)) { (all, lane) =>
      val value = if (lane < lanes) word(x.job.id, r.row, (r.offset + x.sent) / 16 + lane)
        else BigInt("feedfacefeedfacefeedfacefeedface", 16)
      all | (value << (128 * lane))
    }
    val last = x.sent + bytes == r.bytes
    x.d.io.memoryDataValid.poke(true.B); x.d.io.memoryData.poke(data.U)
    x.d.io.memoryLaneValidMask.poke(((1 << lanes) - 1).U)
    x.d.io.memoryChunkLast.poke(last.B)
    x.d.io.memoryStreamLast.poke((last && x.requestIndex == x.requests.size).B)
    x.d.io.memoryContextId.poke(x.job.id.U)
  }

  /** 마지막 payload byte가 entry.endPtr에 포함되는지 실제 갱신 후 확인한다. */
  private def checkedTick(x: Driver, d: InputBufferAcceptanceProbe): Unit = {
    val end = yes(d.io.memoryDataValid) && yes(d.io.memoryDataReady) && yes(d.io.memoryChunkLast)
    val index = number(d.activeEntryObserved)
    val expectedEnd = (x.inputBytes + Integer.bitCount(number(d.io.memoryLaneValidMask)) * 16) & 32767
    x.tick()
    if (end) {
      d.chunksObserved(index).complete.expect(true.B)
      d.chunksObserved(index).endPtr.expect(expectedEnd.U)
    }
  }

  it should "replay a full sixteen KiB row twice while forcing rewind row-handoff and simultaneous updates" in {
    evidence("extra-full-cache-races") { e =>
      test(new InputBufferAcceptanceProbe) { d =>
        val x = new Driver(d, e); x.initialize()
        x.begin(Job(70, rows = 2, k = 64, n = 2, passes = 2, cache = true))
        val holdTargets = Map(1023 -> 5, 2047 -> 7, 4095 -> 3)
        val held = mutable.Set.empty[Int]
        var hold = 0; var heldClocks = 0
        var requestReclaim = 0; var writeReadReclaim = 0; var inFlightHolds = 0
        while (x.outputIndex < x.expected.size && x.cycle < 10000) {
          d.io.readEnable.poke((x.inputBytes >= 16384).B)
          if (hold == 0 && !held(x.outputIndex) && holdTargets.contains(x.outputIndex) && yes(d.io.computeDataValid)) {
            hold = holdTargets(x.outputIndex); held += x.outputIndex
            if (yes(d.readInFlightObserved)) inFlightHolds += 1
          }
          val ready = x.inputBytes >= 16384 && hold == 0
          d.io.computeDataReady.poke(ready.B)
          // 공간이 돌아와도 AG grant를 늦춰 이전 row 반환과 같은 clock에 예약한다.
          val nextRequest = x.requests.lift(x.requestIndex)
          val grantReady = nextRequest match {
            case Some(r) if r.row == 1 && r.offset == 0 => x.outputIndex == 1535 && ready
            case Some(r) if r.row == 1 && r.offset == 4096 => x.outputIndex == 2047 && ready
            case _ => true
          }
          d.io.refillRequestReady.poke(grantReady.B)
          x.pending match {
            case Some(r) if r.row == 1 && r.offset == 0 && x.sent == r.bytes - 64 =>
              // B의 마지막 beat를 A의 다음 chunk 최종 수락과 겹치게 한다.
              if (x.outputIndex == 1791 && ready) x.offer() else x.idleMemory()
            case Some(_) => x.offer()
            case None => x.idleMemory()
          }
          val grant = yes(d.io.refillRequestValid) && yes(d.io.refillRequestReady)
          val write = yes(d.io.memoryDataValid) && yes(d.io.memoryDataReady)
          val reclaim = yes(d.reclaimObserved)
          val read = yes(d.observedReadIssue)
          if (grant && reclaim) requestReclaim += 1
          if (write && read && reclaim) writeReadReclaim += 1
          if (grant && reclaim || write && read && reclaim)
            e.add("cycle" -> x.cycle, "event" -> "concurrent", "request" -> grant,
              "write" -> write, "read" -> read, "reclaim" -> reclaim, "outputIndex" -> x.outputIndex)
          checkedTick(x, d)
          if (hold > 0) { hold -= 1; heldClocks += 1 }
        }
        assert(x.outputIndex == 4096 && x.inputBytes == 32768 && x.requestIndex == 8)
        assert(requestReclaim >= 2 && writeReadReclaim >= 1)
        assert(inFlightHolds == 3 && heldClocks == 15)
        assert(x.nextRowGrantsBeforeDone > 0)
        assert(x.lastOutput - x.firstOutput + 1 == 4096 + 15, "unexpected prepared replay/row bubble")
        x.finish()
        e.metrics("requestAndReclaimCycles") = requestReclaim
        e.metrics("writeReadReclaimCycles") = writeReadReclaim
        e.metrics("inFlightResponseHoldPoints") = inFlightHolds
        e.metrics("heldClocks") = heldClocks
      }
    }
  }

  private case class MaskTarget(address: Int, bytes: Int, bank: Int, region: String)
  it should "preserve forty-eight UB mask-bank-region combinations and physical and extended wrap" in {
    evidence("extra-ub-mask-wrap") { e =>
      test(new InputBufferAcceptanceProbe) { d =>
        val x = new Driver(d, e); x.initialize()
        // 4112B row로 chunk 시작을 16B씩 옮겨 ring wrap을 logical chunk 내부에 둔다.
        x.begin(Job(71, rows = 8, k = 257, compact = true))
        val targets = mutable.ArrayBuffer.empty[MaskTarget]
        for ((start, region) <- Seq((0, "ordinary"), (15360, "physical-wrap"), (31744, "extended-wrap"))) {
          var position = start
          for (bank <- 0 until 4; lanes <- 1 to 4) {
            position += ((bank - position / 16 % 4 + 4) % 4) * 16
            targets += MaskTarget(position, lanes * 16, bank, region)
            position += lanes * 16
          }
        }
        var targetIndex = 0; var physicalCrossings = 0; var extendedCrossings = 0
        while (x.outputIndex < x.expected.size && x.cycle < 7000) {
          d.io.readEnable.poke(true.B); d.io.computeDataReady.poke(true.B)
          d.io.refillRequestReady.poke(true.B)
          var selected: Option[MaskTarget] = None
          x.pending match {
            case Some(r) =>
              val remaining = r.bytes - x.sent
              val next = targets.lift(targetIndex)
              val bytes = next match {
                case Some(t) if x.inputBytes == t.address =>
                  assert(t.bytes <= remaining, "matrix target must remain inside its logical chunk")
                  selected = Some(t); t.bytes
                case Some(t) =>
                  assert(x.inputBytes < t.address, "missed mask target")
                  math.min(math.min(64, remaining), t.address - x.inputBytes)
                case None => math.min(64, remaining)
              }
              offerBytes(x, bytes)
            case None => x.idleMemory()
          }
          val fire = yes(d.io.memoryDataValid) && yes(d.io.memoryDataReady)
          if (fire) selected.foreach { t =>
            d.observedWritePtr.expect((t.address & 32767).U)
            assert(t.address / 16 % 4 == t.bank)
            val crossPhysical = t.address % 16384 + t.bytes > 16384
            val crossExtended = t.address % 32768 + t.bytes > 32768
            if (crossPhysical) physicalCrossings += 1
            if (crossExtended) extendedCrossings += 1
            e.add("event" -> "mask-target", "cycle" -> x.cycle, "address" -> t.address,
              "bank" -> t.bank, "mask" -> ((1 << (t.bytes / 16)) - 1), "region" -> t.region,
              "crossPhysical" -> crossPhysical, "crossExtended" -> crossExtended)
            targetIndex += 1
          }
          checkedTick(x, d)
        }
        assert(targetIndex == 48 && physicalCrossings >= 2 && extendedCrossings >= 1)
        assert(x.outputIndex == 2056 && x.inputBytes == 32896)
        x.finish()
        e.metrics("ubMaskBankRegionCases") = targetIndex
        e.metrics("physicalWrapCrossingBeats") = physicalCrossings
        e.metrics("extendedWrapCrossingBeats") = extendedCrossings
        e.metrics("scope") = "UB 48 region cases plus exact boundary matrix in shared storage suite"
      }
    }
  }

  it should "record a four-entry policy block despite free bytes and resume only after accepted reclaim" in {
    evidence("extra-entry-policy-block") { e =>
      test(new InputBufferAcceptanceProbe) { d =>
        val x = new Driver(d, e); x.initialize()
        x.begin(Job(72, rows = 6, compact = true))
        d.io.refillRequestReady.poke(true.B)
        while (x.completedChunks < 4 && x.cycle < 40) {
          if (x.pending.nonEmpty) x.offer() else x.idleMemory()
          checkedTick(x, d)
        }
        x.idleMemory()
        d.observedEntryCount.expect(4.U); d.io.freeBytes.expect(16320.U); d.io.full.expect(false.B)
        val before = x.requestIndex
        for (_ <- 0 until 5) {
          d.io.refillRequestValid.expect(false.B); checkedTick(x, d)
        }
        assert(x.requestIndex == before && before == 4)
        e.add("event" -> "expected-policy-block", "entries" -> 4, "freeBytes" -> 16320,
          "blockedClocks" -> 5, "supportedPreloadEntries" -> 4, "fifthEntrySupported" -> false)
        d.io.refillRequestReady.poke(false.B)
        d.io.readEnable.poke(true.B); d.io.computeDataReady.poke(true.B)
        while (x.outputIndex == 0 && x.cycle < 60) checkedTick(x, d)
        d.io.computeDataReady.poke(false.B)
        d.io.refillRequestValid.expect(true.B)
        d.io.refillRequestReady.poke(true.B); checkedTick(x, d)
        assert(x.requestIndex == 5)
        x.run(finalHold = 0)
        e.metrics("expectedPolicyBlock") = true
        e.metrics("blockClass") = "metadata-capacity; five simultaneous preloads unsupported"
      }
    }
  }

  it should "accept an existing tail reservation at 4080 free while enforcing the 4096 admission edge" in {
    evidence("extra-full-pending-tail") { e =>
      test(new InputBufferAcceptanceProbe) { d =>
        val x = new Driver(d, e); x.initialize()
        x.begin(Job(73, vpu = true, vectorBytes = 12304))
        d.io.refillRequestReady.poke(true.B)
        while (x.completedChunks < 3 && x.cycle < 250) {
          if (x.pending.nonEmpty) x.offer() else x.idleMemory()
          checkedTick(x, d)
        }
        x.idleMemory()
        d.io.freeBytes.expect(4096.U); d.io.full.expect(false.B)
        d.io.refillRequestValid.expect(true.B); d.io.refillRequestBytes.expect(16.U)
        checkedTick(x, d)
        d.io.refillRequestReady.poke(false.B)
        d.io.freeBytes.expect(4080.U); d.io.full.expect(true.B)
        d.observedReserved.expect(16.U); d.io.refillPending.expect(true.B)
        for (_ <- 0 until 4) checkedTick(x, d)
        x.offer(); d.io.memoryDataReady.expect(true.B); checkedTick(x, d)
        x.idleMemory()
        d.observedReserved.expect(0.U); d.io.supplyStreamComplete.expect(true.B)
        d.io.operationDone.expect(false.B)
        x.run(finalHold = 5)
        e.metrics("freeBeforeGrant") = 4096
        e.metrics("freeDuringReservedTail") = 4080
        e.metrics("pendingHoldClocks") = 4
        e.metrics("reservedResponseAcceptedWhileFull") = true
      }
    }
  }

  private case class Segment(start: Int, end: Int, source: String, address: Long)
  /** canonical DRAM backing과 IB residency를 갖는 시험용 resolver다. 실제 AG/IB RTL은 아니다. */
  private class SourceProfile(val job: Job, val name: String) {
    private val dram = mutable.Map.empty[Long, BigInt]
    private val ib = mutable.Map.empty[Long, BigInt]
    private val plans = mutable.Map.empty[(Int, Int, Int), Vector[Segment]]
    def hit(byte: Int): Boolean = name == "ib" ||
      (name == "mixed" && ((byte < 64) || (byte >= 256 && byte < 320) || (byte >= 4080 && byte < 4160)))
    private def base(row: Int, cached: Boolean): Long = (if (cached) 0x800000L else 0x100000L) + row * 0x20000L
    for (row <- 0 until job.rowCount; index <- 0 until job.bytes / 16) {
      dram(base(row, false) + index * 16) = word(job.id, row, index)
      if (hit(index * 16)) ib(base(row, true) + index * 16) = word(job.id, row, index)
    }
    def segments(r: Request): Vector[Segment] = plans.getOrElseUpdate((r.row, r.offset, r.bytes), {
      val result = mutable.ArrayBuffer.empty[Segment]
      var start = r.offset
      while (start < r.offset + r.bytes) {
        val cached = hit(start)
        val burst = if (name == "dram") 4096 else if (cached) 256 else 512
        var end = start + 16
        while (end < r.offset + r.bytes && end - start < burst && hit(end) == cached) end += 16
        result += Segment(start, end, if (cached) "IB" else "DRAM", base(r.row, cached) + start)
        start = end
      }
      result.toVector
    })
    def response(r: Request, sent: Int): (BigInt, Int, Segment, Boolean) = {
      val position = r.offset + sent
      val segment = segments(r).find(s => position >= s.start && position < s.end).get
      val bytes = math.min(64, segment.end - position)
      val memory = if (segment.source == "IB") ib else dram
      val address = segment.address + position - segment.start
      val data = (0 until bytes / 16).foldLeft(BigInt(0)) { (value, lane) =>
        value | (memory(address + lane * 16) << (128 * lane))
      }
      (data, bytes, segment, position + bytes == segment.end)
    }
  }

  private case class PhaseReference(row: Int, column: Int, phase: Int, k: Int, beat: Int)
  private def sourceRun(d: InputBufferAcceptanceProbe, e: Evidence, job: Job,
    profileName: String, phaseReference: Boolean): String = {
    val x = new Driver(d, e); x.begin(job)
    val source = new SourceProfile(job, profileName)
    val digest = MessageDigest.getInstance("SHA-256")
    // output column마다 W1→W2를 실행하는 명시적인 시험용 reference schedule이다.
    val reference = if (!phaseReference) Vector.empty else
      (for { row <- 0 until job.rows; column <- 0 until job.n; phase <- 0 until 2
        k <- 0 until job.k; beat <- 0 until 16 }
        yield PhaseReference(row, column, phase, k, beat)).toVector
    var physicalLasts = 0; var intermediateLasts = 0; var ibBeats = 0; var dramBeats = 0
    var normalizedLasts = 0; var refIndex = 0
    while (x.outputIndex < x.expected.size && x.cycle < x.expected.size * 3 + 2000) {
      d.io.refillRequestReady.poke(true.B); d.io.readEnable.poke(true.B)
      d.io.computeDataReady.poke((x.cycle % 13 != 8).B)
      var physicalLast = false; var segment: Option[Segment] = None
      x.pending match {
        case Some(r) =>
          val (data, bytes, s, last) = source.response(r, x.sent)
          physicalLast = last; segment = Some(s)
          val logicalLast = x.sent + bytes == r.bytes
          d.io.memoryDataValid.poke(true.B); d.io.memoryData.poke(data.U)
          d.io.memoryLaneValidMask.poke(((1 << (bytes / 16)) - 1).U)
          // 시험용 adapter가 physical RLAST를 흡수하고 logical completion만 전달한다.
          d.io.memoryChunkLast.poke(logicalLast.B)
          d.io.memoryStreamLast.poke((logicalLast && x.requestIndex == x.requests.size).B)
          d.io.memoryContextId.poke(job.id.U)
        case None => x.idleMemory()
      }
      val memoryFire = yes(d.io.memoryDataValid) && yes(d.io.memoryDataReady)
      if (memoryFire) {
        if (segment.get.source == "IB") ibBeats += 1 else dramBeats += 1
        if (physicalLast) {
          physicalLasts += 1
          val logical = yes(d.io.memoryChunkLast)
          if (!logical) intermediateLasts += 1
          e.add("event" -> "physical-last", "profile" -> profileName, "cache" -> job.cache,
            "cycle" -> x.cycle, "source" -> segment.get.source, "sourceAddress" -> segment.get.address,
            "logicalChunkLast" -> logical, "logicalBytesAccepted" -> x.sent)
        }
        if (yes(d.io.memoryChunkLast)) normalizedLasts += 1
      }
      if (yes(d.io.computeDataValid) && yes(d.io.computeDataReady)) {
        val data = d.io.computeData.peek().litValue
        val hex = ("0" * 32 + data.toString(16)).takeRight(32)
        digest.update(hex.getBytes(StandardCharsets.US_ASCII))
        if (phaseReference) {
          val r = reference(refIndex)
          d.io.inputRowIndex.expect(r.row.U); d.io.rowPassIndex.expect((2 * r.column + r.phase).U)
          d.io.computeData.expect(word(job.id, r.row, r.k * 16 + r.beat).U)
          if (r.k == job.k - 1 && r.beat == 15) {
            d.io.inputRowDone.expect((r.column == job.n - 1 && r.phase == 1).B)
            e.add("event" -> "phase-reference", "profile" -> profileName, "cache" -> job.cache,
              "row" -> r.row, "column" -> r.column, "phase" -> (if (r.phase == 0) "W1" else "W2"),
              "pass" -> (2 * r.column + r.phase), "inputRowDone" -> yes(d.io.inputRowDone))
          }
          refIndex += 1
        }
      }
      checkedTick(x, d)
    }
    assert(x.outputIndex == x.expected.size && normalizedLasts == x.requests.size)
    if (profileName != "dram") assert(intermediateLasts > 0)
    if (profileName == "mixed") assert(ibBeats > 0 && dramBeats > 0)
    if (phaseReference) assert(refIndex == reference.size)
    x.finish()
    val hash = digest.digest().map(b => "%02x".format(b & 255)).mkString
    e.metrics((if (job.cache) "cache-" else "stream-") + profileName) = Map(
      "physicalLasts" -> physicalLasts, "intermediatePhysicalLasts" -> intermediateLasts,
      "logicalCompletions" -> normalizedLasts, "ibBeats" -> ibBeats, "dramBeats" -> dramBeats,
      "outputSha256" -> hash, "phaseReferenceBeats" -> refIndex)
    hash
  }

  it should "normalize source split boundaries and preserve STREAM output for DRAM miss IB hit and mixed sources" in {
    evidence("extra-source-split-contract") { e =>
      test(new InputBufferAcceptanceProbe) { d =>
        val init = new Driver(d, e); init.initialize()
        val job = Job(74, k = 17)
        val hashes = Seq("dram", "ib", "mixed").map(profile => sourceRun(d, e, job, profile, phaseReference = false))
        assert(hashes.distinct.size == 1)
        e.metrics("scope") = "test-only resolver/engines/normalizer + actual UB; production AG/IB integration unavailable"
      }
    }
  }

  it should "match a two-times-N fusion reference in CACHE and STREAM for both IB hits and misses" in {
    evidence("extra-fusion-reference-contract") { e =>
      test(new InputBufferAcceptanceProbe) { d =>
        val init = new Driver(d, e); init.initialize()
        val hashes = for (cache <- Seq(true, false); profile <- Seq("dram", "ib", "mixed"))
          yield sourceRun(d, e, Job(75, rows = 2, k = 2, n = 3, passes = 6, cache = cache, fusion = true),
            profile, phaseReference = true)
        assert(hashes.distinct.size == 1)
        e.metrics("scope") = "explicit W1-W2 per-column reference model; production phase/qparam/IB epoch wiring unavailable"
        e.metrics("profiles") = 6
      }
    }
  }
}
