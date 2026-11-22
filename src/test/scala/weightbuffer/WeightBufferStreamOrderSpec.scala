package npu.core.memory

import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec
import scala.collection.mutable
import scala.language.reflectiveCalls
import java.nio.charset.StandardCharsets
import java.nio.file.{Files, Paths}
import java.time.Instant

/** AG 모형의 논리 순서를 실제 SRAM을 거친 출력과 비교한다.
  * AG의 DRAM/IB 주소 생성 자체는 이 테스트의 검증 범위에 포함하지 않는다.
  */
class WeightBufferStreamOrderSpec extends AnyFlatSpec with ChiselScalatestTester {
  behavior of "WB STREAM logical order"

  private case class Scenario(id: String, title: String, m: Int, n: Int, k: Int,
    stalls: Boolean, preload: Boolean, context: Int) {
    val groupBytes = n * k * 256
    val groupBeats = groupBytes / 16
    val totalBytes = groupBytes * m
    val totalBeats = groupBeats * m
  }
  private case class Expected(m: Int, n: Int, k: Int, beat: Int, data: BigInt)
  private case class Request(m: Int, offset: Int, bytes: Int)
  private case class Pending(request: Request, due: Int, var sent: Int = 0)
  private def yes(x: Bool): Boolean = x.peek().litToBoolean
  private def num(x: UInt): Int = x.peek().litValue.toInt
  private def hex(x: BigInt): String = "0x" + ("0" * 32 + x.toString(16)).takeRight(32)
  private def word(context: Int, n: Int, k: Int, beat: Int): BigInt =
    (BigInt(0x5742) << 112) | (BigInt(context) << 96) |
      (BigInt(n) << 64) | (BigInt(k) << 32) | BigInt(beat)

  // JSON 기록에 Scala 표준 라이브러리만 사용한다.
  private def quote(s: String): String = "\"" + s.flatMap {
    case '"' => "\\\""
    case '\\' => "\\\\"
    case '\n' => "\\n"
    case '\r' => "\\r"
    case '\t' => "\\t"
    case c if c < ' ' => "\\u" + ("%04x".format(c.toInt))
    case c => c.toString
  } + "\""
  private def json(x: Any): String = x match {
    case null => "null"
    case s: String => quote(s)
    case b: Boolean => b.toString
    case n: Int => n.toString
    case n: Long => n.toString
    case xs: scala.collection.Map[_, _] =>
      xs.iterator.map { case (k, v) => quote(k.toString) + ":" + json(v) }.mkString("{", ",", "}")
    case xs: Iterable[_] => xs.iterator.map(json).mkString("[", ",", "]")
    case other => throw new IllegalArgumentException("Unsupported trace value: " + other.getClass)
  }
  private def obj(fields: (String, Any)*): mutable.LinkedHashMap[String, Any] =
    mutable.LinkedHashMap(fields: _*)
  private def save(id: String, result: Any): Unit = {
    val dir = Paths.get(sys.props.getOrElse("wb.streamOrderTraceDir", "target/wb-stream-order/traces"))
    Files.createDirectories(dir)
    Files.write(dir.resolve(id + ".json"), (json(result) + "\n").getBytes(StandardCharsets.UTF_8))
  }
  private def configure(d: WeightBufferDataPath, s: Scenario): Unit = {
    d.io.config.bufferEnable.poke(true.B)
    d.io.config.operationMode.poke(WeightBufferOperationMode.GEMM)
    d.io.config.reuseMode.poke(WeightBufferReuseMode.STREAM)
    d.io.config.fusionEnable.poke(false.B)
    d.io.config.weightSet0Bytes.poke(s.groupBytes.U)
    d.io.config.weightSet1Bytes.poke(0.U)
    d.io.config.weightReplayCount.poke(s.m.U)
    d.io.config.inputRowCount.poke(s.m.U)
    d.io.config.reductionTileCount.poke(s.k.U)
    d.io.config.outputColumnCount.poke(s.n.U)
    d.io.config.operand2PayloadBytes.poke(0.U)
    d.io.config.constantOperandEnable.poke(false.B)
    d.io.config.lutLoadEnable.poke(false.B)
    d.io.config.lutPayloadBytes.poke(0.U)
    d.io.config.lutTargetEnableMask.poke(0.U)
    d.io.config.normalImpendingThresholdBytes.poke(128.U)
    d.io.config.contextId.poke(s.context.U)
  }
  private def initialize(d: WeightBufferDataPath, s: Scenario): Unit = {
    d.clock.setTimeout(10000)
    configure(d, s)
    d.io.contextStart.poke(false.B); d.io.prefillStart.poke(false.B)
    d.io.softReset.poke(false.B); d.io.readEnable.poke(false.B)
    d.io.computeDataReady.poke(false.B); d.io.refillRequestReady.poke(false.B)
    d.io.lutCreditValid.poke(false.B); d.io.lutCreditBytes.poke(16.U)
    d.io.lutDataReady.poke(true.B)
    d.io.memoryDataValid.poke(false.B); d.io.memoryData.poke(0.U)
    d.io.memoryLaneValidMask.poke(15.U)
    d.io.memoryChunkLast.poke(false.B); d.io.memoryStreamLast.poke(false.B)
    d.io.memoryContextId.poke(s.context.U)
    d.io.memoryDataKind.poke(WeightBufferDataKind.WEIGHT)
    d.reset.poke(true.B); d.clock.step(2); d.reset.poke(false.B); d.clock.step()
  }

