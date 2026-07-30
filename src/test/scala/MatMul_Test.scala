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

  it should "overlap skewed weight loading with two matrix multiplications" in {
    test(new MatMulUnit_16()).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
      val size = 16
      val random = new Random(0)

      val weight0 = Array.tabulate(size, size) { (_, _) => random.nextInt(10) }
      val weight1 = Array.tabulate(size, size) { (_, _) => random.nextInt(10) }
      val input0  = Array.tabulate(size, size) { (_, _) => random.nextInt(10) }
      val input1  = Array.tabulate(size, size) { (_, _) => random.nextInt(10) }

      def matrixMultiply(
        a: Array[Array[Int]],
        w: Array[Array[Int]]
      ): Array[Array[Int]] = {
        Array.tabulate(size, size) { (r, c) =>
          (0 until size).map(k => a(r)(k) * w(k)(c)).sum
        }
      }

      val expected0 = matrixMultiply(input0, weight0)
      val expected1 = matrixMultiply(input1, weight1)
      val actual0 = Array.fill(size, size)(BigInt(0))
      val actual1 = Array.fill(size, size)(BigInt(0))

      for (i <- 0 until size) {
        dut.io.in_A(i).poke(0.U)
        dut.io.in_W(i).poke(0.U)
        dut.io.in_Valid(i).poke(false.B)
        dut.io.in_Prop_W(i).poke(false.B)
      }

      /*
       * Global skewed schedule for column/lane c:
       *
       *   local  0..15 : load weight0 into w0 (valid=1, prop=0)
       *   local 16..31 : load weight1 into w1 (valid=1, prop=1)
       *                  while input0 is multiplied by weight0
       *   local 32..   : select w1 for input1 MAC (valid=0, prop=0)
       *
       * A0 starts at global cycle 16, immediately after MacUnit(0)(0)
       * receives its final weight0 value. A1 starts 16 cycles later.
       */
      val a0StartCycle = size
      val a1StartCycle = 2 * size
      val computeCycles = 3 * size - 1
      val totalCycles = a1StartCycle + computeCycles

      for (t <- 0 until totalCycles) {
        for (lane <- 0 until size) {
          val weightCycle = t - lane
          val loadingW0 = weightCycle >= 0 && weightCycle < size
          val loadingW1 = weightCycle >= size && weightCycle < 2 * size

          val w =
            if (loadingW0) weight0(size - 1 - weightCycle)(lane)
            else if (loadingW1) weight1(2 * size - 1 - weightCycle)(lane)
            else 0

          val input0Row = t - a0StartCycle - lane
          val input1Row = t - a1StartCycle - lane
          val a =
            if (input0Row >= 0 && input0Row < size) input0(input0Row)(lane)
            else if (input1Row >= 0 && input1Row < size) input1(input1Row)(lane)
            else 0

          dut.io.in_W(lane).poke(w.U)
          dut.io.in_Valid(lane).poke((loadingW0 || loadingW1).B)
          dut.io.in_Prop_W(lane).poke(loadingW1.B)
          dut.io.in_A(lane).poke(a.U)
        }

        dut.clock.step()

        for (c <- 0 until size) {
          val output0Row = t - a0StartCycle - (size - 1) - c
          val output1Row = t - a1StartCycle - (size - 1) - c

          if (output0Row >= 0 && output0Row < size) {
            actual0(output0Row)(c) = dut.io.out_MAC(c).peek().litValue
          }
          if (output1Row >= 0 && output1Row < size) {
            actual1(output1Row)(c) = dut.io.out_MAC(c).peek().litValue
          }
        }
      }

      def printMatrix(name: String, matrix: Seq[Seq[BigInt]]): Unit = {
        println(s"\n===== $name =====")
        matrix.zipWithIndex.foreach { case (row, r) =>
          println(f"row $r%2d : ${row.map(v => f"$v%6d").mkString(" ")}")
        }
      }

      printMatrix("EXPECTED OUTPUT 0 (A0 x W0)", expected0.map(_.map(BigInt(_)).toSeq).toSeq)
      printMatrix("ACTUAL OUTPUT 0 (A0 x W0)", actual0.map(_.toSeq).toSeq)
      printMatrix("EXPECTED OUTPUT 1 (A1 x W1)", expected1.map(_.map(BigInt(_)).toSeq).toSeq)
      printMatrix("ACTUAL OUTPUT 1 (A1 x W1)", actual1.map(_.toSeq).toSeq)

      for (r <- 0 until size; c <- 0 until size) {
        assert(
          actual0(r)(c) == expected0(r)(c),
          s"C0($r,$c) mismatch: actual=${actual0(r)(c)}, expected=${expected0(r)(c)}"
        )
        assert(
          actual1(r)(c) == expected1(r)(c),
          s"C1($r,$c) mismatch: actual=${actual1(r)(c)}, expected=${expected1(r)(c)}"
        )
      }
    }
  }
}