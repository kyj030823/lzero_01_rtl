import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec

class WeightBuffer_Test extends AnyFlatSpec with ChiselScalatestTester {
  behavior of "WeightBuffer"

  it should "use internal counters and switch buffers after 256 CU reads" in {
    test(new WeightBuffer()) { dut =>
      dut.clock.setTimeout(0)

      val dmaBytes = 64
      val cuBytes = 16
      val dmaBeatsPerBuffer = 64
      val cuWordsPerBuffer = 256

      def value(buffer: Int, byteAddress: Int): Int =
        (buffer * 73 + byteAddress * 17) & 0xff

      def pokeDmaBeat(buffer: Int, beat: Int): Unit = {
        for (byte <- 0 until dmaBytes) {
          val byteAddress = beat * dmaBytes + byte
          dut.io.dma_data(byte).poke(value(buffer, byteAddress).U)
        }
      }

      def expectCuWord(buffer: Int, word: Int): Unit = {
        dut.io.cu_read_valid.expect(true.B)
        for (byte <- 0 until cuBytes) {
          val byteAddress = word * cuBytes + byte
          dut.io.cu_read_data(byte).expect(
            value(buffer, byteAddress).U,
            s"buffer=$buffer word=$word byte=$byte"
          )
        }
      }

      def pulseLoadReset(): Unit = {
        dut.io.dma_valid.poke(false.B)
        dut.io.load_reset.poke(true.B)
        dut.clock.step()
        dut.io.load_reset.poke(false.B)
      }

      def pulseReadReset(): Unit = {
        dut.io.cu_read_en.poke(false.B)
        dut.io.read_reset.poke(true.B)
        dut.clock.step()
        dut.io.read_reset.poke(false.B)
      }

      dut.io.dma_valid.poke(false.B)
      dut.io.load_reset.poke(false.B)
      dut.io.cu_read_en.poke(false.B)
      dut.io.read_reset.poke(false.B)
      for (byte <- 0 until dmaBytes) {
        dut.io.dma_data(byte).poke(0.U)
      }

      dut.reset.poke(true.B)
      dut.clock.step(2)
      dut.reset.poke(false.B)

      // Reset starts with read buffer 0, so DMA fills buffer 1.
      pulseLoadReset()
      dut.io.dma_valid.poke(true.B)
      for (beat <- 0 until dmaBeatsPerBuffer) {
        pokeDmaBeat(buffer = 1, beat = beat)
        dut.io.load_done.expect((beat == dmaBeatsPerBuffer - 1).B)
        dut.clock.step()
      }
      dut.io.dma_valid.poke(false.B)
      dut.io.load_done.expect(false.B)

      // There is no initial swap input. One unverified pass switches the
      // active read side from buffer 0 to the loaded buffer 1.
      pulseReadReset()
      dut.io.cu_read_en.poke(true.B)
      for (word <- 0 until cuWordsPerBuffer) {
        dut.clock.step()
        dut.io.cu_read_valid.expect(true.B)
        dut.io.read_done.expect((word == cuWordsPerBuffer - 1).B)
      }
      dut.io.cu_read_en.poke(false.B)
      dut.clock.step()
      dut.io.read_done.expect(false.B)

      // Read buffer 1 while DMA fills the now-inactive buffer 0.
      pulseReadReset()
      pulseLoadReset()
      for (word <- 0 until cuWordsPerBuffer) {
        dut.io.cu_read_en.poke(true.B)

        if (word < dmaBeatsPerBuffer) {
          dut.io.dma_valid.poke(true.B)
          pokeDmaBeat(buffer = 0, beat = word)
          dut.io.load_done.expect((word == dmaBeatsPerBuffer - 1).B)
        } else {
          dut.io.dma_valid.poke(false.B)
          dut.io.load_done.expect(false.B)
        }

        dut.clock.step()
        expectCuWord(buffer = 1, word = word)
        dut.io.read_done.expect((word == cuWordsPerBuffer - 1).B)
      }

      // The final read automatically selects buffer 0.
      dut.io.cu_read_en.poke(false.B)
      dut.io.dma_valid.poke(false.B)
      dut.clock.step()
      pulseReadReset()

      for (word <- 0 until cuWordsPerBuffer) {
        dut.io.cu_read_en.poke(true.B)
        dut.clock.step()
        expectCuWord(buffer = 0, word = word)
        dut.io.read_done.expect((word == cuWordsPerBuffer - 1).B)
      }

      dut.io.cu_read_en.poke(false.B)
      dut.clock.step()
      dut.io.cu_read_valid.expect(false.B)
      dut.io.read_done.expect(false.B)
    }
  }
}
