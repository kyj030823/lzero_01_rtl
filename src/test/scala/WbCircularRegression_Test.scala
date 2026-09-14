package npu.core.memory

import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec
import scala.collection.mutable

// Observe existing controller signals without changing production RTL.
class WbObserved extends WbController {
  val debug = IO(Output(new Bundle {
    val used = UInt(14.W)
    val soon = Bool()
    val full = Bool()
    val state = UInt(3.W)
    val count = UInt(4.W)
  }))
  debug.used := usedBytes
  debug.soon := soonempty
  debug.full := queueFull
  debug.state := state
  debug.count := blNum
}

class WbCircularHarness extends Module {
  val io = IO(new Bundle {
    val ctrl = new OcmCommonIo
    val data = Input(UInt(512.W))
    val out = Output(UInt(128.W))
    val lutMode = Input(Bool())
    val lutOut = Output(UInt(128.W))
    val rd = Output(Bool())
    val wr = Output(Bool())
    val addr = Output(UInt(10.W))
    val used = Output(UInt(14.W))
    val soon = Output(Bool())
    val full = Output(Bool())
    val state = Output(UInt(3.W))
    val count = Output(UInt(4.W))
  })
  val c = Module(new WbObserved)
  val m = Module(new AsymmetricSRAM)
  c.io.ctrl <> io.ctrl
  c.io.is_lut_load := io.lutMode
  m.io.wr_en := c.io.wr_en
  m.io.wr_addr := c.io.wr_addr
  m.io.wr_data := io.data
  m.io.rd_en := c.io.rd_en
  m.io.rd_addr := c.io.rd_addr
  c.io.rd_data := m.io.rd_data
  io.out := c.io.rd_data_to_cu
  io.lutOut := c.io.rd_data_to_lut
  io.rd := c.io.rd_en
  io.wr := c.io.wr_en
  io.addr := c.io.rd_addr
  io.used := c.debug.used
  io.soon := c.debug.soon
  io.full := c.debug.full
  io.state := c.debug.state
  io.count := c.debug.count
}

class WbCircularRegression_Test extends AnyFlatSpec with ChiselScalatestTester {
  behavior of "WbController circular SRAM"
  class Driver(val d: WbCircularHarness) {
    d.clock.setTimeout(10000)
    val expected = mutable.Queue.empty[(BigInt, Boolean, Boolean)]
    var serial = 0
    var reads = 0
    var lasts = 0
    var lutReads = 0
    var cycles = 0
    def bool(x: Bool): Boolean = x.peek().litToBoolean
    d.io.ctrl.enable.poke(false.B)
    d.io.ctrl.soft_reset.poke(false.B)
    d.io.ctrl.shoot.poke(false.B)
    d.io.ctrl.dma_data_valid.poke(false.B)
    d.io.ctrl.rlast.poke(false.B)
    d.io.ctrl.dma_data_last.poke(false.B)
    d.io.data.poke(0.U)
    d.io.lutMode.poke(false.B)
    d.reset.poke(true.B); d.clock.step(2); d.reset.poke(false.B)
    d.io.state.expect(0.U)
    d.io.full.expect(false.B) // Empty SRAM; IDLE still blocks new requests.
    d.io.ctrl.full.expect(true.B)
    d.io.ctrl.enable.poke(true.B)
    tick()

