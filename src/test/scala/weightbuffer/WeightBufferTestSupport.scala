package npu.core.memory

import chisel3._
import chiseltest._
import chiseltest.experimental.expose
import org.scalatest.Tag
import java.nio.file.{Files, Paths}
import java.nio.charset.StandardCharsets
import scala.collection.mutable

/** 이전 실행에서 제외했던 긴 LUT 조합을 분류한다. */
object WbExtendedLut extends Tag("npu.core.memory.WbExtendedLut")

/** 테스트 전용 관측 포트다. 제품 WB의 IO는 바꾸지 않는다. */
class ObservedWeightBuffer extends WeightBufferDataPath {
  val observedWritePtr = expose(core.writer.io.writeCommitPtr)
  val observedReclaimPtr = expose(core.writer.reclaimPtr)
  val observedReserved = expose(core.io.reservedBytes)
  val observedEntries = expose(core.writer.io.chunkEntries)
  val observedReadIssue = expose(core.reader.io.storageReadEnable)
  val observedReadAddress = expose(core.reader.io.storageReadBytePtr)
  val observedReadIdle = expose(core.io.readPipelineIdle)
  val observedIssueEnd = expose(core.reader.io.currentChunk.endPtr)
  val observedIssueContext = expose(core.reader.io.currentChunk.contextId)
}

object WbEvidence {
  def json(v: Any): String = v match {
    case null => "null"
    case s: String => "\"" + s.flatMap {
      case '"' => "\\\""
      case '\\' => "\\\\"
      case '\n' => "\\n"
      case '\r' => "\\r"
      case '\t' => "\\t"
      case c if c < ' ' => "\\u%04x".format(c.toInt)
      case c => c.toString
    } + "\""
    case b: Boolean => b.toString
    case m: collection.Map[_, _] => m.iterator.map { case (k, x) => json(k.toString) + ":" + json(x) }.mkString("{", ",", "}")
    case xs: collection.Seq[_] => xs.iterator.map(json).mkString("[", ",", "]")
    case n => n.toString
  }
  class Log(val id: String, val requirements: Seq[Int], val description: String) {
    val samples = mutable.ArrayBuffer.empty[Map[String, Any]]
    val metrics = mutable.LinkedHashMap.empty[String, Any]
    var extra = Map.empty[String, Any]
    def add(values: (String, Any)*): Unit = samples += (extra ++ values.toMap)
  }
  def run(id: String, requirements: Seq[Int], description: String)(body: Log => Unit): Unit = {
    val log = new Log(id, requirements, description)
    var status = "FAIL"; var error = ""
    try { body(log); status = "PASS" }
    catch { case e: Throwable => error = e.toString; throw e }
    finally {
      val dir = Paths.get(sys.props.getOrElse("wb.acceptanceTraceDir", "target/wb-acceptance/traces"))
      Files.createDirectories(dir)
      Files.write(dir.resolve(id + ".json"), json(Map("schemaVersion" -> 1, "id" -> id,
        "requirements" -> requirements, "description" -> description, "status" -> status,
        "error" -> error, "metrics" -> log.metrics.toMap, "samples" -> log.samples.toSeq)).getBytes(StandardCharsets.UTF_8))
    }
  }
}

