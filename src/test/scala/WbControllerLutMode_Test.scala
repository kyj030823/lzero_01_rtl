package npu.core.memory

import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec

class WbControllerLutMode_Test extends AnyFlatSpec with ChiselScalatestTester {
  behavior of "WbControllerWithSram stored LUT buffer mode"

  it should "route read data using the LUT mode captured when the buffer was written" in {
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
      dut.io.rlast.poke(false.B)
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
        dut.io.dma_data_last.poke(false.B)
        dut.io.rlast.poke((beat == 63).B)
        dut.clock.step()
      }
      dut.io.dma_data_valid.poke(false.B)
      dut.io.dma_data_last.poke(false.B)
      dut.io.rlast.poke(false.B)

      // LUT mode is captured when DMA data is written, so read routing must ignore the live flag.
      dut.io.lut_prog_mode.poke(false.B)
      dut.io.shoot.poke(true.B)
      dut.clock.step()
      dut.io.shoot.poke(false.B)

      for (word <- 0 until 256) {
        dut.clock.step()
        dut.io.rd_data_valid.expect(true.B)
        dut.io.rd_data_to_cu.expect(0.U)
        dut.io.rd_data_to_lut.expect(expectedWord(word).U)
      }
    }
  }

  it should "preload 6KB LUT data as 4KB plus 2KB in one buffer and route all reads to LUT" in {
    test(new WbControllerWithSram()).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
      val dmaBeats = 96          // 96 * 64B = 6KB
      val readWords = 384        // 384 * 16B = 6KB

      def byteValue(address: Int): Int = (address * 13 + 5) & 0xff

      def dmaBeat(beat: Int): BigInt = {
        (0 until 64).foldLeft(BigInt(0)) { (word, byte) =>
          val address = beat * 64 + byte
          word | (BigInt(byteValue(address)) << (8 * byte))
        }
      }

      def expectedWord(word: Int): BigInt = {
        (0 until 16).foldLeft(BigInt(0)) { (data, byte) =>
          val address = word * 16 + byte
          data | (BigInt(byteValue(address)) << (8 * byte))
        }
      }

      dut.io.soft_reset.poke(true.B)
      dut.io.enable.poke(false.B)
      dut.io.shoot.poke(false.B)
      dut.io.lut_prog_mode.poke(true.B)
      dut.io.dma_data.poke(0.U)
      dut.io.dma_data_valid.poke(false.B)
      dut.io.dma_data_last.poke(false.B)
      dut.io.rlast.poke(false.B)
      dut.io.dma_write_ready.poke(true.B)

      dut.reset.poke(true.B)
      dut.clock.step(2)
      dut.reset.poke(false.B)
      dut.io.soft_reset.poke(false.B)

      dut.io.enable.poke(true.B)
      dut.clock.step()

      println("\n================ WB LUT 6KB PRELOAD TEST ================")
      println("DMA: 96 beats x 64B = 6KB")
      println("     beat  0..63 -> first 4KB")
      println("     beat 64..95 -> extra 2KB")
      println("CU : 384 reads x 16B = 6KB, all must go to LUT")
      println("---------------------------------------------------------")

      dut.io.dma_data_valid.poke(true.B)
      for (beat <- 0 until dmaBeats) {
        dut.io.dma_data.poke(dmaBeat(beat).U)
        dut.io.dma_data_last.poke(false.B)
        dut.io.rlast.poke((beat == dmaBeats - 1).B)

        if (beat == 0 || beat == 63 || beat == 64 || beat == 95) {
          val region = if (beat < 64) "first 4KB" else "extra 2KB"
          println(f"write beat=$beat%2d wr_addr=${dut.io.dbg_pong_wr_addr.peek().litValue}%3d region=$region")
        }
        dut.clock.step()
      }
      dut.io.dma_data_valid.poke(false.B)
      dut.io.dma_data_last.poke(false.B)
      dut.io.rlast.poke(false.B)
      dut.io.ready.expect(true.B)

      // Live LUT flag is lowered before read. Routing must still use the stored buffer mode.
      dut.io.lut_prog_mode.poke(false.B)
      dut.io.shoot.poke(true.B)
      dut.clock.step()
      dut.io.shoot.poke(false.B)

      for (word <- 0 until readWords) {
        dut.clock.step()
        dut.io.rd_data_valid.expect(true.B)
        dut.io.rd_data_to_cu.expect(0.U)
        dut.io.rd_data_to_lut.expect(expectedWord(word).U, s"6KB LUT word $word")

        if (word == 0 || word == 255 || word == 256 || word == 383) {
          val region = if (word < 256) "first 4KB" else "extra 2KB"
          println(f"read  word=$word%3d region=$region -> LUT data=0x${dut.io.rd_data_to_lut.peek().litValue}%032x")
        }
      }

      dut.clock.step()
      dut.io.rd_data_valid.expect(false.B)
      println("PASS: 6KB LUT preload was read completely through lut_data_out")
      println("=========================================================\n")
    }
  }

}