    def tick(write: Boolean = false, end: Boolean = false, finalDma: Boolean = false,
             shoot: Boolean = false, lut: Boolean = false, lutSignal: Boolean = false): Unit = {
      d.io.lutMode.poke(lutSignal.B)
      d.io.ctrl.dma_data_valid.poke(write.B)
      d.io.ctrl.rlast.poke(end.B)
      d.io.ctrl.dma_data_last.poke(finalDma.B)
      d.io.ctrl.shoot.poke(shoot.B)
      if (write) {
        val words = (0 until 4).map { lane =>
          val id = BigInt(serial * 4 + lane + 1)
          (id << 96) | ((id ^ BigInt("deadbeef",16)) << 32) | id
        }
        d.io.data.poke(words.zipWithIndex.map { case (v,i) => v << (128*i) }.reduce(_ | _).U)
        assert(bool(d.io.wr), s"cycle=$cycles write rejected")
        words.zipWithIndex.foreach { case (v,i) =>
          expected.enqueue((v, (end || finalDma) && i == 3, lut))
        }
        serial += 1
      }
      val reading = bool(d.io.rd)
      val answer = if (reading) {
        assert(expected.nonEmpty, s"cycle=$cycles read underflow addr=${d.io.addr.peek().litValue}")
        Some(expected.dequeue())
      } else None
      d.clock.step()
      answer.foreach { case (value,last,lut) =>
        d.io.out.expect((if (lut) BigInt(0) else value).U,
          s"cycle=$cycles word=$reads expectedLut=$lut last=$last CU output")
        d.io.lutOut.expect((if (lut) value else BigInt(0)).U,
          s"cycle=$cycles word=$reads expectedLut=$lut last=$last LUT output")
        if (lut) lutReads += 1
        reads += 1
        if (last) lasts += 1
      }
      d.io.ctrl.last_data_out.expect(answer.exists(_._2).B, s"cycle=$cycles last alignment")
      cycles += 1
    }
    def block(bytes: Int, finalDma: Boolean = false, gaps: Boolean = false,
              finalOnly: Boolean = false, lut: Boolean = false, holdLut: Boolean = false): Unit = {
      for (i <- 0 until bytes / 64) {
        if (gaps && i % 3 == 0) tick()
        val last = i == bytes / 64 - 1
        tick(true, last && !finalOnly, last && finalDma, lut=lut, lutSignal=lut && (i == 0 || holdLut))
      }
      d.io.lutMode.poke(false.B)
      d.io.ctrl.dma_data_valid.poke(false.B)
      d.io.ctrl.rlast.poke(false.B)
      d.io.ctrl.dma_data_last.poke(false.B)
    }
    def start(): Unit = { d.io.ctrl.ready.expect(true.B); tick(shoot=true) }
    def idle(n: Int): Unit = (0 until n).foreach(_ => tick())
    def drain(): Unit = {
      var n = 0
      while ((expected.nonEmpty || bool(d.io.rd)) && n < 4000) { tick(); n += 1 }
      assert(expected.isEmpty, s"timeout remaining=${expected.size} state=${d.io.state.peek().litValue}")
      idle(3)
    }
    def softReset(): Unit = {
      d.io.lutMode.poke(false.B)
      d.io.ctrl.dma_data_valid.poke(false.B)
      d.io.ctrl.rlast.poke(false.B)
      d.io.ctrl.dma_data_last.poke(false.B)
      d.io.ctrl.shoot.poke(false.B)
      d.io.ctrl.soft_reset.poke(true.B)
      d.clock.step()
      expected.clear()
      d.io.ctrl.soft_reset.poke(false.B)
      // Reset edge is an abort boundary; pending old SRAM response is discarded.
      tick()
      d.io.count.expect(0.U)
    }
    def result(): Unit = println(s"  cycles=$cycles checkedWords=$reads checkedBlockEnds=$lasts checkedLutWords=$lutReads")
  }
  def scenario(name: String)(body: Driver => Unit): Unit = {
    it should name in {
      println(s"[CASE START] $name")
      try {
        test(new WbCircularHarness) { dut =>
          val t = new Driver(dut)
          body(t)
          t.result()
        }
        println(s"[CASE PASS] $name")
      } catch {
        case e: Throwable =>
          println(s"[CASE FAIL] $name : ${e.getMessage}")
          throw e
      }
    }
  }

