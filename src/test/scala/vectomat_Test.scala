import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec

class vectomat_Test extends AnyFlatSpec with ChiselScalatestTester {
  behavior of "vectomat"

  it should "collect the first vector of 16 matrices and output them in order" in {
    test(new vectomat()).withAnnotations(Seq(WriteVcdAnnotation)) { dut =>
      val size = 16
      val actualMatrix = Array.fill(size, size)(BigInt(0))

      def firstVectorValue(matrix: Int, lane: Int): Int =
        matrix * size + lane

      dut.io.in_valid.poke(false.B)
      for (lane <- 0 until size) {
        dut.io.in_vec(lane).poke(0.U)
      }
      dut.clock.step()

      for {
        matrix <- 0 until size
        vector <- 0 until size
      } {
        dut.io.in_valid.poke(true.B)

        for (lane <- 0 until size) {
          val value =
            if (vector == 0) firstVectorValue(matrix, lane)
            else (matrix + vector + lane) & 0xff

          dut.io.in_vec(lane).poke(value.U)
        }

        if (matrix == size - 1) {
          dut.io.out_valid.expect(true.B)

          for (lane <- 0 until size) {
            actualMatrix(vector)(lane) = dut.io.out_vec(lane).peek().litValue
            dut.io.out_vec(lane).expect(
              firstVectorValue(vector, lane).U,
              s"output vector $vector, lane $lane"
            )
          }
        } else {
          dut.io.out_valid.expect(false.B)
        }

        dut.clock.step()
      }

      dut.io.in_valid.poke(false.B)
      dut.io.out_valid.expect(false.B)

      val expectedMatrix = Array.tabulate(size, size) { (matrix, lane) =>
        BigInt(firstVectorValue(matrix, lane))
      }

      def printMatrix(name: String, matrix: Array[Array[BigInt]]): Unit = {
        println(s"\n===== $name =====")
        matrix.zipWithIndex.foreach { case (row, index) =>
          val formattedRow = row.map(value => f"$value%4d").mkString(" ")
          println(f"row $index%2d : " + formattedRow)
        }
      }

      printMatrix("EXPECTED MATRIX", expectedMatrix)
      printMatrix("ACTUAL MATRIX", actualMatrix)
    }
  }
}
