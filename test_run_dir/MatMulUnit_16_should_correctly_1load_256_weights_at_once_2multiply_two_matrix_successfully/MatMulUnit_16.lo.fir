FIRRTL version 1.2.0
circuit MatMulUnit_16 :
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

  module MatMulUnit_16 : @[src/main/scala/MatMul.scala 52:7]
    input clock : Clock @[src/main/scala/MatMul.scala 52:7]
    input reset : UInt<1> @[src/main/scala/MatMul.scala 52:7]
    input io_in_A_0 : UInt<8> @[src/main/scala/MatMul.scala 54:14]
    input io_in_A_1 : UInt<8> @[src/main/scala/MatMul.scala 54:14]
    input io_in_A_2 : UInt<8> @[src/main/scala/MatMul.scala 54:14]
    input io_in_A_3 : UInt<8> @[src/main/scala/MatMul.scala 54:14]
    input io_in_A_4 : UInt<8> @[src/main/scala/MatMul.scala 54:14]
    input io_in_A_5 : UInt<8> @[src/main/scala/MatMul.scala 54:14]
    input io_in_A_6 : UInt<8> @[src/main/scala/MatMul.scala 54:14]
    input io_in_A_7 : UInt<8> @[src/main/scala/MatMul.scala 54:14]
    input io_in_A_8 : UInt<8> @[src/main/scala/MatMul.scala 54:14]
    input io_in_A_9 : UInt<8> @[src/main/scala/MatMul.scala 54:14]
    input io_in_A_10 : UInt<8> @[src/main/scala/MatMul.scala 54:14]
    input io_in_A_11 : UInt<8> @[src/main/scala/MatMul.scala 54:14]
    input io_in_A_12 : UInt<8> @[src/main/scala/MatMul.scala 54:14]
    input io_in_A_13 : UInt<8> @[src/main/scala/MatMul.scala 54:14]
    input io_in_A_14 : UInt<8> @[src/main/scala/MatMul.scala 54:14]
    input io_in_A_15 : UInt<8> @[src/main/scala/MatMul.scala 54:14]
    input io_in_Valid_0 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    input io_in_Valid_1 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    input io_in_Valid_2 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    input io_in_Valid_3 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    input io_in_Valid_4 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    input io_in_Valid_5 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    input io_in_Valid_6 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    input io_in_Valid_7 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    input io_in_Valid_8 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    input io_in_Valid_9 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    input io_in_Valid_10 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    input io_in_Valid_11 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    input io_in_Valid_12 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    input io_in_Valid_13 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    input io_in_Valid_14 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    input io_in_Valid_15 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    input io_in_Prop_W_0 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    input io_in_Prop_W_1 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    input io_in_Prop_W_2 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    input io_in_Prop_W_3 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    input io_in_Prop_W_4 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    input io_in_Prop_W_5 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    input io_in_Prop_W_6 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    input io_in_Prop_W_7 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    input io_in_Prop_W_8 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    input io_in_Prop_W_9 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    input io_in_Prop_W_10 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    input io_in_Prop_W_11 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    input io_in_Prop_W_12 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    input io_in_Prop_W_13 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    input io_in_Prop_W_14 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    input io_in_Prop_W_15 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    input io_in_W_0 : UInt<8> @[src/main/scala/MatMul.scala 54:14]
    input io_in_W_1 : UInt<8> @[src/main/scala/MatMul.scala 54:14]
    input io_in_W_2 : UInt<8> @[src/main/scala/MatMul.scala 54:14]
    input io_in_W_3 : UInt<8> @[src/main/scala/MatMul.scala 54:14]
    input io_in_W_4 : UInt<8> @[src/main/scala/MatMul.scala 54:14]
    input io_in_W_5 : UInt<8> @[src/main/scala/MatMul.scala 54:14]
    input io_in_W_6 : UInt<8> @[src/main/scala/MatMul.scala 54:14]
    input io_in_W_7 : UInt<8> @[src/main/scala/MatMul.scala 54:14]
    input io_in_W_8 : UInt<8> @[src/main/scala/MatMul.scala 54:14]
    input io_in_W_9 : UInt<8> @[src/main/scala/MatMul.scala 54:14]
    input io_in_W_10 : UInt<8> @[src/main/scala/MatMul.scala 54:14]
    input io_in_W_11 : UInt<8> @[src/main/scala/MatMul.scala 54:14]
    input io_in_W_12 : UInt<8> @[src/main/scala/MatMul.scala 54:14]
    input io_in_W_13 : UInt<8> @[src/main/scala/MatMul.scala 54:14]
    input io_in_W_14 : UInt<8> @[src/main/scala/MatMul.scala 54:14]
    input io_in_W_15 : UInt<8> @[src/main/scala/MatMul.scala 54:14]
    output io_out_Valid_0 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    output io_out_Valid_1 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    output io_out_Valid_2 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    output io_out_Valid_3 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    output io_out_Valid_4 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    output io_out_Valid_5 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    output io_out_Valid_6 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    output io_out_Valid_7 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    output io_out_Valid_8 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    output io_out_Valid_9 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    output io_out_Valid_10 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    output io_out_Valid_11 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    output io_out_Valid_12 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    output io_out_Valid_13 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    output io_out_Valid_14 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    output io_out_Valid_15 : UInt<1> @[src/main/scala/MatMul.scala 54:14]
    output io_out_MAC_0 : UInt<16> @[src/main/scala/MatMul.scala 54:14]
    output io_out_MAC_1 : UInt<16> @[src/main/scala/MatMul.scala 54:14]
    output io_out_MAC_2 : UInt<16> @[src/main/scala/MatMul.scala 54:14]
    output io_out_MAC_3 : UInt<16> @[src/main/scala/MatMul.scala 54:14]
    output io_out_MAC_4 : UInt<16> @[src/main/scala/MatMul.scala 54:14]
    output io_out_MAC_5 : UInt<16> @[src/main/scala/MatMul.scala 54:14]
    output io_out_MAC_6 : UInt<16> @[src/main/scala/MatMul.scala 54:14]
    output io_out_MAC_7 : UInt<16> @[src/main/scala/MatMul.scala 54:14]
    output io_out_MAC_8 : UInt<16> @[src/main/scala/MatMul.scala 54:14]
    output io_out_MAC_9 : UInt<16> @[src/main/scala/MatMul.scala 54:14]
    output io_out_MAC_10 : UInt<16> @[src/main/scala/MatMul.scala 54:14]
    output io_out_MAC_11 : UInt<16> @[src/main/scala/MatMul.scala 54:14]
    output io_out_MAC_12 : UInt<16> @[src/main/scala/MatMul.scala 54:14]
    output io_out_MAC_13 : UInt<16> @[src/main/scala/MatMul.scala 54:14]
    output io_out_MAC_14 : UInt<16> @[src/main/scala/MatMul.scala 54:14]
    output io_out_MAC_15 : UInt<16> @[src/main/scala/MatMul.scala 54:14]

    inst macs_0_0 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_0_1 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_0_2 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_0_3 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_0_4 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_0_5 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_0_6 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_0_7 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_0_8 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_0_9 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_0_10 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_0_11 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_0_12 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_0_13 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_0_14 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_0_15 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_1_0 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_1_1 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_1_2 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_1_3 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_1_4 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_1_5 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_1_6 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_1_7 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_1_8 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_1_9 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_1_10 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_1_11 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_1_12 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_1_13 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_1_14 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_1_15 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_2_0 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_2_1 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_2_2 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_2_3 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_2_4 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_2_5 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_2_6 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_2_7 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_2_8 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_2_9 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_2_10 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_2_11 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_2_12 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_2_13 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_2_14 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_2_15 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_3_0 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_3_1 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_3_2 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_3_3 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_3_4 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_3_5 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_3_6 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_3_7 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_3_8 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_3_9 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_3_10 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_3_11 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_3_12 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_3_13 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_3_14 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_3_15 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_4_0 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_4_1 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_4_2 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_4_3 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_4_4 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_4_5 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_4_6 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_4_7 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_4_8 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_4_9 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_4_10 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_4_11 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_4_12 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_4_13 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_4_14 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_4_15 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_5_0 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_5_1 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_5_2 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_5_3 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_5_4 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_5_5 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_5_6 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_5_7 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_5_8 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_5_9 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_5_10 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_5_11 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_5_12 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_5_13 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_5_14 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_5_15 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_6_0 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_6_1 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_6_2 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_6_3 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_6_4 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_6_5 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_6_6 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_6_7 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_6_8 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_6_9 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_6_10 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_6_11 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_6_12 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_6_13 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_6_14 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_6_15 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_7_0 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_7_1 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_7_2 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_7_3 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_7_4 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_7_5 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_7_6 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_7_7 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_7_8 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_7_9 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_7_10 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_7_11 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_7_12 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_7_13 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_7_14 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_7_15 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_8_0 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_8_1 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_8_2 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_8_3 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_8_4 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_8_5 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_8_6 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_8_7 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_8_8 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_8_9 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_8_10 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_8_11 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_8_12 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_8_13 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_8_14 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_8_15 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_9_0 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_9_1 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_9_2 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_9_3 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_9_4 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_9_5 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_9_6 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_9_7 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_9_8 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_9_9 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_9_10 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_9_11 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_9_12 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_9_13 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_9_14 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_9_15 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_10_0 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_10_1 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_10_2 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_10_3 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_10_4 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_10_5 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_10_6 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_10_7 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_10_8 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_10_9 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_10_10 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_10_11 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_10_12 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_10_13 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_10_14 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_10_15 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_11_0 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_11_1 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_11_2 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_11_3 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_11_4 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_11_5 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_11_6 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_11_7 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_11_8 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_11_9 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_11_10 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_11_11 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_11_12 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_11_13 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_11_14 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_11_15 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_12_0 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_12_1 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_12_2 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_12_3 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_12_4 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_12_5 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_12_6 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_12_7 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_12_8 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_12_9 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_12_10 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_12_11 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_12_12 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_12_13 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_12_14 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_12_15 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_13_0 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_13_1 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_13_2 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_13_3 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_13_4 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_13_5 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_13_6 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_13_7 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_13_8 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_13_9 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_13_10 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_13_11 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_13_12 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_13_13 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_13_14 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_13_15 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_14_0 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_14_1 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_14_2 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_14_3 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_14_4 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_14_5 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_14_6 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_14_7 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_14_8 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_14_9 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_14_10 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_14_11 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_14_12 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_14_13 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_14_14 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_14_15 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_15_0 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_15_1 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_15_2 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_15_3 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_15_4 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_15_5 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_15_6 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_15_7 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_15_8 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_15_9 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_15_10 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_15_11 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_15_12 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_15_13 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_15_14 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    inst macs_15_15 of MacUnit @[src/main/scala/MatMul.scala 65:37]
    io_out_Valid_0 <= macs_15_0.io_out_valid @[src/main/scala/MatMul.scala 111:25]
    io_out_Valid_1 <= macs_15_1.io_out_valid @[src/main/scala/MatMul.scala 111:25]
    io_out_Valid_2 <= macs_15_2.io_out_valid @[src/main/scala/MatMul.scala 111:25]
    io_out_Valid_3 <= macs_15_3.io_out_valid @[src/main/scala/MatMul.scala 111:25]
    io_out_Valid_4 <= macs_15_4.io_out_valid @[src/main/scala/MatMul.scala 111:25]
    io_out_Valid_5 <= macs_15_5.io_out_valid @[src/main/scala/MatMul.scala 111:25]
    io_out_Valid_6 <= macs_15_6.io_out_valid @[src/main/scala/MatMul.scala 111:25]
    io_out_Valid_7 <= macs_15_7.io_out_valid @[src/main/scala/MatMul.scala 111:25]
    io_out_Valid_8 <= macs_15_8.io_out_valid @[src/main/scala/MatMul.scala 111:25]
    io_out_Valid_9 <= macs_15_9.io_out_valid @[src/main/scala/MatMul.scala 111:25]
    io_out_Valid_10 <= macs_15_10.io_out_valid @[src/main/scala/MatMul.scala 111:25]
    io_out_Valid_11 <= macs_15_11.io_out_valid @[src/main/scala/MatMul.scala 111:25]
    io_out_Valid_12 <= macs_15_12.io_out_valid @[src/main/scala/MatMul.scala 111:25]
    io_out_Valid_13 <= macs_15_13.io_out_valid @[src/main/scala/MatMul.scala 111:25]
    io_out_Valid_14 <= macs_15_14.io_out_valid @[src/main/scala/MatMul.scala 111:25]
    io_out_Valid_15 <= macs_15_15.io_out_valid @[src/main/scala/MatMul.scala 111:25]
    io_out_MAC_0 <= macs_15_0.io_out_c @[src/main/scala/MatMul.scala 110:25]
    io_out_MAC_1 <= macs_15_1.io_out_c @[src/main/scala/MatMul.scala 110:25]
    io_out_MAC_2 <= macs_15_2.io_out_c @[src/main/scala/MatMul.scala 110:25]
    io_out_MAC_3 <= macs_15_3.io_out_c @[src/main/scala/MatMul.scala 110:25]
    io_out_MAC_4 <= macs_15_4.io_out_c @[src/main/scala/MatMul.scala 110:25]
    io_out_MAC_5 <= macs_15_5.io_out_c @[src/main/scala/MatMul.scala 110:25]
    io_out_MAC_6 <= macs_15_6.io_out_c @[src/main/scala/MatMul.scala 110:25]
    io_out_MAC_7 <= macs_15_7.io_out_c @[src/main/scala/MatMul.scala 110:25]
    io_out_MAC_8 <= macs_15_8.io_out_c @[src/main/scala/MatMul.scala 110:25]
    io_out_MAC_9 <= macs_15_9.io_out_c @[src/main/scala/MatMul.scala 110:25]
    io_out_MAC_10 <= macs_15_10.io_out_c @[src/main/scala/MatMul.scala 110:25]
    io_out_MAC_11 <= macs_15_11.io_out_c @[src/main/scala/MatMul.scala 110:25]
    io_out_MAC_12 <= macs_15_12.io_out_c @[src/main/scala/MatMul.scala 110:25]
    io_out_MAC_13 <= macs_15_13.io_out_c @[src/main/scala/MatMul.scala 110:25]
    io_out_MAC_14 <= macs_15_14.io_out_c @[src/main/scala/MatMul.scala 110:25]
    io_out_MAC_15 <= macs_15_15.io_out_c @[src/main/scala/MatMul.scala 110:25]
    macs_0_0.clock <= clock
    macs_0_0.reset <= reset
    macs_0_0.io_in_a <= io_in_A_0 @[src/main/scala/MatMul.scala 71:21]
    macs_0_0.io_in_c <= UInt<16>("h0") @[src/main/scala/MatMul.scala 103:22]
    macs_0_0.io_in_w <= io_in_W_0 @[src/main/scala/MatMul.scala 79:22]
    macs_0_0.io_in_prop_w <= io_in_Prop_W_0 @[src/main/scala/MatMul.scala 95:27]
    macs_0_0.io_in_valid <= io_in_Valid_0 @[src/main/scala/MatMul.scala 87:26]
    macs_0_1.clock <= clock
    macs_0_1.reset <= reset
    macs_0_1.io_in_a <= macs_0_0.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_0_1.io_in_c <= UInt<16>("h0") @[src/main/scala/MatMul.scala 103:22]
    macs_0_1.io_in_w <= io_in_W_1 @[src/main/scala/MatMul.scala 79:22]
    macs_0_1.io_in_prop_w <= io_in_Prop_W_1 @[src/main/scala/MatMul.scala 95:27]
    macs_0_1.io_in_valid <= io_in_Valid_1 @[src/main/scala/MatMul.scala 87:26]
    macs_0_2.clock <= clock
    macs_0_2.reset <= reset
    macs_0_2.io_in_a <= macs_0_1.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_0_2.io_in_c <= UInt<16>("h0") @[src/main/scala/MatMul.scala 103:22]
    macs_0_2.io_in_w <= io_in_W_2 @[src/main/scala/MatMul.scala 79:22]
    macs_0_2.io_in_prop_w <= io_in_Prop_W_2 @[src/main/scala/MatMul.scala 95:27]
    macs_0_2.io_in_valid <= io_in_Valid_2 @[src/main/scala/MatMul.scala 87:26]
    macs_0_3.clock <= clock
    macs_0_3.reset <= reset
    macs_0_3.io_in_a <= macs_0_2.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_0_3.io_in_c <= UInt<16>("h0") @[src/main/scala/MatMul.scala 103:22]
    macs_0_3.io_in_w <= io_in_W_3 @[src/main/scala/MatMul.scala 79:22]
    macs_0_3.io_in_prop_w <= io_in_Prop_W_3 @[src/main/scala/MatMul.scala 95:27]
    macs_0_3.io_in_valid <= io_in_Valid_3 @[src/main/scala/MatMul.scala 87:26]
    macs_0_4.clock <= clock
    macs_0_4.reset <= reset
    macs_0_4.io_in_a <= macs_0_3.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_0_4.io_in_c <= UInt<16>("h0") @[src/main/scala/MatMul.scala 103:22]
    macs_0_4.io_in_w <= io_in_W_4 @[src/main/scala/MatMul.scala 79:22]
    macs_0_4.io_in_prop_w <= io_in_Prop_W_4 @[src/main/scala/MatMul.scala 95:27]
    macs_0_4.io_in_valid <= io_in_Valid_4 @[src/main/scala/MatMul.scala 87:26]
    macs_0_5.clock <= clock
    macs_0_5.reset <= reset
    macs_0_5.io_in_a <= macs_0_4.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_0_5.io_in_c <= UInt<16>("h0") @[src/main/scala/MatMul.scala 103:22]
    macs_0_5.io_in_w <= io_in_W_5 @[src/main/scala/MatMul.scala 79:22]
    macs_0_5.io_in_prop_w <= io_in_Prop_W_5 @[src/main/scala/MatMul.scala 95:27]
    macs_0_5.io_in_valid <= io_in_Valid_5 @[src/main/scala/MatMul.scala 87:26]
    macs_0_6.clock <= clock
    macs_0_6.reset <= reset
    macs_0_6.io_in_a <= macs_0_5.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_0_6.io_in_c <= UInt<16>("h0") @[src/main/scala/MatMul.scala 103:22]
    macs_0_6.io_in_w <= io_in_W_6 @[src/main/scala/MatMul.scala 79:22]
    macs_0_6.io_in_prop_w <= io_in_Prop_W_6 @[src/main/scala/MatMul.scala 95:27]
    macs_0_6.io_in_valid <= io_in_Valid_6 @[src/main/scala/MatMul.scala 87:26]
    macs_0_7.clock <= clock
    macs_0_7.reset <= reset
    macs_0_7.io_in_a <= macs_0_6.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_0_7.io_in_c <= UInt<16>("h0") @[src/main/scala/MatMul.scala 103:22]
    macs_0_7.io_in_w <= io_in_W_7 @[src/main/scala/MatMul.scala 79:22]
    macs_0_7.io_in_prop_w <= io_in_Prop_W_7 @[src/main/scala/MatMul.scala 95:27]
    macs_0_7.io_in_valid <= io_in_Valid_7 @[src/main/scala/MatMul.scala 87:26]
    macs_0_8.clock <= clock
    macs_0_8.reset <= reset
    macs_0_8.io_in_a <= macs_0_7.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_0_8.io_in_c <= UInt<16>("h0") @[src/main/scala/MatMul.scala 103:22]
    macs_0_8.io_in_w <= io_in_W_8 @[src/main/scala/MatMul.scala 79:22]
    macs_0_8.io_in_prop_w <= io_in_Prop_W_8 @[src/main/scala/MatMul.scala 95:27]
    macs_0_8.io_in_valid <= io_in_Valid_8 @[src/main/scala/MatMul.scala 87:26]
    macs_0_9.clock <= clock
    macs_0_9.reset <= reset
    macs_0_9.io_in_a <= macs_0_8.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_0_9.io_in_c <= UInt<16>("h0") @[src/main/scala/MatMul.scala 103:22]
    macs_0_9.io_in_w <= io_in_W_9 @[src/main/scala/MatMul.scala 79:22]
    macs_0_9.io_in_prop_w <= io_in_Prop_W_9 @[src/main/scala/MatMul.scala 95:27]
    macs_0_9.io_in_valid <= io_in_Valid_9 @[src/main/scala/MatMul.scala 87:26]
    macs_0_10.clock <= clock
    macs_0_10.reset <= reset
    macs_0_10.io_in_a <= macs_0_9.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_0_10.io_in_c <= UInt<16>("h0") @[src/main/scala/MatMul.scala 103:22]
    macs_0_10.io_in_w <= io_in_W_10 @[src/main/scala/MatMul.scala 79:22]
    macs_0_10.io_in_prop_w <= io_in_Prop_W_10 @[src/main/scala/MatMul.scala 95:27]
    macs_0_10.io_in_valid <= io_in_Valid_10 @[src/main/scala/MatMul.scala 87:26]
    macs_0_11.clock <= clock
    macs_0_11.reset <= reset
    macs_0_11.io_in_a <= macs_0_10.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_0_11.io_in_c <= UInt<16>("h0") @[src/main/scala/MatMul.scala 103:22]
    macs_0_11.io_in_w <= io_in_W_11 @[src/main/scala/MatMul.scala 79:22]
    macs_0_11.io_in_prop_w <= io_in_Prop_W_11 @[src/main/scala/MatMul.scala 95:27]
    macs_0_11.io_in_valid <= io_in_Valid_11 @[src/main/scala/MatMul.scala 87:26]
    macs_0_12.clock <= clock
    macs_0_12.reset <= reset
    macs_0_12.io_in_a <= macs_0_11.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_0_12.io_in_c <= UInt<16>("h0") @[src/main/scala/MatMul.scala 103:22]
    macs_0_12.io_in_w <= io_in_W_12 @[src/main/scala/MatMul.scala 79:22]
    macs_0_12.io_in_prop_w <= io_in_Prop_W_12 @[src/main/scala/MatMul.scala 95:27]
    macs_0_12.io_in_valid <= io_in_Valid_12 @[src/main/scala/MatMul.scala 87:26]
    macs_0_13.clock <= clock
    macs_0_13.reset <= reset
    macs_0_13.io_in_a <= macs_0_12.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_0_13.io_in_c <= UInt<16>("h0") @[src/main/scala/MatMul.scala 103:22]
    macs_0_13.io_in_w <= io_in_W_13 @[src/main/scala/MatMul.scala 79:22]
    macs_0_13.io_in_prop_w <= io_in_Prop_W_13 @[src/main/scala/MatMul.scala 95:27]
    macs_0_13.io_in_valid <= io_in_Valid_13 @[src/main/scala/MatMul.scala 87:26]
    macs_0_14.clock <= clock
    macs_0_14.reset <= reset
    macs_0_14.io_in_a <= macs_0_13.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_0_14.io_in_c <= UInt<16>("h0") @[src/main/scala/MatMul.scala 103:22]
    macs_0_14.io_in_w <= io_in_W_14 @[src/main/scala/MatMul.scala 79:22]
    macs_0_14.io_in_prop_w <= io_in_Prop_W_14 @[src/main/scala/MatMul.scala 95:27]
    macs_0_14.io_in_valid <= io_in_Valid_14 @[src/main/scala/MatMul.scala 87:26]
    macs_0_15.clock <= clock
    macs_0_15.reset <= reset
    macs_0_15.io_in_a <= macs_0_14.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_0_15.io_in_c <= UInt<16>("h0") @[src/main/scala/MatMul.scala 103:22]
    macs_0_15.io_in_w <= io_in_W_15 @[src/main/scala/MatMul.scala 79:22]
    macs_0_15.io_in_prop_w <= io_in_Prop_W_15 @[src/main/scala/MatMul.scala 95:27]
    macs_0_15.io_in_valid <= io_in_Valid_15 @[src/main/scala/MatMul.scala 87:26]
    macs_1_0.clock <= clock
    macs_1_0.reset <= reset
    macs_1_0.io_in_a <= io_in_A_1 @[src/main/scala/MatMul.scala 71:21]
    macs_1_0.io_in_c <= macs_0_0.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_1_0.io_in_w <= macs_0_0.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_1_0.io_in_prop_w <= macs_0_0.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_1_0.io_in_valid <= macs_0_0.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_1_1.clock <= clock
    macs_1_1.reset <= reset
    macs_1_1.io_in_a <= macs_1_0.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_1_1.io_in_c <= macs_0_1.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_1_1.io_in_w <= macs_0_1.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_1_1.io_in_prop_w <= macs_0_1.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_1_1.io_in_valid <= macs_0_1.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_1_2.clock <= clock
    macs_1_2.reset <= reset
    macs_1_2.io_in_a <= macs_1_1.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_1_2.io_in_c <= macs_0_2.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_1_2.io_in_w <= macs_0_2.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_1_2.io_in_prop_w <= macs_0_2.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_1_2.io_in_valid <= macs_0_2.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_1_3.clock <= clock
    macs_1_3.reset <= reset
    macs_1_3.io_in_a <= macs_1_2.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_1_3.io_in_c <= macs_0_3.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_1_3.io_in_w <= macs_0_3.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_1_3.io_in_prop_w <= macs_0_3.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_1_3.io_in_valid <= macs_0_3.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_1_4.clock <= clock
    macs_1_4.reset <= reset
    macs_1_4.io_in_a <= macs_1_3.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_1_4.io_in_c <= macs_0_4.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_1_4.io_in_w <= macs_0_4.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_1_4.io_in_prop_w <= macs_0_4.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_1_4.io_in_valid <= macs_0_4.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_1_5.clock <= clock
    macs_1_5.reset <= reset
    macs_1_5.io_in_a <= macs_1_4.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_1_5.io_in_c <= macs_0_5.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_1_5.io_in_w <= macs_0_5.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_1_5.io_in_prop_w <= macs_0_5.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_1_5.io_in_valid <= macs_0_5.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_1_6.clock <= clock
    macs_1_6.reset <= reset
    macs_1_6.io_in_a <= macs_1_5.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_1_6.io_in_c <= macs_0_6.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_1_6.io_in_w <= macs_0_6.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_1_6.io_in_prop_w <= macs_0_6.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_1_6.io_in_valid <= macs_0_6.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_1_7.clock <= clock
    macs_1_7.reset <= reset
    macs_1_7.io_in_a <= macs_1_6.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_1_7.io_in_c <= macs_0_7.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_1_7.io_in_w <= macs_0_7.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_1_7.io_in_prop_w <= macs_0_7.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_1_7.io_in_valid <= macs_0_7.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_1_8.clock <= clock
    macs_1_8.reset <= reset
    macs_1_8.io_in_a <= macs_1_7.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_1_8.io_in_c <= macs_0_8.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_1_8.io_in_w <= macs_0_8.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_1_8.io_in_prop_w <= macs_0_8.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_1_8.io_in_valid <= macs_0_8.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_1_9.clock <= clock
    macs_1_9.reset <= reset
    macs_1_9.io_in_a <= macs_1_8.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_1_9.io_in_c <= macs_0_9.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_1_9.io_in_w <= macs_0_9.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_1_9.io_in_prop_w <= macs_0_9.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_1_9.io_in_valid <= macs_0_9.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_1_10.clock <= clock
    macs_1_10.reset <= reset
    macs_1_10.io_in_a <= macs_1_9.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_1_10.io_in_c <= macs_0_10.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_1_10.io_in_w <= macs_0_10.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_1_10.io_in_prop_w <= macs_0_10.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_1_10.io_in_valid <= macs_0_10.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_1_11.clock <= clock
    macs_1_11.reset <= reset
    macs_1_11.io_in_a <= macs_1_10.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_1_11.io_in_c <= macs_0_11.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_1_11.io_in_w <= macs_0_11.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_1_11.io_in_prop_w <= macs_0_11.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_1_11.io_in_valid <= macs_0_11.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_1_12.clock <= clock
    macs_1_12.reset <= reset
    macs_1_12.io_in_a <= macs_1_11.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_1_12.io_in_c <= macs_0_12.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_1_12.io_in_w <= macs_0_12.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_1_12.io_in_prop_w <= macs_0_12.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_1_12.io_in_valid <= macs_0_12.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_1_13.clock <= clock
    macs_1_13.reset <= reset
    macs_1_13.io_in_a <= macs_1_12.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_1_13.io_in_c <= macs_0_13.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_1_13.io_in_w <= macs_0_13.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_1_13.io_in_prop_w <= macs_0_13.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_1_13.io_in_valid <= macs_0_13.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_1_14.clock <= clock
    macs_1_14.reset <= reset
    macs_1_14.io_in_a <= macs_1_13.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_1_14.io_in_c <= macs_0_14.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_1_14.io_in_w <= macs_0_14.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_1_14.io_in_prop_w <= macs_0_14.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_1_14.io_in_valid <= macs_0_14.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_1_15.clock <= clock
    macs_1_15.reset <= reset
    macs_1_15.io_in_a <= macs_1_14.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_1_15.io_in_c <= macs_0_15.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_1_15.io_in_w <= macs_0_15.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_1_15.io_in_prop_w <= macs_0_15.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_1_15.io_in_valid <= macs_0_15.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_2_0.clock <= clock
    macs_2_0.reset <= reset
    macs_2_0.io_in_a <= io_in_A_2 @[src/main/scala/MatMul.scala 71:21]
    macs_2_0.io_in_c <= macs_1_0.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_2_0.io_in_w <= macs_1_0.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_2_0.io_in_prop_w <= macs_1_0.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_2_0.io_in_valid <= macs_1_0.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_2_1.clock <= clock
    macs_2_1.reset <= reset
    macs_2_1.io_in_a <= macs_2_0.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_2_1.io_in_c <= macs_1_1.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_2_1.io_in_w <= macs_1_1.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_2_1.io_in_prop_w <= macs_1_1.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_2_1.io_in_valid <= macs_1_1.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_2_2.clock <= clock
    macs_2_2.reset <= reset
    macs_2_2.io_in_a <= macs_2_1.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_2_2.io_in_c <= macs_1_2.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_2_2.io_in_w <= macs_1_2.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_2_2.io_in_prop_w <= macs_1_2.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_2_2.io_in_valid <= macs_1_2.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_2_3.clock <= clock
    macs_2_3.reset <= reset
    macs_2_3.io_in_a <= macs_2_2.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_2_3.io_in_c <= macs_1_3.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_2_3.io_in_w <= macs_1_3.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_2_3.io_in_prop_w <= macs_1_3.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_2_3.io_in_valid <= macs_1_3.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_2_4.clock <= clock
    macs_2_4.reset <= reset
    macs_2_4.io_in_a <= macs_2_3.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_2_4.io_in_c <= macs_1_4.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_2_4.io_in_w <= macs_1_4.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_2_4.io_in_prop_w <= macs_1_4.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_2_4.io_in_valid <= macs_1_4.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_2_5.clock <= clock
    macs_2_5.reset <= reset
    macs_2_5.io_in_a <= macs_2_4.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_2_5.io_in_c <= macs_1_5.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_2_5.io_in_w <= macs_1_5.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_2_5.io_in_prop_w <= macs_1_5.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_2_5.io_in_valid <= macs_1_5.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_2_6.clock <= clock
    macs_2_6.reset <= reset
    macs_2_6.io_in_a <= macs_2_5.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_2_6.io_in_c <= macs_1_6.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_2_6.io_in_w <= macs_1_6.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_2_6.io_in_prop_w <= macs_1_6.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_2_6.io_in_valid <= macs_1_6.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_2_7.clock <= clock
    macs_2_7.reset <= reset
    macs_2_7.io_in_a <= macs_2_6.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_2_7.io_in_c <= macs_1_7.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_2_7.io_in_w <= macs_1_7.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_2_7.io_in_prop_w <= macs_1_7.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_2_7.io_in_valid <= macs_1_7.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_2_8.clock <= clock
    macs_2_8.reset <= reset
    macs_2_8.io_in_a <= macs_2_7.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_2_8.io_in_c <= macs_1_8.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_2_8.io_in_w <= macs_1_8.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_2_8.io_in_prop_w <= macs_1_8.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_2_8.io_in_valid <= macs_1_8.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_2_9.clock <= clock
    macs_2_9.reset <= reset
    macs_2_9.io_in_a <= macs_2_8.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_2_9.io_in_c <= macs_1_9.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_2_9.io_in_w <= macs_1_9.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_2_9.io_in_prop_w <= macs_1_9.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_2_9.io_in_valid <= macs_1_9.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_2_10.clock <= clock
    macs_2_10.reset <= reset
    macs_2_10.io_in_a <= macs_2_9.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_2_10.io_in_c <= macs_1_10.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_2_10.io_in_w <= macs_1_10.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_2_10.io_in_prop_w <= macs_1_10.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_2_10.io_in_valid <= macs_1_10.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_2_11.clock <= clock
    macs_2_11.reset <= reset
    macs_2_11.io_in_a <= macs_2_10.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_2_11.io_in_c <= macs_1_11.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_2_11.io_in_w <= macs_1_11.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_2_11.io_in_prop_w <= macs_1_11.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_2_11.io_in_valid <= macs_1_11.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_2_12.clock <= clock
    macs_2_12.reset <= reset
    macs_2_12.io_in_a <= macs_2_11.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_2_12.io_in_c <= macs_1_12.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_2_12.io_in_w <= macs_1_12.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_2_12.io_in_prop_w <= macs_1_12.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_2_12.io_in_valid <= macs_1_12.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_2_13.clock <= clock
    macs_2_13.reset <= reset
    macs_2_13.io_in_a <= macs_2_12.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_2_13.io_in_c <= macs_1_13.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_2_13.io_in_w <= macs_1_13.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_2_13.io_in_prop_w <= macs_1_13.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_2_13.io_in_valid <= macs_1_13.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_2_14.clock <= clock
    macs_2_14.reset <= reset
    macs_2_14.io_in_a <= macs_2_13.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_2_14.io_in_c <= macs_1_14.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_2_14.io_in_w <= macs_1_14.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_2_14.io_in_prop_w <= macs_1_14.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_2_14.io_in_valid <= macs_1_14.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_2_15.clock <= clock
    macs_2_15.reset <= reset
    macs_2_15.io_in_a <= macs_2_14.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_2_15.io_in_c <= macs_1_15.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_2_15.io_in_w <= macs_1_15.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_2_15.io_in_prop_w <= macs_1_15.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_2_15.io_in_valid <= macs_1_15.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_3_0.clock <= clock
    macs_3_0.reset <= reset
    macs_3_0.io_in_a <= io_in_A_3 @[src/main/scala/MatMul.scala 71:21]
    macs_3_0.io_in_c <= macs_2_0.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_3_0.io_in_w <= macs_2_0.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_3_0.io_in_prop_w <= macs_2_0.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_3_0.io_in_valid <= macs_2_0.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_3_1.clock <= clock
    macs_3_1.reset <= reset
    macs_3_1.io_in_a <= macs_3_0.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_3_1.io_in_c <= macs_2_1.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_3_1.io_in_w <= macs_2_1.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_3_1.io_in_prop_w <= macs_2_1.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_3_1.io_in_valid <= macs_2_1.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_3_2.clock <= clock
    macs_3_2.reset <= reset
    macs_3_2.io_in_a <= macs_3_1.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_3_2.io_in_c <= macs_2_2.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_3_2.io_in_w <= macs_2_2.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_3_2.io_in_prop_w <= macs_2_2.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_3_2.io_in_valid <= macs_2_2.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_3_3.clock <= clock
    macs_3_3.reset <= reset
    macs_3_3.io_in_a <= macs_3_2.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_3_3.io_in_c <= macs_2_3.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_3_3.io_in_w <= macs_2_3.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_3_3.io_in_prop_w <= macs_2_3.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_3_3.io_in_valid <= macs_2_3.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_3_4.clock <= clock
    macs_3_4.reset <= reset
    macs_3_4.io_in_a <= macs_3_3.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_3_4.io_in_c <= macs_2_4.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_3_4.io_in_w <= macs_2_4.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_3_4.io_in_prop_w <= macs_2_4.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_3_4.io_in_valid <= macs_2_4.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_3_5.clock <= clock
    macs_3_5.reset <= reset
    macs_3_5.io_in_a <= macs_3_4.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_3_5.io_in_c <= macs_2_5.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_3_5.io_in_w <= macs_2_5.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_3_5.io_in_prop_w <= macs_2_5.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_3_5.io_in_valid <= macs_2_5.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_3_6.clock <= clock
    macs_3_6.reset <= reset
    macs_3_6.io_in_a <= macs_3_5.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_3_6.io_in_c <= macs_2_6.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_3_6.io_in_w <= macs_2_6.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_3_6.io_in_prop_w <= macs_2_6.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_3_6.io_in_valid <= macs_2_6.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_3_7.clock <= clock
    macs_3_7.reset <= reset
    macs_3_7.io_in_a <= macs_3_6.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_3_7.io_in_c <= macs_2_7.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_3_7.io_in_w <= macs_2_7.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_3_7.io_in_prop_w <= macs_2_7.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_3_7.io_in_valid <= macs_2_7.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_3_8.clock <= clock
    macs_3_8.reset <= reset
    macs_3_8.io_in_a <= macs_3_7.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_3_8.io_in_c <= macs_2_8.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_3_8.io_in_w <= macs_2_8.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_3_8.io_in_prop_w <= macs_2_8.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_3_8.io_in_valid <= macs_2_8.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_3_9.clock <= clock
    macs_3_9.reset <= reset
    macs_3_9.io_in_a <= macs_3_8.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_3_9.io_in_c <= macs_2_9.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_3_9.io_in_w <= macs_2_9.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_3_9.io_in_prop_w <= macs_2_9.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_3_9.io_in_valid <= macs_2_9.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_3_10.clock <= clock
    macs_3_10.reset <= reset
    macs_3_10.io_in_a <= macs_3_9.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_3_10.io_in_c <= macs_2_10.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_3_10.io_in_w <= macs_2_10.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_3_10.io_in_prop_w <= macs_2_10.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_3_10.io_in_valid <= macs_2_10.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_3_11.clock <= clock
    macs_3_11.reset <= reset
    macs_3_11.io_in_a <= macs_3_10.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_3_11.io_in_c <= macs_2_11.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_3_11.io_in_w <= macs_2_11.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_3_11.io_in_prop_w <= macs_2_11.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_3_11.io_in_valid <= macs_2_11.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_3_12.clock <= clock
    macs_3_12.reset <= reset
    macs_3_12.io_in_a <= macs_3_11.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_3_12.io_in_c <= macs_2_12.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_3_12.io_in_w <= macs_2_12.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_3_12.io_in_prop_w <= macs_2_12.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_3_12.io_in_valid <= macs_2_12.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_3_13.clock <= clock
    macs_3_13.reset <= reset
    macs_3_13.io_in_a <= macs_3_12.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_3_13.io_in_c <= macs_2_13.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_3_13.io_in_w <= macs_2_13.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_3_13.io_in_prop_w <= macs_2_13.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_3_13.io_in_valid <= macs_2_13.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_3_14.clock <= clock
    macs_3_14.reset <= reset
    macs_3_14.io_in_a <= macs_3_13.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_3_14.io_in_c <= macs_2_14.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_3_14.io_in_w <= macs_2_14.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_3_14.io_in_prop_w <= macs_2_14.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_3_14.io_in_valid <= macs_2_14.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_3_15.clock <= clock
    macs_3_15.reset <= reset
    macs_3_15.io_in_a <= macs_3_14.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_3_15.io_in_c <= macs_2_15.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_3_15.io_in_w <= macs_2_15.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_3_15.io_in_prop_w <= macs_2_15.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_3_15.io_in_valid <= macs_2_15.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_4_0.clock <= clock
    macs_4_0.reset <= reset
    macs_4_0.io_in_a <= io_in_A_4 @[src/main/scala/MatMul.scala 71:21]
    macs_4_0.io_in_c <= macs_3_0.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_4_0.io_in_w <= macs_3_0.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_4_0.io_in_prop_w <= macs_3_0.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_4_0.io_in_valid <= macs_3_0.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_4_1.clock <= clock
    macs_4_1.reset <= reset
    macs_4_1.io_in_a <= macs_4_0.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_4_1.io_in_c <= macs_3_1.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_4_1.io_in_w <= macs_3_1.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_4_1.io_in_prop_w <= macs_3_1.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_4_1.io_in_valid <= macs_3_1.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_4_2.clock <= clock
    macs_4_2.reset <= reset
    macs_4_2.io_in_a <= macs_4_1.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_4_2.io_in_c <= macs_3_2.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_4_2.io_in_w <= macs_3_2.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_4_2.io_in_prop_w <= macs_3_2.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_4_2.io_in_valid <= macs_3_2.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_4_3.clock <= clock
    macs_4_3.reset <= reset
    macs_4_3.io_in_a <= macs_4_2.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_4_3.io_in_c <= macs_3_3.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_4_3.io_in_w <= macs_3_3.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_4_3.io_in_prop_w <= macs_3_3.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_4_3.io_in_valid <= macs_3_3.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_4_4.clock <= clock
    macs_4_4.reset <= reset
    macs_4_4.io_in_a <= macs_4_3.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_4_4.io_in_c <= macs_3_4.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_4_4.io_in_w <= macs_3_4.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_4_4.io_in_prop_w <= macs_3_4.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_4_4.io_in_valid <= macs_3_4.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_4_5.clock <= clock
    macs_4_5.reset <= reset
    macs_4_5.io_in_a <= macs_4_4.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_4_5.io_in_c <= macs_3_5.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_4_5.io_in_w <= macs_3_5.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_4_5.io_in_prop_w <= macs_3_5.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_4_5.io_in_valid <= macs_3_5.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_4_6.clock <= clock
    macs_4_6.reset <= reset
    macs_4_6.io_in_a <= macs_4_5.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_4_6.io_in_c <= macs_3_6.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_4_6.io_in_w <= macs_3_6.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_4_6.io_in_prop_w <= macs_3_6.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_4_6.io_in_valid <= macs_3_6.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_4_7.clock <= clock
    macs_4_7.reset <= reset
    macs_4_7.io_in_a <= macs_4_6.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_4_7.io_in_c <= macs_3_7.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_4_7.io_in_w <= macs_3_7.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_4_7.io_in_prop_w <= macs_3_7.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_4_7.io_in_valid <= macs_3_7.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_4_8.clock <= clock
    macs_4_8.reset <= reset
    macs_4_8.io_in_a <= macs_4_7.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_4_8.io_in_c <= macs_3_8.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_4_8.io_in_w <= macs_3_8.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_4_8.io_in_prop_w <= macs_3_8.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_4_8.io_in_valid <= macs_3_8.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_4_9.clock <= clock
    macs_4_9.reset <= reset
    macs_4_9.io_in_a <= macs_4_8.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_4_9.io_in_c <= macs_3_9.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_4_9.io_in_w <= macs_3_9.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_4_9.io_in_prop_w <= macs_3_9.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_4_9.io_in_valid <= macs_3_9.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_4_10.clock <= clock
    macs_4_10.reset <= reset
    macs_4_10.io_in_a <= macs_4_9.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_4_10.io_in_c <= macs_3_10.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_4_10.io_in_w <= macs_3_10.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_4_10.io_in_prop_w <= macs_3_10.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_4_10.io_in_valid <= macs_3_10.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_4_11.clock <= clock
    macs_4_11.reset <= reset
    macs_4_11.io_in_a <= macs_4_10.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_4_11.io_in_c <= macs_3_11.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_4_11.io_in_w <= macs_3_11.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_4_11.io_in_prop_w <= macs_3_11.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_4_11.io_in_valid <= macs_3_11.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_4_12.clock <= clock
    macs_4_12.reset <= reset
    macs_4_12.io_in_a <= macs_4_11.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_4_12.io_in_c <= macs_3_12.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_4_12.io_in_w <= macs_3_12.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_4_12.io_in_prop_w <= macs_3_12.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_4_12.io_in_valid <= macs_3_12.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_4_13.clock <= clock
    macs_4_13.reset <= reset
    macs_4_13.io_in_a <= macs_4_12.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_4_13.io_in_c <= macs_3_13.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_4_13.io_in_w <= macs_3_13.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_4_13.io_in_prop_w <= macs_3_13.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_4_13.io_in_valid <= macs_3_13.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_4_14.clock <= clock
    macs_4_14.reset <= reset
    macs_4_14.io_in_a <= macs_4_13.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_4_14.io_in_c <= macs_3_14.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_4_14.io_in_w <= macs_3_14.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_4_14.io_in_prop_w <= macs_3_14.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_4_14.io_in_valid <= macs_3_14.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_4_15.clock <= clock
    macs_4_15.reset <= reset
    macs_4_15.io_in_a <= macs_4_14.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_4_15.io_in_c <= macs_3_15.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_4_15.io_in_w <= macs_3_15.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_4_15.io_in_prop_w <= macs_3_15.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_4_15.io_in_valid <= macs_3_15.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_5_0.clock <= clock
    macs_5_0.reset <= reset
    macs_5_0.io_in_a <= io_in_A_5 @[src/main/scala/MatMul.scala 71:21]
    macs_5_0.io_in_c <= macs_4_0.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_5_0.io_in_w <= macs_4_0.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_5_0.io_in_prop_w <= macs_4_0.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_5_0.io_in_valid <= macs_4_0.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_5_1.clock <= clock
    macs_5_1.reset <= reset
    macs_5_1.io_in_a <= macs_5_0.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_5_1.io_in_c <= macs_4_1.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_5_1.io_in_w <= macs_4_1.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_5_1.io_in_prop_w <= macs_4_1.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_5_1.io_in_valid <= macs_4_1.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_5_2.clock <= clock
    macs_5_2.reset <= reset
    macs_5_2.io_in_a <= macs_5_1.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_5_2.io_in_c <= macs_4_2.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_5_2.io_in_w <= macs_4_2.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_5_2.io_in_prop_w <= macs_4_2.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_5_2.io_in_valid <= macs_4_2.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_5_3.clock <= clock
    macs_5_3.reset <= reset
    macs_5_3.io_in_a <= macs_5_2.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_5_3.io_in_c <= macs_4_3.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_5_3.io_in_w <= macs_4_3.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_5_3.io_in_prop_w <= macs_4_3.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_5_3.io_in_valid <= macs_4_3.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_5_4.clock <= clock
    macs_5_4.reset <= reset
    macs_5_4.io_in_a <= macs_5_3.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_5_4.io_in_c <= macs_4_4.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_5_4.io_in_w <= macs_4_4.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_5_4.io_in_prop_w <= macs_4_4.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_5_4.io_in_valid <= macs_4_4.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_5_5.clock <= clock
    macs_5_5.reset <= reset
    macs_5_5.io_in_a <= macs_5_4.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_5_5.io_in_c <= macs_4_5.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_5_5.io_in_w <= macs_4_5.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_5_5.io_in_prop_w <= macs_4_5.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_5_5.io_in_valid <= macs_4_5.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_5_6.clock <= clock
    macs_5_6.reset <= reset
    macs_5_6.io_in_a <= macs_5_5.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_5_6.io_in_c <= macs_4_6.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_5_6.io_in_w <= macs_4_6.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_5_6.io_in_prop_w <= macs_4_6.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_5_6.io_in_valid <= macs_4_6.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_5_7.clock <= clock
    macs_5_7.reset <= reset
    macs_5_7.io_in_a <= macs_5_6.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_5_7.io_in_c <= macs_4_7.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_5_7.io_in_w <= macs_4_7.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_5_7.io_in_prop_w <= macs_4_7.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_5_7.io_in_valid <= macs_4_7.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_5_8.clock <= clock
    macs_5_8.reset <= reset
    macs_5_8.io_in_a <= macs_5_7.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_5_8.io_in_c <= macs_4_8.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_5_8.io_in_w <= macs_4_8.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_5_8.io_in_prop_w <= macs_4_8.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_5_8.io_in_valid <= macs_4_8.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_5_9.clock <= clock
    macs_5_9.reset <= reset
    macs_5_9.io_in_a <= macs_5_8.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_5_9.io_in_c <= macs_4_9.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_5_9.io_in_w <= macs_4_9.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_5_9.io_in_prop_w <= macs_4_9.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_5_9.io_in_valid <= macs_4_9.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_5_10.clock <= clock
    macs_5_10.reset <= reset
    macs_5_10.io_in_a <= macs_5_9.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_5_10.io_in_c <= macs_4_10.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_5_10.io_in_w <= macs_4_10.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_5_10.io_in_prop_w <= macs_4_10.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_5_10.io_in_valid <= macs_4_10.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_5_11.clock <= clock
    macs_5_11.reset <= reset
    macs_5_11.io_in_a <= macs_5_10.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_5_11.io_in_c <= macs_4_11.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_5_11.io_in_w <= macs_4_11.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_5_11.io_in_prop_w <= macs_4_11.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_5_11.io_in_valid <= macs_4_11.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_5_12.clock <= clock
    macs_5_12.reset <= reset
    macs_5_12.io_in_a <= macs_5_11.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_5_12.io_in_c <= macs_4_12.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_5_12.io_in_w <= macs_4_12.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_5_12.io_in_prop_w <= macs_4_12.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_5_12.io_in_valid <= macs_4_12.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_5_13.clock <= clock
    macs_5_13.reset <= reset
    macs_5_13.io_in_a <= macs_5_12.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_5_13.io_in_c <= macs_4_13.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_5_13.io_in_w <= macs_4_13.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_5_13.io_in_prop_w <= macs_4_13.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_5_13.io_in_valid <= macs_4_13.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_5_14.clock <= clock
    macs_5_14.reset <= reset
    macs_5_14.io_in_a <= macs_5_13.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_5_14.io_in_c <= macs_4_14.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_5_14.io_in_w <= macs_4_14.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_5_14.io_in_prop_w <= macs_4_14.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_5_14.io_in_valid <= macs_4_14.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_5_15.clock <= clock
    macs_5_15.reset <= reset
    macs_5_15.io_in_a <= macs_5_14.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_5_15.io_in_c <= macs_4_15.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_5_15.io_in_w <= macs_4_15.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_5_15.io_in_prop_w <= macs_4_15.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_5_15.io_in_valid <= macs_4_15.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_6_0.clock <= clock
    macs_6_0.reset <= reset
    macs_6_0.io_in_a <= io_in_A_6 @[src/main/scala/MatMul.scala 71:21]
    macs_6_0.io_in_c <= macs_5_0.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_6_0.io_in_w <= macs_5_0.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_6_0.io_in_prop_w <= macs_5_0.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_6_0.io_in_valid <= macs_5_0.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_6_1.clock <= clock
    macs_6_1.reset <= reset
    macs_6_1.io_in_a <= macs_6_0.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_6_1.io_in_c <= macs_5_1.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_6_1.io_in_w <= macs_5_1.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_6_1.io_in_prop_w <= macs_5_1.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_6_1.io_in_valid <= macs_5_1.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_6_2.clock <= clock
    macs_6_2.reset <= reset
    macs_6_2.io_in_a <= macs_6_1.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_6_2.io_in_c <= macs_5_2.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_6_2.io_in_w <= macs_5_2.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_6_2.io_in_prop_w <= macs_5_2.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_6_2.io_in_valid <= macs_5_2.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_6_3.clock <= clock
    macs_6_3.reset <= reset
    macs_6_3.io_in_a <= macs_6_2.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_6_3.io_in_c <= macs_5_3.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_6_3.io_in_w <= macs_5_3.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_6_3.io_in_prop_w <= macs_5_3.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_6_3.io_in_valid <= macs_5_3.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_6_4.clock <= clock
    macs_6_4.reset <= reset
    macs_6_4.io_in_a <= macs_6_3.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_6_4.io_in_c <= macs_5_4.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_6_4.io_in_w <= macs_5_4.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_6_4.io_in_prop_w <= macs_5_4.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_6_4.io_in_valid <= macs_5_4.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_6_5.clock <= clock
    macs_6_5.reset <= reset
    macs_6_5.io_in_a <= macs_6_4.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_6_5.io_in_c <= macs_5_5.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_6_5.io_in_w <= macs_5_5.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_6_5.io_in_prop_w <= macs_5_5.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_6_5.io_in_valid <= macs_5_5.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_6_6.clock <= clock
    macs_6_6.reset <= reset
    macs_6_6.io_in_a <= macs_6_5.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_6_6.io_in_c <= macs_5_6.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_6_6.io_in_w <= macs_5_6.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_6_6.io_in_prop_w <= macs_5_6.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_6_6.io_in_valid <= macs_5_6.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_6_7.clock <= clock
    macs_6_7.reset <= reset
    macs_6_7.io_in_a <= macs_6_6.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_6_7.io_in_c <= macs_5_7.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_6_7.io_in_w <= macs_5_7.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_6_7.io_in_prop_w <= macs_5_7.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_6_7.io_in_valid <= macs_5_7.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_6_8.clock <= clock
    macs_6_8.reset <= reset
    macs_6_8.io_in_a <= macs_6_7.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_6_8.io_in_c <= macs_5_8.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_6_8.io_in_w <= macs_5_8.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_6_8.io_in_prop_w <= macs_5_8.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_6_8.io_in_valid <= macs_5_8.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_6_9.clock <= clock
    macs_6_9.reset <= reset
    macs_6_9.io_in_a <= macs_6_8.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_6_9.io_in_c <= macs_5_9.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_6_9.io_in_w <= macs_5_9.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_6_9.io_in_prop_w <= macs_5_9.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_6_9.io_in_valid <= macs_5_9.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_6_10.clock <= clock
    macs_6_10.reset <= reset
    macs_6_10.io_in_a <= macs_6_9.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_6_10.io_in_c <= macs_5_10.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_6_10.io_in_w <= macs_5_10.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_6_10.io_in_prop_w <= macs_5_10.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_6_10.io_in_valid <= macs_5_10.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_6_11.clock <= clock
    macs_6_11.reset <= reset
    macs_6_11.io_in_a <= macs_6_10.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_6_11.io_in_c <= macs_5_11.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_6_11.io_in_w <= macs_5_11.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_6_11.io_in_prop_w <= macs_5_11.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_6_11.io_in_valid <= macs_5_11.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_6_12.clock <= clock
    macs_6_12.reset <= reset
    macs_6_12.io_in_a <= macs_6_11.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_6_12.io_in_c <= macs_5_12.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_6_12.io_in_w <= macs_5_12.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_6_12.io_in_prop_w <= macs_5_12.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_6_12.io_in_valid <= macs_5_12.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_6_13.clock <= clock
    macs_6_13.reset <= reset
    macs_6_13.io_in_a <= macs_6_12.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_6_13.io_in_c <= macs_5_13.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_6_13.io_in_w <= macs_5_13.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_6_13.io_in_prop_w <= macs_5_13.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_6_13.io_in_valid <= macs_5_13.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_6_14.clock <= clock
    macs_6_14.reset <= reset
    macs_6_14.io_in_a <= macs_6_13.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_6_14.io_in_c <= macs_5_14.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_6_14.io_in_w <= macs_5_14.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_6_14.io_in_prop_w <= macs_5_14.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_6_14.io_in_valid <= macs_5_14.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_6_15.clock <= clock
    macs_6_15.reset <= reset
    macs_6_15.io_in_a <= macs_6_14.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_6_15.io_in_c <= macs_5_15.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_6_15.io_in_w <= macs_5_15.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_6_15.io_in_prop_w <= macs_5_15.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_6_15.io_in_valid <= macs_5_15.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_7_0.clock <= clock
    macs_7_0.reset <= reset
    macs_7_0.io_in_a <= io_in_A_7 @[src/main/scala/MatMul.scala 71:21]
    macs_7_0.io_in_c <= macs_6_0.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_7_0.io_in_w <= macs_6_0.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_7_0.io_in_prop_w <= macs_6_0.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_7_0.io_in_valid <= macs_6_0.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_7_1.clock <= clock
    macs_7_1.reset <= reset
    macs_7_1.io_in_a <= macs_7_0.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_7_1.io_in_c <= macs_6_1.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_7_1.io_in_w <= macs_6_1.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_7_1.io_in_prop_w <= macs_6_1.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_7_1.io_in_valid <= macs_6_1.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_7_2.clock <= clock
    macs_7_2.reset <= reset
    macs_7_2.io_in_a <= macs_7_1.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_7_2.io_in_c <= macs_6_2.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_7_2.io_in_w <= macs_6_2.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_7_2.io_in_prop_w <= macs_6_2.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_7_2.io_in_valid <= macs_6_2.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_7_3.clock <= clock
    macs_7_3.reset <= reset
    macs_7_3.io_in_a <= macs_7_2.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_7_3.io_in_c <= macs_6_3.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_7_3.io_in_w <= macs_6_3.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_7_3.io_in_prop_w <= macs_6_3.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_7_3.io_in_valid <= macs_6_3.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_7_4.clock <= clock
    macs_7_4.reset <= reset
    macs_7_4.io_in_a <= macs_7_3.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_7_4.io_in_c <= macs_6_4.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_7_4.io_in_w <= macs_6_4.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_7_4.io_in_prop_w <= macs_6_4.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_7_4.io_in_valid <= macs_6_4.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_7_5.clock <= clock
    macs_7_5.reset <= reset
    macs_7_5.io_in_a <= macs_7_4.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_7_5.io_in_c <= macs_6_5.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_7_5.io_in_w <= macs_6_5.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_7_5.io_in_prop_w <= macs_6_5.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_7_5.io_in_valid <= macs_6_5.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_7_6.clock <= clock
    macs_7_6.reset <= reset
    macs_7_6.io_in_a <= macs_7_5.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_7_6.io_in_c <= macs_6_6.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_7_6.io_in_w <= macs_6_6.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_7_6.io_in_prop_w <= macs_6_6.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_7_6.io_in_valid <= macs_6_6.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_7_7.clock <= clock
    macs_7_7.reset <= reset
    macs_7_7.io_in_a <= macs_7_6.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_7_7.io_in_c <= macs_6_7.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_7_7.io_in_w <= macs_6_7.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_7_7.io_in_prop_w <= macs_6_7.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_7_7.io_in_valid <= macs_6_7.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_7_8.clock <= clock
    macs_7_8.reset <= reset
    macs_7_8.io_in_a <= macs_7_7.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_7_8.io_in_c <= macs_6_8.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_7_8.io_in_w <= macs_6_8.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_7_8.io_in_prop_w <= macs_6_8.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_7_8.io_in_valid <= macs_6_8.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_7_9.clock <= clock
    macs_7_9.reset <= reset
    macs_7_9.io_in_a <= macs_7_8.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_7_9.io_in_c <= macs_6_9.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_7_9.io_in_w <= macs_6_9.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_7_9.io_in_prop_w <= macs_6_9.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_7_9.io_in_valid <= macs_6_9.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_7_10.clock <= clock
    macs_7_10.reset <= reset
    macs_7_10.io_in_a <= macs_7_9.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_7_10.io_in_c <= macs_6_10.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_7_10.io_in_w <= macs_6_10.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_7_10.io_in_prop_w <= macs_6_10.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_7_10.io_in_valid <= macs_6_10.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_7_11.clock <= clock
    macs_7_11.reset <= reset
    macs_7_11.io_in_a <= macs_7_10.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_7_11.io_in_c <= macs_6_11.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_7_11.io_in_w <= macs_6_11.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_7_11.io_in_prop_w <= macs_6_11.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_7_11.io_in_valid <= macs_6_11.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_7_12.clock <= clock
    macs_7_12.reset <= reset
    macs_7_12.io_in_a <= macs_7_11.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_7_12.io_in_c <= macs_6_12.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_7_12.io_in_w <= macs_6_12.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_7_12.io_in_prop_w <= macs_6_12.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_7_12.io_in_valid <= macs_6_12.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_7_13.clock <= clock
    macs_7_13.reset <= reset
    macs_7_13.io_in_a <= macs_7_12.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_7_13.io_in_c <= macs_6_13.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_7_13.io_in_w <= macs_6_13.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_7_13.io_in_prop_w <= macs_6_13.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_7_13.io_in_valid <= macs_6_13.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_7_14.clock <= clock
    macs_7_14.reset <= reset
    macs_7_14.io_in_a <= macs_7_13.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_7_14.io_in_c <= macs_6_14.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_7_14.io_in_w <= macs_6_14.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_7_14.io_in_prop_w <= macs_6_14.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_7_14.io_in_valid <= macs_6_14.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_7_15.clock <= clock
    macs_7_15.reset <= reset
    macs_7_15.io_in_a <= macs_7_14.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_7_15.io_in_c <= macs_6_15.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_7_15.io_in_w <= macs_6_15.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_7_15.io_in_prop_w <= macs_6_15.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_7_15.io_in_valid <= macs_6_15.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_8_0.clock <= clock
    macs_8_0.reset <= reset
    macs_8_0.io_in_a <= io_in_A_8 @[src/main/scala/MatMul.scala 71:21]
    macs_8_0.io_in_c <= macs_7_0.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_8_0.io_in_w <= macs_7_0.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_8_0.io_in_prop_w <= macs_7_0.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_8_0.io_in_valid <= macs_7_0.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_8_1.clock <= clock
    macs_8_1.reset <= reset
    macs_8_1.io_in_a <= macs_8_0.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_8_1.io_in_c <= macs_7_1.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_8_1.io_in_w <= macs_7_1.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_8_1.io_in_prop_w <= macs_7_1.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_8_1.io_in_valid <= macs_7_1.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_8_2.clock <= clock
    macs_8_2.reset <= reset
    macs_8_2.io_in_a <= macs_8_1.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_8_2.io_in_c <= macs_7_2.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_8_2.io_in_w <= macs_7_2.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_8_2.io_in_prop_w <= macs_7_2.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_8_2.io_in_valid <= macs_7_2.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_8_3.clock <= clock
    macs_8_3.reset <= reset
    macs_8_3.io_in_a <= macs_8_2.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_8_3.io_in_c <= macs_7_3.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_8_3.io_in_w <= macs_7_3.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_8_3.io_in_prop_w <= macs_7_3.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_8_3.io_in_valid <= macs_7_3.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_8_4.clock <= clock
    macs_8_4.reset <= reset
    macs_8_4.io_in_a <= macs_8_3.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_8_4.io_in_c <= macs_7_4.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_8_4.io_in_w <= macs_7_4.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_8_4.io_in_prop_w <= macs_7_4.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_8_4.io_in_valid <= macs_7_4.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_8_5.clock <= clock
    macs_8_5.reset <= reset
    macs_8_5.io_in_a <= macs_8_4.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_8_5.io_in_c <= macs_7_5.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_8_5.io_in_w <= macs_7_5.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_8_5.io_in_prop_w <= macs_7_5.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_8_5.io_in_valid <= macs_7_5.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_8_6.clock <= clock
    macs_8_6.reset <= reset
    macs_8_6.io_in_a <= macs_8_5.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_8_6.io_in_c <= macs_7_6.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_8_6.io_in_w <= macs_7_6.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_8_6.io_in_prop_w <= macs_7_6.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_8_6.io_in_valid <= macs_7_6.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_8_7.clock <= clock
    macs_8_7.reset <= reset
    macs_8_7.io_in_a <= macs_8_6.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_8_7.io_in_c <= macs_7_7.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_8_7.io_in_w <= macs_7_7.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_8_7.io_in_prop_w <= macs_7_7.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_8_7.io_in_valid <= macs_7_7.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_8_8.clock <= clock
    macs_8_8.reset <= reset
    macs_8_8.io_in_a <= macs_8_7.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_8_8.io_in_c <= macs_7_8.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_8_8.io_in_w <= macs_7_8.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_8_8.io_in_prop_w <= macs_7_8.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_8_8.io_in_valid <= macs_7_8.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_8_9.clock <= clock
    macs_8_9.reset <= reset
    macs_8_9.io_in_a <= macs_8_8.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_8_9.io_in_c <= macs_7_9.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_8_9.io_in_w <= macs_7_9.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_8_9.io_in_prop_w <= macs_7_9.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_8_9.io_in_valid <= macs_7_9.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_8_10.clock <= clock
    macs_8_10.reset <= reset
    macs_8_10.io_in_a <= macs_8_9.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_8_10.io_in_c <= macs_7_10.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_8_10.io_in_w <= macs_7_10.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_8_10.io_in_prop_w <= macs_7_10.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_8_10.io_in_valid <= macs_7_10.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_8_11.clock <= clock
    macs_8_11.reset <= reset
    macs_8_11.io_in_a <= macs_8_10.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_8_11.io_in_c <= macs_7_11.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_8_11.io_in_w <= macs_7_11.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_8_11.io_in_prop_w <= macs_7_11.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_8_11.io_in_valid <= macs_7_11.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_8_12.clock <= clock
    macs_8_12.reset <= reset
    macs_8_12.io_in_a <= macs_8_11.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_8_12.io_in_c <= macs_7_12.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_8_12.io_in_w <= macs_7_12.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_8_12.io_in_prop_w <= macs_7_12.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_8_12.io_in_valid <= macs_7_12.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_8_13.clock <= clock
    macs_8_13.reset <= reset
    macs_8_13.io_in_a <= macs_8_12.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_8_13.io_in_c <= macs_7_13.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_8_13.io_in_w <= macs_7_13.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_8_13.io_in_prop_w <= macs_7_13.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_8_13.io_in_valid <= macs_7_13.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_8_14.clock <= clock
    macs_8_14.reset <= reset
    macs_8_14.io_in_a <= macs_8_13.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_8_14.io_in_c <= macs_7_14.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_8_14.io_in_w <= macs_7_14.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_8_14.io_in_prop_w <= macs_7_14.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_8_14.io_in_valid <= macs_7_14.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_8_15.clock <= clock
    macs_8_15.reset <= reset
    macs_8_15.io_in_a <= macs_8_14.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_8_15.io_in_c <= macs_7_15.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_8_15.io_in_w <= macs_7_15.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_8_15.io_in_prop_w <= macs_7_15.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_8_15.io_in_valid <= macs_7_15.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_9_0.clock <= clock
    macs_9_0.reset <= reset
    macs_9_0.io_in_a <= io_in_A_9 @[src/main/scala/MatMul.scala 71:21]
    macs_9_0.io_in_c <= macs_8_0.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_9_0.io_in_w <= macs_8_0.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_9_0.io_in_prop_w <= macs_8_0.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_9_0.io_in_valid <= macs_8_0.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_9_1.clock <= clock
    macs_9_1.reset <= reset
    macs_9_1.io_in_a <= macs_9_0.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_9_1.io_in_c <= macs_8_1.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_9_1.io_in_w <= macs_8_1.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_9_1.io_in_prop_w <= macs_8_1.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_9_1.io_in_valid <= macs_8_1.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_9_2.clock <= clock
    macs_9_2.reset <= reset
    macs_9_2.io_in_a <= macs_9_1.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_9_2.io_in_c <= macs_8_2.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_9_2.io_in_w <= macs_8_2.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_9_2.io_in_prop_w <= macs_8_2.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_9_2.io_in_valid <= macs_8_2.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_9_3.clock <= clock
    macs_9_3.reset <= reset
    macs_9_3.io_in_a <= macs_9_2.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_9_3.io_in_c <= macs_8_3.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_9_3.io_in_w <= macs_8_3.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_9_3.io_in_prop_w <= macs_8_3.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_9_3.io_in_valid <= macs_8_3.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_9_4.clock <= clock
    macs_9_4.reset <= reset
    macs_9_4.io_in_a <= macs_9_3.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_9_4.io_in_c <= macs_8_4.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_9_4.io_in_w <= macs_8_4.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_9_4.io_in_prop_w <= macs_8_4.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_9_4.io_in_valid <= macs_8_4.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_9_5.clock <= clock
    macs_9_5.reset <= reset
    macs_9_5.io_in_a <= macs_9_4.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_9_5.io_in_c <= macs_8_5.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_9_5.io_in_w <= macs_8_5.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_9_5.io_in_prop_w <= macs_8_5.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_9_5.io_in_valid <= macs_8_5.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_9_6.clock <= clock
    macs_9_6.reset <= reset
    macs_9_6.io_in_a <= macs_9_5.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_9_6.io_in_c <= macs_8_6.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_9_6.io_in_w <= macs_8_6.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_9_6.io_in_prop_w <= macs_8_6.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_9_6.io_in_valid <= macs_8_6.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_9_7.clock <= clock
    macs_9_7.reset <= reset
    macs_9_7.io_in_a <= macs_9_6.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_9_7.io_in_c <= macs_8_7.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_9_7.io_in_w <= macs_8_7.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_9_7.io_in_prop_w <= macs_8_7.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_9_7.io_in_valid <= macs_8_7.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_9_8.clock <= clock
    macs_9_8.reset <= reset
    macs_9_8.io_in_a <= macs_9_7.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_9_8.io_in_c <= macs_8_8.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_9_8.io_in_w <= macs_8_8.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_9_8.io_in_prop_w <= macs_8_8.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_9_8.io_in_valid <= macs_8_8.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_9_9.clock <= clock
    macs_9_9.reset <= reset
    macs_9_9.io_in_a <= macs_9_8.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_9_9.io_in_c <= macs_8_9.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_9_9.io_in_w <= macs_8_9.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_9_9.io_in_prop_w <= macs_8_9.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_9_9.io_in_valid <= macs_8_9.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_9_10.clock <= clock
    macs_9_10.reset <= reset
    macs_9_10.io_in_a <= macs_9_9.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_9_10.io_in_c <= macs_8_10.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_9_10.io_in_w <= macs_8_10.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_9_10.io_in_prop_w <= macs_8_10.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_9_10.io_in_valid <= macs_8_10.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_9_11.clock <= clock
    macs_9_11.reset <= reset
    macs_9_11.io_in_a <= macs_9_10.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_9_11.io_in_c <= macs_8_11.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_9_11.io_in_w <= macs_8_11.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_9_11.io_in_prop_w <= macs_8_11.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_9_11.io_in_valid <= macs_8_11.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_9_12.clock <= clock
    macs_9_12.reset <= reset
    macs_9_12.io_in_a <= macs_9_11.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_9_12.io_in_c <= macs_8_12.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_9_12.io_in_w <= macs_8_12.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_9_12.io_in_prop_w <= macs_8_12.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_9_12.io_in_valid <= macs_8_12.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_9_13.clock <= clock
    macs_9_13.reset <= reset
    macs_9_13.io_in_a <= macs_9_12.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_9_13.io_in_c <= macs_8_13.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_9_13.io_in_w <= macs_8_13.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_9_13.io_in_prop_w <= macs_8_13.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_9_13.io_in_valid <= macs_8_13.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_9_14.clock <= clock
    macs_9_14.reset <= reset
    macs_9_14.io_in_a <= macs_9_13.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_9_14.io_in_c <= macs_8_14.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_9_14.io_in_w <= macs_8_14.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_9_14.io_in_prop_w <= macs_8_14.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_9_14.io_in_valid <= macs_8_14.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_9_15.clock <= clock
    macs_9_15.reset <= reset
    macs_9_15.io_in_a <= macs_9_14.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_9_15.io_in_c <= macs_8_15.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_9_15.io_in_w <= macs_8_15.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_9_15.io_in_prop_w <= macs_8_15.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_9_15.io_in_valid <= macs_8_15.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_10_0.clock <= clock
    macs_10_0.reset <= reset
    macs_10_0.io_in_a <= io_in_A_10 @[src/main/scala/MatMul.scala 71:21]
    macs_10_0.io_in_c <= macs_9_0.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_10_0.io_in_w <= macs_9_0.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_10_0.io_in_prop_w <= macs_9_0.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_10_0.io_in_valid <= macs_9_0.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_10_1.clock <= clock
    macs_10_1.reset <= reset
    macs_10_1.io_in_a <= macs_10_0.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_10_1.io_in_c <= macs_9_1.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_10_1.io_in_w <= macs_9_1.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_10_1.io_in_prop_w <= macs_9_1.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_10_1.io_in_valid <= macs_9_1.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_10_2.clock <= clock
    macs_10_2.reset <= reset
    macs_10_2.io_in_a <= macs_10_1.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_10_2.io_in_c <= macs_9_2.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_10_2.io_in_w <= macs_9_2.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_10_2.io_in_prop_w <= macs_9_2.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_10_2.io_in_valid <= macs_9_2.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_10_3.clock <= clock
    macs_10_3.reset <= reset
    macs_10_3.io_in_a <= macs_10_2.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_10_3.io_in_c <= macs_9_3.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_10_3.io_in_w <= macs_9_3.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_10_3.io_in_prop_w <= macs_9_3.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_10_3.io_in_valid <= macs_9_3.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_10_4.clock <= clock
    macs_10_4.reset <= reset
    macs_10_4.io_in_a <= macs_10_3.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_10_4.io_in_c <= macs_9_4.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_10_4.io_in_w <= macs_9_4.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_10_4.io_in_prop_w <= macs_9_4.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_10_4.io_in_valid <= macs_9_4.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_10_5.clock <= clock
    macs_10_5.reset <= reset
    macs_10_5.io_in_a <= macs_10_4.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_10_5.io_in_c <= macs_9_5.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_10_5.io_in_w <= macs_9_5.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_10_5.io_in_prop_w <= macs_9_5.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_10_5.io_in_valid <= macs_9_5.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_10_6.clock <= clock
    macs_10_6.reset <= reset
    macs_10_6.io_in_a <= macs_10_5.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_10_6.io_in_c <= macs_9_6.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_10_6.io_in_w <= macs_9_6.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_10_6.io_in_prop_w <= macs_9_6.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_10_6.io_in_valid <= macs_9_6.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_10_7.clock <= clock
    macs_10_7.reset <= reset
    macs_10_7.io_in_a <= macs_10_6.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_10_7.io_in_c <= macs_9_7.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_10_7.io_in_w <= macs_9_7.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_10_7.io_in_prop_w <= macs_9_7.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_10_7.io_in_valid <= macs_9_7.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_10_8.clock <= clock
    macs_10_8.reset <= reset
    macs_10_8.io_in_a <= macs_10_7.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_10_8.io_in_c <= macs_9_8.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_10_8.io_in_w <= macs_9_8.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_10_8.io_in_prop_w <= macs_9_8.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_10_8.io_in_valid <= macs_9_8.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_10_9.clock <= clock
    macs_10_9.reset <= reset
    macs_10_9.io_in_a <= macs_10_8.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_10_9.io_in_c <= macs_9_9.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_10_9.io_in_w <= macs_9_9.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_10_9.io_in_prop_w <= macs_9_9.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_10_9.io_in_valid <= macs_9_9.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_10_10.clock <= clock
    macs_10_10.reset <= reset
    macs_10_10.io_in_a <= macs_10_9.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_10_10.io_in_c <= macs_9_10.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_10_10.io_in_w <= macs_9_10.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_10_10.io_in_prop_w <= macs_9_10.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_10_10.io_in_valid <= macs_9_10.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_10_11.clock <= clock
    macs_10_11.reset <= reset
    macs_10_11.io_in_a <= macs_10_10.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_10_11.io_in_c <= macs_9_11.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_10_11.io_in_w <= macs_9_11.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_10_11.io_in_prop_w <= macs_9_11.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_10_11.io_in_valid <= macs_9_11.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_10_12.clock <= clock
    macs_10_12.reset <= reset
    macs_10_12.io_in_a <= macs_10_11.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_10_12.io_in_c <= macs_9_12.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_10_12.io_in_w <= macs_9_12.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_10_12.io_in_prop_w <= macs_9_12.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_10_12.io_in_valid <= macs_9_12.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_10_13.clock <= clock
    macs_10_13.reset <= reset
    macs_10_13.io_in_a <= macs_10_12.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_10_13.io_in_c <= macs_9_13.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_10_13.io_in_w <= macs_9_13.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_10_13.io_in_prop_w <= macs_9_13.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_10_13.io_in_valid <= macs_9_13.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_10_14.clock <= clock
    macs_10_14.reset <= reset
    macs_10_14.io_in_a <= macs_10_13.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_10_14.io_in_c <= macs_9_14.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_10_14.io_in_w <= macs_9_14.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_10_14.io_in_prop_w <= macs_9_14.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_10_14.io_in_valid <= macs_9_14.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_10_15.clock <= clock
    macs_10_15.reset <= reset
    macs_10_15.io_in_a <= macs_10_14.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_10_15.io_in_c <= macs_9_15.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_10_15.io_in_w <= macs_9_15.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_10_15.io_in_prop_w <= macs_9_15.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_10_15.io_in_valid <= macs_9_15.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_11_0.clock <= clock
    macs_11_0.reset <= reset
    macs_11_0.io_in_a <= io_in_A_11 @[src/main/scala/MatMul.scala 71:21]
    macs_11_0.io_in_c <= macs_10_0.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_11_0.io_in_w <= macs_10_0.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_11_0.io_in_prop_w <= macs_10_0.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_11_0.io_in_valid <= macs_10_0.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_11_1.clock <= clock
    macs_11_1.reset <= reset
    macs_11_1.io_in_a <= macs_11_0.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_11_1.io_in_c <= macs_10_1.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_11_1.io_in_w <= macs_10_1.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_11_1.io_in_prop_w <= macs_10_1.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_11_1.io_in_valid <= macs_10_1.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_11_2.clock <= clock
    macs_11_2.reset <= reset
    macs_11_2.io_in_a <= macs_11_1.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_11_2.io_in_c <= macs_10_2.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_11_2.io_in_w <= macs_10_2.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_11_2.io_in_prop_w <= macs_10_2.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_11_2.io_in_valid <= macs_10_2.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_11_3.clock <= clock
    macs_11_3.reset <= reset
    macs_11_3.io_in_a <= macs_11_2.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_11_3.io_in_c <= macs_10_3.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_11_3.io_in_w <= macs_10_3.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_11_3.io_in_prop_w <= macs_10_3.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_11_3.io_in_valid <= macs_10_3.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_11_4.clock <= clock
    macs_11_4.reset <= reset
    macs_11_4.io_in_a <= macs_11_3.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_11_4.io_in_c <= macs_10_4.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_11_4.io_in_w <= macs_10_4.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_11_4.io_in_prop_w <= macs_10_4.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_11_4.io_in_valid <= macs_10_4.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_11_5.clock <= clock
    macs_11_5.reset <= reset
    macs_11_5.io_in_a <= macs_11_4.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_11_5.io_in_c <= macs_10_5.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_11_5.io_in_w <= macs_10_5.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_11_5.io_in_prop_w <= macs_10_5.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_11_5.io_in_valid <= macs_10_5.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_11_6.clock <= clock
    macs_11_6.reset <= reset
    macs_11_6.io_in_a <= macs_11_5.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_11_6.io_in_c <= macs_10_6.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_11_6.io_in_w <= macs_10_6.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_11_6.io_in_prop_w <= macs_10_6.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_11_6.io_in_valid <= macs_10_6.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_11_7.clock <= clock
    macs_11_7.reset <= reset
    macs_11_7.io_in_a <= macs_11_6.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_11_7.io_in_c <= macs_10_7.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_11_7.io_in_w <= macs_10_7.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_11_7.io_in_prop_w <= macs_10_7.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_11_7.io_in_valid <= macs_10_7.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_11_8.clock <= clock
    macs_11_8.reset <= reset
    macs_11_8.io_in_a <= macs_11_7.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_11_8.io_in_c <= macs_10_8.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_11_8.io_in_w <= macs_10_8.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_11_8.io_in_prop_w <= macs_10_8.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_11_8.io_in_valid <= macs_10_8.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_11_9.clock <= clock
    macs_11_9.reset <= reset
    macs_11_9.io_in_a <= macs_11_8.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_11_9.io_in_c <= macs_10_9.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_11_9.io_in_w <= macs_10_9.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_11_9.io_in_prop_w <= macs_10_9.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_11_9.io_in_valid <= macs_10_9.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_11_10.clock <= clock
    macs_11_10.reset <= reset
    macs_11_10.io_in_a <= macs_11_9.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_11_10.io_in_c <= macs_10_10.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_11_10.io_in_w <= macs_10_10.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_11_10.io_in_prop_w <= macs_10_10.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_11_10.io_in_valid <= macs_10_10.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_11_11.clock <= clock
    macs_11_11.reset <= reset
    macs_11_11.io_in_a <= macs_11_10.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_11_11.io_in_c <= macs_10_11.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_11_11.io_in_w <= macs_10_11.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_11_11.io_in_prop_w <= macs_10_11.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_11_11.io_in_valid <= macs_10_11.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_11_12.clock <= clock
    macs_11_12.reset <= reset
    macs_11_12.io_in_a <= macs_11_11.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_11_12.io_in_c <= macs_10_12.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_11_12.io_in_w <= macs_10_12.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_11_12.io_in_prop_w <= macs_10_12.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_11_12.io_in_valid <= macs_10_12.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_11_13.clock <= clock
    macs_11_13.reset <= reset
    macs_11_13.io_in_a <= macs_11_12.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_11_13.io_in_c <= macs_10_13.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_11_13.io_in_w <= macs_10_13.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_11_13.io_in_prop_w <= macs_10_13.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_11_13.io_in_valid <= macs_10_13.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_11_14.clock <= clock
    macs_11_14.reset <= reset
    macs_11_14.io_in_a <= macs_11_13.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_11_14.io_in_c <= macs_10_14.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_11_14.io_in_w <= macs_10_14.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_11_14.io_in_prop_w <= macs_10_14.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_11_14.io_in_valid <= macs_10_14.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_11_15.clock <= clock
    macs_11_15.reset <= reset
    macs_11_15.io_in_a <= macs_11_14.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_11_15.io_in_c <= macs_10_15.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_11_15.io_in_w <= macs_10_15.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_11_15.io_in_prop_w <= macs_10_15.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_11_15.io_in_valid <= macs_10_15.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_12_0.clock <= clock
    macs_12_0.reset <= reset
    macs_12_0.io_in_a <= io_in_A_12 @[src/main/scala/MatMul.scala 71:21]
    macs_12_0.io_in_c <= macs_11_0.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_12_0.io_in_w <= macs_11_0.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_12_0.io_in_prop_w <= macs_11_0.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_12_0.io_in_valid <= macs_11_0.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_12_1.clock <= clock
    macs_12_1.reset <= reset
    macs_12_1.io_in_a <= macs_12_0.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_12_1.io_in_c <= macs_11_1.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_12_1.io_in_w <= macs_11_1.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_12_1.io_in_prop_w <= macs_11_1.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_12_1.io_in_valid <= macs_11_1.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_12_2.clock <= clock
    macs_12_2.reset <= reset
    macs_12_2.io_in_a <= macs_12_1.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_12_2.io_in_c <= macs_11_2.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_12_2.io_in_w <= macs_11_2.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_12_2.io_in_prop_w <= macs_11_2.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_12_2.io_in_valid <= macs_11_2.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_12_3.clock <= clock
    macs_12_3.reset <= reset
    macs_12_3.io_in_a <= macs_12_2.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_12_3.io_in_c <= macs_11_3.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_12_3.io_in_w <= macs_11_3.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_12_3.io_in_prop_w <= macs_11_3.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_12_3.io_in_valid <= macs_11_3.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_12_4.clock <= clock
    macs_12_4.reset <= reset
    macs_12_4.io_in_a <= macs_12_3.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_12_4.io_in_c <= macs_11_4.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_12_4.io_in_w <= macs_11_4.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_12_4.io_in_prop_w <= macs_11_4.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_12_4.io_in_valid <= macs_11_4.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_12_5.clock <= clock
    macs_12_5.reset <= reset
    macs_12_5.io_in_a <= macs_12_4.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_12_5.io_in_c <= macs_11_5.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_12_5.io_in_w <= macs_11_5.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_12_5.io_in_prop_w <= macs_11_5.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_12_5.io_in_valid <= macs_11_5.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_12_6.clock <= clock
    macs_12_6.reset <= reset
    macs_12_6.io_in_a <= macs_12_5.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_12_6.io_in_c <= macs_11_6.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_12_6.io_in_w <= macs_11_6.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_12_6.io_in_prop_w <= macs_11_6.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_12_6.io_in_valid <= macs_11_6.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_12_7.clock <= clock
    macs_12_7.reset <= reset
    macs_12_7.io_in_a <= macs_12_6.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_12_7.io_in_c <= macs_11_7.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_12_7.io_in_w <= macs_11_7.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_12_7.io_in_prop_w <= macs_11_7.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_12_7.io_in_valid <= macs_11_7.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_12_8.clock <= clock
    macs_12_8.reset <= reset
    macs_12_8.io_in_a <= macs_12_7.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_12_8.io_in_c <= macs_11_8.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_12_8.io_in_w <= macs_11_8.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_12_8.io_in_prop_w <= macs_11_8.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_12_8.io_in_valid <= macs_11_8.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_12_9.clock <= clock
    macs_12_9.reset <= reset
    macs_12_9.io_in_a <= macs_12_8.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_12_9.io_in_c <= macs_11_9.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_12_9.io_in_w <= macs_11_9.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_12_9.io_in_prop_w <= macs_11_9.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_12_9.io_in_valid <= macs_11_9.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_12_10.clock <= clock
    macs_12_10.reset <= reset
    macs_12_10.io_in_a <= macs_12_9.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_12_10.io_in_c <= macs_11_10.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_12_10.io_in_w <= macs_11_10.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_12_10.io_in_prop_w <= macs_11_10.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_12_10.io_in_valid <= macs_11_10.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_12_11.clock <= clock
    macs_12_11.reset <= reset
    macs_12_11.io_in_a <= macs_12_10.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_12_11.io_in_c <= macs_11_11.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_12_11.io_in_w <= macs_11_11.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_12_11.io_in_prop_w <= macs_11_11.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_12_11.io_in_valid <= macs_11_11.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_12_12.clock <= clock
    macs_12_12.reset <= reset
    macs_12_12.io_in_a <= macs_12_11.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_12_12.io_in_c <= macs_11_12.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_12_12.io_in_w <= macs_11_12.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_12_12.io_in_prop_w <= macs_11_12.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_12_12.io_in_valid <= macs_11_12.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_12_13.clock <= clock
    macs_12_13.reset <= reset
    macs_12_13.io_in_a <= macs_12_12.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_12_13.io_in_c <= macs_11_13.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_12_13.io_in_w <= macs_11_13.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_12_13.io_in_prop_w <= macs_11_13.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_12_13.io_in_valid <= macs_11_13.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_12_14.clock <= clock
    macs_12_14.reset <= reset
    macs_12_14.io_in_a <= macs_12_13.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_12_14.io_in_c <= macs_11_14.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_12_14.io_in_w <= macs_11_14.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_12_14.io_in_prop_w <= macs_11_14.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_12_14.io_in_valid <= macs_11_14.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_12_15.clock <= clock
    macs_12_15.reset <= reset
    macs_12_15.io_in_a <= macs_12_14.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_12_15.io_in_c <= macs_11_15.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_12_15.io_in_w <= macs_11_15.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_12_15.io_in_prop_w <= macs_11_15.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_12_15.io_in_valid <= macs_11_15.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_13_0.clock <= clock
    macs_13_0.reset <= reset
    macs_13_0.io_in_a <= io_in_A_13 @[src/main/scala/MatMul.scala 71:21]
    macs_13_0.io_in_c <= macs_12_0.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_13_0.io_in_w <= macs_12_0.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_13_0.io_in_prop_w <= macs_12_0.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_13_0.io_in_valid <= macs_12_0.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_13_1.clock <= clock
    macs_13_1.reset <= reset
    macs_13_1.io_in_a <= macs_13_0.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_13_1.io_in_c <= macs_12_1.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_13_1.io_in_w <= macs_12_1.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_13_1.io_in_prop_w <= macs_12_1.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_13_1.io_in_valid <= macs_12_1.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_13_2.clock <= clock
    macs_13_2.reset <= reset
    macs_13_2.io_in_a <= macs_13_1.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_13_2.io_in_c <= macs_12_2.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_13_2.io_in_w <= macs_12_2.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_13_2.io_in_prop_w <= macs_12_2.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_13_2.io_in_valid <= macs_12_2.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_13_3.clock <= clock
    macs_13_3.reset <= reset
    macs_13_3.io_in_a <= macs_13_2.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_13_3.io_in_c <= macs_12_3.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_13_3.io_in_w <= macs_12_3.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_13_3.io_in_prop_w <= macs_12_3.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_13_3.io_in_valid <= macs_12_3.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_13_4.clock <= clock
    macs_13_4.reset <= reset
    macs_13_4.io_in_a <= macs_13_3.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_13_4.io_in_c <= macs_12_4.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_13_4.io_in_w <= macs_12_4.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_13_4.io_in_prop_w <= macs_12_4.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_13_4.io_in_valid <= macs_12_4.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_13_5.clock <= clock
    macs_13_5.reset <= reset
    macs_13_5.io_in_a <= macs_13_4.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_13_5.io_in_c <= macs_12_5.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_13_5.io_in_w <= macs_12_5.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_13_5.io_in_prop_w <= macs_12_5.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_13_5.io_in_valid <= macs_12_5.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_13_6.clock <= clock
    macs_13_6.reset <= reset
    macs_13_6.io_in_a <= macs_13_5.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_13_6.io_in_c <= macs_12_6.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_13_6.io_in_w <= macs_12_6.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_13_6.io_in_prop_w <= macs_12_6.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_13_6.io_in_valid <= macs_12_6.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_13_7.clock <= clock
    macs_13_7.reset <= reset
    macs_13_7.io_in_a <= macs_13_6.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_13_7.io_in_c <= macs_12_7.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_13_7.io_in_w <= macs_12_7.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_13_7.io_in_prop_w <= macs_12_7.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_13_7.io_in_valid <= macs_12_7.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_13_8.clock <= clock
    macs_13_8.reset <= reset
    macs_13_8.io_in_a <= macs_13_7.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_13_8.io_in_c <= macs_12_8.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_13_8.io_in_w <= macs_12_8.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_13_8.io_in_prop_w <= macs_12_8.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_13_8.io_in_valid <= macs_12_8.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_13_9.clock <= clock
    macs_13_9.reset <= reset
    macs_13_9.io_in_a <= macs_13_8.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_13_9.io_in_c <= macs_12_9.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_13_9.io_in_w <= macs_12_9.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_13_9.io_in_prop_w <= macs_12_9.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_13_9.io_in_valid <= macs_12_9.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_13_10.clock <= clock
    macs_13_10.reset <= reset
    macs_13_10.io_in_a <= macs_13_9.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_13_10.io_in_c <= macs_12_10.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_13_10.io_in_w <= macs_12_10.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_13_10.io_in_prop_w <= macs_12_10.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_13_10.io_in_valid <= macs_12_10.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_13_11.clock <= clock
    macs_13_11.reset <= reset
    macs_13_11.io_in_a <= macs_13_10.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_13_11.io_in_c <= macs_12_11.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_13_11.io_in_w <= macs_12_11.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_13_11.io_in_prop_w <= macs_12_11.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_13_11.io_in_valid <= macs_12_11.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_13_12.clock <= clock
    macs_13_12.reset <= reset
    macs_13_12.io_in_a <= macs_13_11.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_13_12.io_in_c <= macs_12_12.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_13_12.io_in_w <= macs_12_12.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_13_12.io_in_prop_w <= macs_12_12.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_13_12.io_in_valid <= macs_12_12.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_13_13.clock <= clock
    macs_13_13.reset <= reset
    macs_13_13.io_in_a <= macs_13_12.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_13_13.io_in_c <= macs_12_13.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_13_13.io_in_w <= macs_12_13.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_13_13.io_in_prop_w <= macs_12_13.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_13_13.io_in_valid <= macs_12_13.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_13_14.clock <= clock
    macs_13_14.reset <= reset
    macs_13_14.io_in_a <= macs_13_13.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_13_14.io_in_c <= macs_12_14.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_13_14.io_in_w <= macs_12_14.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_13_14.io_in_prop_w <= macs_12_14.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_13_14.io_in_valid <= macs_12_14.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_13_15.clock <= clock
    macs_13_15.reset <= reset
    macs_13_15.io_in_a <= macs_13_14.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_13_15.io_in_c <= macs_12_15.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_13_15.io_in_w <= macs_12_15.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_13_15.io_in_prop_w <= macs_12_15.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_13_15.io_in_valid <= macs_12_15.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_14_0.clock <= clock
    macs_14_0.reset <= reset
    macs_14_0.io_in_a <= io_in_A_14 @[src/main/scala/MatMul.scala 71:21]
    macs_14_0.io_in_c <= macs_13_0.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_14_0.io_in_w <= macs_13_0.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_14_0.io_in_prop_w <= macs_13_0.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_14_0.io_in_valid <= macs_13_0.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_14_1.clock <= clock
    macs_14_1.reset <= reset
    macs_14_1.io_in_a <= macs_14_0.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_14_1.io_in_c <= macs_13_1.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_14_1.io_in_w <= macs_13_1.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_14_1.io_in_prop_w <= macs_13_1.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_14_1.io_in_valid <= macs_13_1.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_14_2.clock <= clock
    macs_14_2.reset <= reset
    macs_14_2.io_in_a <= macs_14_1.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_14_2.io_in_c <= macs_13_2.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_14_2.io_in_w <= macs_13_2.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_14_2.io_in_prop_w <= macs_13_2.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_14_2.io_in_valid <= macs_13_2.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_14_3.clock <= clock
    macs_14_3.reset <= reset
    macs_14_3.io_in_a <= macs_14_2.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_14_3.io_in_c <= macs_13_3.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_14_3.io_in_w <= macs_13_3.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_14_3.io_in_prop_w <= macs_13_3.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_14_3.io_in_valid <= macs_13_3.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_14_4.clock <= clock
    macs_14_4.reset <= reset
    macs_14_4.io_in_a <= macs_14_3.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_14_4.io_in_c <= macs_13_4.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_14_4.io_in_w <= macs_13_4.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_14_4.io_in_prop_w <= macs_13_4.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_14_4.io_in_valid <= macs_13_4.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_14_5.clock <= clock
    macs_14_5.reset <= reset
    macs_14_5.io_in_a <= macs_14_4.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_14_5.io_in_c <= macs_13_5.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_14_5.io_in_w <= macs_13_5.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_14_5.io_in_prop_w <= macs_13_5.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_14_5.io_in_valid <= macs_13_5.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_14_6.clock <= clock
    macs_14_6.reset <= reset
    macs_14_6.io_in_a <= macs_14_5.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_14_6.io_in_c <= macs_13_6.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_14_6.io_in_w <= macs_13_6.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_14_6.io_in_prop_w <= macs_13_6.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_14_6.io_in_valid <= macs_13_6.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_14_7.clock <= clock
    macs_14_7.reset <= reset
    macs_14_7.io_in_a <= macs_14_6.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_14_7.io_in_c <= macs_13_7.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_14_7.io_in_w <= macs_13_7.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_14_7.io_in_prop_w <= macs_13_7.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_14_7.io_in_valid <= macs_13_7.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_14_8.clock <= clock
    macs_14_8.reset <= reset
    macs_14_8.io_in_a <= macs_14_7.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_14_8.io_in_c <= macs_13_8.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_14_8.io_in_w <= macs_13_8.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_14_8.io_in_prop_w <= macs_13_8.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_14_8.io_in_valid <= macs_13_8.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_14_9.clock <= clock
    macs_14_9.reset <= reset
    macs_14_9.io_in_a <= macs_14_8.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_14_9.io_in_c <= macs_13_9.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_14_9.io_in_w <= macs_13_9.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_14_9.io_in_prop_w <= macs_13_9.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_14_9.io_in_valid <= macs_13_9.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_14_10.clock <= clock
    macs_14_10.reset <= reset
    macs_14_10.io_in_a <= macs_14_9.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_14_10.io_in_c <= macs_13_10.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_14_10.io_in_w <= macs_13_10.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_14_10.io_in_prop_w <= macs_13_10.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_14_10.io_in_valid <= macs_13_10.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_14_11.clock <= clock
    macs_14_11.reset <= reset
    macs_14_11.io_in_a <= macs_14_10.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_14_11.io_in_c <= macs_13_11.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_14_11.io_in_w <= macs_13_11.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_14_11.io_in_prop_w <= macs_13_11.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_14_11.io_in_valid <= macs_13_11.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_14_12.clock <= clock
    macs_14_12.reset <= reset
    macs_14_12.io_in_a <= macs_14_11.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_14_12.io_in_c <= macs_13_12.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_14_12.io_in_w <= macs_13_12.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_14_12.io_in_prop_w <= macs_13_12.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_14_12.io_in_valid <= macs_13_12.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_14_13.clock <= clock
    macs_14_13.reset <= reset
    macs_14_13.io_in_a <= macs_14_12.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_14_13.io_in_c <= macs_13_13.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_14_13.io_in_w <= macs_13_13.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_14_13.io_in_prop_w <= macs_13_13.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_14_13.io_in_valid <= macs_13_13.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_14_14.clock <= clock
    macs_14_14.reset <= reset
    macs_14_14.io_in_a <= macs_14_13.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_14_14.io_in_c <= macs_13_14.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_14_14.io_in_w <= macs_13_14.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_14_14.io_in_prop_w <= macs_13_14.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_14_14.io_in_valid <= macs_13_14.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_14_15.clock <= clock
    macs_14_15.reset <= reset
    macs_14_15.io_in_a <= macs_14_14.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_14_15.io_in_c <= macs_13_15.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_14_15.io_in_w <= macs_13_15.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_14_15.io_in_prop_w <= macs_13_15.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_14_15.io_in_valid <= macs_13_15.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_15_0.clock <= clock
    macs_15_0.reset <= reset
    macs_15_0.io_in_a <= io_in_A_15 @[src/main/scala/MatMul.scala 71:21]
    macs_15_0.io_in_c <= macs_14_0.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_15_0.io_in_w <= macs_14_0.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_15_0.io_in_prop_w <= macs_14_0.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_15_0.io_in_valid <= macs_14_0.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_15_1.clock <= clock
    macs_15_1.reset <= reset
    macs_15_1.io_in_a <= macs_15_0.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_15_1.io_in_c <= macs_14_1.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_15_1.io_in_w <= macs_14_1.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_15_1.io_in_prop_w <= macs_14_1.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_15_1.io_in_valid <= macs_14_1.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_15_2.clock <= clock
    macs_15_2.reset <= reset
    macs_15_2.io_in_a <= macs_15_1.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_15_2.io_in_c <= macs_14_2.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_15_2.io_in_w <= macs_14_2.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_15_2.io_in_prop_w <= macs_14_2.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_15_2.io_in_valid <= macs_14_2.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_15_3.clock <= clock
    macs_15_3.reset <= reset
    macs_15_3.io_in_a <= macs_15_2.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_15_3.io_in_c <= macs_14_3.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_15_3.io_in_w <= macs_14_3.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_15_3.io_in_prop_w <= macs_14_3.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_15_3.io_in_valid <= macs_14_3.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_15_4.clock <= clock
    macs_15_4.reset <= reset
    macs_15_4.io_in_a <= macs_15_3.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_15_4.io_in_c <= macs_14_4.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_15_4.io_in_w <= macs_14_4.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_15_4.io_in_prop_w <= macs_14_4.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_15_4.io_in_valid <= macs_14_4.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_15_5.clock <= clock
    macs_15_5.reset <= reset
    macs_15_5.io_in_a <= macs_15_4.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_15_5.io_in_c <= macs_14_5.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_15_5.io_in_w <= macs_14_5.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_15_5.io_in_prop_w <= macs_14_5.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_15_5.io_in_valid <= macs_14_5.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_15_6.clock <= clock
    macs_15_6.reset <= reset
    macs_15_6.io_in_a <= macs_15_5.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_15_6.io_in_c <= macs_14_6.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_15_6.io_in_w <= macs_14_6.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_15_6.io_in_prop_w <= macs_14_6.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_15_6.io_in_valid <= macs_14_6.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_15_7.clock <= clock
    macs_15_7.reset <= reset
    macs_15_7.io_in_a <= macs_15_6.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_15_7.io_in_c <= macs_14_7.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_15_7.io_in_w <= macs_14_7.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_15_7.io_in_prop_w <= macs_14_7.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_15_7.io_in_valid <= macs_14_7.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_15_8.clock <= clock
    macs_15_8.reset <= reset
    macs_15_8.io_in_a <= macs_15_7.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_15_8.io_in_c <= macs_14_8.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_15_8.io_in_w <= macs_14_8.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_15_8.io_in_prop_w <= macs_14_8.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_15_8.io_in_valid <= macs_14_8.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_15_9.clock <= clock
    macs_15_9.reset <= reset
    macs_15_9.io_in_a <= macs_15_8.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_15_9.io_in_c <= macs_14_9.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_15_9.io_in_w <= macs_14_9.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_15_9.io_in_prop_w <= macs_14_9.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_15_9.io_in_valid <= macs_14_9.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_15_10.clock <= clock
    macs_15_10.reset <= reset
    macs_15_10.io_in_a <= macs_15_9.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_15_10.io_in_c <= macs_14_10.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_15_10.io_in_w <= macs_14_10.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_15_10.io_in_prop_w <= macs_14_10.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_15_10.io_in_valid <= macs_14_10.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_15_11.clock <= clock
    macs_15_11.reset <= reset
    macs_15_11.io_in_a <= macs_15_10.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_15_11.io_in_c <= macs_14_11.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_15_11.io_in_w <= macs_14_11.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_15_11.io_in_prop_w <= macs_14_11.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_15_11.io_in_valid <= macs_14_11.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_15_12.clock <= clock
    macs_15_12.reset <= reset
    macs_15_12.io_in_a <= macs_15_11.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_15_12.io_in_c <= macs_14_12.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_15_12.io_in_w <= macs_14_12.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_15_12.io_in_prop_w <= macs_14_12.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_15_12.io_in_valid <= macs_14_12.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_15_13.clock <= clock
    macs_15_13.reset <= reset
    macs_15_13.io_in_a <= macs_15_12.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_15_13.io_in_c <= macs_14_13.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_15_13.io_in_w <= macs_14_13.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_15_13.io_in_prop_w <= macs_14_13.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_15_13.io_in_valid <= macs_14_13.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_15_14.clock <= clock
    macs_15_14.reset <= reset
    macs_15_14.io_in_a <= macs_15_13.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_15_14.io_in_c <= macs_14_14.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_15_14.io_in_w <= macs_14_14.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_15_14.io_in_prop_w <= macs_14_14.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_15_14.io_in_valid <= macs_14_14.io_out_valid @[src/main/scala/MatMul.scala 87:26]
    macs_15_15.clock <= clock
    macs_15_15.reset <= reset
    macs_15_15.io_in_a <= macs_15_14.io_out_a @[src/main/scala/MatMul.scala 71:21]
    macs_15_15.io_in_c <= macs_14_15.io_out_c @[src/main/scala/MatMul.scala 103:22]
    macs_15_15.io_in_w <= macs_14_15.io_out_w @[src/main/scala/MatMul.scala 79:22]
    macs_15_15.io_in_prop_w <= macs_14_15.io_out_prop_w @[src/main/scala/MatMul.scala 95:27]
    macs_15_15.io_in_valid <= macs_14_15.io_out_valid @[src/main/scala/MatMul.scala 87:26]
