package npu.core.memory

import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec

class WbControllerWithSram_Test extends AnyFlatSpec with ChiselScalatestTester {
  behavior of "WbControllerWithSram"

  it should "preload the inactive bank and stream it to the CU in 16-byte words" in {
    test(new WbControllerWithSram()).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
      val dmaBeats = 64
      val bytesPerBeat = 64
      val bytesPerRead = 16
      val readWords = 256
      val actualWords = Array.fill(readWords)(BigInt(0))

      def byteValue(address: Int): Int = (address * 17 + 29) & 0xff

      def dmaBeat(beat: Int): BigInt = {
        (0 until bytesPerBeat).foldLeft(BigInt(0)) { (word, byte) =>
          val address = beat * bytesPerBeat + byte
          word | (BigInt(byteValue(address)) << (8 * byte))
        }
      }

      def expectedReadWord(word: Int): BigInt = {
        (0 until bytesPerRead).foldLeft(BigInt(0)) { (data, byte) =>
          val address = word * bytesPerRead + byte
          data | (BigInt(byteValue(address)) << (8 * byte))
        }
      }

      dut.io.soft_reset.poke(true.B)
      dut.io.enable.poke(false.B)
      dut.io.shoot.poke(false.B)
      dut.io.lut_prog_mode.poke(false.B)
      dut.io.dma_data.poke(0.U)
      dut.io.dma_data_valid.poke(false.B)
      dut.io.dma_data_last.poke(false.B)
      dut.io.dma_write_ready.poke(true.B)

      dut.reset.poke(true.B)
      dut.clock.step(2)
      dut.reset.poke(false.B)
      dut.io.soft_reset.poke(false.B)

      // IDLE -> PRELOAD.
      dut.io.enable.poke(true.B)
      dut.clock.step()
      dut.io.hungry.expect(true.B)

      // Fill the inactive Pong bank with exactly 64 accepted DMA beats.
      dut.io.dma_data_valid.poke(true.B)
      for (beat <- 0 until dmaBeats) {
        dut.io.dma_data.poke(dmaBeat(beat).U)
        dut.io.dma_data_last.poke((beat == dmaBeats - 1).B)
        dut.clock.step()
      }
      dut.io.dma_data_valid.poke(false.B)
      dut.io.dma_data_last.poke(false.B)

      // The final write and initial Ping->Pong hand-off occur together.
      dut.io.ready.expect(true.B)

      // READY -> WORKING. The first synchronous SRAM request starts after it.
      dut.io.shoot.poke(true.B)
      dut.clock.step()
      dut.io.shoot.poke(false.B)
      dut.io.working.expect(true.B)

      for (word <- 0 until readWords) {
        dut.clock.step()
        dut.io.rd_data_valid.expect(true.B)
        actualWords(word) = dut.io.rd_data_to_cu.peek().litValue
        dut.io.rd_data_to_cu.expect(
          expectedReadWord(word).U,
          s"CU word $word"
        )
        dut.io.rd_data_to_lut.expect(0.U)
      }

      val expectedWords = Array.tabulate(readWords)(expectedReadWord)
      val passedWords = actualWords.indices.count { index =>
        actualWords(index) == expectedWords(index)
      }

      def hex128(value: BigInt): String = f"$value%032x"

      println("\n================ WB CONTROLLER + SRAM TEST RESULT ================")
      println("DMA: 64 beats x 64B -> Pong 4KB")
      println("CU : 256 reads x 16B <- Pong 4KB")
      println("------------------------------------------------------------------")
      println("Beat | CU word 0                         | CU word 1")
      println("     | CU word 2                         | CU word 3       | Result")
      println("------------------------------------------------------------------")

      val visibleBeats = (0 until 4) ++ (60 until 64)
      visibleBeats.foreach { beat =>
        val base = beat * 4
        val pass = (0 until 4).forall { offset =>
          actualWords(base + offset) == expectedWords(base + offset)
        }
        println(f"$beat%4d | ${hex128(actualWords(base))} | ${hex128(actualWords(base + 1))}")
        println(f"     | ${hex128(actualWords(base + 2))} | ${hex128(actualWords(base + 3))} | ${if (pass) "PASS" else "FAIL"}")
        if (beat == 3) println(" ... |                              omitted                              |")
      }

      println("------------------------------------------------------------------")
      println(s"Verified CU words : $passedWords / $readWords")
      println(s"Overall result    : ${if (passedWords == readWords) "PASS" else "FAIL"}")
      println("==================================================================\n")
    }
  }
}