object WbAcceptanceSupport {
  case class Job(id: Int, bytes: Int = 256, passes: Int = 1, cache: Boolean = false,
    lut: Int = 0, enabled: Boolean = true, vpu: Boolean = false, constant: Boolean = false) {
    val compute: Boolean = enabled && bytes > 0 && !(vpu && constant)
    val outputs: Int = if (!compute) 0 else bytes / 16 * (if (vpu) 1 else passes)
    val inputs: Int = if (!compute) 0 else bytes * (if (cache || vpu) 1 else passes)
  }
  def yes(x: Bool): Boolean = x.peek().litToBoolean
  def number(x: UInt): Int = x.peek().litValue.toInt
  def word(id: Int, index: Int, lut: Boolean = false): BigInt =
    (BigInt(if (lut) 0x4c55 else 0x5742) << 112) | (BigInt(id) << 96) |
      (BigInt(index) << 48) | BigInt(0x12340000L + index)
  def hex(x: BigInt): String = "0x" + ("0" * 32 + x.toString(16)).takeRight(32)
  def configure(d: WeightBufferDataPath, j: Job): Unit = {
    d.io.config.bufferEnable.poke(j.enabled.B)
    d.io.config.operationMode.poke(if (j.vpu) WeightBufferOperationMode.VPU_DIRECT else WeightBufferOperationMode.GEMM)
    d.io.config.reuseMode.poke(if (j.cache) WeightBufferReuseMode.LOCAL_WEIGHT_CACHE else WeightBufferReuseMode.STREAM)
    d.io.config.fusionEnable.poke(false.B)
    d.io.config.weightSet0Bytes.poke((if (j.vpu) 0 else j.bytes).U)
    d.io.config.weightSet1Bytes.poke(0.U)
    d.io.config.weightReplayCount.poke(j.passes.U); d.io.config.inputRowCount.poke(j.passes.U)
    d.io.config.reductionTileCount.poke((if (j.vpu) 0 else j.bytes / 256).U)
    d.io.config.outputColumnCount.poke((if (j.vpu || j.bytes == 0) 0 else 1).U)
    d.io.config.operand2PayloadBytes.poke((if (j.vpu) j.bytes else 0).U)
    d.io.config.constantOperandEnable.poke(j.constant.B)
    d.io.config.lutLoadEnable.poke((j.lut > 0).B); d.io.config.lutPayloadBytes.poke(j.lut.U)
    d.io.config.lutTargetEnableMask.poke(21.U)
    d.io.config.normalImpendingThresholdBytes.poke(128.U); d.io.config.contextId.poke(j.id.U)
  }

  /** 입력 handshake로 정답 큐와 공간을 갱신한다. DUT counter를 정답으로 쓰지 않는다. */
  class Driver(val d: ObservedWeightBuffer, val log: WbEvidence.Log) {
    var cycle = 0
    var job = Job(1)
    var lutIn = 0; var weightIn = 0; var lutOut = 0; var weightOut = 0
    var requestCount = 0; var doneCount = 0; var contextDoneCount = 0; var passCount = 0
    var overlapCount = 0; var readIssues = 0
    var resident = 0; var reserved = 0; var entries = 0
    var writtenAbsolute = 0; var reclaimedAbsolute = 0
    var requested = 0; var completedChunks = 0
    var activeBytes = 0; var activeSent = 0; var activeOffset = 0
    var firstOutputCycle = -1; var lastOutputCycle = -1

    def idleMemory(): Unit = {
      d.io.memoryDataValid.poke(false.B); d.io.memoryData.poke(0.U)
      d.io.memoryLaneValidMask.poke(15.U)
      d.io.memoryChunkLast.poke(false.B); d.io.memoryStreamLast.poke(false.B)
      d.io.memoryContextId.poke(job.id.U); d.io.memoryDataKind.poke(WeightBufferDataKind.WEIGHT)
    }
    def initialize(): Unit = {
      d.clock.setTimeout(100000); configure(d, job)
      d.io.contextStart.poke(false.B); d.io.prefillStart.poke(false.B); d.io.softReset.poke(false.B)
      d.io.readEnable.poke(false.B); d.io.computeDataReady.poke(false.B)
      d.io.refillRequestReady.poke(false.B); d.io.lutCreditValid.poke(false.B)
      d.io.lutCreditBytes.poke(16.U); d.io.lutDataReady.poke(false.B); idleMemory()
      d.reset.poke(true.B); d.clock.step(2); d.reset.poke(false.B); d.clock.step()
    }
    def begin(j: Job): Unit = {
      assert(resident == 0 && reserved == 0 && entries == 0, "previous context must drain")
      job = j
      lutIn = 0; weightIn = 0; lutOut = 0; weightOut = 0; requested = 0
      requestCount = 0; completedChunks = 0; doneCount = 0; contextDoneCount = 0
      passCount = 0; overlapCount = 0; activeBytes = 0; activeSent = 0; activeOffset = 0
      firstOutputCycle = -1; lastOutputCycle = -1
      configure(d, j); idleMemory()
      d.io.readEnable.poke(false.B); d.io.computeDataReady.poke(false.B)
      d.io.refillRequestReady.poke(false.B); d.io.lutCreditValid.poke(false.B)
      d.io.lutDataReady.poke(false.B); d.io.contextStart.poke(true.B)
      d.io.configValid.expect(true.B); d.io.contextReady.expect(true.B); d.io.contextAccepted.expect(true.B)
      log.add("cycle" -> cycle, "event" -> "context-start", "contextId" -> j.id,
        "bytes" -> j.bytes, "lutBytes" -> j.lut, "passes" -> j.passes, "cache" -> j.cache,
        "computeEnabled" -> j.compute, "vpu" -> j.vpu)
      d.clock.step(); cycle += 1; d.io.contextStart.poke(false.B)
      entries = if (j.lut > 0) 1 else 0
    }

