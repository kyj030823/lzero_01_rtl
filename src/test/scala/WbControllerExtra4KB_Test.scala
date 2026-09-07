package npu.core.memory

import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec

class WbControllerExtra4KB_Test extends AnyFlatSpec with ChiselScalatestTester {
  behavior of "WbControllerWithSram split write behavior"

  private val Beats4KB = 64
  private val Words4KB = 256
  private val BytesPerBeat = 64

  private def init(dut: WbControllerWithSram): Unit = {
    dut.io.soft_reset.poke(true.B)
    dut.io.enable.poke(false.B)
    dut.io.shoot.poke(false.B)
    dut.io.lut_prog_mode.poke(false.B)
    dut.io.rlast.poke(false.B)
    dut.io.dma_data.poke(0.U)
    dut.io.dma_data_valid.poke(false.B)
    dut.io.dma_data_last.poke(false.B)
    dut.io.dma_write_ready.poke(true.B)

    dut.reset.poke(true.B)
    dut.clock.step(2)
    dut.reset.poke(false.B)
    dut.io.soft_reset.poke(false.B)

    dut.io.enable.poke(true.B)
    dut.clock.step()
  }

  private def dmaBeat(block: Int, beat: Int): BigInt = {
    (0 until BytesPerBeat).foldLeft(BigInt(0)) { (data, byte) =>
      val value = ((block + 1) * 17 + beat * 3 + byte) & 255
      data | (BigInt(value) << (8 * byte))
    }
  }

  private def hex512(value: BigInt): String = {
    "0x" + value.toString(16).reverse.padTo(128, '0').reverse
  }

  private def beatBytes(block: Int, beat: Int): Seq[Int] = {
    (0 until BytesPerBeat).map { byte =>
      val value = ((block + 1) * 17 + beat * 3 + byte) & 255
      value
    }
  }

  private def byteWindow(block: Int, beat: Int): String = {
    val bytes = beatBytes(block, beat)
    val head = bytes.take(8).map(value => f"$value%02x").mkString(" ")
    val tail = bytes.takeRight(8).map(value => f"$value%02x").mkString(" ")
    "bytes[0..7]=" + head + ", bytes[56..63]=" + tail
  }

  private def printWriteSummary(beat: Int, bank: String, addr: BigInt, data: BigInt, note: String): Unit = {
    val pingWr = if (bank == "Ping") 1 else 0
    val pongWr = if (bank == "Pong") 1 else 0
    println(f"$beat%4d |   1   |   0   | $bank%10s |    $pingWr    |    $pongWr    | $note")
    println("     |       |       |            |         |         | block=3, beat=" + beat + ", wr_addr=" + addr)
    println("     |       |       |            |         |         | " + byteWindow(block = 3, beat = beat))
    println("     |       |       |            |         |         | data=" + hex512(data))
  }

  private def pokeDmaBeat(dut: WbControllerWithSram, block: Int, beat: Int, rlast: Boolean): Unit = {
    dut.io.dma_data_valid.poke(true.B)
    dut.io.dma_data_last.poke(false.B)
    dut.io.rlast.poke(rlast.B)
    dut.io.dma_data.poke(dmaBeat(block, beat).U)
  }

  private def stopDma(dut: WbControllerWithSram): Unit = {
    dut.io.dma_data_valid.poke(false.B)
    dut.io.dma_data_last.poke(false.B)
    dut.io.rlast.poke(false.B)
    dut.io.dma_data.poke(0.U)
  }

  private def expectWritePing(dut: WbControllerWithSram, block: Int, beat: Int): Unit = {
    dut.io.dbg_ping_wr_en.expect(true.B, "expected DMA beat to write Ping")
    dut.io.dbg_pong_wr_en.expect(false.B, "Pong must not be written on this beat")
    dut.io.dbg_ping_wr_data.expect(dmaBeat(block, beat).U)
  }

  private def expectWritePong(dut: WbControllerWithSram, block: Int, beat: Int): Unit = {
    dut.io.dbg_ping_wr_en.expect(false.B, "Ping must not be written on this beat")
    dut.io.dbg_pong_wr_en.expect(true.B, "expected DMA beat to write Pong")
    dut.io.dbg_pong_wr_data.expect(dmaBeat(block, beat).U)
  }

  private def send4KB(dut: WbControllerWithSram, block: Int): Unit = {
    for (beat <- 0 until Beats4KB) {
      pokeDmaBeat(dut, block, beat, rlast = beat == Beats4KB - 1)
      dut.clock.step()
    }
    stopDma(dut)
  }

  private def startRead(dut: WbControllerWithSram): Unit = {
    dut.io.shoot.poke(true.B)
    dut.clock.step()
    dut.io.shoot.poke(false.B)
    dut.io.working.expect(true.B)
  }

