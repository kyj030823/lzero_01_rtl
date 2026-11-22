package npu.core.memory

import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec
import scala.collection.mutable
import WbAcceptanceSupport._

/** 저장소/예약/응답 보관은 짧은 단위 시험으로 모든 경계를 직접 만든다. */
class CircularBufferBoundarySpec extends AnyFlatSpec with ChiselScalatestTester {
  behavior of "Circular buffer boundaries"

  it should "steer every prefix mask from every bank across physical and extended wrap" in {
    WbEvidence.run("storage-mask-matrix", Seq(10), "시작 bank × mask × 일반/물리 wrap/확장 wrap 48조합") { log =>
      test(new CircularBufferStorage) { d =>
        val model = Array.tabulate[BigInt](1024)(i => word(110, i))
        def packed(values: Seq[BigInt]): BigInt = values.zipWithIndex.foldLeft(BigInt(0)) {
          case (a, (v, lane)) => a | (v << (lane * 128))
        }
        d.io.writeEnable.poke(false.B); d.io.writeBytePtr.poke(0.U)
        d.io.writeData.poke(0.U); d.io.writeLaneValidMask.poke(15.U)
        d.io.readEnable.poke(false.B); d.io.readBytePtr.poke(0.U)
        d.reset.poke(true.B); d.clock.step(2); d.reset.poke(false.B)
        for (base <- 0 until 1024 by 4) {
          d.io.writeEnable.poke(true.B); d.io.writeBytePtr.poke((base * 16).U)
          d.io.writeData.poke(packed(model.slice(base, base + 4).toSeq).U); d.clock.step()
        }
        d.io.writeEnable.poke(false.B)
        var cases = 0; var reads = 0
        for (region <- Seq(0, 16320, 32704); bank <- 0 until 4; lanes <- 1 to 4) {
          val address = region + bank * 16
          val values = (0 until 4).map(lane => word(111 + cases, lane))
          d.io.readEnable.poke(false.B)
          d.io.writeEnable.poke(true.B); d.io.writeBytePtr.poke(address.U)
          d.io.writeLaneValidMask.poke(((1 << lanes) - 1).U)
          d.io.writeData.poke(packed(values).U); d.clock.step()
          for (lane <- 0 until lanes) model(((address / 16) + lane) % 1024) = values(lane)
          d.io.writeEnable.poke(false.B)
          for (offset <- -2 until 6) {
            val read = (address + offset * 16) & 32767
            d.io.readEnable.poke(true.B); d.io.readBytePtr.poke(read.U); d.clock.step()
            d.io.readDataValid.expect(true.B); d.io.readData.expect(model((read / 16) % 1024).U)
            reads += 1
          }
          log.add("caseIndex" -> cases, "startBank" -> bank, "lanes" -> lanes,
            "mask" -> ((1 << lanes) - 1), "address" -> address, "neighborReads" -> 8, "passed" -> true)
          cases += 1
        }
        // 같은 bank의 다른 word를 읽으면서 쓸 수 있어야 한다.
        for (bank <- 0 until 4; lanes <- 1 to 4) {
          val address = bank * 16; val read = address + 128
          val expected = model(read / 16)
          val values = (0 until 4).map(lane => word(170 + bank * 4 + lanes, lane))
          d.io.writeEnable.poke(true.B); d.io.writeBytePtr.poke(address.U)
          d.io.writeLaneValidMask.poke(((1 << lanes) - 1).U); d.io.writeData.poke(packed(values).U)
          d.io.readEnable.poke(true.B); d.io.readBytePtr.poke(read.U); d.clock.step()
          d.io.readDataValid.expect(true.B); d.io.readData.expect(expected.U)
          for (lane <- 0 until lanes) model((address / 16 + lane) % 1024) = values(lane)
        }
        d.io.writeEnable.poke(false.B); d.io.readEnable.poke(false.B); d.clock.step()
        d.io.readDataValid.expect(false.B)
        log.metrics("matrixCases") = cases; log.metrics("neighborReadChecks") = reads
        log.metrics("simultaneousReadWriteCases") = 16
      }
    }
  }

