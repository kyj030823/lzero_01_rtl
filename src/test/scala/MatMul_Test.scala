import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec
import scala.util.Random // 스칼라의 난수 생성기

// 하드웨어 테스트를 위한 기본 클래스 상속
class MacUnitTest extends AnyFlatSpec with ChiselScalatestTester {
  behavior of "MacUnit"

  // 테스트 케이스 시작
  it should "correctly load weight, multiply, and pass input/partial sum" in {
    // 칩(MacUnit)을 시뮬레이터 위에 올립니다. (dut: Device Under Test의 약자)
    test(new MacUnit()) { dut =>
      
      // ----------------------------------------------------
      // [1단계] 초기화: 남아있을지 모르는 쓰레기값을 0으로 밉니다.
      // ----------------------------------------------------
      dut.io.in_prop_w.poke(false.B)  // clear_w 핀에 전기(1)를 찌릅니다.
      dut.io.in_valid.poke(true.B)
      dut.io.in_w.poke(5.U)
      dut.clock.step(1)

      // ----------------------------------------------------
      // [2단계] Weight 장전: Weight 레지스터에 5를 넣습니다.
      // ----------------------------------------------------
      dut.io.in_prop_w.poke(true.B)
      dut.io.in_a.poke(6.U)
      dut.io.in_c.poke(10.U)
      dut.io.in_w.poke(6.U)
      dut.clock.step(1)

      // 예상: (A * W) + C = (2 * 5) + 10 = 20
      // MAC 연산과 in_a 통과 로직은 레지스터(순차 로직)를 거치지 않는 '조합 로직'이므로, 
      // 클럭(step)을 뛰게 하지 않아도 poke 하자마자 전기가 흘러서 바로 결과를 알 수 있습니다.
      dut.io.out_c.expect(40.U) 
      dut.io.out_a.expect(6.U)   // A값(2)이 오른쪽으로 잘 넘어가는지도 확인

      dut.clock.step(1) // 다음 테스트를 위해 1클럭 넘김

      // ----------------------------------------------------
      // [4단계] 연산 테스트 2
      // ----------------------------------------------------
      // 입력: A = 3, 위에서 내려오는 부분합 C = 0
      dut.io.in_prop_w.poke(false.B)
      dut.io.in_a.poke(3.U)
      dut.io.in_c.poke(0.U)
      dut.clock.step(1)

      // 예상: (3 * 5) + 0 = 15 (Weight 5는 계속 유지되어야 함)
      dut.io.out_c.expect(18.U)
      dut.io.out_a.expect(3.U)
    }
  }
}

class MatMulUnit_16Test extends AnyFlatSpec with ChiselScalatestTester {
  behavior of "MatMulUnit_16"
  // test case start
  it should "correctly (1)load 256 weights at once, (2)multiply two matrix successfully" in {
    test(new MatMulUnit_16()){ dut =>
      val size = 16
      val random = new Random(0)

      // Keep operands small enough that every dot product fits in UInt(16.W).
      val weight = Array.tabulate(size, size) { (_, _) => random.nextInt(10) }
      val input  = Array.tabulate(size, size) { (_, _) => random.nextInt(10) }

      val expected = Array.tabulate(size, size) { (r, c) =>
        (0 until size).map(k => input(r)(k) * weight(k)(c)).sum
      }
      val actual = Array.fill(size, size)(BigInt(0))

      // Give every input a defined value before the first clock edge.
      for (i <- 0 until size) {
        dut.io.in_A(i).poke(0.U)
        dut.io.in_W(i).poke(0.U)
        dut.io.in_Valid(i).poke(false.B)
        dut.io.in_Prop_W(i).poke(false.B)
      }

      /*
       * Preload W into w0. out_w is registered at each MacUnit, so a weight
       * moves down one row per cycle. Reverse order leaves weight(r)(c) in
       * MacUnit(r)(c) after 16 cycles.
       */
      for (t <- 0 until size) {
        for (c <- 0 until size) {
          dut.io.in_W(c).poke(weight(size - 1 - t)(c).U)
          dut.io.in_Valid(c).poke(true.B)
          dut.io.in_Prop_W(c).poke(false.B)
        }
        dut.clock.step()
      }

      /*
       * Drain valid while keeping prop_w low. During this phase, each upper
       * PE continues forwarding w0, so the trailing valid reaches and stores
       * the preceding weight in the next PE without overwriting it with w1.
       */
      for (_ <- 0 until size) {
        for (i <- 0 until size) {
          dut.io.in_A(i).poke(0.U)
          dut.io.in_W(i).poke(0.U)
          dut.io.in_Valid(i).poke(false.B)
          dut.io.in_Prop_W(i).poke(false.B)
        }
        dut.clock.step()
      }

      // After valid has drained completely, select w0 throughout the array.
      for (_ <- 0 until size) {
        for (i <- 0 until size) {
          dut.io.in_A(i).poke(0.U)
          dut.io.in_W(i).poke(0.U)
          dut.io.in_Valid(i).poke(false.B)
          dut.io.in_Prop_W(i).poke(true.B)
        }
        dut.clock.step()
      }

      /*
       * A(i)(k) is applied at cycle i+k to compensate for the horizontal
       * register delay while the partial sum travels downward.
       */
      val resultLatency = size
      val computeCycles = 3 * size - 1

      for (t <- 0 until computeCycles) {
        for (k <- 0 until size) {
          val inputRow = t - k
          val a = if (inputRow >= 0 && inputRow < size) input(inputRow)(k) else 0

          dut.io.in_A(k).poke(a.U)
          dut.io.in_W(k).poke(0.U)
          dut.io.in_Valid(k).poke(false.B)
          dut.io.in_Prop_W(k).poke(true.B)
        }

        dut.clock.step()

        // Column c produces row i at compute cycle i + c + size - 1.
        for (c <- 0 until size) {
          val outputRow = t - (resultLatency - 1) - c
          if (outputRow >= 0 && outputRow < size) {
            actual(outputRow)(c) = dut.io.out_MAC(c).peek().litValue
          }
        }
      }

      def printMatrix(name: String, matrix: Seq[Seq[BigInt]]): Unit = {
        println(s"\n===== $name =====")
        matrix.zipWithIndex.foreach { case (row, r) =>
          println(f"row $r%2d : ${row.map(v => f"$v%6d").mkString(" ")}")
        }
      }

      printMatrix(
        "EXPECTED OUTPUT",
        expected.map(_.map(BigInt(_)).toSeq).toSeq
      )
      printMatrix(
        "ACTUAL OUTPUT",
        actual.map(_.toSeq).toSeq
      )

      for (r <- 0 until size; c <- 0 until size) {
        assert(
          actual(r)(c) == expected(r)(c),
          s"C($r,$c) mismatch: actual=${actual(r)(c)}, expected=${expected(r)(c)}"
        )
      }
    }
  }
}