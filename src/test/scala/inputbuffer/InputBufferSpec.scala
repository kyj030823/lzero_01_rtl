package npu.core.memory

import chisel3._
import chiseltest._
import chiseltest.experimental.expose
import org.scalatest.flatspec.AnyFlatSpec
import java.nio.file.{Files, Paths}
import java.nio.charset.StandardCharsets
import scala.collection.mutable

/** 제품 IO를 바꾸지 않는 소수의 관측 포트다. */
class ObservedInputBuffer extends InputBufferDataPath {
  val observedReadPtr = expose(core.reader.io.readPtr)
  val observedReadIssue = expose(core.reader.io.storageReadEnable)
  val observedReadAddress = expose(core.reader.io.storageReadBytePtr)
  val observedWritePtr = expose(core.writer.io.writeCommitPtr)
  val observedReclaimPtr = expose(core.writer.reclaimPtr)
  val observedReserved = expose(core.io.reservedBytes)
  val observedEntryCount = expose(core.writer.entryCount)
}

object InputBufferTestSupport {
  case class Job(id: Int, rows: Int = 1, k: Int = 1, n: Int = 1, passes: Int = 1,
    cache: Boolean = false, compact: Boolean = false, fusion: Boolean = false,
    enabled: Boolean = true, vpu: Boolean = false, vectorBytes: Int = 0) {
    val bytes = if (vpu) vectorBytes else k * (if (compact) 16 else 256)
    val compute = enabled && (if (vpu) vectorBytes > 0 else rows > 0 && k > 0 && n > 0)
    val rowCount = if (vpu) 1 else rows
    val passCount = if (vpu) 1 else passes
  }
  case class Request(group: Int, row: Int, pass: Int, offset: Int, bytes: Int)
  case class Expected(row: Int, pass: Int, word: Int)
  def yes(x: Bool): Boolean = x.peek().litToBoolean
  def number(x: UInt): Int = x.peek().litValue.toInt
  def word(id: Int, row: Int, index: Int): BigInt =
    (BigInt(0x5542) << 112) | (BigInt(id) << 96) | (BigInt(row) << 64) |
      (BigInt(index) << 16) | BigInt(0x5432)
  def configure(c: InputBufferConfig, j: Job): Unit = {
    c.bufferEnable.poke(j.enabled.B)
    c.operationMode.poke(if (j.vpu) InputBufferOperationMode.VPU_DIRECT else InputBufferOperationMode.GEMM)
    c.reuseMode.poke(if (j.cache) InputBufferReuseMode.LOCAL_ROW_CACHE else InputBufferReuseMode.STREAM)
    c.compactInputEnable.poke(j.compact.B); c.fusionEnable.poke(j.fusion.B)
    c.inputRowCount.poke(j.rows.U); c.reductionTileCount.poke(j.k.U)
    c.outputColumnCount.poke(j.n.U); c.rowReplayCount.poke(j.passes.U)
    c.vectorPayloadBytes.poke(j.vectorBytes.U)
    c.normalImpendingThresholdBytes.poke(128.U)
    c.compactImpendingThresholdBytes.poke(16.U)
    c.contextId.poke(j.id.U)
  }

  def json(v: Any): String = v match {
    case null => "null"
    case s: String => "\"" + s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n") + "\""
    case m: collection.Map[_, _] => m.iterator.map { case (k, x) => json(k.toString) + ":" + json(x) }.mkString("{", ",", "}")
    case xs: collection.Seq[_] => xs.iterator.map(json).mkString("[", ",", "]")
    case x => x.toString
  }
  class Evidence(val id: String) {
    val events = mutable.ArrayBuffer.empty[Map[String, Any]]
    val jobs = mutable.ArrayBuffer.empty[Map[String, Any]]
    val metrics = mutable.LinkedHashMap.empty[String, Any]
    def add(values: (String, Any)*): Unit = events += values.toMap
  }
  def evidence(id: String)(body: Evidence => Unit): Unit = {
    val e = new Evidence(id)
    var passed = false; var error = ""
    try { body(e); passed = true }
    catch { case t: Throwable => error = t.toString; throw t }
    finally {
      val dir = Paths.get(sys.props.getOrElse("ub.traceDir", "target/ub-tests"))
      Files.createDirectories(dir)
      Files.write(dir.resolve(id + ".json"), json(Map("id" -> id, "passed" -> passed,
        "error" -> error, "metrics" -> e.metrics.toMap, "jobs" -> e.jobs.toSeq,
        "events" -> e.events.toSeq)).getBytes(StandardCharsets.UTF_8))
    }
  }