  it should "write a split 4KB DMA block to Pong first, then to freed Ping after ping-pong swap" in {
    test(new WbControllerWithSram()).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
      init(dut)

      // First 4KB: fills Pong, then controller becomes ready to read Pong.
      send4KB(dut, block = 0)
      dut.io.ready.expect(true.B)

      // Read Pong. During the first 64 cycles, fill Ping with block1.
      startRead(dut)
      for (word <- 0 until Words4KB) {
        if (word < Beats4KB) pokeDmaBeat(dut, block = 1, beat = word, rlast = word == Beats4KB - 1)
        else stopDma(dut)
        dut.clock.step()
      }

      // Now active read bank should be Ping. Fill Pong with a normal 4KB block first,
      // but do not finish the Ping read yet.
      for (word <- 0 until Beats4KB) {
        pokeDmaBeat(dut, block = 2, beat = word, rlast = word == Beats4KB - 1)
        dut.clock.step()
      }

      // Continue reading Ping with no DMA until 32 cycles before Ping read completes.
      for (_ <- Beats4KB until (Words4KB - 32)) {
        stopDma(dut)
        dut.clock.step()
      }

      println("")
      println("================ WB SPLIT WRITE BANK TEST ================")
      println("Setup: reading Ping, Pong already has one 4KB block")
      println("Check: extra 4KB first half -> Pong, second half -> freed Ping")
      println("----------------------------------------------------------")
      println("beat | valid | rlast | write_bank | ping_wr | pong_wr | note")
      println("-----+-------+-------+------------+---------+---------+------------------")

      // Send block3 every clock and detect the actual Pong -> Ping write transition.
      var sawPong = false
      var foundSwap = false
      var lastPongBeat = -1
      var firstPingBeat = -1
      var lastPongAddr = BigInt(-1)
      var firstPingAddr = BigInt(-1)
      var lastPongData = BigInt(0)
      var firstPingData = BigInt(0)
      val beatBank = Array.fill(Beats4KB)("None")
      val beatAddr = Array.fill(Beats4KB)(BigInt(-1))
      val beatData = Array.fill(Beats4KB)(BigInt(0))

      for (beat <- 0 until Beats4KB) {
        pokeDmaBeat(dut, block = 3, beat = beat, rlast = beat == Beats4KB - 1)

        val pingWr = dut.io.dbg_ping_wr_en.peek().litValue == 1
        val pongWr = dut.io.dbg_pong_wr_en.peek().litValue == 1
        assert(pingWr || pongWr, "block3 beat " + beat + " was not written to either bank")
        val actualData = if (pingWr) dut.io.dbg_ping_wr_data.peek().litValue else dut.io.dbg_pong_wr_data.peek().litValue
        assert(actualData == dmaBeat(block = 3, beat = beat), "block3 beat " + beat + " write data mismatch")

        if (pongWr) {
          sawPong = true
          lastPongBeat = beat
          lastPongAddr = dut.io.dbg_pong_wr_addr.peek().litValue
          lastPongData = dut.io.dbg_pong_wr_data.peek().litValue
          beatBank(beat) = "Pong"
          beatAddr(beat) = lastPongAddr
          beatData(beat) = lastPongData
        } else if (pingWr) {
          beatBank(beat) = "Ping"
          beatAddr(beat) = dut.io.dbg_ping_wr_addr.peek().litValue
          beatData(beat) = dut.io.dbg_ping_wr_data.peek().litValue
          if (sawPong && !foundSwap) {
            foundSwap = true
            firstPingBeat = beat
            firstPingAddr = dut.io.dbg_ping_wr_addr.peek().litValue
            firstPingData = dut.io.dbg_ping_wr_data.peek().litValue
          }
        } else {
          beatBank(beat) = "None"
        }

        dut.clock.step()
      }

      assert(foundSwap, "block3 write bank never changed from Pong to Ping")
      assert(firstPingBeat >= 0, "first Ping beat was not recorded")
      assert(lastPongBeat == firstPingBeat - 1, "Pong to Ping transition was not contiguous")

      val beforeBeforeBeat = (lastPongBeat - 1).max(0)
      val afterAfterBeat = (firstPingBeat + 1).min(Beats4KB - 1)

      printWriteSummary(beforeBeforeBeat, beatBank(beforeBeforeBeat), beatAddr(beforeBeforeBeat), beatData(beforeBeforeBeat), "one clock before last Pong")
      println(f"$lastPongBeat%4d |   1   |   0   |       Pong |    0    |    1    | last before swap")
      println("     |       |       |            |         |         | block=3, beat=" + lastPongBeat + ", wr_addr=" + lastPongAddr)
      println("     |       |       |            |         |         | " + byteWindow(block = 3, beat = lastPongBeat))
      println("     |       |       |            |         |         | data=" + hex512(lastPongData))
      println("     |       |       |            |         |         | exp =" + hex512(dmaBeat(block = 3, beat = lastPongBeat)))
      println("-----+-------+-------+------------+---------+---------+------------------")
      println("                 READ BANK SWAP / WRITE BANK CHANGES")
      println("-----+-------+-------+------------+---------+---------+------------------")
      println(f"$firstPingBeat%4d |   1   |   0   |       Ping |    1    |    0    | first after swap")
      println("     |       |       |            |         |         | block=3, beat=" + firstPingBeat + ", wr_addr=" + firstPingAddr)
      println("     |       |       |            |         |         | " + byteWindow(block = 3, beat = firstPingBeat))
      println("     |       |       |            |         |         | data=" + hex512(firstPingData))
      println("     |       |       |            |         |         | exp =" + hex512(dmaBeat(block = 3, beat = firstPingBeat)))
      printWriteSummary(afterAfterBeat, beatBank(afterAfterBeat), beatAddr(afterAfterBeat), beatData(afterAfterBeat), "one clock after first Ping")
      println("-----+-------+-------+------------+---------+---------+------------------")
      stopDma(dut)

      println("PASS condition: block3 wrote Pong until beat " + lastPongBeat + ", then Ping from beat " + firstPingBeat)
      println("==========================================================")
    }
  }
}