  private def run(d: WeightBufferDataPath, s: Scenario): Unit = {
    initialize(d, s)
    // 기대 출력은 DUT index를 읽지 않고 명세의 독립적인 중첩 반복으로 만든다.
    val expected = (for {
      m <- 0 until s.m; n <- 0 until s.n; k <- 0 until s.k; beat <- 0 until 16
    } yield Expected(m, n, k, beat, word(s.context, n, k, beat))).toVector
    val requests = (for {
      m <- 0 until s.m; offset <- 0 until s.groupBytes by 4096
    } yield Request(m, offset, math.min(4096, s.groupBytes - offset))).toVector
    val releaseAt = requests.map(r =>
      (r.m * s.groupBeats + (r.offset + r.bytes) / 16 - 1) -> r.bytes).toMap
    val samples = mutable.ArrayBuffer.empty[Any]
    val requestEvents = mutable.ArrayBuffer.empty[Any]
    val checks = mutable.ArrayBuffer.empty[Any]
    val receivedByGroup = Array.fill(s.m)(0)
    val random = new scala.util.Random(0x57424d4e4bL + s.context)
    val forcedStalls = mutable.Map.empty[Int, Int]
    var pending: Option[Pending] = None
    var heldMemory: Option[(BigInt, Int, Boolean, Boolean)] = None
    var heldOutput: Option[(BigInt, Boolean, Int)] = None
    var heldRequest: Option[(Int, Int, Boolean)] = None
    var cycle = 0
    var requestCount = 0
    var grantedBytes = 0
    var receivedBytes = 0
    var outputCount = 0
    var reclaimedBytes = 0
    var passDoneCount = 0
    var operationDoneCount = 0
    var contextDoneCount = 0
    var firstOutputCycle = -1
    var lastOutputCycle = -1
    var outputStallCycles = 0
    var readPauseCycles = 0
    var sourceDelayCycles = 0
    var lastProgress = 0
    var passed = false
    var error: String = null
    val started = Instant.now().toString

    try {
      d.io.configValid.expect(true.B); d.io.contextReady.expect(true.B)
      d.io.contextStart.poke(true.B); d.io.contextAccepted.expect(true.B)
      d.clock.step(); d.io.contextStart.poke(false.B)
      var finished = false
      while (!finished && cycle < 6000) {
        val outputAllowed = !s.preload || receivedBytes == s.totalBytes
        val readPause = s.stalls && cycle % 61 >= 37 && cycle % 61 <= 39
        val boundary = outputCount == s.groupBeats - 1 || outputCount == s.totalBeats - 1
        if (s.stalls && boundary && !forcedStalls.contains(outputCount)) forcedStalls(outputCount) = 3
        val forced = forcedStalls.getOrElse(outputCount, 0) > 0
        val outReady = outputAllowed && !forced && (!s.stalls || cycle % 17 < 14)
        d.io.readEnable.poke((outputAllowed && !readPause).B)
        d.io.computeDataReady.poke(outReady.B)
        d.io.refillRequestReady.poke((!s.stalls || cycle % 7 != 2).B)
        if (forced) forcedStalls(outputCount) -= 1

        if (heldMemory.isEmpty) pending.foreach { p =>
          if (cycle >= p.due && (!s.stalls || random.nextInt(5) != 0)) {
            val bytes = math.min(64, p.request.bytes - p.sent)
            // Source offset의 해석은 기대 출력 배열과 별도로 계산한다.
            val data = (0 until bytes / 16).foldLeft(BigInt(0)) { (acc, lane) =>
              val index = (p.request.offset + p.sent) / 16 + lane
              val n = index / (s.k * 16)
              val k = (index / 16) % s.k
              acc | (word(s.context, n, k, index % 16) << (lane * 128))
            }
            val last = p.sent + bytes == p.request.bytes
            val streamLast = last && p.request.m == s.m - 1 &&
              p.request.offset + p.request.bytes == s.groupBytes
            heldMemory = Some((data, bytes, last, streamLast))
          }
        }
        d.io.memoryDataValid.poke(heldMemory.nonEmpty.B)
        heldMemory.foreach { case (data, bytes, last, streamLast) =>
          d.io.memoryData.poke(data.U)
          d.io.memoryLaneValidMask.poke(((1 << (bytes / 16)) - 1).U)
          d.io.memoryChunkLast.poke(last.B); d.io.memoryStreamLast.poke(streamLast.B)
        }
        val reqValid = yes(d.io.refillRequestValid)
        val reqReady = yes(d.io.refillRequestReady)
        val reqFire = reqValid && reqReady
        val memValid = yes(d.io.memoryDataValid)
        val memReady = yes(d.io.memoryDataReady)
        val memFire = memValid && memReady
        val outValid = yes(d.io.computeDataValid)
        val outFire = outValid && outReady
        val outData = if (outValid) d.io.computeData.peek().litValue else BigInt(0)
        val outPass = num(d.io.passIndex)
        val outLast = yes(d.io.computeDataLast)
        val passDone = yes(d.io.passDone)
        val opDone = yes(d.io.operationDone)
        val contextDone = yes(d.io.contextDone)
        val e = if (outputCount < expected.size) Some(expected(outputCount)) else None
        val inputM = pending.map(_.request.m).getOrElse(-1)
        val inputIndex = pending.map(p => (p.request.offset + p.sent) / 16).getOrElse(-1)
        samples += obj(
          "cycle" -> cycle, "requestValid" -> reqValid, "requestReady" -> reqReady,
          "requestFire" -> reqFire, "requestBytes" -> num(d.io.refillRequestBytes),
          "requestGroup" -> num(d.io.refillRequestGroupIndex),
          "memoryValid" -> memValid, "memoryReady" -> memReady, "memoryFire" -> memFire,
          "memoryBytes" -> heldMemory.map(_._2).getOrElse(0),
          "memoryData" -> (if (memValid) hex(heldMemory.get._1 & ((BigInt(1) << 128) - 1)) else null),
          "inputM" -> inputM, "inputN" -> (if (inputIndex >= 0) inputIndex / (s.k * 16) else -1),
          "inputK" -> (if (inputIndex >= 0) (inputIndex / 16) % s.k else -1),
          "readEnable" -> yes(d.io.readEnable),
          "outputValid" -> outValid, "outputReady" -> outReady, "outputFire" -> outFire,
          "outputIndex" -> outputCount, "passIndex" -> outPass,
          "expectedM" -> e.map(_.m).getOrElse(-1), "expectedN" -> e.map(_.n).getOrElse(-1),
          "expectedK" -> e.map(_.k).getOrElse(-1), "expectedBeat" -> e.map(_.beat).getOrElse(-1),
          "expectedData" -> (if (outValid) e.map(x => hex(x.data)).orNull else null),
          "outputData" -> (if (outValid) hex(outData) else null),
          "actualN" -> (if (outValid) ((outData >> 64) & 0xffff).toInt else -1),
          "actualK" -> (if (outValid) ((outData >> 32) & 0xffff).toInt else -1),
          "actualBeat" -> (if (outValid) (outData & 0xffff).toInt else -1),
          "match" -> (!outValid || e.exists(x => x.data == outData && x.m == outPass)),
          "outputLast" -> outLast, "passDone" -> passDone, "operationDone" -> opDone,
          "contextDone" -> contextDone, "contextActive" -> yes(d.io.contextActive),
          "freeBytes" -> num(d.io.freeBytes), "refillPending" -> yes(d.io.refillPending),
          "initialReady" -> yes(d.io.initialReady), "hungry" -> yes(d.io.hungry),
          "starving" -> yes(d.io.starving), "impending" -> yes(d.io.impending))

        d.io.freeBytes.expect((16384 - grantedBytes + reclaimedBytes).U)
        d.io.refillPending.expect(pending.nonEmpty.B)
        d.io.weightCacheReady.expect(false.B); d.io.lutDataValid.expect(false.B)
        if (memValid) d.io.memoryDataReady.expect(true.B)
        assert(!(reqFire && memFire), "single outstanding refill cannot overlap grant and response")
        heldRequest.foreach { case (bytes, m, starts) =>
          d.io.refillRequestValid.expect(true.B); d.io.refillRequestBytes.expect(bytes.U)
          d.io.refillRequestGroupIndex.expect(m.U)
          d.io.refillRequestStartsNewGroup.expect(starts.B)
        }
        if (reqValid) {
          assert(requestCount < requests.size, "unexpected extra refill request")
          val r = requests(requestCount)
          d.io.refillRequestBytes.expect(r.bytes.U); d.io.refillRequestGroupIndex.expect(r.m.U)
          d.io.refillRequestStartsNewGroup.expect((r.offset == 0).B)
          d.io.refillRequestContextId.expect(s.context.U)
          d.io.refillRequestDataKind.expect(WeightBufferDataKind.WEIGHT)
          d.io.refillRequestIsPrefill.expect(false.B)
        }
        heldRequest = if (reqValid && !reqReady)
          Some((num(d.io.refillRequestBytes), num(d.io.refillRequestGroupIndex),
            yes(d.io.refillRequestStartsNewGroup))) else None
        heldOutput.foreach { case (data, last, m) =>
          d.io.computeDataValid.expect(true.B); d.io.computeData.expect(data.U)
          d.io.computeDataLast.expect(last.B); d.io.passIndex.expect(m.U)
        }
        if (outValid) {
          assert(e.nonEmpty, "unexpected extra output")
          val x = e.get
          d.io.computeData.expect(x.data.U); d.io.passIndex.expect(x.m.U)
          d.io.computeDataLast.expect((outputCount == s.totalBeats - 1).B)
          val localByte = (outputCount % s.groupBeats) * 16
          val chunkEnd = math.min((localByte / 4096 + 1) * 4096, s.groupBytes)
          assert(receivedByGroup(x.m) >= chunkEnd, "output preceded its chunk commit")
        }
        heldOutput = if (outValid && !outReady) Some((outData, outLast, outPass)) else None
        d.io.operationDone.expect((outFire && outputCount == s.totalBeats - 1).B)
        d.io.passDone.expect((outFire && (outputCount + 1) % s.groupBeats == 0).B)
        if (s.preload && outputCount > 0 && outputCount < s.totalBeats)
          assert(outFire, "preloaded STREAM must remain continuous across n/k/m boundaries")

        if (reqFire) {
          assert(pending.isEmpty)
          val r = requests(requestCount)
          requestEvents += obj("cycle" -> cycle, "m" -> r.m, "offset" -> r.offset, "bytes" -> r.bytes)
          pending = Some(Pending(r, cycle + (if (s.stalls) 2 + random.nextInt(3) else 1)))
          requestCount += 1; grantedBytes += r.bytes
        }
        if (memFire) {
          val p = pending.get; val bytes = heldMemory.get._2
          receivedBytes += bytes; receivedByGroup(p.request.m) += bytes; p.sent += bytes
          if (p.sent == p.request.bytes) pending = None
          heldMemory = None
        }
        if (outFire) {
          if (firstOutputCycle < 0) firstOutputCycle = cycle
          lastOutputCycle = cycle
          reclaimedBytes += releaseAt.getOrElse(outputCount, 0); outputCount += 1
        }
        if (outValid && !outReady) outputStallCycles += 1
        if (readPause) readPauseCycles += 1
        if (pending.nonEmpty && !memValid) sourceDelayCycles += 1
        if (passDone) passDoneCount += 1
        if (opDone) operationDoneCount += 1
        if (reqFire || memFire || outFire || contextDone) lastProgress = cycle
        assert(cycle - lastProgress < 120, "no progress for 120 cycles")
        if (contextDone) {
          contextDoneCount += 1
          assert(outputCount == s.totalBeats && receivedBytes == s.totalBytes)
          finished = true
        }
        d.clock.step(); cycle += 1
      }
      assert(finished, "STREAM test timed out")
      assert(requestCount == requests.size && pending.isEmpty)
      assert(outputCount == expected.size && reclaimedBytes == s.totalBytes)
      assert(passDoneCount == s.m && operationDoneCount == 1 && contextDoneCount == 1)
      if (s.stalls) assert(outputStallCycles >= 6 && readPauseCycles > 0 && sourceDelayCycles > 0)
      if (s.preload) assert(lastOutputCycle - firstOutputCycle + 1 == s.totalBeats)
      d.io.freeBytes.expect(16384.U); d.io.contextActive.expect(false.B)
      for (_ <- 0 until 3) {
        d.io.computeDataValid.expect(false.B); d.io.refillRequestValid.expect(false.B)
        d.io.operationDone.expect(false.B); d.io.impending.expect(false.B); d.clock.step()
      }
      for ((id, label) <- Seq(
        "order" -> "m→n→k·tile 내부 beat 순서와 실제 데이터 일치",
        "requests" -> "각 M-group의 byte 수·요청 횟수·groupIndex 일치",
        "commit" -> "완료한 chunk 범위에서만 출력",
        "completion" -> "passDone=M회, operationDone=최종 수락 1회",
        "space" -> "예약·반환 일치 및 마지막 소비 후 전체 공간 반환",
        "hold" -> (if (s.stalls) "정지 중 data·last·passIndex 보존" else "준비된 출력 구간에 빈 cycle 없음")))
        checks += obj("id" -> id, "label" -> label, "passed" -> true)
      passed = true
    } catch {
      case t: Throwable => error = Option(t.getMessage).getOrElse(t.getClass.getName); throw t
    } finally {
      save(s.id, obj("schemaVersion" -> 1, "id" -> s.id, "title" -> s.title,
        "status" -> (if (passed) "PASS" else "FAIL"), "kind" -> "stream",
        "startedAt" -> started, "error" -> error,
        "config" -> obj("m" -> s.m, "n" -> s.n, "k" -> s.k, "weightReplayCount" -> s.m,
          "groupBytes" -> s.groupBytes, "contextId" -> s.context, "stalls" -> s.stalls, "preload" -> s.preload),
        "expected" -> obj("inputBytes" -> s.totalBytes, "outputBeats" -> s.totalBeats,
          "requestCount" -> requests.size, "passDoneCount" -> s.m, "operationDoneCount" -> 1),
        "actual" -> obj("cycles" -> cycle, "inputBytes" -> receivedBytes, "outputBeats" -> outputCount,
          "requestCount" -> requestCount, "passDoneCount" -> passDoneCount,
          "operationDoneCount" -> operationDoneCount, "contextDoneCount" -> contextDoneCount,
          "firstOutputCycle" -> firstOutputCycle, "lastOutputCycle" -> lastOutputCycle,
          "outputStallCycles" -> outputStallCycles, "readPauseCycles" -> readPauseCycles,
          "sourceDelayCycles" -> sourceDelayCycles),
        "checks" -> checks, "requests" -> requestEvents, "samples" -> samples))
    }
  }