  private case class Entry(index: Int, var start: Int, var end: Int, var bytes: Int,
    var complete: Boolean, stream: Boolean)
  private class WriterModel(val d: CircularBufferWritePath, val log: WbEvidence.Log) {
    var cycle = 0; var written = 0; var reclaimed = 0; var reserved = 0
    var tail = 0; val queue = mutable.ArrayBuffer.empty[Entry]
    var active: Option[Entry] = None
    var triple = 0; var grantRelease = 0; var writeRelease = 0
    def initialize(): Unit = {
      d.io.softReset.poke(false.B); d.io.contextId.poke(1.U)
      d.io.reserveRefill.valid.poke(false.B)
      d.io.reserveRefill.bits.payloadBytes.poke(16.U); d.io.reserveRefill.bits.streaming.poke(false.B)
      d.io.reserveRefill.bits.contextId.poke(1.U); d.io.reserveRefill.bits.userTag.poke(1.U)
      d.io.reserveRefill.bits.groupIndex.poke(0.U); d.io.reserveRefill.bits.lastInGroup.poke(true.B)
      d.io.streamCredit.get.valid.poke(false.B); d.io.streamCredit.get.bits.poke(16.U)
      d.io.memoryDataValid.poke(false.B); d.io.memoryData.poke(123.U)
      d.io.memoryLaneValidMask.poke(15.U); d.io.memoryChunkLast.poke(false.B)
      d.io.memoryStreamLast.poke(false.B); d.io.memoryContextId.poke(1.U); d.io.memoryUserTag.poke(1.U)
      d.io.reclaim.valid.poke(false.B); d.io.reclaim.bits.poke(0.U)
      d.io.releaseChunk.valid.poke(false.B); d.io.releaseChunk.bits.poke(0.U)
      d.reset.poke(true.B); d.clock.step(2); d.reset.poke(false.B)
    }
    def tick(): Unit = {
      val resident = written - reclaimed
      val free = 16384 - resident - reserved
      val streaming = yes(d.io.reserveRefill.bits.streaming)
      val bytes = number(d.io.reserveRefill.bits.payloadBytes)
      val reserveReady = active.isEmpty && queue.size < 4 &&
        (if (streaming) bytes == 0 else free >= 4096 && bytes <= 4096 && bytes % 16 == 0)
      d.io.reserveRefill.ready.expect(reserveReady.B)
      d.io.freeBytes.expect(free.U); d.io.full.expect((free < 4096).B)
      d.io.reservedBytes.expect(reserved.U); d.io.writeCommitPtr.expect((written & 32767).U)
      d.io.refillPending.expect((active.nonEmpty && (!active.get.stream || reserved > 0)).B)
      d.io.receivingStream.expect(active.exists(_.stream).B)
      for (i <- 0 until 4) {
        val expected = queue.find(_.index == i)
        d.io.chunkEntries(i).allocated.expect(expected.nonEmpty.B)
        expected.foreach { e =>
          d.io.chunkEntries(i).startPtr.expect((e.start & 32767).U)
          d.io.chunkEntries(i).endPtr.expect((e.end & 32767).U)
          d.io.chunkEntries(i).payloadBytes.expect(e.bytes.U)
          d.io.chunkEntries(i).complete.expect(e.complete.B)
          d.io.chunkEntries(i).streaming.expect(e.stream.B)
        }
      }
      val mask = number(d.io.memoryLaneValidMask)
      val payload = Integer.bitCount(mask) * 16
      val memReady = active.nonEmpty && Set(1, 3, 7, 15)(mask) && reserved >= payload && reserved > 0
      d.io.memoryDataReady.expect(memReady.B)
      val creditBytes = number(d.io.streamCredit.get.bits)
      val creditReady = active.exists(_.stream) && creditBytes > 0 && creditBytes % 16 == 0 && creditBytes <= free
      d.io.streamCredit.get.ready.expect(creditReady.B)
      val grant = reserveReady && yes(d.io.reserveRefill.valid)
      val credit = creditReady && yes(d.io.streamCredit.get.valid)
      val write = memReady && yes(d.io.memoryDataValid)
      val reclaim = yes(d.io.reclaim.valid)
      val release = yes(d.io.releaseChunk.valid)
      val delta = if (reclaim) (number(d.io.reclaim.bits) - (reclaimed & 32767)) & 32767 else 0
      d.io.storageWriteEnable.expect(write.B)
      log.add("cycle" -> cycle, "event" -> "writer", "freeBytes" -> free,
        "residentBytes" -> resident, "reservedBytes" -> reserved, "entries" -> queue.size,
        "requestFire" -> grant, "creditFire" -> credit, "memoryFire" -> write,
        "reclaimBytes" -> delta, "release" -> release, "creditBytes" -> creditBytes,
        "memoryBytes" -> payload, "requestBytes" -> (if (streaming) 0 else if (bytes == 0) 4096 else bytes),
        "memoryLast" -> yes(d.io.memoryChunkLast), "writePtr" -> (written & 32767))
      if (credit && write && reclaim) triple += 1
      if (grant && release) grantRelease += 1
      if (write && release) writeRelease += 1
      if (write) {
        val e = active.get
        written += payload; reserved -= payload; e.end = written; e.bytes += payload
        if (yes(d.io.memoryChunkLast)) { e.complete = true; active = None; reserved = 0 }
      }
      if (credit) reserved += creditBytes
      if (reclaim) {
        assert(delta <= resident); reclaimed += delta
        queue.headOption.filter(_.stream).foreach { e => e.start = reclaimed; e.bytes -= delta }
      }
      if (release) {
        assert(queue.nonEmpty && queue.head.complete)
        d.io.releaseChunk.bits.expect(queue.head.index.U); queue.remove(0)
      }
      if (grant) {
        val e = Entry(tail, written, written, 0, false, streaming)
        queue += e; active = Some(e); tail = (tail + 1) % 4
        reserved = if (streaming) 0 else if (bytes == 0) 4096 else bytes
      }
      d.clock.step(); cycle += 1
    }
    def reservation(bytes: Int, stream: Boolean = false): Unit = {
      d.io.reserveRefill.bits.payloadBytes.poke(bytes.U); d.io.reserveRefill.bits.streaming.poke(stream.B)
      d.io.reserveRefill.valid.poke(true.B); d.io.reserveRefill.ready.expect(true.B)
      tick(); d.io.reserveRefill.valid.poke(false.B)
    }
    def credit(bytes: Int): Unit = {
      d.io.streamCredit.get.bits.poke(bytes.U); d.io.streamCredit.get.valid.poke(true.B)
      tick(); d.io.streamCredit.get.valid.poke(false.B)
    }
    def offer(bytes: Int, last: Boolean): Unit = {
      d.io.memoryLaneValidMask.poke(((1 << (bytes / 16)) - 1).U)
      d.io.memoryDataValid.poke(true.B); d.io.memoryChunkLast.poke(last.B)
    }
    def send(bytes: Int): Unit = {
      for (offset <- 0 until bytes by 64) {
        val n = math.min(64, bytes - offset)
        offer(n, offset + n == bytes); d.io.memoryDataReady.expect(true.B); tick()
      }
      d.io.memoryDataValid.poke(false.B)
    }
    def reclaimTo(pointer: Int, release: Boolean = false): Unit = {
      d.io.reclaim.valid.poke(true.B); d.io.reclaim.bits.poke((pointer & 32767).U)
      d.io.releaseChunk.valid.poke(release.B)
      if (release) d.io.releaseChunk.bits.poke(queue.head.index.U)
    }
    def clearReturns(): Unit = {
      d.io.reclaim.valid.poke(false.B); d.io.releaseChunk.valid.poke(false.B)
    }
    def returnHead(): Unit = {
      reclaimTo(queue.head.end, release = true); tick(); clearReturns()
    }
  }

