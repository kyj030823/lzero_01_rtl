package npu.core.memory

import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec

class WbControllerLutMode_Test extends AnyFlatSpec with ChiselScalatestTester {
  behavior of "WbControllerWithSram LUT buffer mode"

  it should "remember LUT mode per buffer through the final delayed read" in {
    test(new WbControllerWithSram()) { dut =>
      def dmaBeat(beat: Int): BigInt = {
        (0 until 64).foldLeft(BigInt(0)) { (word, byte) =>
          val value = (beat * 64 + byte + 7) & 0xff
          word | (BigInt(value) << (8 * byte))
        }
      }

      def expectedWord(word: Int): BigInt = {
        (0 until 16).foldLeft(BigInt(0)) { (data, byte) =>
          val value = (word * 16 + byte + 7) & 0xff
          data | (BigInt(value) << (8 * byte))
        }
      }

      dut.io.soft_reset.poke(true.B)
      dut.io.enable.poke(false.B)
      dut.io.shoot.poke(false.B)
      dut.io.lut_prog_mode.poke(true.B)
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

      dut.io.dma_data_valid.poke(true.B)
      for (beat <- 0 until 64) {
        dut.io.dma_data.poke(dmaBeat(beat).U)
        dut.io.dma_data_last.poke((beat == 63).B)
        dut.clock.step()
      }
      dut.io.dma_data_valid.poke(false.B)
      dut.io.dma_data_last.poke(false.B)

      // Prove that routing uses the saved buffer bit, not the live input.
      dut.io.lut_prog_mode.poke(false.B)
      dut.io.shoot.poke(true.B)
      dut.clock.step()
      dut.io.shoot.poke(false.B)

      for (word <- 0 until 256) {
        dut.clock.step()
        dut.io.rd_data_valid.expect(true.B)
        dut.io.rd_data_to_cu.expect(0.U)
        dut.io.rd_data_to_lut.expect(
          expectedWord(word).U,
          s"LUT word $word"
        )
      }
    }
  }
}