  it should "preserve m-n-k order for three preloaded STREAM groups without output bubbles" in {
    test(new WeightBufferDataPath) { d =>
      run(d, Scenario("baseline", "기본 순서 · 연속 출력", 3, 2, 4, false, true, 51))
    }
  }
  it should "preserve m-n-k order through deterministic DMA and compute pauses" in {
    test(new WeightBufferDataPath) { d =>
      run(d, Scenario("stalls", "입력 지연 · 출력 정지", 3, 2, 4, true, false, 52))
    }
  }
  it should "preserve logical order across 4KiB and 512B refill boundaries" in {
    test(new WeightBufferDataPath) { d =>
      run(d, Scenario("chunk-boundary", "4KiB chunk 경계", 2, 3, 6, true, false, 53))
    }
  }
  it should "reject unequal STREAM row and replay counts before context acceptance" in {
    test(new WeightBufferDataPath) { d =>
      val s = Scenario("count-mismatch", "Row / replayCount 설정 검사", 3, 2, 4, false, false, 54)
      initialize(d, s)
      val samples = mutable.ArrayBuffer.empty[Any]
      var passed = false
      var error: String = null
      try {
        for ((count, i) <- Seq(2, 3).zipWithIndex) {
          d.io.config.weightReplayCount.poke(count.U)
          d.io.configValid.expect((count == s.m).B)
          d.io.contextReady.expect((count == s.m).B)
          d.io.contextAccepted.expect(false.B)
          d.io.refillRequestValid.expect(false.B); d.io.computeDataValid.expect(false.B)
          samples += obj("cycle" -> i, "inputRowCount" -> s.m, "weightReplayCount" -> count,
            "expectedConfigValid" -> (count == s.m), "configValid" -> yes(d.io.configValid),
            "contextReady" -> yes(d.io.contextReady), "contextAccepted" -> yes(d.io.contextAccepted))
          d.clock.step()
        }
        passed = true
      } catch {
        case t: Throwable => error = Option(t.getMessage).getOrElse(t.getClass.getName); throw t
      } finally {
        save(s.id, obj("schemaVersion" -> 1, "id" -> s.id, "title" -> s.title,
          "kind" -> "config", "status" -> (if (passed) "PASS" else "FAIL"), "error" -> error,
          "config" -> obj("m" -> 3, "n" -> 2, "k" -> 4, "weightReplayCount" -> 2),
          "checks" -> Seq(obj("id" -> "mismatch", "label" -> "M=3/replay=2 거부, replay=3 허용",
            "passed" -> passed)), "samples" -> samples))
      }
    }
  }
}