  it should "enforce four KiB admission reserved responses and the shared entry limit" in {
    WbEvidence.run("writer-admission", Seq(10), "0B full 응답, 4080/4096B 경계, 4-entry, 미확정 예약 반환") { log =>
      test(new CircularBufferWritePath(enableStreaming = true, enableContextPrefill = true)) { d =>
        val x = new WriterModel(d, log); x.initialize()
        for (_ <- 0 until 4) { x.reservation(4096); x.send(4096) }
        d.io.freeBytes.expect(0.U); d.io.reserveRefill.ready.expect(false.B)
        for (_ <- 0 until 4) x.returnHead()
        // Entry가 남는 상황에서 byte-space만으로 admission을 막는 경우다.
        x.reservation(0, stream = true); x.credit(12304); x.send(12304)
        assert(x.queue.size == 1)
        d.io.reserveRefill.bits.streaming.poke(false.B); d.io.reserveRefill.bits.payloadBytes.poke(16.U)
        d.io.freeBytes.expect(4080.U); d.io.reserveRefill.ready.expect(false.B); x.tick()
        x.reclaimTo(x.reclaimed + 16); x.tick(); x.clearReturns()
        d.io.freeBytes.expect(4096.U); d.io.reserveRefill.ready.expect(true.B)
        x.reservation(16); x.send(16); x.returnHead(); x.returnHead()
        for (_ <- 0 until 4) { x.reservation(256); x.send(256) }
        d.io.freeBytes.expect(15360.U); d.io.reserveRefill.ready.expect(false.B)
        // 반환한 entry는 다음 clock부터 새 예약에 사용할 수 있다.
        d.io.reserveRefill.valid.poke(true.B); d.io.reserveRefill.bits.payloadBytes.poke(16.U)
        x.reclaimTo(x.queue.head.end, release = true)
        d.io.reserveRefill.ready.expect(false.B); x.tick(); x.clearReturns()
        d.io.reserveRefill.ready.expect(true.B); x.tick(); d.io.reserveRefill.valid.poke(false.B)
        x.send(16)
        while (x.queue.nonEmpty) x.returnHead()
        x.reservation(0); d.io.reservedBytes.expect(4096.U); x.send(80)
        d.io.reservedBytes.expect(0.U); d.io.freeBytes.expect(16304.U); x.returnHead()
        d.io.freeBytes.expect(16384.U); x.tick()
        log.metrics("spaceBoundaryBytes") = Seq(4080, 4096)
        log.metrics("fullReservedResponseBeats") = 64
        log.metrics("entryBlockedWithFreeBytes") = 15360
      }
    }
  }

