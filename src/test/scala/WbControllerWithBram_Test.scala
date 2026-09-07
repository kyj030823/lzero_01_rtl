package npu.core.memory

import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec

class WbControllerWithBram_Test extends AnyFlatSpec with ChiselScalatestTester {
  behavior of "WbControllerWithBram four-slot circular queue"

  private val Beats4KB = 64
  private val Words4KB = 256
  private val BytesPerBeat = 64
  private val BytesPerWord = 16

  private def init(dut: WbControllerWithBram): Unit = {
    dut.clock.setTimeout(0)

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

  private def byteValue(block: Int, byteAddress: Int): Int = {
    ((block + 1) * 19 + byteAddress) & 255
  }

  private def dmaBeat(block: Int, beat: Int): BigInt = {
    (0 until BytesPerBeat).foldLeft(BigInt(0)) { (data, byte) =>
      val address = beat * BytesPerBeat + byte
      data | (BigInt(byteValue(block, address)) << (8 * byte))
    }
  }

  private def expectedWord(block: Int, word: Int): BigInt = {
    (0 until BytesPerWord).foldLeft(BigInt(0)) { (data, byte) =>
      val address = word * BytesPerWord + byte
      data | (BigInt(byteValue(block, address)) << (8 * byte))
    }
  }

  private def hex128(value: BigInt): String = {
    "0x" + value.toString(16).reverse.padTo(32, '0').reverse
  }

  private def byteWindow(block: Int, beat: Int): String = {
    val bytes = (0 until BytesPerBeat).map { byte =>
      val address = beat * BytesPerBeat + byte
      byteValue(block, address)
    }
    val head = bytes.take(8).map(value => f"$value%02x").mkString(" ")
    val tail = bytes.takeRight(8).map(value => f"$value%02x").mkString(" ")
    "bytes[0..7]=" + head + ", bytes[56..63]=" + tail
  }

  private def pokeDmaBeat(dut: WbControllerWithBram, block: Int, beat: Int, rlast: Boolean): Unit = {
    dut.io.dma_data_valid.poke(true.B)
    dut.io.dma_data_last.poke(false.B)
    dut.io.rlast.poke(rlast.B)
    dut.io.dma_data.poke(dmaBeat(block, beat).U)
  }

  private def stopDma(dut: WbControllerWithBram): Unit = {
    dut.io.dma_data_valid.poke(false.B)
    dut.io.dma_data_last.poke(false.B)
    dut.io.rlast.poke(false.B)
    dut.io.dma_data.poke(0.U)
  }

  private def slotBank(slot: Int): String = if (slot < 2) "Ping" else "Pong"
  private def slotBankUInt(slot: Int): BigInt = if (slot < 2) BigInt(0) else BigInt(1)
  private def slotBase(slot: Int): Int = if ((slot & 1) == 0) 0 else 64

  private def expectWriteSlot(dut: WbControllerWithBram, block: Int, slot: Int, beat: Int): Unit = {
    val bank = slotBankUInt(slot)
    val addr = slotBase(slot) + beat
    dut.io.dbg_write_bank.expect(bank.U, "write bank for block " + block + " beat " + beat)
    dut.io.dbg_wr_addr.expect(addr.U, "write address for block " + block + " beat " + beat)
    if (bank == 0) {
      dut.io.dbg_ping_wr_en.expect(true.B)
      dut.io.dbg_pong_wr_en.expect(false.B)
      dut.io.dbg_ping_wr_data.expect(dmaBeat(block, beat).U)
    } else {
      dut.io.dbg_ping_wr_en.expect(false.B)
      dut.io.dbg_pong_wr_en.expect(true.B)
      dut.io.dbg_pong_wr_data.expect(dmaBeat(block, beat).U)
    }
  }

  private def write4KBToSlot(dut: WbControllerWithBram, block: Int, slot: Int): Unit = {
    for (beat <- 0 until Beats4KB) {
      pokeDmaBeat(dut, block, beat, rlast = beat == Beats4KB - 1)
      expectWriteSlot(dut, block, slot, beat)
      if (beat == 0 || beat == Beats4KB - 1) {
        println(f"write block=$block%2d slot=$slot%1d bank=${slotBank(slot)}%4s beat=$beat%2d wr_addr=${slotBase(slot) + beat}%3d " + byteWindow(block, beat))
      }
      dut.clock.step()
    }
    stopDma(dut)
  }

  private def startRead(dut: WbControllerWithBram): Unit = {
    dut.io.shoot.poke(true.B)
    dut.clock.step()
    dut.io.shoot.poke(false.B)
    dut.io.working.expect(true.B)
  }

  private def expectReadBlock(dut: WbControllerWithBram, block: Int, slot: Int): Unit = {
    val base = if ((slot & 1) == 0) 0 else Words4KB
    for (word <- 0 until Words4KB) {
      dut.io.dbg_active_bank.expect(slotBankUInt(slot).U)
      dut.io.dbg_rd_addr.expect((base + word).U)
      dut.clock.step()
      dut.io.rd_data_valid.expect(true.B)
      val actual = dut.io.rd_data_to_cu.peek().litValue
      val expected = expectedWord(block, word)
      dut.io.rd_data_to_cu.expect(expected.U, "read block " + block + " word " + word)
      if (word == 0 || word == Words4KB - 1) {
        println(f"read  block=$block%2d slot=$slot%1d bank=${slotBank(slot)}%4s word=$word%3d rd_addr=${base + word}%3d data=${hex128(actual)}")
      }
    }
  }

  it should "write and read four 4KB slots in circular order" in {
    test(new WbControllerWithBram()).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
      init(dut)

      println("")
      println("================ WB FOUR-SLOT WRITE MAP ================")
      println("slot0=Ping[0..63], slot1=Ping[64..127], slot2=Pong[0..63], slot3=Pong[64..127]")
      write4KBToSlot(dut, block = 0, slot = 0)
      write4KBToSlot(dut, block = 1, slot = 1)
      write4KBToSlot(dut, block = 2, slot = 2)
      write4KBToSlot(dut, block = 3, slot = 3)
      dut.io.hungry.expect(false.B)
      println("=======================================================")

      println("")
      println("================ WB FOUR-SLOT READ ORDER ================")
      startRead(dut)
      expectReadBlock(dut, block = 0, slot = 0)
      expectReadBlock(dut, block = 1, slot = 1)
      expectReadBlock(dut, block = 2, slot = 2)
      expectReadBlock(dut, block = 3, slot = 3)
      println("========================================================")
    }
  }