  /** 기대값은 독립적인 m/pass/word 및 refill 계획으로 만들고 DUT counter를 사용하지 않는다. */
  class Driver(val d: ObservedInputBuffer, val e: Evidence) {
    var job = Job(1)
    var requests = Vector.empty[Request]
    var expected = Vector.empty[Expected]
    var cycle = 0; var requestIndex = 0; var outputIndex = 0
    var pending: Option[Request] = None
    var sent = 0; var inputBytes = 0; var resident = 0; var reserved = 0
    var released = 0; var entries = 0; var completedChunks = 0; var completedRows = 0
    var passDone = 0; var rowDone = 0; var opDone = 0; var ctxDone = 0
    var firstOutput = -1; var lastOutput = -1; var firstOutputInputBytes = -1
    var nextRowGrantsBeforeDone = 0; var dmaDuringPause = 0
    var paused = false

    def initialize(): Unit = {
      d.clock.setTimeout(100000)
      configure(d.io.config, job)
      d.io.contextStart.poke(false.B); d.io.softReset.poke(false.B)
      d.io.readEnable.poke(false.B); d.io.computeDataReady.poke(false.B)
      d.io.refillRequestReady.poke(false.B)
      idleMemory()
      d.reset.poke(true.B); d.clock.step(2); d.reset.poke(false.B); d.clock.step()
    }
    def idleMemory(): Unit = {
      d.io.memoryDataValid.poke(false.B); d.io.memoryData.poke(0.U)
      d.io.memoryLaneValidMask.poke(15.U); d.io.memoryChunkLast.poke(false.B)
      d.io.memoryStreamLast.poke(false.B); d.io.memoryContextId.poke(job.id.U)
    }
    def begin(j: Job): Unit = {
      job = j
      requests = (if (!j.compute) Vector.empty else
        (for {
          row <- 0 until j.rowCount
          pass <- 0 until (if (j.cache) 1 else j.passCount)
          offset <- 0 until j.bytes by 4096
        } yield Request(if (j.cache) row else row * j.passCount + pass,
          row, pass, offset, math.min(4096, j.bytes - offset))).toVector)
      expected = (if (!j.compute) Vector.empty else
        (for { row <- 0 until j.rowCount; pass <- 0 until j.passCount; w <- 0 until j.bytes / 16 }
          yield Expected(row, pass, w)).toVector)
      cycle = 0; requestIndex = 0; outputIndex = 0; pending = None
      sent = 0; inputBytes = 0; resident = 0; reserved = 0; released = 0; entries = 0
      completedChunks = 0; completedRows = 0; passDone = 0; rowDone = 0; opDone = 0; ctxDone = 0
      firstOutput = -1; lastOutput = -1; firstOutputInputBytes = -1
      nextRowGrantsBeforeDone = 0; dmaDuringPause = 0; paused = false
      configure(d.io.config, j)
      idleMemory()
      d.io.readEnable.poke(false.B); d.io.computeDataReady.poke(false.B)
      d.io.refillRequestReady.poke(false.B); d.io.contextStart.poke(true.B)
      d.io.configValid.expect(true.B); d.io.contextReady.expect(true.B)
      d.io.contextAccepted.expect(true.B); d.clock.step(); d.io.contextStart.poke(false.B)
    }
    def offer(): Unit = {
      val r = pending.get
      val bytes = math.min(64, r.bytes - sent)
      val lanes = bytes / 16
      // 무효 lane에도 다른 값을 넣어 mask 없이 기록하는 오류를 검출한다.
      val data = (0 until 4).foldLeft(BigInt(0)) { (a, lane) =>
        val w = if (lane < lanes) word(job.id, r.row, (r.offset + sent) / 16 + lane)
          else BigInt("deadbeefdeadbeefdeadbeefdeadbeef", 16)
        a | (w << (128 * lane))
      }
      val last = sent + bytes == r.bytes
      d.io.memoryDataValid.poke(true.B); d.io.memoryData.poke(data.U)
      d.io.memoryLaneValidMask.poke(((1 << lanes) - 1).U)
      d.io.memoryChunkLast.poke(last.B)
      d.io.memoryStreamLast.poke((last && requestIndex == requests.size).B)
      d.io.memoryContextId.poke(job.id.U)
    }
    def tick(): Unit = {
      val requestValid = yes(d.io.refillRequestValid)
      val grant = requestValid && yes(d.io.refillRequestReady)
      val mf = yes(d.io.memoryDataValid) && yes(d.io.memoryDataReady)
      val valid = yes(d.io.computeDataValid)
      val fire = valid && yes(d.io.computeDataReady)
      val bytes = Integer.bitCount(number(d.io.memoryLaneValidMask)) * 16
      val totalInput = requests.map(_.bytes).sum
      val free = 16384 - resident - reserved
      d.io.freeBytes.expect(free.U); d.io.full.expect((free < 4096).B)
      d.observedReserved.expect(reserved.U); d.observedEntryCount.expect(entries.U)
      d.observedWritePtr.expect((inputBytes & 32767).U)
      d.observedReclaimPtr.expect((released & 32767).U)
      val readAddress = if (!job.cache) outputIndex * 16
        else if (outputIndex < expected.size) expected(outputIndex).row * job.bytes + expected(outputIndex).word * 16
        else totalInput
      d.observedReadPtr.expect((readAddress & 32767).U)
      assert(free >= 0 && entries <= 4)
      if (yes(d.observedReadIssue)) {
        val ahead = (inputBytes - number(d.observedReadAddress)) & 32767
        assert(ahead >= 16 && ahead <= 16384, "UB issued an uncommitted SRAM read")
      }
      d.io.initialReady.expect((!job.compute || completedChunks > 0).B)
      d.io.supplyStreamComplete.expect((totalInput > 0 && inputBytes == totalInput).B)
      if (outputIndex == expected.size || !job.compute) {
        d.io.refillRequestValid.expect(false.B); d.io.computeDataValid.expect(false.B)
        d.io.impending.expect(false.B); d.io.hungry.expect(false.B); d.io.starving.expect(false.B)
      }
      if (job.compute && job.cache && outputIndex < expected.size) {
        val out = expected(outputIndex)
        if (requestIndex < requests.size && requests(requestIndex).row > out.row && out.pass != job.passCount - 1) {
          d.io.refillRequestValid.expect(false.B); d.io.hungry.expect(false.B)
        }
        d.io.rowCacheReady.expect((completedRows > out.row).B)
      }
      if (requestValid) {
        assert(requestIndex < requests.size)
        val r = requests(requestIndex)
        d.io.refillRequestBytes.expect(r.bytes.U); d.io.refillRequestGroupIndex.expect(r.group.U)
        d.io.refillRequestRowIndex.expect(r.row.U)
        d.io.refillRequestRowPassIndex.expect(r.pass.U)
        d.io.refillRequestStartsNewGroup.expect((r.offset == 0).B)
        d.io.refillRequestAllowsOverwrite.expect((r.row > 0 && r.pass == 0 && r.offset == 0).B)
        d.io.refillRequestContextId.expect(job.id.U)
        if (job.cache && outputIndex < expected.size && r.row > expected(outputIndex).row)
          assert(expected(outputIndex).pass == job.passCount - 1)
      }
      if (valid) {
        assert(outputIndex < expected.size)
        val out = expected(outputIndex)
        d.io.computeData.expect(word(job.id, out.row, out.word).U)
        d.io.computeDataLast.expect((outputIndex == expected.size - 1).B)
        if (!job.vpu) {
          d.io.inputRowIndex.expect(out.row.U); d.io.rowPassIndex.expect(out.pass.U)
        } else {
          d.io.inputRowIndex.expect(0.U); d.io.rowPassIndex.expect(0.U)
        }
      }
      val passEnd = fire && expected(outputIndex).word == job.bytes / 16 - 1
      val rowEnd = passEnd && expected(outputIndex).pass == job.passCount - 1
      d.io.rowPassDone.expect((!job.vpu && passEnd).B)
      d.io.inputRowDone.expect((!job.vpu && rowEnd).B)
      d.io.operationDone.expect((fire && outputIndex == expected.size - 1).B)
      if (yes(d.io.contextDone)) ctxDone += 1

      if (grant) {
        assert(pending.isEmpty)
        val r = requests(requestIndex)
        if (job.cache && outputIndex < expected.size && r.row > expected(outputIndex).row)
          nextRowGrantsBeforeDone += 1
        pending = Some(r); sent = 0
        requestIndex += 1; reserved += r.bytes; entries += 1
        e.add("context" -> job.id, "cycle" -> cycle, "event" -> "request",
          "row" -> r.row, "pass" -> r.pass, "offset" -> r.offset, "bytes" -> r.bytes,
          "freeBefore" -> free, "outputIndex" -> outputIndex)
      }
      if (mf) {
        assert(pending.nonEmpty)
        sent += bytes; inputBytes += bytes; resident += bytes; reserved -= bytes
        if (paused) dmaDuringPause += 1
        if (yes(d.io.memoryChunkLast)) {
          val r = pending.get
          assert(sent == r.bytes)
          completedChunks += 1
          if (r.offset + r.bytes == job.bytes && (job.cache || r.pass == job.passCount - 1))
            completedRows += 1
          pending = None
          e.add("context" -> job.id, "cycle" -> cycle, "event" -> "chunk-commit",
            "row" -> r.row, "inputBytes" -> inputBytes, "outputIndex" -> outputIndex)
        }
      }
      if (fire) {
        val out = expected(outputIndex)
        if (firstOutput < 0) { firstOutput = cycle; firstOutputInputBytes = inputBytes }
        lastOutput = cycle
        val consumed = (out.word + 1) * 16
        val chunkEnd = consumed % 4096 == 0 || consumed == job.bytes
        if (chunkEnd && (!job.cache || out.pass == job.passCount - 1)) {
          val count = if (consumed % 4096 == 0) 4096 else consumed % 4096
          resident -= count; released += count; entries -= 1
        }
        if (passEnd) {
          passDone += 1
          if (rowEnd) rowDone += 1
          e.add("context" -> job.id, "cycle" -> cycle, "event" -> "pass-done",
            "row" -> out.row, "pass" -> out.pass, "rowDone" -> rowEnd,
            "operationDone" -> (outputIndex == expected.size - 1), "freeBefore" -> free)
        }
        if (outputIndex == expected.size - 1) opDone += 1
        outputIndex += 1
      }
      assert(resident >= 0 && reserved >= 0)
      d.clock.step(); cycle += 1
    }
    def finish(): Unit = {
      idleMemory(); d.io.refillRequestReady.poke(false.B)
      d.io.readEnable.poke(false.B); d.io.computeDataReady.poke(false.B)
      var n = 0
      while (yes(d.io.contextActive) && n < 8) { tick(); n += 1 }
      d.io.contextActive.expect(false.B)
      for (_ <- 0 until 4) tick()
      assert(ctxDone == 1 && opDone == (if (job.compute) 1 else 0))
      assert(outputIndex == expected.size && resident == 0 && reserved == 0 && entries == 0)
      e.jobs += Map("context" -> job.id, "rowBytes" -> job.bytes, "rows" -> job.rowCount,
        "passes" -> job.passCount, "cache" -> job.cache, "compact" -> job.compact,
        "inputBytes" -> inputBytes, "outputBeats" -> outputIndex, "requests" -> requestIndex,
        "firstOutputCycle" -> firstOutput, "lastOutputCycle" -> lastOutput,
        "firstOutputInputBytes" -> firstOutputInputBytes,
        "nextRowGrantsBeforeRowDone" -> nextRowGrantsBeforeDone,
        "dmaDuringPause" -> dmaDuringPause, "operationDoneCount" -> opDone, "contextDoneCount" -> ctxDone)
    }
    def run(readStartBytes: Int = 0, cadence: Boolean = false, stalls: Boolean = false,
      finalHold: Int = 3): Unit = {
      var step = 0; var hold = 0; var held = false
      val limit = math.max(100, expected.size * (if (cadence) 20 else 2) + requests.size * 70 + 200)
      while ((outputIndex < expected.size || (!job.compute && yes(d.io.contextActive))) && cycle < limit) {
        d.io.refillRequestReady.poke((!stalls || cycle % 7 != 3).B)
        if (pending.nonEmpty && (!stalls || cycle % 5 != 2)) offer() else idleMemory()
        paused = cadence && cycle >= 1 && cycle < 21
        val read = inputBytes >= readStartBytes && !paused
        d.io.readEnable.poke(read.B)
        if (!held && expected.nonEmpty && outputIndex == expected.size - 1 && yes(d.io.computeDataValid)) {
          held = true; hold = finalHold
        }
        val ready = read && !paused && (!cadence || step % 16 == 0) &&
          (!stalls || cycle % 11 != 4) && hold == 0
        d.io.computeDataReady.poke(ready.B)
        tick()
        if (!paused) step += 1
        if (hold > 0) hold -= 1
      }
      assert(outputIndex == expected.size, "UB run timed out")
      finish()
    }
  }
}

