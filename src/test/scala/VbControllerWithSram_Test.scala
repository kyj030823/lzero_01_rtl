package npu.core.memory

import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec

class VbControllerWithSram_Test extends AnyFlatSpec with ChiselScalatestTester {
  behavior of "VbControllerWithSram"

  private def data(i: Int): BigInt =
    (BigInt("01" * 15, 16) << 8) | BigInt(i & 0xff)

  private val nextFrameData = BigInt("aa" * 15 + "55", 16)

  private def run(
      dut: VbControllerWithSram,
      count: Int,
      waitCycles: Int,
      firstOutputWithLastWrite: Boolean,
      nextWriteWithLastOutput: Boolean,
      label: String
  ): Unit = {
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

    println(s"\n=== ${label} ===")
    println("| event                            | write       | output      |")
    println("|----------------------------------|-------------|-------------|")

    for (i <- 0 until count) {
      val simultaneous = firstOutputWithLastWrite && i == count - 1
      dut.io.wr_valid.poke(true.B)
      dut.io.last_write.poke((i == count - 1).B)
      dut.io.wr_data.poke(data(i).U)
      dut.io.fusion_req_in.poke(simultaneous.B)
      dut.clock.step()

      if (simultaneous) {
        dut.io.rd_valid.expect(true.B)
        dut.io.rd_data.expect(data(0).U)
        println(f"| last input + first output        | write[${i}%3d]  | output[  0] |")
      }
    }

    dut.io.wr_valid.poke(false.B)
    dut.io.last_write.poke(false.B)
    dut.io.fusion_req_in.poke(false.B)

    if (!firstOutputWithLastWrite) {
      dut.clock.step(waitCycles)
      dut.io.rd_valid.expect(false.B)
      println(f"| wait before output               | ${waitCycles}%3d clocks  | -           |")
    }

    val firstOutput = if (firstOutputWithLastWrite) 1 else 0
    for (i <- firstOutput until count) {
      val simultaneous = nextWriteWithLastOutput && i == count - 1
      dut.io.fusion_req_in.poke(true.B)
      dut.io.wr_valid.poke(simultaneous.B)
      dut.io.last_write.poke(false.B)
      dut.io.wr_data.poke(nextFrameData.U)
      dut.clock.step()

      dut.io.rd_valid.expect(true.B)
      dut.io.rd_data.expect(data(i).U)

      if (simultaneous) {
        println(f"| last output + next first input   | write[  0]  | output[${i}%3d] |")
      } else if (i < firstOutput + 3 || i >= count - 3) {
        println(f"| normal output                    | -           | output[${i}%3d] |")
      }
    }

    dut.io.fusion_req_in.poke(false.B)
    dut.io.wr_valid.poke(false.B)
    dut.clock.step()
    dut.io.rd_valid.expect(false.B)

    if (nextWriteWithLastOutput) {
      dut.io.fusion_req_in.poke(true.B)
      dut.clock.step()
      dut.io.rd_valid.expect(true.B)
      dut.io.rd_data.expect(nextFrameData.U)
      println("| verify next frame write          | -           | output[  0] |")
      dut.io.fusion_req_in.poke(false.B)
      dut.clock.step()
    }
  }

  private def vbTest(
      count: Int,
      waitCycles: Int,
      firstOverlap: Boolean,
      lastOverlap: Boolean,
      label: String
  ): Unit = {
    test(new VbControllerWithSram)
      .withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
        run(dut, count, waitCycles, firstOverlap, lastOverlap, label)
      }
  }

  it should "1. write 256, wait, and output 256 entries" in {
    vbTest(256, 5, firstOverlap = false, lastOverlap = false, label = "256 delayed")
  }

  it should "2. output entry zero with the final 256-entry write" in {
    vbTest(256, 0, firstOverlap = true, lastOverlap = false, label = "256 first overlap")
  }

  it should "3. write 128, wait, and output 128 entries" in {
    vbTest(128, 5, firstOverlap = false, lastOverlap = false, label = "128 delayed")
  }

  it should "4. output entry zero with the final 128-entry write" in {
    vbTest(128, 0, firstOverlap = true, lastOverlap = false, label = "128 first overlap")
  }

  it should "5. accept the next write with the final 256-entry output" in {
    vbTest(256, 5, firstOverlap = false, lastOverlap = true, label = "256 last overlap")
  }

  it should "6. accept the next write with the final 128-entry output" in {
    vbTest(128, 5, firstOverlap = false, lastOverlap = true, label = "128 last overlap")
  }
}
