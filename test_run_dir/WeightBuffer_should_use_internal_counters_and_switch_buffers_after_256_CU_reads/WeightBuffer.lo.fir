FIRRTL version 1.2.0
circuit WeightBuffer :
  module WeightBuffer : @[src/main/scala/weightbuffer.scala 13:7]
    input clock : Clock @[src/main/scala/weightbuffer.scala 13:7]
    input reset : UInt<1> @[src/main/scala/weightbuffer.scala 13:7]
    input io_dma_valid : UInt<1> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_0 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_1 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_2 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_3 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_4 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_5 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_6 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_7 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_8 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_9 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_10 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_11 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_12 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_13 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_14 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_15 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_16 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_17 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_18 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_19 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_20 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_21 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_22 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_23 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_24 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_25 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_26 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_27 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_28 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_29 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_30 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_31 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_32 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_33 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_34 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_35 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_36 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_37 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_38 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_39 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_40 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_41 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_42 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_43 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_44 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_45 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_46 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_47 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_48 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_49 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_50 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_51 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_52 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_53 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_54 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_55 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_56 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_57 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_58 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_59 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_60 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_61 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_62 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_dma_data_63 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    input io_load_reset : UInt<1> @[src/main/scala/weightbuffer.scala 14:14]
    output io_load_done : UInt<1> @[src/main/scala/weightbuffer.scala 14:14]
    input io_cu_read_en : UInt<1> @[src/main/scala/weightbuffer.scala 14:14]
    output io_cu_read_data_0 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    output io_cu_read_data_1 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    output io_cu_read_data_2 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    output io_cu_read_data_3 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    output io_cu_read_data_4 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    output io_cu_read_data_5 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    output io_cu_read_data_6 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    output io_cu_read_data_7 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    output io_cu_read_data_8 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    output io_cu_read_data_9 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    output io_cu_read_data_10 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    output io_cu_read_data_11 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    output io_cu_read_data_12 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    output io_cu_read_data_13 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    output io_cu_read_data_14 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    output io_cu_read_data_15 : UInt<8> @[src/main/scala/weightbuffer.scala 14:14]
    output io_cu_read_valid : UInt<1> @[src/main/scala/weightbuffer.scala 14:14]
    input io_read_reset : UInt<1> @[src/main/scala/weightbuffer.scala 14:14]
    output io_read_done : UInt<1> @[src/main/scala/weightbuffer.scala 14:14]

    mem wb_b0_bank0_lane0 : @[src/main/scala/weightbuffer.scala 29:16]
      data-type => UInt<64>
      depth => 64
      read-latency => 1
      write-latency => 1
      reader => bankReadData_lane0
      writer => MPORT
      read-under-write => undefined
    mem wb_b0_bank0_lane1 : @[src/main/scala/weightbuffer.scala 29:16]
      data-type => UInt<64>
      depth => 64
      read-latency => 1
      write-latency => 1
      reader => bankReadData_lane1
      writer => MPORT_1
      read-under-write => undefined
    mem wb_b0_bank1_lane0 : @[src/main/scala/weightbuffer.scala 29:16]
      data-type => UInt<64>
      depth => 64
      read-latency => 1
      write-latency => 1
      reader => bankReadData_lane0_1
      writer => MPORT_2
      read-under-write => undefined
    mem wb_b0_bank1_lane1 : @[src/main/scala/weightbuffer.scala 29:16]
      data-type => UInt<64>
      depth => 64
      read-latency => 1
      write-latency => 1
      reader => bankReadData_lane1_1
      writer => MPORT_3
      read-under-write => undefined
    mem wb_b0_bank2_lane0 : @[src/main/scala/weightbuffer.scala 29:16]
      data-type => UInt<64>
      depth => 64
      read-latency => 1
      write-latency => 1
      reader => bankReadData_lane0_2
      writer => MPORT_4
      read-under-write => undefined
    mem wb_b0_bank2_lane1 : @[src/main/scala/weightbuffer.scala 29:16]
      data-type => UInt<64>
      depth => 64
      read-latency => 1
      write-latency => 1
      reader => bankReadData_lane1_2
      writer => MPORT_5
      read-under-write => undefined
    mem wb_b0_bank3_lane0 : @[src/main/scala/weightbuffer.scala 29:16]
      data-type => UInt<64>
      depth => 64
      read-latency => 1
      write-latency => 1
      reader => bankReadData_lane0_3
      writer => MPORT_6
      read-under-write => undefined
    mem wb_b0_bank3_lane1 : @[src/main/scala/weightbuffer.scala 29:16]
      data-type => UInt<64>
      depth => 64
      read-latency => 1
      write-latency => 1
      reader => bankReadData_lane1_3
      writer => MPORT_7
      read-under-write => undefined
    mem wb_b1_bank0_lane0 : @[src/main/scala/weightbuffer.scala 29:16]
      data-type => UInt<64>
      depth => 64
      read-latency => 1
      write-latency => 1
      reader => bankReadData_lane0_4
      writer => MPORT_8
      read-under-write => undefined
    mem wb_b1_bank0_lane1 : @[src/main/scala/weightbuffer.scala 29:16]
      data-type => UInt<64>
      depth => 64
      read-latency => 1
      write-latency => 1
      reader => bankReadData_lane1_4
      writer => MPORT_9
      read-under-write => undefined
    mem wb_b1_bank1_lane0 : @[src/main/scala/weightbuffer.scala 29:16]
      data-type => UInt<64>
      depth => 64
      read-latency => 1
      write-latency => 1
      reader => bankReadData_lane0_5
      writer => MPORT_10
      read-under-write => undefined
    mem wb_b1_bank1_lane1 : @[src/main/scala/weightbuffer.scala 29:16]
      data-type => UInt<64>
      depth => 64
      read-latency => 1
      write-latency => 1
      reader => bankReadData_lane1_5
      writer => MPORT_11
      read-under-write => undefined
    mem wb_b1_bank2_lane0 : @[src/main/scala/weightbuffer.scala 29:16]
      data-type => UInt<64>
      depth => 64
      read-latency => 1
      write-latency => 1
      reader => bankReadData_lane0_6
      writer => MPORT_12
      read-under-write => undefined
    mem wb_b1_bank2_lane1 : @[src/main/scala/weightbuffer.scala 29:16]
      data-type => UInt<64>
      depth => 64
      read-latency => 1
      write-latency => 1
      reader => bankReadData_lane1_6
      writer => MPORT_13
      read-under-write => undefined
    mem wb_b1_bank3_lane0 : @[src/main/scala/weightbuffer.scala 29:16]
      data-type => UInt<64>
      depth => 64
      read-latency => 1
      write-latency => 1
      reader => bankReadData_lane0_7
      writer => MPORT_14
      read-under-write => undefined
    mem wb_b1_bank3_lane1 : @[src/main/scala/weightbuffer.scala 29:16]
      data-type => UInt<64>
      depth => 64
      read-latency => 1
      write-latency => 1
      reader => bankReadData_lane1_7
      writer => MPORT_15
      read-under-write => undefined
    reg activeReadBuffer : UInt<1>, clock with :
      reset => (UInt<1>("h0"), activeReadBuffer) @[src/main/scala/weightbuffer.scala 27:33]
    reg writeAddr : UInt<6>, clock with :
      reset => (UInt<1>("h0"), writeAddr) @[src/main/scala/weightbuffer.scala 32:26]
    reg readAddr : UInt<8>, clock with :
      reset => (UInt<1>("h0"), readAddr) @[src/main/scala/weightbuffer.scala 33:26]
    node writeBuffer = eq(activeReadBuffer, UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 35:21]
    node _io_load_done_T = eq(writeAddr, UInt<6>("h3f")) @[src/main/scala/weightbuffer.scala 37:45]
    node _io_load_done_T_1 = and(io_dma_valid, _io_load_done_T) @[src/main/scala/weightbuffer.scala 37:32]
    node _writeAddr_T = eq(writeAddr, UInt<6>("h3f")) @[src/main/scala/weightbuffer.scala 42:32]
    node _writeAddr_T_1 = add(writeAddr, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 42:57]
    node _writeAddr_T_2 = tail(_writeAddr_T_1, 1) @[src/main/scala/weightbuffer.scala 42:57]
    node _writeAddr_T_3 = mux(_writeAddr_T, UInt<1>("h0"), _writeAddr_T_2) @[src/main/scala/weightbuffer.scala 42:21]
    node _GEN_0 = mux(io_dma_valid, _writeAddr_T_3, writeAddr) @[src/main/scala/weightbuffer.scala 41:28 42:15 32:26]
    node _GEN_1 = mux(io_load_reset, UInt<1>("h0"), _GEN_0) @[src/main/scala/weightbuffer.scala 39:23 40:15]
    node _laneWord_WIRE__1 = io_dma_data_1 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE__0 = io_dma_data_0 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_lo_lo = cat(_laneWord_WIRE__1, _laneWord_WIRE__0) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE__3 = io_dma_data_3 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE__2 = io_dma_data_2 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_lo_hi = cat(_laneWord_WIRE__3, _laneWord_WIRE__2) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_lo = cat(laneWord_lo_hi, laneWord_lo_lo) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE__5 = io_dma_data_5 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE__4 = io_dma_data_4 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_hi_lo = cat(_laneWord_WIRE__5, _laneWord_WIRE__4) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE__7 = io_dma_data_7 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE__6 = io_dma_data_6 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_hi_hi = cat(_laneWord_WIRE__7, _laneWord_WIRE__6) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_hi = cat(laneWord_hi_hi, laneWord_hi_lo) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord = cat(laneWord_hi, laneWord_lo) @[src/main/scala/weightbuffer.scala 49:8]
    node _T = eq(writeBuffer, UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 51:38]
    node _T_1 = and(io_dma_valid, _T) @[src/main/scala/weightbuffer.scala 51:23]
    node _GEN_2 = validif(_T_1, writeAddr) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_3 = validif(_T_1, clock) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_4 = mux(_T_1, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 29:16 51:59 52:38]
    node _GEN_5 = validif(_T_1, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_6 = validif(_T_1, laneWord) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _laneWord_WIRE_1_1 = io_dma_data_9 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_1_0 = io_dma_data_8 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_lo_lo_1 = cat(_laneWord_WIRE_1_1, _laneWord_WIRE_1_0) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_1_3 = io_dma_data_11 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_1_2 = io_dma_data_10 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_lo_hi_1 = cat(_laneWord_WIRE_1_3, _laneWord_WIRE_1_2) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_lo_1 = cat(laneWord_lo_hi_1, laneWord_lo_lo_1) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_1_5 = io_dma_data_13 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_1_4 = io_dma_data_12 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_hi_lo_1 = cat(_laneWord_WIRE_1_5, _laneWord_WIRE_1_4) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_1_7 = io_dma_data_15 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_1_6 = io_dma_data_14 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_hi_hi_1 = cat(_laneWord_WIRE_1_7, _laneWord_WIRE_1_6) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_hi_1 = cat(laneWord_hi_hi_1, laneWord_hi_lo_1) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_1 = cat(laneWord_hi_1, laneWord_lo_1) @[src/main/scala/weightbuffer.scala 49:8]
    node _T_2 = eq(writeBuffer, UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 51:38]
    node _T_3 = and(io_dma_valid, _T_2) @[src/main/scala/weightbuffer.scala 51:23]
    node _GEN_7 = validif(_T_3, writeAddr) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_8 = validif(_T_3, clock) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_9 = mux(_T_3, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 29:16 51:59 52:38]
    node _GEN_10 = validif(_T_3, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_11 = validif(_T_3, laneWord_1) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _laneWord_WIRE_2_1 = io_dma_data_17 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_2_0 = io_dma_data_16 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_lo_lo_2 = cat(_laneWord_WIRE_2_1, _laneWord_WIRE_2_0) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_2_3 = io_dma_data_19 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_2_2 = io_dma_data_18 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_lo_hi_2 = cat(_laneWord_WIRE_2_3, _laneWord_WIRE_2_2) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_lo_2 = cat(laneWord_lo_hi_2, laneWord_lo_lo_2) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_2_5 = io_dma_data_21 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_2_4 = io_dma_data_20 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_hi_lo_2 = cat(_laneWord_WIRE_2_5, _laneWord_WIRE_2_4) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_2_7 = io_dma_data_23 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_2_6 = io_dma_data_22 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_hi_hi_2 = cat(_laneWord_WIRE_2_7, _laneWord_WIRE_2_6) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_hi_2 = cat(laneWord_hi_hi_2, laneWord_hi_lo_2) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_2 = cat(laneWord_hi_2, laneWord_lo_2) @[src/main/scala/weightbuffer.scala 49:8]
    node _T_4 = eq(writeBuffer, UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 51:38]
    node _T_5 = and(io_dma_valid, _T_4) @[src/main/scala/weightbuffer.scala 51:23]
    node _GEN_12 = validif(_T_5, writeAddr) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_13 = validif(_T_5, clock) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_14 = mux(_T_5, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 29:16 51:59 52:38]
    node _GEN_15 = validif(_T_5, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_16 = validif(_T_5, laneWord_2) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _laneWord_WIRE_3_1 = io_dma_data_25 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_3_0 = io_dma_data_24 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_lo_lo_3 = cat(_laneWord_WIRE_3_1, _laneWord_WIRE_3_0) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_3_3 = io_dma_data_27 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_3_2 = io_dma_data_26 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_lo_hi_3 = cat(_laneWord_WIRE_3_3, _laneWord_WIRE_3_2) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_lo_3 = cat(laneWord_lo_hi_3, laneWord_lo_lo_3) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_3_5 = io_dma_data_29 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_3_4 = io_dma_data_28 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_hi_lo_3 = cat(_laneWord_WIRE_3_5, _laneWord_WIRE_3_4) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_3_7 = io_dma_data_31 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_3_6 = io_dma_data_30 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_hi_hi_3 = cat(_laneWord_WIRE_3_7, _laneWord_WIRE_3_6) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_hi_3 = cat(laneWord_hi_hi_3, laneWord_hi_lo_3) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_3 = cat(laneWord_hi_3, laneWord_lo_3) @[src/main/scala/weightbuffer.scala 49:8]
    node _T_6 = eq(writeBuffer, UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 51:38]
    node _T_7 = and(io_dma_valid, _T_6) @[src/main/scala/weightbuffer.scala 51:23]
    node _GEN_17 = validif(_T_7, writeAddr) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_18 = validif(_T_7, clock) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_19 = mux(_T_7, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 29:16 51:59 52:38]
    node _GEN_20 = validif(_T_7, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_21 = validif(_T_7, laneWord_3) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _laneWord_WIRE_4_1 = io_dma_data_33 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_4_0 = io_dma_data_32 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_lo_lo_4 = cat(_laneWord_WIRE_4_1, _laneWord_WIRE_4_0) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_4_3 = io_dma_data_35 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_4_2 = io_dma_data_34 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_lo_hi_4 = cat(_laneWord_WIRE_4_3, _laneWord_WIRE_4_2) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_lo_4 = cat(laneWord_lo_hi_4, laneWord_lo_lo_4) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_4_5 = io_dma_data_37 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_4_4 = io_dma_data_36 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_hi_lo_4 = cat(_laneWord_WIRE_4_5, _laneWord_WIRE_4_4) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_4_7 = io_dma_data_39 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_4_6 = io_dma_data_38 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_hi_hi_4 = cat(_laneWord_WIRE_4_7, _laneWord_WIRE_4_6) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_hi_4 = cat(laneWord_hi_hi_4, laneWord_hi_lo_4) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_4 = cat(laneWord_hi_4, laneWord_lo_4) @[src/main/scala/weightbuffer.scala 49:8]
    node _T_8 = eq(writeBuffer, UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 51:38]
    node _T_9 = and(io_dma_valid, _T_8) @[src/main/scala/weightbuffer.scala 51:23]
    node _GEN_22 = validif(_T_9, writeAddr) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_23 = validif(_T_9, clock) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_24 = mux(_T_9, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 29:16 51:59 52:38]
    node _GEN_25 = validif(_T_9, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_26 = validif(_T_9, laneWord_4) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _laneWord_WIRE_5_1 = io_dma_data_41 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_5_0 = io_dma_data_40 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_lo_lo_5 = cat(_laneWord_WIRE_5_1, _laneWord_WIRE_5_0) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_5_3 = io_dma_data_43 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_5_2 = io_dma_data_42 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_lo_hi_5 = cat(_laneWord_WIRE_5_3, _laneWord_WIRE_5_2) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_lo_5 = cat(laneWord_lo_hi_5, laneWord_lo_lo_5) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_5_5 = io_dma_data_45 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_5_4 = io_dma_data_44 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_hi_lo_5 = cat(_laneWord_WIRE_5_5, _laneWord_WIRE_5_4) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_5_7 = io_dma_data_47 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_5_6 = io_dma_data_46 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_hi_hi_5 = cat(_laneWord_WIRE_5_7, _laneWord_WIRE_5_6) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_hi_5 = cat(laneWord_hi_hi_5, laneWord_hi_lo_5) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_5 = cat(laneWord_hi_5, laneWord_lo_5) @[src/main/scala/weightbuffer.scala 49:8]
    node _T_10 = eq(writeBuffer, UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 51:38]
    node _T_11 = and(io_dma_valid, _T_10) @[src/main/scala/weightbuffer.scala 51:23]
    node _GEN_27 = validif(_T_11, writeAddr) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_28 = validif(_T_11, clock) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_29 = mux(_T_11, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 29:16 51:59 52:38]
    node _GEN_30 = validif(_T_11, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_31 = validif(_T_11, laneWord_5) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _laneWord_WIRE_6_1 = io_dma_data_49 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_6_0 = io_dma_data_48 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_lo_lo_6 = cat(_laneWord_WIRE_6_1, _laneWord_WIRE_6_0) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_6_3 = io_dma_data_51 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_6_2 = io_dma_data_50 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_lo_hi_6 = cat(_laneWord_WIRE_6_3, _laneWord_WIRE_6_2) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_lo_6 = cat(laneWord_lo_hi_6, laneWord_lo_lo_6) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_6_5 = io_dma_data_53 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_6_4 = io_dma_data_52 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_hi_lo_6 = cat(_laneWord_WIRE_6_5, _laneWord_WIRE_6_4) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_6_7 = io_dma_data_55 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_6_6 = io_dma_data_54 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_hi_hi_6 = cat(_laneWord_WIRE_6_7, _laneWord_WIRE_6_6) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_hi_6 = cat(laneWord_hi_hi_6, laneWord_hi_lo_6) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_6 = cat(laneWord_hi_6, laneWord_lo_6) @[src/main/scala/weightbuffer.scala 49:8]
    node _T_12 = eq(writeBuffer, UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 51:38]
    node _T_13 = and(io_dma_valid, _T_12) @[src/main/scala/weightbuffer.scala 51:23]
    node _GEN_32 = validif(_T_13, writeAddr) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_33 = validif(_T_13, clock) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_34 = mux(_T_13, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 29:16 51:59 52:38]
    node _GEN_35 = validif(_T_13, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_36 = validif(_T_13, laneWord_6) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _laneWord_WIRE_7_1 = io_dma_data_57 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_7_0 = io_dma_data_56 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_lo_lo_7 = cat(_laneWord_WIRE_7_1, _laneWord_WIRE_7_0) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_7_3 = io_dma_data_59 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_7_2 = io_dma_data_58 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_lo_hi_7 = cat(_laneWord_WIRE_7_3, _laneWord_WIRE_7_2) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_lo_7 = cat(laneWord_lo_hi_7, laneWord_lo_lo_7) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_7_5 = io_dma_data_61 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_7_4 = io_dma_data_60 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_hi_lo_7 = cat(_laneWord_WIRE_7_5, _laneWord_WIRE_7_4) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_7_7 = io_dma_data_63 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_7_6 = io_dma_data_62 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_hi_hi_7 = cat(_laneWord_WIRE_7_7, _laneWord_WIRE_7_6) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_hi_7 = cat(laneWord_hi_hi_7, laneWord_hi_lo_7) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_7 = cat(laneWord_hi_7, laneWord_lo_7) @[src/main/scala/weightbuffer.scala 49:8]
    node _T_14 = eq(writeBuffer, UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 51:38]
    node _T_15 = and(io_dma_valid, _T_14) @[src/main/scala/weightbuffer.scala 51:23]
    node _GEN_37 = validif(_T_15, writeAddr) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_38 = validif(_T_15, clock) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_39 = mux(_T_15, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 29:16 51:59 52:38]
    node _GEN_40 = validif(_T_15, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_41 = validif(_T_15, laneWord_7) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _laneWord_WIRE_8_1 = io_dma_data_1 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_8_0 = io_dma_data_0 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_lo_lo_8 = cat(_laneWord_WIRE_8_1, _laneWord_WIRE_8_0) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_8_3 = io_dma_data_3 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_8_2 = io_dma_data_2 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_lo_hi_8 = cat(_laneWord_WIRE_8_3, _laneWord_WIRE_8_2) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_lo_8 = cat(laneWord_lo_hi_8, laneWord_lo_lo_8) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_8_5 = io_dma_data_5 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_8_4 = io_dma_data_4 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_hi_lo_8 = cat(_laneWord_WIRE_8_5, _laneWord_WIRE_8_4) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_8_7 = io_dma_data_7 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_8_6 = io_dma_data_6 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_hi_hi_8 = cat(_laneWord_WIRE_8_7, _laneWord_WIRE_8_6) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_hi_8 = cat(laneWord_hi_hi_8, laneWord_hi_lo_8) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_8 = cat(laneWord_hi_8, laneWord_lo_8) @[src/main/scala/weightbuffer.scala 49:8]
    node _T_16 = eq(writeBuffer, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 51:38]
    node _T_17 = and(io_dma_valid, _T_16) @[src/main/scala/weightbuffer.scala 51:23]
    node _GEN_42 = validif(_T_17, writeAddr) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_43 = validif(_T_17, clock) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_44 = mux(_T_17, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 29:16 51:59 52:38]
    node _GEN_45 = validif(_T_17, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_46 = validif(_T_17, laneWord_8) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _laneWord_WIRE_9_1 = io_dma_data_9 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_9_0 = io_dma_data_8 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_lo_lo_9 = cat(_laneWord_WIRE_9_1, _laneWord_WIRE_9_0) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_9_3 = io_dma_data_11 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_9_2 = io_dma_data_10 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_lo_hi_9 = cat(_laneWord_WIRE_9_3, _laneWord_WIRE_9_2) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_lo_9 = cat(laneWord_lo_hi_9, laneWord_lo_lo_9) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_9_5 = io_dma_data_13 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_9_4 = io_dma_data_12 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_hi_lo_9 = cat(_laneWord_WIRE_9_5, _laneWord_WIRE_9_4) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_9_7 = io_dma_data_15 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_9_6 = io_dma_data_14 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_hi_hi_9 = cat(_laneWord_WIRE_9_7, _laneWord_WIRE_9_6) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_hi_9 = cat(laneWord_hi_hi_9, laneWord_hi_lo_9) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_9 = cat(laneWord_hi_9, laneWord_lo_9) @[src/main/scala/weightbuffer.scala 49:8]
    node _T_18 = eq(writeBuffer, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 51:38]
    node _T_19 = and(io_dma_valid, _T_18) @[src/main/scala/weightbuffer.scala 51:23]
    node _GEN_47 = validif(_T_19, writeAddr) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_48 = validif(_T_19, clock) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_49 = mux(_T_19, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 29:16 51:59 52:38]
    node _GEN_50 = validif(_T_19, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_51 = validif(_T_19, laneWord_9) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _laneWord_WIRE_10_1 = io_dma_data_17 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_10_0 = io_dma_data_16 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_lo_lo_10 = cat(_laneWord_WIRE_10_1, _laneWord_WIRE_10_0) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_10_3 = io_dma_data_19 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_10_2 = io_dma_data_18 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_lo_hi_10 = cat(_laneWord_WIRE_10_3, _laneWord_WIRE_10_2) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_lo_10 = cat(laneWord_lo_hi_10, laneWord_lo_lo_10) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_10_5 = io_dma_data_21 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_10_4 = io_dma_data_20 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_hi_lo_10 = cat(_laneWord_WIRE_10_5, _laneWord_WIRE_10_4) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_10_7 = io_dma_data_23 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_10_6 = io_dma_data_22 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_hi_hi_10 = cat(_laneWord_WIRE_10_7, _laneWord_WIRE_10_6) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_hi_10 = cat(laneWord_hi_hi_10, laneWord_hi_lo_10) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_10 = cat(laneWord_hi_10, laneWord_lo_10) @[src/main/scala/weightbuffer.scala 49:8]
    node _T_20 = eq(writeBuffer, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 51:38]
    node _T_21 = and(io_dma_valid, _T_20) @[src/main/scala/weightbuffer.scala 51:23]
    node _GEN_52 = validif(_T_21, writeAddr) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_53 = validif(_T_21, clock) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_54 = mux(_T_21, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 29:16 51:59 52:38]
    node _GEN_55 = validif(_T_21, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_56 = validif(_T_21, laneWord_10) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _laneWord_WIRE_11_1 = io_dma_data_25 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_11_0 = io_dma_data_24 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_lo_lo_11 = cat(_laneWord_WIRE_11_1, _laneWord_WIRE_11_0) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_11_3 = io_dma_data_27 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_11_2 = io_dma_data_26 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_lo_hi_11 = cat(_laneWord_WIRE_11_3, _laneWord_WIRE_11_2) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_lo_11 = cat(laneWord_lo_hi_11, laneWord_lo_lo_11) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_11_5 = io_dma_data_29 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_11_4 = io_dma_data_28 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_hi_lo_11 = cat(_laneWord_WIRE_11_5, _laneWord_WIRE_11_4) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_11_7 = io_dma_data_31 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_11_6 = io_dma_data_30 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_hi_hi_11 = cat(_laneWord_WIRE_11_7, _laneWord_WIRE_11_6) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_hi_11 = cat(laneWord_hi_hi_11, laneWord_hi_lo_11) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_11 = cat(laneWord_hi_11, laneWord_lo_11) @[src/main/scala/weightbuffer.scala 49:8]
    node _T_22 = eq(writeBuffer, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 51:38]
    node _T_23 = and(io_dma_valid, _T_22) @[src/main/scala/weightbuffer.scala 51:23]
    node _GEN_57 = validif(_T_23, writeAddr) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_58 = validif(_T_23, clock) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_59 = mux(_T_23, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 29:16 51:59 52:38]
    node _GEN_60 = validif(_T_23, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_61 = validif(_T_23, laneWord_11) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _laneWord_WIRE_12_1 = io_dma_data_33 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_12_0 = io_dma_data_32 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_lo_lo_12 = cat(_laneWord_WIRE_12_1, _laneWord_WIRE_12_0) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_12_3 = io_dma_data_35 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_12_2 = io_dma_data_34 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_lo_hi_12 = cat(_laneWord_WIRE_12_3, _laneWord_WIRE_12_2) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_lo_12 = cat(laneWord_lo_hi_12, laneWord_lo_lo_12) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_12_5 = io_dma_data_37 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_12_4 = io_dma_data_36 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_hi_lo_12 = cat(_laneWord_WIRE_12_5, _laneWord_WIRE_12_4) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_12_7 = io_dma_data_39 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_12_6 = io_dma_data_38 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_hi_hi_12 = cat(_laneWord_WIRE_12_7, _laneWord_WIRE_12_6) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_hi_12 = cat(laneWord_hi_hi_12, laneWord_hi_lo_12) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_12 = cat(laneWord_hi_12, laneWord_lo_12) @[src/main/scala/weightbuffer.scala 49:8]
    node _T_24 = eq(writeBuffer, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 51:38]
    node _T_25 = and(io_dma_valid, _T_24) @[src/main/scala/weightbuffer.scala 51:23]
    node _GEN_62 = validif(_T_25, writeAddr) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_63 = validif(_T_25, clock) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_64 = mux(_T_25, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 29:16 51:59 52:38]
    node _GEN_65 = validif(_T_25, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_66 = validif(_T_25, laneWord_12) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _laneWord_WIRE_13_1 = io_dma_data_41 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_13_0 = io_dma_data_40 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_lo_lo_13 = cat(_laneWord_WIRE_13_1, _laneWord_WIRE_13_0) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_13_3 = io_dma_data_43 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_13_2 = io_dma_data_42 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_lo_hi_13 = cat(_laneWord_WIRE_13_3, _laneWord_WIRE_13_2) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_lo_13 = cat(laneWord_lo_hi_13, laneWord_lo_lo_13) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_13_5 = io_dma_data_45 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_13_4 = io_dma_data_44 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_hi_lo_13 = cat(_laneWord_WIRE_13_5, _laneWord_WIRE_13_4) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_13_7 = io_dma_data_47 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_13_6 = io_dma_data_46 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_hi_hi_13 = cat(_laneWord_WIRE_13_7, _laneWord_WIRE_13_6) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_hi_13 = cat(laneWord_hi_hi_13, laneWord_hi_lo_13) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_13 = cat(laneWord_hi_13, laneWord_lo_13) @[src/main/scala/weightbuffer.scala 49:8]
    node _T_26 = eq(writeBuffer, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 51:38]
    node _T_27 = and(io_dma_valid, _T_26) @[src/main/scala/weightbuffer.scala 51:23]
    node _GEN_67 = validif(_T_27, writeAddr) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_68 = validif(_T_27, clock) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_69 = mux(_T_27, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 29:16 51:59 52:38]
    node _GEN_70 = validif(_T_27, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_71 = validif(_T_27, laneWord_13) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _laneWord_WIRE_14_1 = io_dma_data_49 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_14_0 = io_dma_data_48 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_lo_lo_14 = cat(_laneWord_WIRE_14_1, _laneWord_WIRE_14_0) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_14_3 = io_dma_data_51 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_14_2 = io_dma_data_50 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_lo_hi_14 = cat(_laneWord_WIRE_14_3, _laneWord_WIRE_14_2) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_lo_14 = cat(laneWord_lo_hi_14, laneWord_lo_lo_14) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_14_5 = io_dma_data_53 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_14_4 = io_dma_data_52 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_hi_lo_14 = cat(_laneWord_WIRE_14_5, _laneWord_WIRE_14_4) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_14_7 = io_dma_data_55 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_14_6 = io_dma_data_54 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_hi_hi_14 = cat(_laneWord_WIRE_14_7, _laneWord_WIRE_14_6) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_hi_14 = cat(laneWord_hi_hi_14, laneWord_hi_lo_14) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_14 = cat(laneWord_hi_14, laneWord_lo_14) @[src/main/scala/weightbuffer.scala 49:8]
    node _T_28 = eq(writeBuffer, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 51:38]
    node _T_29 = and(io_dma_valid, _T_28) @[src/main/scala/weightbuffer.scala 51:23]
    node _GEN_72 = validif(_T_29, writeAddr) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_73 = validif(_T_29, clock) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_74 = mux(_T_29, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 29:16 51:59 52:38]
    node _GEN_75 = validif(_T_29, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_76 = validif(_T_29, laneWord_14) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _laneWord_WIRE_15_1 = io_dma_data_57 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_15_0 = io_dma_data_56 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_lo_lo_15 = cat(_laneWord_WIRE_15_1, _laneWord_WIRE_15_0) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_15_3 = io_dma_data_59 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_15_2 = io_dma_data_58 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_lo_hi_15 = cat(_laneWord_WIRE_15_3, _laneWord_WIRE_15_2) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_lo_15 = cat(laneWord_lo_hi_15, laneWord_lo_lo_15) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_15_5 = io_dma_data_61 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_15_4 = io_dma_data_60 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_hi_lo_15 = cat(_laneWord_WIRE_15_5, _laneWord_WIRE_15_4) @[src/main/scala/weightbuffer.scala 49:8]
    node _laneWord_WIRE_15_7 = io_dma_data_63 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node _laneWord_WIRE_15_6 = io_dma_data_62 @[src/main/scala/weightbuffer.scala 47:{27,27}]
    node laneWord_hi_hi_15 = cat(_laneWord_WIRE_15_7, _laneWord_WIRE_15_6) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_hi_15 = cat(laneWord_hi_hi_15, laneWord_hi_lo_15) @[src/main/scala/weightbuffer.scala 49:8]
    node laneWord_15 = cat(laneWord_hi_15, laneWord_lo_15) @[src/main/scala/weightbuffer.scala 49:8]
    node _T_30 = eq(writeBuffer, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 51:38]
    node _T_31 = and(io_dma_valid, _T_30) @[src/main/scala/weightbuffer.scala 51:23]
    node _GEN_77 = validif(_T_31, writeAddr) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_78 = validif(_T_31, clock) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_79 = mux(_T_31, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 29:16 51:59 52:38]
    node _GEN_80 = validif(_T_31, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _GEN_81 = validif(_T_31, laneWord_15) @[src/main/scala/weightbuffer.scala 51:59 52:38]
    node _lastCuRead_T = eq(readAddr, UInt<8>("hff")) @[src/main/scala/weightbuffer.scala 58:46]
    node lastCuRead = and(io_cu_read_en, _lastCuRead_T) @[src/main/scala/weightbuffer.scala 58:34]
    node selectedBank = bits(readAddr, 1, 0) @[src/main/scala/weightbuffer.scala 59:30]
    node cuWordAddr = bits(readAddr, 7, 2) @[src/main/scala/weightbuffer.scala 60:28]
    reg selectedBankReg : UInt<2>, clock with :
      reset => (UInt<1>("h0"), selectedBankReg) @[src/main/scala/weightbuffer.scala 61:34]
    node _GEN_82 = mux(io_cu_read_en, selectedBank, selectedBankReg) @[src/main/scala/weightbuffer.scala 61:{34,34,34}]
    reg selectedBufferReg : UInt<1>, clock with :
      reset => (UInt<1>("h0"), selectedBufferReg) @[src/main/scala/weightbuffer.scala 62:36]
    node _GEN_83 = mux(io_cu_read_en, activeReadBuffer, selectedBufferReg) @[src/main/scala/weightbuffer.scala 62:{36,36,36}]
    node _readAddr_T = eq(readAddr, UInt<8>("hff")) @[src/main/scala/weightbuffer.scala 67:30]
    node _readAddr_T_1 = add(readAddr, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 67:55]
    node _readAddr_T_2 = tail(_readAddr_T_1, 1) @[src/main/scala/weightbuffer.scala 67:55]
    node _readAddr_T_3 = mux(_readAddr_T, UInt<1>("h0"), _readAddr_T_2) @[src/main/scala/weightbuffer.scala 67:20]
    node _GEN_84 = mux(io_cu_read_en, _readAddr_T_3, readAddr) @[src/main/scala/weightbuffer.scala 66:29 67:14 33:26]
    node _GEN_85 = mux(io_read_reset, UInt<1>("h0"), _GEN_84) @[src/main/scala/weightbuffer.scala 64:23 65:14]
    node _bankReadData_readEnable_T = eq(activeReadBuffer, UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 72:24]
    node _bankReadData_readEnable_T_1 = and(io_cu_read_en, _bankReadData_readEnable_T) @[src/main/scala/weightbuffer.scala 71:36]
    node _bankReadData_readEnable_T_2 = eq(selectedBank, UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 72:60]
    node bankReadData_readEnable = and(_bankReadData_readEnable_T_1, _bankReadData_readEnable_T_2) @[src/main/scala/weightbuffer.scala 72:44]
    node _GEN_86 = validif(bankReadData_readEnable, cuWordAddr) @[src/main/scala/weightbuffer.scala 73:{44,44}]
    node _GEN_87 = mux(bankReadData_readEnable, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 29:16 73:{44,44}]
    node _bankReadData_lane0_WIRE = _GEN_86 @[src/main/scala/weightbuffer.scala 73:44]
    node _GEN_88 = validif(bankReadData_readEnable, _bankReadData_lane0_WIRE) @[src/main/scala/weightbuffer.scala 73:{44,44}]
    node _GEN_89 = validif(bankReadData_readEnable, clock) @[src/main/scala/weightbuffer.scala 73:{44,44}]
    node _bankReadData_lane1_WIRE = _GEN_86 @[src/main/scala/weightbuffer.scala 74:44]
    node _GEN_90 = validif(bankReadData_readEnable, _bankReadData_lane1_WIRE) @[src/main/scala/weightbuffer.scala 74:{44,44}]
    node bankReadData_0_0 = cat(wb_b0_bank0_lane1.bankReadData_lane1.data, wb_b0_bank0_lane0.bankReadData_lane0.data) @[src/main/scala/weightbuffer.scala 75:8]
    node _bankReadData_readEnable_T_3 = eq(activeReadBuffer, UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 72:24]
    node _bankReadData_readEnable_T_4 = and(io_cu_read_en, _bankReadData_readEnable_T_3) @[src/main/scala/weightbuffer.scala 71:36]
    node _bankReadData_readEnable_T_5 = eq(selectedBank, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 72:60]
    node bankReadData_readEnable_1 = and(_bankReadData_readEnable_T_4, _bankReadData_readEnable_T_5) @[src/main/scala/weightbuffer.scala 72:44]
    node _GEN_91 = validif(bankReadData_readEnable_1, cuWordAddr) @[src/main/scala/weightbuffer.scala 73:{44,44}]
    node _GEN_92 = mux(bankReadData_readEnable_1, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 29:16 73:{44,44}]
    node _bankReadData_lane0_WIRE_1 = _GEN_91 @[src/main/scala/weightbuffer.scala 73:44]
    node _GEN_93 = validif(bankReadData_readEnable_1, _bankReadData_lane0_WIRE_1) @[src/main/scala/weightbuffer.scala 73:{44,44}]
    node _GEN_94 = validif(bankReadData_readEnable_1, clock) @[src/main/scala/weightbuffer.scala 73:{44,44}]
    node _bankReadData_lane1_WIRE_1 = _GEN_91 @[src/main/scala/weightbuffer.scala 74:44]
    node _GEN_95 = validif(bankReadData_readEnable_1, _bankReadData_lane1_WIRE_1) @[src/main/scala/weightbuffer.scala 74:{44,44}]
    node bankReadData_0_1 = cat(wb_b0_bank1_lane1.bankReadData_lane1_1.data, wb_b0_bank1_lane0.bankReadData_lane0_1.data) @[src/main/scala/weightbuffer.scala 75:8]
    node _bankReadData_readEnable_T_6 = eq(activeReadBuffer, UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 72:24]
    node _bankReadData_readEnable_T_7 = and(io_cu_read_en, _bankReadData_readEnable_T_6) @[src/main/scala/weightbuffer.scala 71:36]
    node _bankReadData_readEnable_T_8 = eq(selectedBank, UInt<2>("h2")) @[src/main/scala/weightbuffer.scala 72:60]
    node bankReadData_readEnable_2 = and(_bankReadData_readEnable_T_7, _bankReadData_readEnable_T_8) @[src/main/scala/weightbuffer.scala 72:44]
    node _GEN_96 = validif(bankReadData_readEnable_2, cuWordAddr) @[src/main/scala/weightbuffer.scala 73:{44,44}]
    node _GEN_97 = mux(bankReadData_readEnable_2, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 29:16 73:{44,44}]
    node _bankReadData_lane0_WIRE_2 = _GEN_96 @[src/main/scala/weightbuffer.scala 73:44]
    node _GEN_98 = validif(bankReadData_readEnable_2, _bankReadData_lane0_WIRE_2) @[src/main/scala/weightbuffer.scala 73:{44,44}]
    node _GEN_99 = validif(bankReadData_readEnable_2, clock) @[src/main/scala/weightbuffer.scala 73:{44,44}]
    node _bankReadData_lane1_WIRE_2 = _GEN_96 @[src/main/scala/weightbuffer.scala 74:44]
    node _GEN_100 = validif(bankReadData_readEnable_2, _bankReadData_lane1_WIRE_2) @[src/main/scala/weightbuffer.scala 74:{44,44}]
    node bankReadData_0_2 = cat(wb_b0_bank2_lane1.bankReadData_lane1_2.data, wb_b0_bank2_lane0.bankReadData_lane0_2.data) @[src/main/scala/weightbuffer.scala 75:8]
    node _bankReadData_readEnable_T_9 = eq(activeReadBuffer, UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 72:24]
    node _bankReadData_readEnable_T_10 = and(io_cu_read_en, _bankReadData_readEnable_T_9) @[src/main/scala/weightbuffer.scala 71:36]
    node _bankReadData_readEnable_T_11 = eq(selectedBank, UInt<2>("h3")) @[src/main/scala/weightbuffer.scala 72:60]
    node bankReadData_readEnable_3 = and(_bankReadData_readEnable_T_10, _bankReadData_readEnable_T_11) @[src/main/scala/weightbuffer.scala 72:44]
    node _GEN_101 = validif(bankReadData_readEnable_3, cuWordAddr) @[src/main/scala/weightbuffer.scala 73:{44,44}]
    node _GEN_102 = mux(bankReadData_readEnable_3, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 29:16 73:{44,44}]
    node _bankReadData_lane0_WIRE_3 = _GEN_101 @[src/main/scala/weightbuffer.scala 73:44]
    node _GEN_103 = validif(bankReadData_readEnable_3, _bankReadData_lane0_WIRE_3) @[src/main/scala/weightbuffer.scala 73:{44,44}]
    node _GEN_104 = validif(bankReadData_readEnable_3, clock) @[src/main/scala/weightbuffer.scala 73:{44,44}]
    node _bankReadData_lane1_WIRE_3 = _GEN_101 @[src/main/scala/weightbuffer.scala 74:44]
    node _GEN_105 = validif(bankReadData_readEnable_3, _bankReadData_lane1_WIRE_3) @[src/main/scala/weightbuffer.scala 74:{44,44}]
    node bankReadData_0_3 = cat(wb_b0_bank3_lane1.bankReadData_lane1_3.data, wb_b0_bank3_lane0.bankReadData_lane0_3.data) @[src/main/scala/weightbuffer.scala 75:8]
    node _bankReadData_readEnable_T_12 = eq(activeReadBuffer, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 72:24]
    node _bankReadData_readEnable_T_13 = and(io_cu_read_en, _bankReadData_readEnable_T_12) @[src/main/scala/weightbuffer.scala 71:36]
    node _bankReadData_readEnable_T_14 = eq(selectedBank, UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 72:60]
    node bankReadData_readEnable_4 = and(_bankReadData_readEnable_T_13, _bankReadData_readEnable_T_14) @[src/main/scala/weightbuffer.scala 72:44]
    node _GEN_106 = validif(bankReadData_readEnable_4, cuWordAddr) @[src/main/scala/weightbuffer.scala 73:{44,44}]
    node _GEN_107 = mux(bankReadData_readEnable_4, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 29:16 73:{44,44}]
    node _bankReadData_lane0_WIRE_4 = _GEN_106 @[src/main/scala/weightbuffer.scala 73:44]
    node _GEN_108 = validif(bankReadData_readEnable_4, _bankReadData_lane0_WIRE_4) @[src/main/scala/weightbuffer.scala 73:{44,44}]
    node _GEN_109 = validif(bankReadData_readEnable_4, clock) @[src/main/scala/weightbuffer.scala 73:{44,44}]
    node _bankReadData_lane1_WIRE_4 = _GEN_106 @[src/main/scala/weightbuffer.scala 74:44]
    node _GEN_110 = validif(bankReadData_readEnable_4, _bankReadData_lane1_WIRE_4) @[src/main/scala/weightbuffer.scala 74:{44,44}]
    node bankReadData_1_0 = cat(wb_b1_bank0_lane1.bankReadData_lane1_4.data, wb_b1_bank0_lane0.bankReadData_lane0_4.data) @[src/main/scala/weightbuffer.scala 75:8]
    node _bankReadData_readEnable_T_15 = eq(activeReadBuffer, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 72:24]
    node _bankReadData_readEnable_T_16 = and(io_cu_read_en, _bankReadData_readEnable_T_15) @[src/main/scala/weightbuffer.scala 71:36]
    node _bankReadData_readEnable_T_17 = eq(selectedBank, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 72:60]
    node bankReadData_readEnable_5 = and(_bankReadData_readEnable_T_16, _bankReadData_readEnable_T_17) @[src/main/scala/weightbuffer.scala 72:44]
    node _GEN_111 = validif(bankReadData_readEnable_5, cuWordAddr) @[src/main/scala/weightbuffer.scala 73:{44,44}]
    node _GEN_112 = mux(bankReadData_readEnable_5, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 29:16 73:{44,44}]
    node _bankReadData_lane0_WIRE_5 = _GEN_111 @[src/main/scala/weightbuffer.scala 73:44]
    node _GEN_113 = validif(bankReadData_readEnable_5, _bankReadData_lane0_WIRE_5) @[src/main/scala/weightbuffer.scala 73:{44,44}]
    node _GEN_114 = validif(bankReadData_readEnable_5, clock) @[src/main/scala/weightbuffer.scala 73:{44,44}]
    node _bankReadData_lane1_WIRE_5 = _GEN_111 @[src/main/scala/weightbuffer.scala 74:44]
    node _GEN_115 = validif(bankReadData_readEnable_5, _bankReadData_lane1_WIRE_5) @[src/main/scala/weightbuffer.scala 74:{44,44}]
    node bankReadData_1_1 = cat(wb_b1_bank1_lane1.bankReadData_lane1_5.data, wb_b1_bank1_lane0.bankReadData_lane0_5.data) @[src/main/scala/weightbuffer.scala 75:8]
    node _bankReadData_readEnable_T_18 = eq(activeReadBuffer, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 72:24]
    node _bankReadData_readEnable_T_19 = and(io_cu_read_en, _bankReadData_readEnable_T_18) @[src/main/scala/weightbuffer.scala 71:36]
    node _bankReadData_readEnable_T_20 = eq(selectedBank, UInt<2>("h2")) @[src/main/scala/weightbuffer.scala 72:60]
    node bankReadData_readEnable_6 = and(_bankReadData_readEnable_T_19, _bankReadData_readEnable_T_20) @[src/main/scala/weightbuffer.scala 72:44]
    node _GEN_116 = validif(bankReadData_readEnable_6, cuWordAddr) @[src/main/scala/weightbuffer.scala 73:{44,44}]
    node _GEN_117 = mux(bankReadData_readEnable_6, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 29:16 73:{44,44}]
    node _bankReadData_lane0_WIRE_6 = _GEN_116 @[src/main/scala/weightbuffer.scala 73:44]
    node _GEN_118 = validif(bankReadData_readEnable_6, _bankReadData_lane0_WIRE_6) @[src/main/scala/weightbuffer.scala 73:{44,44}]
    node _GEN_119 = validif(bankReadData_readEnable_6, clock) @[src/main/scala/weightbuffer.scala 73:{44,44}]
    node _bankReadData_lane1_WIRE_6 = _GEN_116 @[src/main/scala/weightbuffer.scala 74:44]
    node _GEN_120 = validif(bankReadData_readEnable_6, _bankReadData_lane1_WIRE_6) @[src/main/scala/weightbuffer.scala 74:{44,44}]
    node bankReadData_1_2 = cat(wb_b1_bank2_lane1.bankReadData_lane1_6.data, wb_b1_bank2_lane0.bankReadData_lane0_6.data) @[src/main/scala/weightbuffer.scala 75:8]
    node _bankReadData_readEnable_T_21 = eq(activeReadBuffer, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 72:24]
    node _bankReadData_readEnable_T_22 = and(io_cu_read_en, _bankReadData_readEnable_T_21) @[src/main/scala/weightbuffer.scala 71:36]
    node _bankReadData_readEnable_T_23 = eq(selectedBank, UInt<2>("h3")) @[src/main/scala/weightbuffer.scala 72:60]
    node bankReadData_readEnable_7 = and(_bankReadData_readEnable_T_22, _bankReadData_readEnable_T_23) @[src/main/scala/weightbuffer.scala 72:44]
    node _GEN_121 = validif(bankReadData_readEnable_7, cuWordAddr) @[src/main/scala/weightbuffer.scala 73:{44,44}]
    node _GEN_122 = mux(bankReadData_readEnable_7, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 29:16 73:{44,44}]
    node _bankReadData_lane0_WIRE_7 = _GEN_121 @[src/main/scala/weightbuffer.scala 73:44]
    node _GEN_123 = validif(bankReadData_readEnable_7, _bankReadData_lane0_WIRE_7) @[src/main/scala/weightbuffer.scala 73:{44,44}]
    node _GEN_124 = validif(bankReadData_readEnable_7, clock) @[src/main/scala/weightbuffer.scala 73:{44,44}]
    node _bankReadData_lane1_WIRE_7 = _GEN_121 @[src/main/scala/weightbuffer.scala 74:44]
    node _GEN_125 = validif(bankReadData_readEnable_7, _bankReadData_lane1_WIRE_7) @[src/main/scala/weightbuffer.scala 74:{44,44}]
    node bankReadData_1_3 = cat(wb_b1_bank3_lane1.bankReadData_lane1_7.data, wb_b1_bank3_lane0.bankReadData_lane0_7.data) @[src/main/scala/weightbuffer.scala 75:8]
    node _selectedWord_selected_T = eq(selectedBufferReg, UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 79:38]
    node _selectedWord_selected_T_1 = eq(selectedBankReg, UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 80:23]
    node selectedWord_selected = and(_selectedWord_selected_T, _selectedWord_selected_T_1) @[src/main/scala/weightbuffer.scala 79:58]
    node _selectedWord_selected_T_2 = eq(selectedBufferReg, UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 79:38]
    node _selectedWord_selected_T_3 = eq(selectedBankReg, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 80:23]
    node selectedWord_selected_1 = and(_selectedWord_selected_T_2, _selectedWord_selected_T_3) @[src/main/scala/weightbuffer.scala 79:58]
    node _selectedWord_selected_T_4 = eq(selectedBufferReg, UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 79:38]
    node _selectedWord_selected_T_5 = eq(selectedBankReg, UInt<2>("h2")) @[src/main/scala/weightbuffer.scala 80:23]
    node selectedWord_selected_2 = and(_selectedWord_selected_T_4, _selectedWord_selected_T_5) @[src/main/scala/weightbuffer.scala 79:58]
    node _selectedWord_selected_T_6 = eq(selectedBufferReg, UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 79:38]
    node _selectedWord_selected_T_7 = eq(selectedBankReg, UInt<2>("h3")) @[src/main/scala/weightbuffer.scala 80:23]
    node selectedWord_selected_3 = and(_selectedWord_selected_T_6, _selectedWord_selected_T_7) @[src/main/scala/weightbuffer.scala 79:58]
    node _selectedWord_selected_T_8 = eq(selectedBufferReg, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 79:38]
    node _selectedWord_selected_T_9 = eq(selectedBankReg, UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 80:23]
    node selectedWord_selected_4 = and(_selectedWord_selected_T_8, _selectedWord_selected_T_9) @[src/main/scala/weightbuffer.scala 79:58]
    node _selectedWord_selected_T_10 = eq(selectedBufferReg, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 79:38]
    node _selectedWord_selected_T_11 = eq(selectedBankReg, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 80:23]
    node selectedWord_selected_5 = and(_selectedWord_selected_T_10, _selectedWord_selected_T_11) @[src/main/scala/weightbuffer.scala 79:58]
    node _selectedWord_selected_T_12 = eq(selectedBufferReg, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 79:38]
    node _selectedWord_selected_T_13 = eq(selectedBankReg, UInt<2>("h2")) @[src/main/scala/weightbuffer.scala 80:23]
    node selectedWord_selected_6 = and(_selectedWord_selected_T_12, _selectedWord_selected_T_13) @[src/main/scala/weightbuffer.scala 79:58]
    node _selectedWord_selected_T_14 = eq(selectedBufferReg, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 79:38]
    node _selectedWord_selected_T_15 = eq(selectedBankReg, UInt<2>("h3")) @[src/main/scala/weightbuffer.scala 80:23]
    node selectedWord_selected_7 = and(_selectedWord_selected_T_14, _selectedWord_selected_T_15) @[src/main/scala/weightbuffer.scala 79:58]
    node _selectedWord_T = mux(selectedWord_selected, bankReadData_0_0, UInt<1>("h0")) @[src/main/scala/chisel3/util/Mux.scala 30:73]
    node _selectedWord_T_1 = mux(selectedWord_selected_1, bankReadData_0_1, UInt<1>("h0")) @[src/main/scala/chisel3/util/Mux.scala 30:73]
    node _selectedWord_T_2 = mux(selectedWord_selected_2, bankReadData_0_2, UInt<1>("h0")) @[src/main/scala/chisel3/util/Mux.scala 30:73]
    node _selectedWord_T_3 = mux(selectedWord_selected_3, bankReadData_0_3, UInt<1>("h0")) @[src/main/scala/chisel3/util/Mux.scala 30:73]
    node _selectedWord_T_4 = mux(selectedWord_selected_4, bankReadData_1_0, UInt<1>("h0")) @[src/main/scala/chisel3/util/Mux.scala 30:73]
    node _selectedWord_T_5 = mux(selectedWord_selected_5, bankReadData_1_1, UInt<1>("h0")) @[src/main/scala/chisel3/util/Mux.scala 30:73]
    node _selectedWord_T_6 = mux(selectedWord_selected_6, bankReadData_1_2, UInt<1>("h0")) @[src/main/scala/chisel3/util/Mux.scala 30:73]
    node _selectedWord_T_7 = mux(selectedWord_selected_7, bankReadData_1_3, UInt<1>("h0")) @[src/main/scala/chisel3/util/Mux.scala 30:73]
    node _selectedWord_T_8 = or(_selectedWord_T, _selectedWord_T_1) @[src/main/scala/chisel3/util/Mux.scala 30:73]
    node _selectedWord_T_9 = or(_selectedWord_T_8, _selectedWord_T_2) @[src/main/scala/chisel3/util/Mux.scala 30:73]
    node _selectedWord_T_10 = or(_selectedWord_T_9, _selectedWord_T_3) @[src/main/scala/chisel3/util/Mux.scala 30:73]
    node _selectedWord_T_11 = or(_selectedWord_T_10, _selectedWord_T_4) @[src/main/scala/chisel3/util/Mux.scala 30:73]
    node _selectedWord_T_12 = or(_selectedWord_T_11, _selectedWord_T_5) @[src/main/scala/chisel3/util/Mux.scala 30:73]
    node _selectedWord_T_13 = or(_selectedWord_T_12, _selectedWord_T_6) @[src/main/scala/chisel3/util/Mux.scala 30:73]
    node _selectedWord_T_14 = or(_selectedWord_T_13, _selectedWord_T_7) @[src/main/scala/chisel3/util/Mux.scala 30:73]
    node selectedWord = _selectedWord_T_14 @[src/main/scala/chisel3/util/Mux.scala 30:{73,73}]
    node _WIRE_1 = selectedWord @[src/main/scala/weightbuffer.scala 84:{43,43}]
    node _T_32 = bits(_WIRE_1, 7, 0) @[src/main/scala/weightbuffer.scala 84:43]
    node _T_33 = bits(_WIRE_1, 15, 8) @[src/main/scala/weightbuffer.scala 84:43]
    node _T_34 = bits(_WIRE_1, 23, 16) @[src/main/scala/weightbuffer.scala 84:43]
    node _T_35 = bits(_WIRE_1, 31, 24) @[src/main/scala/weightbuffer.scala 84:43]
    node _T_36 = bits(_WIRE_1, 39, 32) @[src/main/scala/weightbuffer.scala 84:43]
    node _T_37 = bits(_WIRE_1, 47, 40) @[src/main/scala/weightbuffer.scala 84:43]
    node _T_38 = bits(_WIRE_1, 55, 48) @[src/main/scala/weightbuffer.scala 84:43]
    node _T_39 = bits(_WIRE_1, 63, 56) @[src/main/scala/weightbuffer.scala 84:43]
    node _T_40 = bits(_WIRE_1, 71, 64) @[src/main/scala/weightbuffer.scala 84:43]
    node _T_41 = bits(_WIRE_1, 79, 72) @[src/main/scala/weightbuffer.scala 84:43]
    node _T_42 = bits(_WIRE_1, 87, 80) @[src/main/scala/weightbuffer.scala 84:43]
    node _T_43 = bits(_WIRE_1, 95, 88) @[src/main/scala/weightbuffer.scala 84:43]
    node _T_44 = bits(_WIRE_1, 103, 96) @[src/main/scala/weightbuffer.scala 84:43]
    node _T_45 = bits(_WIRE_1, 111, 104) @[src/main/scala/weightbuffer.scala 84:43]
    node _T_46 = bits(_WIRE_1, 119, 112) @[src/main/scala/weightbuffer.scala 84:43]
    node _T_47 = bits(_WIRE_1, 127, 120) @[src/main/scala/weightbuffer.scala 84:43]
    reg io_cu_read_valid_REG : UInt<1>, clock with :
      reset => (UInt<1>("h0"), io_cu_read_valid_REG) @[src/main/scala/weightbuffer.scala 85:30]
    reg io_read_done_REG : UInt<1>, clock with :
      reset => (UInt<1>("h0"), io_read_done_REG) @[src/main/scala/weightbuffer.scala 86:26]
    node _activeReadBuffer_T = eq(activeReadBuffer, UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 90:25]
    node _GEN_126 = mux(lastCuRead, _activeReadBuffer_T, activeReadBuffer) @[src/main/scala/weightbuffer.scala 89:20 90:22 27:33]
    node _WIRE__0 = _T_32 @[src/main/scala/weightbuffer.scala 84:{43,43}]
    node _WIRE__1 = _T_33 @[src/main/scala/weightbuffer.scala 84:{43,43}]
    node _WIRE__2 = _T_34 @[src/main/scala/weightbuffer.scala 84:{43,43}]
    node _WIRE__3 = _T_35 @[src/main/scala/weightbuffer.scala 84:{43,43}]
    node _WIRE__4 = _T_36 @[src/main/scala/weightbuffer.scala 84:{43,43}]
    node _WIRE__5 = _T_37 @[src/main/scala/weightbuffer.scala 84:{43,43}]
    node _WIRE__6 = _T_38 @[src/main/scala/weightbuffer.scala 84:{43,43}]
    node _WIRE__7 = _T_39 @[src/main/scala/weightbuffer.scala 84:{43,43}]
    node _WIRE__8 = _T_40 @[src/main/scala/weightbuffer.scala 84:{43,43}]
    node _WIRE__9 = _T_41 @[src/main/scala/weightbuffer.scala 84:{43,43}]
    node _WIRE__10 = _T_42 @[src/main/scala/weightbuffer.scala 84:{43,43}]
    node _WIRE__11 = _T_43 @[src/main/scala/weightbuffer.scala 84:{43,43}]
    node _WIRE__12 = _T_44 @[src/main/scala/weightbuffer.scala 84:{43,43}]
    node _WIRE__13 = _T_45 @[src/main/scala/weightbuffer.scala 84:{43,43}]
    node _WIRE__14 = _T_46 @[src/main/scala/weightbuffer.scala 84:{43,43}]
    node _WIRE__15 = _T_47 @[src/main/scala/weightbuffer.scala 84:{43,43}]
    io_load_done <= _io_load_done_T_1 @[src/main/scala/weightbuffer.scala 37:16]
    io_cu_read_data_0 <= _WIRE__0 @[src/main/scala/weightbuffer.scala 84:19]
    io_cu_read_data_1 <= _WIRE__1 @[src/main/scala/weightbuffer.scala 84:19]
    io_cu_read_data_2 <= _WIRE__2 @[src/main/scala/weightbuffer.scala 84:19]
    io_cu_read_data_3 <= _WIRE__3 @[src/main/scala/weightbuffer.scala 84:19]
    io_cu_read_data_4 <= _WIRE__4 @[src/main/scala/weightbuffer.scala 84:19]
    io_cu_read_data_5 <= _WIRE__5 @[src/main/scala/weightbuffer.scala 84:19]
    io_cu_read_data_6 <= _WIRE__6 @[src/main/scala/weightbuffer.scala 84:19]
    io_cu_read_data_7 <= _WIRE__7 @[src/main/scala/weightbuffer.scala 84:19]
    io_cu_read_data_8 <= _WIRE__8 @[src/main/scala/weightbuffer.scala 84:19]
    io_cu_read_data_9 <= _WIRE__9 @[src/main/scala/weightbuffer.scala 84:19]
    io_cu_read_data_10 <= _WIRE__10 @[src/main/scala/weightbuffer.scala 84:19]
    io_cu_read_data_11 <= _WIRE__11 @[src/main/scala/weightbuffer.scala 84:19]
    io_cu_read_data_12 <= _WIRE__12 @[src/main/scala/weightbuffer.scala 84:19]
    io_cu_read_data_13 <= _WIRE__13 @[src/main/scala/weightbuffer.scala 84:19]
    io_cu_read_data_14 <= _WIRE__14 @[src/main/scala/weightbuffer.scala 84:19]
    io_cu_read_data_15 <= _WIRE__15 @[src/main/scala/weightbuffer.scala 84:19]
    io_cu_read_valid <= io_cu_read_valid_REG @[src/main/scala/weightbuffer.scala 85:20]
    io_read_done <= io_read_done_REG @[src/main/scala/weightbuffer.scala 86:16]
    activeReadBuffer <= mux(reset, UInt<1>("h0"), _GEN_126) @[src/main/scala/weightbuffer.scala 27:{33,33}]
    wb_b0_bank0_lane0.bankReadData_lane0.addr <= _GEN_88
    wb_b0_bank0_lane0.bankReadData_lane0.en <= _GEN_87
    wb_b0_bank0_lane0.bankReadData_lane0.clk <= _GEN_89
    wb_b0_bank0_lane0.MPORT.addr <= _GEN_2
    wb_b0_bank0_lane0.MPORT.en <= _GEN_4
    wb_b0_bank0_lane0.MPORT.clk <= _GEN_3
    wb_b0_bank0_lane0.MPORT.data <= _GEN_6
    wb_b0_bank0_lane0.MPORT.mask <= _GEN_5
    wb_b0_bank0_lane1.bankReadData_lane1.addr <= _GEN_90
    wb_b0_bank0_lane1.bankReadData_lane1.en <= _GEN_87
    wb_b0_bank0_lane1.bankReadData_lane1.clk <= _GEN_89
    wb_b0_bank0_lane1.MPORT_1.addr <= _GEN_7
    wb_b0_bank0_lane1.MPORT_1.en <= _GEN_9
    wb_b0_bank0_lane1.MPORT_1.clk <= _GEN_8
    wb_b0_bank0_lane1.MPORT_1.data <= _GEN_11
    wb_b0_bank0_lane1.MPORT_1.mask <= _GEN_10
    wb_b0_bank1_lane0.bankReadData_lane0_1.addr <= _GEN_93
    wb_b0_bank1_lane0.bankReadData_lane0_1.en <= _GEN_92
    wb_b0_bank1_lane0.bankReadData_lane0_1.clk <= _GEN_94
    wb_b0_bank1_lane0.MPORT_2.addr <= _GEN_12
    wb_b0_bank1_lane0.MPORT_2.en <= _GEN_14
    wb_b0_bank1_lane0.MPORT_2.clk <= _GEN_13
    wb_b0_bank1_lane0.MPORT_2.data <= _GEN_16
    wb_b0_bank1_lane0.MPORT_2.mask <= _GEN_15
    wb_b0_bank1_lane1.bankReadData_lane1_1.addr <= _GEN_95
    wb_b0_bank1_lane1.bankReadData_lane1_1.en <= _GEN_92
    wb_b0_bank1_lane1.bankReadData_lane1_1.clk <= _GEN_94
    wb_b0_bank1_lane1.MPORT_3.addr <= _GEN_17
    wb_b0_bank1_lane1.MPORT_3.en <= _GEN_19
    wb_b0_bank1_lane1.MPORT_3.clk <= _GEN_18
    wb_b0_bank1_lane1.MPORT_3.data <= _GEN_21
    wb_b0_bank1_lane1.MPORT_3.mask <= _GEN_20
    wb_b0_bank2_lane0.bankReadData_lane0_2.addr <= _GEN_98
    wb_b0_bank2_lane0.bankReadData_lane0_2.en <= _GEN_97
    wb_b0_bank2_lane0.bankReadData_lane0_2.clk <= _GEN_99
    wb_b0_bank2_lane0.MPORT_4.addr <= _GEN_22
    wb_b0_bank2_lane0.MPORT_4.en <= _GEN_24
    wb_b0_bank2_lane0.MPORT_4.clk <= _GEN_23
    wb_b0_bank2_lane0.MPORT_4.data <= _GEN_26
    wb_b0_bank2_lane0.MPORT_4.mask <= _GEN_25
    wb_b0_bank2_lane1.bankReadData_lane1_2.addr <= _GEN_100
    wb_b0_bank2_lane1.bankReadData_lane1_2.en <= _GEN_97
    wb_b0_bank2_lane1.bankReadData_lane1_2.clk <= _GEN_99
    wb_b0_bank2_lane1.MPORT_5.addr <= _GEN_27
    wb_b0_bank2_lane1.MPORT_5.en <= _GEN_29
    wb_b0_bank2_lane1.MPORT_5.clk <= _GEN_28
    wb_b0_bank2_lane1.MPORT_5.data <= _GEN_31
    wb_b0_bank2_lane1.MPORT_5.mask <= _GEN_30
    wb_b0_bank3_lane0.bankReadData_lane0_3.addr <= _GEN_103
    wb_b0_bank3_lane0.bankReadData_lane0_3.en <= _GEN_102
    wb_b0_bank3_lane0.bankReadData_lane0_3.clk <= _GEN_104
    wb_b0_bank3_lane0.MPORT_6.addr <= _GEN_32
    wb_b0_bank3_lane0.MPORT_6.en <= _GEN_34
    wb_b0_bank3_lane0.MPORT_6.clk <= _GEN_33
    wb_b0_bank3_lane0.MPORT_6.data <= _GEN_36
    wb_b0_bank3_lane0.MPORT_6.mask <= _GEN_35
    wb_b0_bank3_lane1.bankReadData_lane1_3.addr <= _GEN_105
    wb_b0_bank3_lane1.bankReadData_lane1_3.en <= _GEN_102
    wb_b0_bank3_lane1.bankReadData_lane1_3.clk <= _GEN_104
    wb_b0_bank3_lane1.MPORT_7.addr <= _GEN_37
    wb_b0_bank3_lane1.MPORT_7.en <= _GEN_39
    wb_b0_bank3_lane1.MPORT_7.clk <= _GEN_38
    wb_b0_bank3_lane1.MPORT_7.data <= _GEN_41
    wb_b0_bank3_lane1.MPORT_7.mask <= _GEN_40
    wb_b1_bank0_lane0.bankReadData_lane0_4.addr <= _GEN_108
    wb_b1_bank0_lane0.bankReadData_lane0_4.en <= _GEN_107
    wb_b1_bank0_lane0.bankReadData_lane0_4.clk <= _GEN_109
    wb_b1_bank0_lane0.MPORT_8.addr <= _GEN_42
    wb_b1_bank0_lane0.MPORT_8.en <= _GEN_44
    wb_b1_bank0_lane0.MPORT_8.clk <= _GEN_43
    wb_b1_bank0_lane0.MPORT_8.data <= _GEN_46
    wb_b1_bank0_lane0.MPORT_8.mask <= _GEN_45
    wb_b1_bank0_lane1.bankReadData_lane1_4.addr <= _GEN_110
    wb_b1_bank0_lane1.bankReadData_lane1_4.en <= _GEN_107
    wb_b1_bank0_lane1.bankReadData_lane1_4.clk <= _GEN_109
    wb_b1_bank0_lane1.MPORT_9.addr <= _GEN_47
    wb_b1_bank0_lane1.MPORT_9.en <= _GEN_49
    wb_b1_bank0_lane1.MPORT_9.clk <= _GEN_48
    wb_b1_bank0_lane1.MPORT_9.data <= _GEN_51
    wb_b1_bank0_lane1.MPORT_9.mask <= _GEN_50
    wb_b1_bank1_lane0.bankReadData_lane0_5.addr <= _GEN_113
    wb_b1_bank1_lane0.bankReadData_lane0_5.en <= _GEN_112
    wb_b1_bank1_lane0.bankReadData_lane0_5.clk <= _GEN_114
    wb_b1_bank1_lane0.MPORT_10.addr <= _GEN_52
    wb_b1_bank1_lane0.MPORT_10.en <= _GEN_54
    wb_b1_bank1_lane0.MPORT_10.clk <= _GEN_53
    wb_b1_bank1_lane0.MPORT_10.data <= _GEN_56
    wb_b1_bank1_lane0.MPORT_10.mask <= _GEN_55
    wb_b1_bank1_lane1.bankReadData_lane1_5.addr <= _GEN_115
    wb_b1_bank1_lane1.bankReadData_lane1_5.en <= _GEN_112
    wb_b1_bank1_lane1.bankReadData_lane1_5.clk <= _GEN_114
    wb_b1_bank1_lane1.MPORT_11.addr <= _GEN_57
    wb_b1_bank1_lane1.MPORT_11.en <= _GEN_59
    wb_b1_bank1_lane1.MPORT_11.clk <= _GEN_58
    wb_b1_bank1_lane1.MPORT_11.data <= _GEN_61
    wb_b1_bank1_lane1.MPORT_11.mask <= _GEN_60
    wb_b1_bank2_lane0.bankReadData_lane0_6.addr <= _GEN_118
    wb_b1_bank2_lane0.bankReadData_lane0_6.en <= _GEN_117
    wb_b1_bank2_lane0.bankReadData_lane0_6.clk <= _GEN_119
    wb_b1_bank2_lane0.MPORT_12.addr <= _GEN_62
    wb_b1_bank2_lane0.MPORT_12.en <= _GEN_64
    wb_b1_bank2_lane0.MPORT_12.clk <= _GEN_63
    wb_b1_bank2_lane0.MPORT_12.data <= _GEN_66
    wb_b1_bank2_lane0.MPORT_12.mask <= _GEN_65
    wb_b1_bank2_lane1.bankReadData_lane1_6.addr <= _GEN_120
    wb_b1_bank2_lane1.bankReadData_lane1_6.en <= _GEN_117
    wb_b1_bank2_lane1.bankReadData_lane1_6.clk <= _GEN_119
    wb_b1_bank2_lane1.MPORT_13.addr <= _GEN_67
    wb_b1_bank2_lane1.MPORT_13.en <= _GEN_69
    wb_b1_bank2_lane1.MPORT_13.clk <= _GEN_68
    wb_b1_bank2_lane1.MPORT_13.data <= _GEN_71
    wb_b1_bank2_lane1.MPORT_13.mask <= _GEN_70
    wb_b1_bank3_lane0.bankReadData_lane0_7.addr <= _GEN_123
    wb_b1_bank3_lane0.bankReadData_lane0_7.en <= _GEN_122
    wb_b1_bank3_lane0.bankReadData_lane0_7.clk <= _GEN_124
    wb_b1_bank3_lane0.MPORT_14.addr <= _GEN_72
    wb_b1_bank3_lane0.MPORT_14.en <= _GEN_74
    wb_b1_bank3_lane0.MPORT_14.clk <= _GEN_73
    wb_b1_bank3_lane0.MPORT_14.data <= _GEN_76
    wb_b1_bank3_lane0.MPORT_14.mask <= _GEN_75
    wb_b1_bank3_lane1.bankReadData_lane1_7.addr <= _GEN_125
    wb_b1_bank3_lane1.bankReadData_lane1_7.en <= _GEN_122
    wb_b1_bank3_lane1.bankReadData_lane1_7.clk <= _GEN_124
    wb_b1_bank3_lane1.MPORT_15.addr <= _GEN_77
    wb_b1_bank3_lane1.MPORT_15.en <= _GEN_79
    wb_b1_bank3_lane1.MPORT_15.clk <= _GEN_78
    wb_b1_bank3_lane1.MPORT_15.data <= _GEN_81
    wb_b1_bank3_lane1.MPORT_15.mask <= _GEN_80
    writeAddr <= mux(reset, UInt<6>("h0"), _GEN_1) @[src/main/scala/weightbuffer.scala 32:{26,26}]
    readAddr <= mux(reset, UInt<8>("h0"), _GEN_85) @[src/main/scala/weightbuffer.scala 33:{26,26}]
    selectedBankReg <= mux(reset, UInt<1>("h0"), _GEN_82) @[src/main/scala/weightbuffer.scala 61:{34,34}]
    selectedBufferReg <= mux(reset, UInt<1>("h0"), _GEN_83) @[src/main/scala/weightbuffer.scala 62:{36,36}]
    io_cu_read_valid_REG <= mux(reset, UInt<1>("h0"), io_cu_read_en) @[src/main/scala/weightbuffer.scala 85:{30,30,30}]
    io_read_done_REG <= mux(reset, UInt<1>("h0"), lastCuRead) @[src/main/scala/weightbuffer.scala 86:{26,26,26}]