class InputBufferSpec extends AnyFlatSpec with ChiselScalatestTester {
  import InputBufferTestSupport._
  behavior of "UB v3"

  it should "validate mode shape replay capacity and compact threshold without width truncation" in {
    evidence("config") { e =>
      test(new InputBufferController(payloadByteWidth = 15)) { d =>
        d.io.contextStart.poke(false.B); d.io.softReset.poke(false.B)
        d.io.pathStatus.refillPending.poke(false.B); d.io.pathStatus.readPending.poke(false.B)
        d.io.pathStatus.operationDone.poke(false.B)
        configure(d.io.config, Job(1)); d.reset.poke(true.B); d.clock.step(2); d.reset.poke(false.B)
        val cases = Seq(
          (Job(1), true), (Job(1, n = 2, passes = 1), false),
          (Job(1, passes = 0), false), (Job(1, k = 64, cache = true), true),
          (Job(1, k = 65, cache = true), false), (Job(1, k = 128, cache = true), false),
          (Job(1, k = 128, cache = true, compact = true), true),
          (Job(1, k = 65535, cache = true), false),
          (Job(1, cache = true, fusion = true, passes = 2), true),
          (Job(1, fusion = true, passes = 2), true),
          (Job(1, vpu = true, vectorBytes = 80), true),
          (Job(1, vpu = true, vectorBytes = 17), false),
          (Job(1, vpu = true, vectorBytes = 80, cache = true), false),
          (Job(1, enabled = false), true), (Job(1, rows = 0, passes = 0), true))
        for (((j, valid), index) <- cases.zipWithIndex) {
          configure(d.io.config, j); d.io.configValid.expect(valid.B); d.io.contextReady.expect(valid.B)
          e.add("case" -> index, "expectedValid" -> valid); d.clock.step()
        }
        configure(d.io.config, Job(2, k = 128, cache = true, compact = true))
        d.io.config.compactImpendingThresholdBytes.poke(17.U); d.io.configValid.expect(false.B)
        d.io.config.compactImpendingThresholdBytes.poke(16.U)
        d.io.contextStart.poke(true.B); d.clock.step(); d.io.contextStart.poke(false.B)
        d.io.inputRowBytes.expect(2048.U); d.io.activeImpendingThresholdBytes.expect(16.U)
        configure(d.io.config, Job(3)); d.clock.step()
        d.io.activeConfig.contextId.expect(2.U); d.io.activeImpendingThresholdBytes.expect(16.U)
        d.io.pathStatus.operationDone.poke(true.B); d.clock.step()
        d.io.pathStatus.operationDone.poke(false.B); d.clock.step()
        d.io.contextReady.expect(true.B)
        e.metrics("configCases") = 16
      }
    }
  }