  scenario("01 four 4KB blocks fill 16KB and drain") { t =>
    (0 until 4).foreach(i => t.block(4096, i == 3))
    t.d.io.full.expect(true.B); t.d.io.ctrl.full.expect(true.B)
    t.start(); t.drain()
    assert(t.reads == 1024 && t.lasts == 4)
  }
  scenario("02 mixed 4K 2K 4K 2K 4K 4K with concurrent wrap") { t =>
    Seq(4096,2048,4096,2048).foreach(t.block(_))
    t.start(); t.idle(256)
    t.block(4096); t.block(4096, true); t.drain()
    assert(t.reads == 1280 && t.lasts == 6)
  }
  scenario("03 reset during WORKING then fresh 4KB") { t =>
    t.block(4096); t.start(); t.idle(17); t.softReset()
    val before = t.reads
    t.block(4096,true); t.start(); t.drain()
    assert(t.reads - before == 256)
  }
  scenario("04 simultaneous last read and completed write") { t =>
    t.block(4096); t.start(); t.idle(192)
    t.block(4096,true)
    t.d.io.rd.expect(true.B); t.d.io.count.expect(1.U)
    t.drain(); assert(t.reads == 512 && t.lasts == 2)
  }
  scenario("05 STALL waits then resumes at next address") { t =>
    t.block(4096); t.start(); t.drain()
    t.d.io.state.expect(4.U); t.idle(11)
    t.block(2048,true); t.drain()
    assert(t.reads == 384 && t.lasts == 2)
  }
  scenario("06 prepared blocks read without bubbles") { t =>
    t.block(4096); t.block(4096,true); t.start()
    (0 until 512).foreach { _ => t.d.io.rd.expect(true.B); t.tick() }
    t.idle(3); assert(t.lasts == 2)
  }
  scenario("07 short final block with dma_data_last only") { t =>
    t.block(64,true,finalOnly=true); t.start(); t.drain()
    assert(t.reads == 4 && t.lasts == 1)
    t.d.io.rd.expect(false.B)
  }
  scenario("08 consecutive jobs without reset") { t =>
    (0 until 2).foreach { _ => t.block(4096,true); t.start(); t.drain() }
    assert(t.reads == 512 && t.lasts == 2)
  }
  scenario("09 irregular valid gaps while reading and writing") { t =>
    t.block(4096,gaps=true); t.start()
    t.block(4096,true,gaps=true); t.drain()
    assert(t.reads == 512 && t.lasts == 2)
  }
  scenario("10 twelve small blocks wrap metadata queue") { t =>
    t.block(128); t.start()
    (1 until 12).foreach { i => t.drain(); t.block(128,i==11) }
    t.drain(); assert(t.reads == 96 && t.lasts == 12)
  }
  scenario("11 one block crosses physical SRAM end") { t =>
    Seq(4096,4096,4096,2048).foreach(t.block(_))
    t.start(); t.idle(256); t.block(4096,true); t.drain()
    assert(t.reads == 1152 && t.lasts == 5)
  }
  scenario("12 free space 4096 and 4032 bytes") { t =>
    (0 until 3).foreach(_ => t.block(4096))
    t.d.io.full.expect(false.B); t.d.io.ctrl.full.expect(false.B)
    t.tick(write=true)
    t.d.io.full.expect(true.B); t.d.io.ctrl.full.expect(true.B)
  }
  scenario("13 remaining data 144 128 16 and zero bytes") { t =>
    t.block(4096); t.start(); t.idle(247)
    t.d.io.used.expect(144.U); t.d.io.soon.expect(false.B)
    t.tick(); t.d.io.used.expect(128.U); t.d.io.soon.expect(true.B)
    t.idle(7); t.d.io.used.expect(16.U); t.d.io.soon.expect(true.B)
    t.tick(); t.d.io.used.expect(0.U); t.d.io.soon.expect(false.B)
    t.d.io.full.expect(false.B); t.idle(2)
  }
  Seq("PRELOAD","READY","STALL","LAST_READ").foreach { phase =>
    scenario(s"14 reset recovery from $phase") { t =>
      phase match {
        case "PRELOAD" => t.tick(write=true)
        case "READY" => t.block(4096)
        case "STALL" => t.block(4096); t.start(); t.drain()
        case "LAST_READ" => t.block(4096); t.start(); t.idle(255)
      }
      t.softReset()
      val before = t.reads
      t.block(4096,true); t.start(); t.drain()
      assert(t.reads-before == 256)
    }
  }

  // LUT mode is announced on the first accepted beat of each LUT block.
  scenario("LUT01 single 4KB LUT block and last response routing") { t =>
    t.block(4096, finalDma=true, lut=true); t.start(); t.drain()
    assert(t.lutReads == 256 && t.lasts == 1)
  }
  scenario("LUT02 prepared CU LUT CU blocks") { t =>
    t.block(4096); t.block(2048, lut=true); t.block(4096, finalDma=true)
    t.start(); t.drain()
    assert(t.reads == 640 && t.lutReads == 128 && t.lasts == 3)
  }
  scenario("LUT03 consecutive LUT blocks then CU") { t =>
    t.block(2048, lut=true); t.block(2048, lut=true); t.block(4096, finalDma=true)
    t.start(); t.drain()
    assert(t.lutReads == 256 && t.lasts == 3)
  }
  scenario("LUT04 write LUT while CU is reading") { t =>
    t.block(4096); t.start(); t.idle(20)
    t.block(2048, finalDma=true, lut=true, gaps=true)
    t.drain(); assert(t.lutReads == 128 && t.lasts == 2)
  }
  scenario("LUT05 soft reset clears active LUT routing") { t =>
    t.block(4096, lut=true); t.start(); t.idle(16)
    assert(t.lutReads == 16)
    t.softReset()
    val before = t.reads
    t.block(4096, finalDma=true); t.start(); t.drain()
    assert(t.reads-before == 256 && t.lutReads == 16)
  }
  scenario("LUT06 metadata wraps after a queued LUT marker") { t =>
    t.block(128); t.block(128, lut=true); t.start(); t.drain()
    (2 until 12).foreach { i => t.block(128, finalDma=i==11); t.drain() }
    assert(t.lutReads == 8 && t.lasts == 12)
  }
  scenario("LUT07 held mode during a LUT block") { t =>
    t.block(4096, finalDma=true, lut=true, holdLut=true); t.start(); t.drain()
    assert(t.lutReads == 256 && t.lasts == 1)
  }
}