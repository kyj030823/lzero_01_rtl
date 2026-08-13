package npu.core.memory

import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec

class VbSram_Test extends AnyFlatSpec with ChiselScalatestTester {
  behavior of "VbSram"

  it should "store 4 KiB across two 64-bit memory lanes" in {
    test(new VbSram()) { dut =>
      val actual = Array.fill(256)(BigInt(0))

      // Bytes 15..1 are 0x01. Byte 0 increments from 0x00 to 0xff.
      def data(address: Int): BigInt =
        (BigInt("01" * 15, 16) << 8) | BigInt(address & 0xff)

      dut.io.wr_en.poke(false.B)
      dut.io.wr_addr.poke(0.U)
      dut.io.wr_data.poke(0.U)
      dut.io.rd_en.poke(false.B)
      dut.io.rd_addr.poke(0.U)

      for (address <- 0 until 256) {
        dut.io.wr_en.poke(true.B)
        dut.io.wr_addr.poke(address.U)
        dut.io.wr_data.poke(data(address).U)
        dut.clock.step()
      }
      dut.io.wr_en.poke(false.B)

      for (address <- 0 until 256) {
        dut.io.rd_en.poke(true.B)
        dut.io.rd_addr.poke(address.U)
        dut.clock.step()
        dut.io.rd_valid.expect(true.B)
        actual(address) = dut.io.rd_data.peek().litValue
        dut.io.rd_data.expect(data(address).U, s"address=$address")
      }

      dut.io.rd_en.poke(false.B)
      dut.clock.step()
      dut.io.rd_valid.expect(false.B)

      def hex128(value: BigInt): String = f"$value%032x"
      val visibleAddresses = (0 until 8) ++ (248 until 256)

      println("\n====================== VB SRAM TEST RESULT ======================")
      println("Each 16B word: bytes[15:1] = 0x01, byte[0] = address")
      println("----------------------------------------------------------------")
      println("Address | Expected                         | Actual                           | Result")
      println("----------------------------------------------------------------")

      visibleAddresses.foreach { address =>
        val expected = data(address)
        val result = if (actual(address) == expected) "PASS" else "FAIL"
        println(
          f"0x$address%02x    | ${hex128(expected)} | ${hex128(actual(address))} | $result"
        )
        if (address == 7) {
          println("   ...  |                  omitted                   |")
        }
      }

      val passed = actual.indices.count(address => actual(address) == data(address))
      println("----------------------------------------------------------------")
      println(s"Verified words : $passed / 256")
      println(s"Overall result : ${if (passed == 256) "PASS" else "FAIL"}")
      println("================================================================\n")
    }
  }
}