  it should "preserve dense STREAM m-pass-k order and resupply fusion through AG" in {
    evidence("stream") { e =>
      test(new ObservedInputBuffer) { d =>
        val x = new Driver(d, e); x.initialize()
        for (j <- Seq(Job(10, rows = 2, k = 3, n = 2, passes = 2),
          Job(11), Job(12, fusion = true, passes = 2))) {
          x.begin(j); x.run(stalls = true)
          assert(x.inputBytes == x.outputIndex * 16)
        }
      }
    }
  }

  it should "pack a six KiB row and replay without middle-pass refill before overlapping the next row" in {
    evidence("cache-6k") { e =>
      test(new ObservedInputBuffer) { d =>
        val x = new Driver(d, e); x.initialize()
        x.begin(Job(20, rows = 2, k = 24, n = 2, passes = 2, cache = true))
        x.run(readStartBytes = 4096)
        assert(x.inputBytes == 12288 && x.outputIndex == 1536 && x.requestIndex == 4)
        assert(x.firstOutputInputBytes < 6144 && x.nextRowGrantsBeforeDone > 0)
        assert(x.lastOutput - x.firstOutput + 1 == x.expected.size + 3, "prepared row/pass output must not bubble")
      }
    }
  }

  it should "reuse all four entries of a sixteen KiB row during its only and final pass" in {
    evidence("cache-16k") { e =>
      test(new ObservedInputBuffer) { d =>
        val x = new Driver(d, e); x.initialize()
        x.begin(Job(30, rows = 2, k = 64, cache = true))
        x.run(readStartBytes = 16384)
        assert(x.inputBytes == 32768 && x.outputIndex == 2048 && x.requestIndex == 8)
        assert(x.nextRowGrantsBeforeDone > 0)
        assert(x.lastOutput - x.firstOutput + 1 == x.expected.size + 3)
      }
    }
  }