  it should "apply concurrent credit ingress reclaim allocation and release exactly once" in {
    WbEvidence.run("writer-simultaneous", Seq(10), "Credit+write+reclaim 및 allocate/release 동시 갱신") { log =>
      test(new CircularBufferWritePath(enableStreaming = true, enableContextPrefill = true)) { d =>
        val x = new WriterModel(d, log); x.initialize()
        x.reservation(0, stream = true); x.credit(128)
        x.offer(64, last = false); x.tick(); d.io.memoryDataValid.poke(false.B)
        for ((credit, bytes) <- Seq((64, 64), (32, 32))) {
          d.io.streamCredit.get.valid.poke(true.B); d.io.streamCredit.get.bits.poke(credit.U)
          x.offer(bytes, last = false); x.reclaimTo(x.reclaimed + 16); x.tick()
          d.io.streamCredit.get.valid.poke(false.B); d.io.memoryDataValid.poke(false.B); x.clearReturns()
        }
        x.offer(64, last = true); x.reclaimTo(x.reclaimed + 16); x.tick()
        d.io.memoryDataValid.poke(false.B); x.clearReturns()
        d.io.reserveRefill.valid.poke(true.B); d.io.reserveRefill.bits.streaming.poke(false.B)
        d.io.reserveRefill.bits.payloadBytes.poke(256.U)
        x.reclaimTo(x.queue.head.end, release = true); x.tick()
        d.io.reserveRefill.valid.poke(false.B); x.clearReturns(); x.send(256)
        x.reservation(64)
        x.offer(64, last = true); x.reclaimTo(x.queue.head.end, release = true); x.tick()
        d.io.memoryDataValid.poke(false.B); x.clearReturns(); x.returnHead(); x.tick()
        assert(x.triple == 2 && x.grantRelease == 1 && x.writeRelease == 1)
        d.io.freeBytes.expect(16384.U)
        log.metrics("creditWriteReclaimCycles") = x.triple
        log.metrics("allocateReleaseCycles") = x.grantRelease
        log.metrics("writeReleaseCycles") = x.writeRelease
      }
    }
  }