  it should "reuse slot0 when slot3 is not read yet but slot0 has been freed" in {
    test(new WbControllerWithBram()).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
      init(dut)
      write4KBToSlot(dut, block = 0, slot = 0)
      write4KBToSlot(dut, block = 1, slot = 1)
      write4KBToSlot(dut, block = 2, slot = 2)
      write4KBToSlot(dut, block = 3, slot = 3)

      println("")
      println("================ WB SLOT0 REUSE WHILE SLOT3 STILL VALID ================")
      startRead(dut)
      for (word <- 0 until Words4KB) {
        dut.clock.step()
        dut.io.rd_data_valid.expect(true.B)
        dut.io.rd_data_to_cu.expect(expectedWord(0, word).U)
      }

      // slot0 is now free, but slot1/2/3 are still valid. The next DMA block must reuse slot0.
      for (beat <- 0 until Beats4KB) {
        pokeDmaBeat(dut, block = 4, beat = beat, rlast = beat == Beats4KB - 1)
        expectWriteSlot(dut, block = 4, slot = 0, beat = beat)
        if (beat == 0 || beat == 1 || beat == Beats4KB - 1) {
          println(f"reuse block=4 slot=0 bank=Ping beat=$beat%2d wr_addr=$beat%3d " + byteWindow(4, beat))
        }
        dut.clock.step()
      }
      stopDma(dut)
      println("PASS: slot0 was refilled before slot3 was read")
      println("=======================================================================")
    }
  }
}