  it should "consume compact fusion payload only on CU cadence and keep VPU tails linear" in {
    evidence("compact-vpu") { e =>
      test(new ObservedInputBuffer) { d =>
        val x = new Driver(d, e); x.initialize()
        x.begin(Job(40, rows = 2, k = 3, passes = 2, cache = true, compact = true, fusion = true))
        x.run(cadence = true)
        assert(x.inputBytes == 96 && x.outputIndex == 12 && x.dmaDuringPause > 0)
        x.begin(Job(41, k = 2, compact = true)); x.run(cadence = true)
        assert(x.inputBytes == 32 && x.outputIndex == 2)
        x.begin(Job(42, vpu = true, vectorBytes = 80)); x.run()
        assert(x.outputIndex == 5 && x.requestIndex == 1)
      }
    }
  }

  it should "hold final output drain contexts reject stale data and finish empty contexts safely" in {
    evidence("context-drain") { e =>
      test(new ObservedInputBuffer) { d =>
        val x = new Driver(d, e); x.initialize()
        x.begin(Job(50, compact = true))
        d.io.refillRequestReady.poke(true.B)
        while (x.pending.isEmpty) x.tick()
        d.io.refillRequestReady.poke(false.B); x.offer(); x.tick(); x.idleMemory()
        d.io.readEnable.poke(true.B)
        while (!yes(d.io.computeDataValid)) x.tick()
        d.io.readEnable.poke(false.B)
        configure(d.io.config, Job(51, compact = true))
        val held = number(d.observedReadPtr)
        for (_ <- 0 until 5) {
          d.io.contextReady.expect(false.B); d.observedReadPtr.expect(held.U)
          d.io.computeDataLast.expect(true.B); x.tick()
        }
        d.io.computeDataReady.poke(true.B); x.tick(); x.finish()
        x.begin(Job(51, compact = true))
        d.io.refillRequestReady.poke(true.B)
        while (x.pending.isEmpty) x.tick()
        d.io.refillRequestReady.poke(false.B)
        x.offer(); d.io.memoryContextId.poke(50.U)
        for (_ <- 0 until 3) { d.io.memoryDataReady.expect(false.B); x.tick() }
        x.idleMemory(); x.run()
        for (j <- Seq(Job(52, enabled = false), Job(53, rows = 0, passes = 0),
          Job(54, k = 0), Job(55, n = 0, passes = 0), Job(56, vpu = true))) {
          x.begin(j); x.run()
        }
        d.io.softReset.poke(true.B); d.clock.step(); d.io.softReset.poke(false.B)
        d.io.contextReady.expect(true.B); d.io.freeBytes.expect(16384.U)
      }
    }
  }
}
