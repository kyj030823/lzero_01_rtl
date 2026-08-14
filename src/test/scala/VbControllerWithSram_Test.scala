package npu.core.memory

import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec

class VbControllerWithSram_Test extends AnyFlatSpec with ChiselScalatestTester {
  behavior of "VbControllerWithSram"
  private def data(i: Int) = (BigInt("01" * 15, 16) << 8) | BigInt(i & 255)

  private def run(dut: VbControllerWithSram, count: Int, wait: Int, overlap: Boolean): Unit = {
    dut.io.ctrl.soft_reset.poke(true.B)
    dut.io.ctrl.enable.poke(false.B)
    dut.io.fusion_req_in.poke(false.B)
    dut.io.wr_valid.poke(false.B)
    dut.io.last_write.poke(false.B)
    dut.io.wr_data.poke(0.U)
    dut.clock.step(2)
    dut.io.ctrl.soft_reset.poke(false.B)
    dut.io.ctrl.enable.poke(true.B)
    dut.clock.step()
    dut.io.ctrl.working.expect(true.B)

    for (i <- 0 until count) {
      val simultaneous = overlap && i == count - 1
      dut.io.wr_valid.poke(true.B)
      dut.io.last_write.poke((i == count - 1).B)
      dut.io.wr_data.poke(data(i).U)
      dut.io.fusion_req_in.poke(simultaneous.B)
      dut.clock.step()
      if (simultaneous) {
        dut.io.rd_valid.expect(true.B)
        dut.io.rd_data.expect(data(0).U)
        println(f"simultaneous write[${i}%3d], output[  0] = 0x${data(0)}%032x")
      }
    }
    dut.io.wr_valid.poke(false.B)
    dut.io.last_write.poke(false.B)
    dut.io.fusion_req_in.poke(false.B)
    if (!overlap) {
      dut.clock.step(wait)
      dut.io.rd_valid.expect(false.B)
    }
    val first = if (overlap) 1 else 0
    for (i <- first until count) {
      dut.io.fusion_req_in.poke(true.B)
      dut.clock.step()
      dut.io.rd_valid.expect(true.B)
      dut.io.rd_data.expect(data(i).U)
      if (i < first + 3 || i >= count - 3)
        println(f"output[${i}%3d] = 0x${data(i)}%032x")
    }
    dut.io.fusion_req_in.poke(false.B)
    dut.clock.step()
    dut.io.rd_valid.expect(false.B)
  }

  it should "read 256 entries after a delay" in {
    test(new VbControllerWithSram)(dut => run(dut, 256, 5, false))
  }
  it should "output entry zero with the final 256-entry write" in {
    test(new VbControllerWithSram)(dut => run(dut, 256, 0, true))
  }
  it should "read 128 entries after a delay" in {
    test(new VbControllerWithSram)(dut => run(dut, 128, 5, false))
  }
  it should "output entry zero with the final 128-entry write" in {
    test(new VbControllerWithSram)(dut => run(dut, 128, 0, true))
  }
}
