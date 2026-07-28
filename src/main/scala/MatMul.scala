import circt.stage.ChiselStage // import first
import chisel3._
import chisel3.util._

// [1] 하드웨어 모듈 정의 weight stationary
// A x W = C
class MacUnit extends Module {
  val io = IO(new Bundle {
    val in_a      = Input(UInt(8.W)) // input mat
    val in_c      = Input(UInt(16.W)) // output mat init vaa(bias)
    val in_w      = Input(UInt(8.W))

    val in_prop_w = Input(Bool())
    val out_prop_w = Output(Bool())

    val in_valid  = Input(Bool())
    val out_valid = Output(Bool())

    val out_a     = Output(UInt(8.W))
    val out_c     = Output(UInt(16.W))
    val out_w     = Output(UInt(8.W))
  })

  val w0 = RegInit(0.U(8.W))
  val w1 = RegInit(0.U(8.W))

  val a = io.in_a
  val c = io.in_c
  val pre_w = io.in_w
  val valid = io.in_valid
  val prop_w = io.in_prop_w

  io.out_a := RegNext(a)
  io.out_prop_w := RegNext(prop_w)
  io.out_valid := RegNext(valid)
  when(prop_w){
    io.out_w := RegNext(w1)
    io.out_c := RegNext(a * w0 + c)
    w1 := pre_w
  }.otherwise{
    io.out_w := RegNext(w0)
    io.out_c := RegNext(a * w1 + c)
    w0 := pre_w
  }
  when(!valid){
    w0 := w0
    w1 := w1
  }
}

// [2] systolic array 16 by 16
class MatMulUnit_16 extends Module {
  // input output
  val io = IO(new Bundle{
    val in_A    = Input(Vec(16, UInt(8.W)))

    val in_Valid = Input(Vec(16, Bool()))
    val in_Prop_W = Input(Vec(16, Bool()))
    val in_W    = Input(Vec(16, UInt(8.W)))

    val out_Valid = Output(Vec(16, Bool()))
    val out_MAC = Output(Vec(16, UInt(16.W)))
  })

  val macs = Seq.fill(16, 16)(Module(new MacUnit()))
  val macsT = macs.transpose

  for (r <- 0 until 16) {
    macs(r).foldLeft(io.in_A(r)) {
      case (in_a, mac) =>
        mac.io.in_a := in_a
        mac.io.out_a
    }
  }

  for (c <- 0 until 16) {
    macsT(c).foldLeft(io.in_W(c)) {
      case (in_w, macs) =>
        macs.io.in_w := in_w
        macs.io.out_w
    }
  }

  for (c <- 0 until 16) {
    macsT(c).foldLeft(io.in_Valid(c)) {
      case (in_valid, macs) =>
        macs.io.in_valid := in_valid
        macs.io.out_valid
    }
  }

  for (c <- 0 until 16) {
    macsT(c).foldLeft(io.in_Prop_W(c)) {
      case (in_prop_w, macs) =>
        macs.io.in_prop_w := in_prop_w
        macs.io.out_prop_w
    }
  }

  for (c <- 0 until 16) {
    macsT(c).foldLeft(0.U) {
      case (in_c, macs) =>
        macs.io.in_c := in_c
        macs.io.out_c
    }
  }

  // wiring MatMulUnit's input output to each of macUnit
  for (c <- 0 until 16) {
    io.out_MAC(c)       := macs(15)(c).io.out_c // output wiring
    io.out_Valid(c)     := macs(15)(c).io.out_valid
  }
}


// [4] Chisel 6.x 문법에 맞춘 실행 객체
object TPU_Main extends App {
  println("TPU Accelerator SystemVerilog extracting...")
  
  // 1. 가장 작은 세포 (선택사항)
  ChiselStage.emitSystemVerilogFile(new MacUnit(), Array("--target-dir", "generated"))
  
  // 2. 16x16 시스톨릭 어레이 본체
  ChiselStage.emitSystemVerilogFile(new MatMulUnit_16(), Array("--target-dir", "generated"))
  
  println("Extract SV Finished! Please check 'generated' directory")
}