FIRRTL version 1.2.0
circuit MacUnit :
  module MacUnit : @[src/main/scala/MatMul.scala 7:7]
    input clock : Clock @[src/main/scala/MatMul.scala 7:7]
    input reset : UInt<1> @[src/main/scala/MatMul.scala 7:7]
    input io_in_a : UInt<8> @[src/main/scala/MatMul.scala 8:14]
    input io_in_c : UInt<16> @[src/main/scala/MatMul.scala 8:14]
    input io_in_w : UInt<8> @[src/main/scala/MatMul.scala 8:14]
    input io_in_prop_w : UInt<1> @[src/main/scala/MatMul.scala 8:14]
    output io_out_prop_w : UInt<1> @[src/main/scala/MatMul.scala 8:14]
    input io_in_valid : UInt<1> @[src/main/scala/MatMul.scala 8:14]
    output io_out_valid : UInt<1> @[src/main/scala/MatMul.scala 8:14]
    output io_out_a : UInt<8> @[src/main/scala/MatMul.scala 8:14]
    output io_out_c : UInt<16> @[src/main/scala/MatMul.scala 8:14]
    output io_out_w : UInt<8> @[src/main/scala/MatMul.scala 8:14]

    reg w0 : UInt<8>, clock with :
      reset => (UInt<1>("h0"), w0) @[src/main/scala/MatMul.scala 24:19]
    reg w1 : UInt<8>, clock with :
      reset => (UInt<1>("h0"), w1) @[src/main/scala/MatMul.scala 25:19]
    reg io_out_a_REG : UInt<8>, clock with :
      reset => (UInt<1>("h0"), io_out_a_REG) @[src/main/scala/MatMul.scala 33:22]
    reg io_out_prop_w_REG : UInt<1>, clock with :
      reset => (UInt<1>("h0"), io_out_prop_w_REG) @[src/main/scala/MatMul.scala 34:27]
    reg io_out_valid_REG : UInt<1>, clock with :
      reset => (UInt<1>("h0"), io_out_valid_REG) @[src/main/scala/MatMul.scala 35:26]
    reg io_out_w_REG : UInt<8>, clock with :
      reset => (UInt<1>("h0"), io_out_w_REG) @[src/main/scala/MatMul.scala 37:24]
    node _io_out_c_T = mul(io_in_a, w0) @[src/main/scala/MatMul.scala 38:27]
    node _io_out_c_T_1 = add(_io_out_c_T, io_in_c) @[src/main/scala/MatMul.scala 38:32]
    node _io_out_c_T_2 = tail(_io_out_c_T_1, 1) @[src/main/scala/MatMul.scala 38:32]
    reg io_out_c_REG : UInt<16>, clock with :
      reset => (UInt<1>("h0"), io_out_c_REG) @[src/main/scala/MatMul.scala 38:24]
    reg io_out_w_REG_1 : UInt<8>, clock with :
      reset => (UInt<1>("h0"), io_out_w_REG_1) @[src/main/scala/MatMul.scala 41:24]
    node _io_out_c_T_3 = mul(io_in_a, w1) @[src/main/scala/MatMul.scala 42:27]
    node _io_out_c_T_4 = add(_io_out_c_T_3, io_in_c) @[src/main/scala/MatMul.scala 42:32]
    node _io_out_c_T_5 = tail(_io_out_c_T_4, 1) @[src/main/scala/MatMul.scala 42:32]
    reg io_out_c_REG_1 : UInt<16>, clock with :
      reset => (UInt<1>("h0"), io_out_c_REG_1) @[src/main/scala/MatMul.scala 42:24]
    node _GEN_0 = mux(io_in_prop_w, io_out_w_REG, io_out_w_REG_1) @[src/main/scala/MatMul.scala 36:15 37:14 41:14]
    node _GEN_1 = mux(io_in_prop_w, io_out_c_REG, io_out_c_REG_1) @[src/main/scala/MatMul.scala 36:15 38:14 42:14]
    node _GEN_2 = mux(io_in_prop_w, io_in_w, w1) @[src/main/scala/MatMul.scala 36:15 25:19 39:8]
    node _GEN_3 = mux(io_in_prop_w, w0, io_in_w) @[src/main/scala/MatMul.scala 36:15 24:19 43:8]
    node _T = eq(io_in_valid, UInt<1>("h0")) @[src/main/scala/MatMul.scala 45:8]
    node _GEN_4 = mux(_T, w0, _GEN_3) @[src/main/scala/MatMul.scala 45:15 46:8]
    node _GEN_5 = mux(_T, w1, _GEN_2) @[src/main/scala/MatMul.scala 45:15 47:8]
    io_out_prop_w <= io_out_prop_w_REG @[src/main/scala/MatMul.scala 34:17]
    io_out_valid <= io_out_valid_REG @[src/main/scala/MatMul.scala 35:16]
    io_out_a <= io_out_a_REG @[src/main/scala/MatMul.scala 33:12]
    io_out_c <= _GEN_1
    io_out_w <= _GEN_0
    w0 <= mux(reset, UInt<8>("h0"), _GEN_4) @[src/main/scala/MatMul.scala 24:{19,19}]
    w1 <= mux(reset, UInt<8>("h0"), _GEN_5) @[src/main/scala/MatMul.scala 25:{19,19}]
    io_out_a_REG <= io_in_a @[src/main/scala/MatMul.scala 33:22]
    io_out_prop_w_REG <= io_in_prop_w @[src/main/scala/MatMul.scala 34:27]
    io_out_valid_REG <= io_in_valid @[src/main/scala/MatMul.scala 35:26]
    io_out_w_REG <= w1 @[src/main/scala/MatMul.scala 37:24]
    io_out_c_REG <= _io_out_c_T_2 @[src/main/scala/MatMul.scala 38:24]
    io_out_w_REG_1 <= w0 @[src/main/scala/MatMul.scala 41:24]
    io_out_c_REG_1 <= _io_out_c_T_5 @[src/main/scala/MatMul.scala 42:24]