    def tick(): Unit = {
      val mf = yes(d.io.memoryDataValid) && yes(d.io.memoryDataReady)
      val lf = yes(d.io.lutDataValid) && yes(d.io.lutDataReady)
      val wf = yes(d.io.computeDataValid) && yes(d.io.computeDataReady)
      val rf = yes(d.io.refillRequestValid) && yes(d.io.refillRequestReady)
      val cf = yes(d.io.lutCreditValid) && yes(d.io.lutCreditReady)
      val isLut = d.io.memoryDataKind.peek().litValue == WeightBufferDataKind.LUT.litValue
      val payload = Integer.bitCount(number(d.io.memoryLaneValidMask)) * 16
      val free = 16384 - resident - reserved
      d.io.freeBytes.expect(free.U); d.io.full.expect((free < 4096).B)
      d.observedReserved.expect(reserved.U)
      d.observedWritePtr.expect((writtenAbsolute & 32767).U)
      d.observedReclaimPtr.expect((reclaimedAbsolute & 32767).U)
      assert(d.observedEntries.map(e => yes(e.allocated)).count(identity) == entries)
      assert(entries >= 0 && entries <= 4 && free >= 0)
      if (yes(d.observedReadIssue)) {
        val address = number(d.observedReadAddress)
        val committed = (number(d.observedWritePtr) - address) & 32767
        val inRange = (number(d.observedIssueEnd) - address) & 32767
        assert(committed >= 16 && committed <= 16384, s"uncommitted SRAM read @$cycle")
        assert(inRange >= 16 && inRange <= 16384, s"read beyond selected chunk @$cycle")
        d.observedIssueContext.expect(job.id.U); readIssues += 1
      }
      if (yes(d.io.lutDataValid)) {
        assert(lutOut < job.lut / 16 && (lutOut + 1) * 16 <= lutIn)
        d.io.lutData.expect(word(job.id, lutOut, lut = true).U)
        d.io.lutDataLast.expect((lutOut == job.lut / 16 - 1).B)
      }
      if (yes(d.io.computeDataValid)) {
        assert(job.compute && weightOut < job.outputs && lutOut == job.lut / 16)
        val local = weightOut % (job.bytes / 16)
        d.io.computeData.expect(word(job.id, local).U)
        d.io.passIndex.expect((weightOut / (job.bytes / 16)).U)
        d.io.computeDataLast.expect((weightOut == job.outputs - 1).B)
      }
      val expectedPass = wf && (weightOut + 1) % (math.max(16, job.bytes) / 16) == 0
      val expectedDone = wf && weightOut + 1 == job.outputs
      d.io.passDone.expect(expectedPass.B); d.io.operationDone.expect(expectedDone.B)
      d.io.lutReceiveDone.expect((mf && isLut && lutIn + payload == job.lut).B)
      d.io.lutStreamDone.expect((lf && lutOut + 1 == job.lut / 16).B)
      if (!job.compute) {
        d.io.refillRequestValid.expect(false.B)
        d.io.impending.expect(false.B); d.io.hungry.expect(false.B); d.io.starving.expect(false.B)
      }
      if (lutIn < job.lut) d.io.refillRequestValid.expect(false.B)
      if (job.compute && job.cache && weightIn == job.inputs) {
        d.io.hungry.expect(false.B); d.io.refillRequestValid.expect(false.B)
      }
      if (job.compute) d.io.initialReady.expect((completedChunks > 0).B)

      log.add("cycle" -> cycle, "contextId" -> job.id, "event" -> "cycle",
        "freeBytes" -> free, "residentBytes" -> resident, "reservedBytes" -> reserved,
        "entries" -> entries, "writePtr" -> number(d.observedWritePtr), "reclaimPtr" -> number(d.observedReclaimPtr),
        "readIssue" -> yes(d.observedReadIssue), "readAddress" -> number(d.observedReadAddress),
        "issueEnd" -> number(d.observedIssueEnd), "readIdle" -> yes(d.observedReadIdle),
        "requestValid" -> yes(d.io.refillRequestValid), "requestReady" -> yes(d.io.refillRequestReady),
        "requestFire" -> rf, "requestBytes" -> number(d.io.refillRequestBytes),
        "creditFire" -> cf, "creditBytes" -> number(d.io.lutCreditBytes),
        "memoryFire" -> mf, "memoryLut" -> isLut, "memoryBytes" -> payload, "memoryLast" -> yes(d.io.memoryChunkLast),
        "lutValid" -> yes(d.io.lutDataValid), "lutReady" -> yes(d.io.lutDataReady),
        "lutFire" -> lf, "lutIndex" -> lutOut, "lutData" -> hex(d.io.lutData.peek().litValue),
        "lutExpected" -> hex(word(job.id, lutOut, lut = true)),
        "computeValid" -> yes(d.io.computeDataValid), "computeReady" -> yes(d.io.computeDataReady),
        "computeFire" -> wf, "outputIndex" -> weightOut,
        "computeData" -> hex(d.io.computeData.peek().litValue),
        "computeExpected" -> hex(word(job.id, if (job.bytes > 0) weightOut % (job.bytes / 16) else 0)),
        "passIndex" -> number(d.io.passIndex), "computeLast" -> yes(d.io.computeDataLast),
        "readEnable" -> yes(d.io.readEnable), "initialReady" -> yes(d.io.initialReady),
        "impending" -> yes(d.io.impending), "hungry" -> yes(d.io.hungry),
        "receiveDone" -> yes(d.io.lutReceiveDone), "streamDone" -> yes(d.io.lutStreamDone),
        "supplyComplete" -> yes(d.io.weightSupplyComplete), "cacheReady" -> yes(d.io.weightCacheReady),
        "passDone" -> yes(d.io.passDone), "operationDone" -> yes(d.io.operationDone),
        "contextDone" -> yes(d.io.contextDone))

      if (rf) {
        val expected = math.min(4096, job.bytes - requested % job.bytes)
        d.io.refillRequestBytes.expect(expected.U)
        d.io.refillRequestGroupIndex.expect((requested / job.bytes).U)
        d.io.refillRequestContextId.expect(job.id.U)
        assert(activeBytes == 0 && requested < job.inputs)
        activeBytes = expected; activeSent = 0; activeOffset = requested % job.bytes
        requested += expected; reserved += expected; entries += 1; requestCount += 1
      }
      if (cf) reserved += number(d.io.lutCreditBytes)
      if (mf) {
        reserved -= payload; resident += payload; writtenAbsolute += payload
        if (isLut) lutIn += payload
        else {
          assert(activeBytes > 0)
          activeSent += payload; weightIn += payload
          if (yes(d.io.memoryChunkLast)) {
            assert(activeSent == activeBytes); activeBytes = 0; completedChunks += 1
          }
        }
      }
      if (lf) {
        lutOut += 1; resident -= 16; reclaimedAbsolute += 16
        if (lutOut == job.lut / 16) entries -= 1
      }
      if (wf) {
        if (firstOutputCycle < 0) firstOutputCycle = cycle
        lastOutputCycle = cycle
        val consumed = (weightOut % (job.bytes / 16) + 1) * 16
        val chunkEnd = consumed % 4096 == 0 || consumed == job.bytes
        val finalUse = !job.cache || weightOut / (job.bytes / 16) == job.passes - 1
        if (chunkEnd && finalUse) {
          val bytes = if (consumed % 4096 == 0) 4096 else consumed % 4096
          resident -= bytes; reclaimedAbsolute += bytes; entries -= 1
        }
        weightOut += 1
      }
      if (lf && mf && !isLut) overlapCount += 1
      if (expectedPass) passCount += 1
      if (expectedDone) doneCount += 1
      if (yes(d.io.contextDone)) contextDoneCount += 1
      assert(resident >= 0 && reserved >= 0)
      d.clock.step(); cycle += 1
    }
    def waitUntil(condition: => Boolean, limit: Int = 12): Unit = {
      var n = 0
      while (!condition && n < limit) { tick(); n += 1 }
      assert(condition, s"timeout after $limit clocks, context=" + job.id + s", cycle=$cycle")
    }
    def credit(bytes: Int): Unit = {
      d.io.lutCreditBytes.poke(bytes.U); d.io.lutCreditValid.poke(true.B)
      d.io.lutCreditReady.expect(true.B); tick(); d.io.lutCreditValid.poke(false.B)
    }
    def grant(): Unit = {
      d.io.refillRequestReady.poke(true.B); waitUntil(yes(d.io.refillRequestValid))
      tick(); d.io.refillRequestReady.poke(false.B)
    }
    def offer(lut: Boolean, offset: Int, bytes: Int, last: Boolean, streamLast: Boolean): Unit = {
      val value = (0 until bytes / 16).foldLeft(BigInt(0)) { (a, lane) =>
        a | (word(job.id, offset / 16 + lane, lut) << (lane * 128))
      }
      d.io.memoryDataValid.poke(true.B); d.io.memoryData.poke(value.U)
      d.io.memoryLaneValidMask.poke(((1 << (bytes / 16)) - 1).U)
      d.io.memoryContextId.poke(job.id.U)
      d.io.memoryDataKind.poke(if (lut) WeightBufferDataKind.LUT else if (job.vpu) WeightBufferDataKind.VECTOR_OPERAND else WeightBufferDataKind.WEIGHT)
      d.io.memoryChunkLast.poke(last.B); d.io.memoryStreamLast.poke(streamLast.B)
    }
    def sendLut(start: Int, bytes: Int): Unit = {
      for (offset <- start until start + bytes by 64) {
        val n = math.min(64, start + bytes - offset); val last = offset + n == job.lut
        offer(lut = true, offset, n, last, last); d.io.memoryDataReady.expect(true.B); tick()
      }
      idleMemory()
    }
    def sendActive(): Unit = {
      val n = activeBytes; val base = activeOffset; val end = requested == job.inputs
      for (offset <- 0 until n by 64) {
        val size = math.min(64, n - offset)
        offer(lut = false, base + offset, size, offset + size == n, end && offset + size == n)
        d.io.memoryDataReady.expect(true.B); tick()
      }
      idleMemory()
    }
    def consumeAll(): Unit = {
      d.io.readEnable.poke(true.B); d.io.computeDataReady.poke(true.B)
      waitUntil(weightOut == job.outputs, job.outputs + 16)
    }
    def finish(): Unit = {
      d.io.readEnable.poke(false.B); d.io.computeDataReady.poke(false.B)
      waitUntil(!yes(d.io.contextActive))
      for (_ <- 0 until 4) {
        d.io.computeDataValid.expect(false.B); d.io.lutDataValid.expect(false.B)
        d.io.impending.expect(false.B); d.io.operationDone.expect(false.B); tick()
      }
      assert(weightOut == job.outputs && lutOut == job.lut / 16)
      assert(doneCount == (if (job.compute) 1 else 0) && contextDoneCount == 1)
      assert(resident == 0 && reserved == 0 && entries == 0)
      log.metrics("context-" + job.id) = Map("inputBytes" -> weightIn, "lutBytes" -> lutIn,
        "outputBeats" -> weightOut, "passes" -> passCount, "operationDoneCount" -> doneCount,
        "contextDoneCount" -> contextDoneCount, "requests" -> requestCount,
        "overlapCycles" -> overlapCount, "firstOutputCycle" -> firstOutputCycle, "lastOutputCycle" -> lastOutputCycle)
    }
    /** 포인터 주입 없이 실제 쓰기/소비로 wrap 부근까지 이동한다. */
    def padTo(absolute: Int, id: Int): Unit = {
      val amount = absolute - writtenAbsolute
      assert(amount >= 0 && amount % 16 == 0)
      if (amount > 0) {
        begin(Job(id, bytes = amount, vpu = true))
        d.io.readEnable.poke(true.B); d.io.computeDataReady.poke(true.B)
        while (requested < job.inputs) {
          d.io.refillRequestReady.poke(true.B)
          waitUntil(yes(d.io.refillRequestValid), amount / 16 + 16)
          tick(); d.io.refillRequestReady.poke(false.B); sendActive()
        }
        consumeAll(); finish()
      }
    }
  }
}