  it should "hold issued metadata through a delayed response and seek only when the old beat is accepted" in {
    WbEvidence.run("reader-metadata-hold", Seq(14), "1cycle SRAM 응답 모형; live metadata 변경 중 발행 시점 정보 보관") { log =>
      test(new CircularBufferReadPath(userTagWidth = 2)) { d =>
        def chunk(context: Int, tag: Int, group: Int, start: Int, last: Boolean): Unit = {
          d.io.currentChunk.allocated.poke(true.B); d.io.currentChunk.complete.poke(true.B)
          d.io.currentChunk.streaming.poke(false.B)
          d.io.currentChunk.startPtr.poke(start.U); d.io.currentChunk.endPtr.poke((start + 16).U)
          d.io.currentChunk.payloadBytes.poke(16.U); d.io.currentChunk.contextId.poke(context.U)
          d.io.currentChunk.userTag.poke(tag.U); d.io.currentChunk.groupIndex.poke(group.U)
          d.io.currentChunk.lastInGroup.poke(last.B); d.io.currentChunk.lastInStream.poke(last.B)
        }
        d.io.softReset.poke(false.B); d.io.seek.valid.poke(false.B); d.io.seek.bits.poke(0.U)
        d.io.readEnable.poke(false.B); d.io.currentChunkEntryIndex.poke(2.U)
        d.io.allowIncompleteChunk.poke(false.B); d.io.writeCommitPtr.poke(16.U)
        d.io.storageReadDataValid.poke(false.B); d.io.storageReadData.poke(0.U)
        d.io.output.ready.poke(false.B); chunk(3, 2, 7, 0, last = true)
        d.reset.poke(true.B); d.clock.step(2); d.reset.poke(false.B)
        d.io.seek.valid.poke(true.B); d.io.readEnable.poke(true.B)
        d.io.storageReadEnable.expect(true.B); d.clock.step()
        d.io.readEnable.poke(false.B); d.io.seek.bits.poke(16.U)
        d.io.currentChunkEntryIndex.poke(3.U); d.io.writeCommitPtr.poke(32.U)
        chunk(99, 0, 100, 16, last = false)
        d.io.storageReadDataValid.poke(true.B); d.io.storageReadData.poke(word(3, 0).U)
        for (i <- 0 until 5) {
          if (i > 0) d.io.storageReadDataValid.poke(false.B)
          d.io.output.valid.expect(true.B); d.io.output.bits.data.expect(word(3, 0).U)
          d.io.output.bits.contextId.expect(3.U); d.io.output.bits.userTag.expect(2.U)
          d.io.output.bits.groupIndex.expect(7.U); d.io.output.bits.chunkEntryIndex.expect(2.U)
          d.io.output.bits.lastInChunk.expect(true.B); d.io.output.bits.lastInGroup.expect(true.B)
          d.io.output.bits.lastInStream.expect(true.B); d.io.seek.ready.expect(false.B)
          d.io.storageReadEnable.expect(false.B)
          log.add("holdCycle" -> i, "context" -> number(d.io.output.bits.contextId),
            "tag" -> number(d.io.output.bits.userTag), "seekReady" -> false, "passed" -> true)
          d.clock.step()
        }
        d.io.output.ready.poke(true.B); d.io.readEnable.poke(true.B)
        d.io.seek.ready.expect(true.B); d.io.storageReadEnable.expect(true.B)
        d.io.storageReadBytePtr.expect(16.U); d.clock.step()
        d.io.seek.valid.poke(false.B); d.io.readEnable.poke(false.B)
        d.io.storageReadDataValid.poke(true.B); d.io.storageReadData.poke(word(99, 1).U)
        d.io.output.bits.contextId.expect(99.U); d.io.output.bits.userTag.expect(0.U)
        d.io.output.bits.groupIndex.expect(100.U); d.io.output.bits.chunkEntryIndex.expect(3.U)
        d.io.output.bits.lastInChunk.expect(true.B); d.io.output.bits.lastInGroup.expect(false.B)
        d.io.output.bits.data.expect(word(99, 1).U); d.clock.step()
        d.io.storageReadDataValid.poke(false.B)
        d.io.output.valid.expect(false.B); d.io.idle.expect(true.B)
        log.metrics("heldMetadataClocks") = 5
        log.metrics("acceptedResponses") = 2
      }
    }
  }
}
