FIRRTL version 1.2.0
circuit WeightBuffer :
  module WeightBuffer : @[src/main/scala/weightbuffer.scala 16:7]
    input clock : Clock @[src/main/scala/weightbuffer.scala 16:7]
    input reset : UInt<1> @[src/main/scala/weightbuffer.scala 16:7]
    input io_dma_valid : UInt<1> @[src/main/scala/weightbuffer.scala 17:14]
    output io_dma_ready : UInt<1> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_addr : UInt<6> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_0 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_1 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_2 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_3 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_4 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_5 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_6 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_7 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_8 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_9 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_10 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_11 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_12 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_13 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_14 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_15 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_16 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_17 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_18 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_19 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_20 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_21 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_22 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_23 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_24 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_25 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_26 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_27 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_28 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_29 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_30 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_31 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_32 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_33 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_34 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_35 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_36 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_37 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_38 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_39 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_40 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_41 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_42 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_43 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_44 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_45 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_46 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_47 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_48 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_49 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_50 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_51 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_52 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_53 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_54 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_55 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_56 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_57 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_58 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_59 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_60 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_61 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_62 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_dma_data_63 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    input io_cu_read_en : UInt<1> @[src/main/scala/weightbuffer.scala 17:14]
    input io_cu_read_addr : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    output io_cu_read_data_0 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    output io_cu_read_data_1 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    output io_cu_read_data_2 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    output io_cu_read_data_3 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    output io_cu_read_data_4 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    output io_cu_read_data_5 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    output io_cu_read_data_6 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    output io_cu_read_data_7 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    output io_cu_read_data_8 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    output io_cu_read_data_9 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    output io_cu_read_data_10 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    output io_cu_read_data_11 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    output io_cu_read_data_12 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    output io_cu_read_data_13 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    output io_cu_read_data_14 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    output io_cu_read_data_15 : UInt<8> @[src/main/scala/weightbuffer.scala 17:14]
    output io_cu_read_valid : UInt<1> @[src/main/scala/weightbuffer.scala 17:14]
    input io_swap : UInt<1> @[src/main/scala/weightbuffer.scala 17:14]
    output io_read_buffer : UInt<1> @[src/main/scala/weightbuffer.scala 17:14]
    output io_write_buffer : UInt<1> @[src/main/scala/weightbuffer.scala 17:14]

    mem banks_0 : @[src/main/scala/weightbuffer.scala 38:39]
      data-type => UInt<32>
      depth => 128
      read-latency => 1
      write-latency => 1
      reader => readWord
      writer => MPORT
      read-under-write => undefined
    mem banks_1 : @[src/main/scala/weightbuffer.scala 38:39]
      data-type => UInt<32>
      depth => 128
      read-latency => 1
      write-latency => 1
      reader => readWord_1
      writer => MPORT_1
      read-under-write => undefined
    mem banks_2 : @[src/main/scala/weightbuffer.scala 38:39]
      data-type => UInt<32>
      depth => 128
      read-latency => 1
      write-latency => 1
      reader => readWord_2
      writer => MPORT_2
      read-under-write => undefined
    mem banks_3 : @[src/main/scala/weightbuffer.scala 38:39]
      data-type => UInt<32>
      depth => 128
      read-latency => 1
      write-latency => 1
      reader => readWord_3
      writer => MPORT_3
      read-under-write => undefined
    mem banks_4 : @[src/main/scala/weightbuffer.scala 38:39]
      data-type => UInt<32>
      depth => 128
      read-latency => 1
      write-latency => 1
      reader => readWord_4
      writer => MPORT_4
      read-under-write => undefined
    mem banks_5 : @[src/main/scala/weightbuffer.scala 38:39]
      data-type => UInt<32>
      depth => 128
      read-latency => 1
      write-latency => 1
      reader => readWord_5
      writer => MPORT_5
      read-under-write => undefined
    mem banks_6 : @[src/main/scala/weightbuffer.scala 38:39]
      data-type => UInt<32>
      depth => 128
      read-latency => 1
      write-latency => 1
      reader => readWord_6
      writer => MPORT_6
      read-under-write => undefined
    mem banks_7 : @[src/main/scala/weightbuffer.scala 38:39]
      data-type => UInt<32>
      depth => 128
      read-latency => 1
      write-latency => 1
      reader => readWord_7
      writer => MPORT_7
      read-under-write => undefined
    mem banks_8 : @[src/main/scala/weightbuffer.scala 38:39]
      data-type => UInt<32>
      depth => 128
      read-latency => 1
      write-latency => 1
      reader => readWord_8
      writer => MPORT_8
      read-under-write => undefined
    mem banks_9 : @[src/main/scala/weightbuffer.scala 38:39]
      data-type => UInt<32>
      depth => 128
      read-latency => 1
      write-latency => 1
      reader => readWord_9
      writer => MPORT_9
      read-under-write => undefined
    mem banks_10 : @[src/main/scala/weightbuffer.scala 38:39]
      data-type => UInt<32>
      depth => 128
      read-latency => 1
      write-latency => 1
      reader => readWord_10
      writer => MPORT_10
      read-under-write => undefined
    mem banks_11 : @[src/main/scala/weightbuffer.scala 38:39]
      data-type => UInt<32>
      depth => 128
      read-latency => 1
      write-latency => 1
      reader => readWord_11
      writer => MPORT_11
      read-under-write => undefined
    mem banks_12 : @[src/main/scala/weightbuffer.scala 38:39]
      data-type => UInt<32>
      depth => 128
      read-latency => 1
      write-latency => 1
      reader => readWord_12
      writer => MPORT_12
      read-under-write => undefined
    mem banks_13 : @[src/main/scala/weightbuffer.scala 38:39]
      data-type => UInt<32>
      depth => 128
      read-latency => 1
      write-latency => 1
      reader => readWord_13
      writer => MPORT_13
      read-under-write => undefined
    mem banks_14 : @[src/main/scala/weightbuffer.scala 38:39]
      data-type => UInt<32>
      depth => 128
      read-latency => 1
      write-latency => 1
      reader => readWord_14
      writer => MPORT_14
      read-under-write => undefined
    mem banks_15 : @[src/main/scala/weightbuffer.scala 38:39]
      data-type => UInt<32>
      depth => 128
      read-latency => 1
      write-latency => 1
      reader => readWord_15
      writer => MPORT_15
      read-under-write => undefined
    reg activeReadBuffer : UInt<1>, clock with :
      reset => (UInt<1>("h0"), activeReadBuffer) @[src/main/scala/weightbuffer.scala 37:33]
    node _io_write_buffer_T = eq(activeReadBuffer, UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 41:22]
    node _io_dma_ready_T = eq(io_swap, UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 44:19]
    node dmaWrite = and(io_dma_valid, io_dma_ready) @[src/main/scala/weightbuffer.scala 45:31]
    node _dmaWordAddr_T = eq(activeReadBuffer, UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 48:25]
    node dmaWordAddr = cat(_dmaWordAddr_T, io_dma_addr) @[src/main/scala/weightbuffer.scala 48:24]
    node _bankWord_WIRE__1 = io_dma_data_16 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node _bankWord_WIRE__0 = io_dma_data_0 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node bankWord_lo = cat(_bankWord_WIRE__1, _bankWord_WIRE__0) @[src/main/scala/weightbuffer.scala 54:8]
    node _bankWord_WIRE__3 = io_dma_data_48 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node _bankWord_WIRE__2 = io_dma_data_32 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node bankWord_hi = cat(_bankWord_WIRE__3, _bankWord_WIRE__2) @[src/main/scala/weightbuffer.scala 54:8]
    node bankWord = cat(bankWord_hi, bankWord_lo) @[src/main/scala/weightbuffer.scala 54:8]
    node _GEN_0 = validif(dmaWrite, dmaWordAddr) @[src/main/scala/weightbuffer.scala 56:20 57:24]
    node _GEN_1 = validif(dmaWrite, clock) @[src/main/scala/weightbuffer.scala 56:20 57:24]
    node _GEN_2 = mux(dmaWrite, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 56:20 57:24 38:39]
    node _GEN_3 = validif(dmaWrite, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 56:20 57:24]
    node _GEN_4 = validif(dmaWrite, bankWord) @[src/main/scala/weightbuffer.scala 56:20 57:24]
    node _bankWord_WIRE_1_1 = io_dma_data_17 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node _bankWord_WIRE_1_0 = io_dma_data_1 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node bankWord_lo_1 = cat(_bankWord_WIRE_1_1, _bankWord_WIRE_1_0) @[src/main/scala/weightbuffer.scala 54:8]
    node _bankWord_WIRE_1_3 = io_dma_data_49 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node _bankWord_WIRE_1_2 = io_dma_data_33 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node bankWord_hi_1 = cat(_bankWord_WIRE_1_3, _bankWord_WIRE_1_2) @[src/main/scala/weightbuffer.scala 54:8]
    node bankWord_1 = cat(bankWord_hi_1, bankWord_lo_1) @[src/main/scala/weightbuffer.scala 54:8]
    node _GEN_5 = validif(dmaWrite, bankWord_1) @[src/main/scala/weightbuffer.scala 56:20 57:24]
    node _bankWord_WIRE_2_1 = io_dma_data_18 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node _bankWord_WIRE_2_0 = io_dma_data_2 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node bankWord_lo_2 = cat(_bankWord_WIRE_2_1, _bankWord_WIRE_2_0) @[src/main/scala/weightbuffer.scala 54:8]
    node _bankWord_WIRE_2_3 = io_dma_data_50 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node _bankWord_WIRE_2_2 = io_dma_data_34 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node bankWord_hi_2 = cat(_bankWord_WIRE_2_3, _bankWord_WIRE_2_2) @[src/main/scala/weightbuffer.scala 54:8]
    node bankWord_2 = cat(bankWord_hi_2, bankWord_lo_2) @[src/main/scala/weightbuffer.scala 54:8]
    node _GEN_6 = validif(dmaWrite, bankWord_2) @[src/main/scala/weightbuffer.scala 56:20 57:24]
    node _bankWord_WIRE_3_1 = io_dma_data_19 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node _bankWord_WIRE_3_0 = io_dma_data_3 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node bankWord_lo_3 = cat(_bankWord_WIRE_3_1, _bankWord_WIRE_3_0) @[src/main/scala/weightbuffer.scala 54:8]
    node _bankWord_WIRE_3_3 = io_dma_data_51 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node _bankWord_WIRE_3_2 = io_dma_data_35 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node bankWord_hi_3 = cat(_bankWord_WIRE_3_3, _bankWord_WIRE_3_2) @[src/main/scala/weightbuffer.scala 54:8]
    node bankWord_3 = cat(bankWord_hi_3, bankWord_lo_3) @[src/main/scala/weightbuffer.scala 54:8]
    node _GEN_7 = validif(dmaWrite, bankWord_3) @[src/main/scala/weightbuffer.scala 56:20 57:24]
    node _bankWord_WIRE_4_1 = io_dma_data_20 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node _bankWord_WIRE_4_0 = io_dma_data_4 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node bankWord_lo_4 = cat(_bankWord_WIRE_4_1, _bankWord_WIRE_4_0) @[src/main/scala/weightbuffer.scala 54:8]
    node _bankWord_WIRE_4_3 = io_dma_data_52 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node _bankWord_WIRE_4_2 = io_dma_data_36 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node bankWord_hi_4 = cat(_bankWord_WIRE_4_3, _bankWord_WIRE_4_2) @[src/main/scala/weightbuffer.scala 54:8]
    node bankWord_4 = cat(bankWord_hi_4, bankWord_lo_4) @[src/main/scala/weightbuffer.scala 54:8]
    node _GEN_8 = validif(dmaWrite, bankWord_4) @[src/main/scala/weightbuffer.scala 56:20 57:24]
    node _bankWord_WIRE_5_1 = io_dma_data_21 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node _bankWord_WIRE_5_0 = io_dma_data_5 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node bankWord_lo_5 = cat(_bankWord_WIRE_5_1, _bankWord_WIRE_5_0) @[src/main/scala/weightbuffer.scala 54:8]
    node _bankWord_WIRE_5_3 = io_dma_data_53 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node _bankWord_WIRE_5_2 = io_dma_data_37 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node bankWord_hi_5 = cat(_bankWord_WIRE_5_3, _bankWord_WIRE_5_2) @[src/main/scala/weightbuffer.scala 54:8]
    node bankWord_5 = cat(bankWord_hi_5, bankWord_lo_5) @[src/main/scala/weightbuffer.scala 54:8]
    node _GEN_9 = validif(dmaWrite, bankWord_5) @[src/main/scala/weightbuffer.scala 56:20 57:24]
    node _bankWord_WIRE_6_1 = io_dma_data_22 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node _bankWord_WIRE_6_0 = io_dma_data_6 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node bankWord_lo_6 = cat(_bankWord_WIRE_6_1, _bankWord_WIRE_6_0) @[src/main/scala/weightbuffer.scala 54:8]
    node _bankWord_WIRE_6_3 = io_dma_data_54 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node _bankWord_WIRE_6_2 = io_dma_data_38 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node bankWord_hi_6 = cat(_bankWord_WIRE_6_3, _bankWord_WIRE_6_2) @[src/main/scala/weightbuffer.scala 54:8]
    node bankWord_6 = cat(bankWord_hi_6, bankWord_lo_6) @[src/main/scala/weightbuffer.scala 54:8]
    node _GEN_10 = validif(dmaWrite, bankWord_6) @[src/main/scala/weightbuffer.scala 56:20 57:24]
    node _bankWord_WIRE_7_1 = io_dma_data_23 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node _bankWord_WIRE_7_0 = io_dma_data_7 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node bankWord_lo_7 = cat(_bankWord_WIRE_7_1, _bankWord_WIRE_7_0) @[src/main/scala/weightbuffer.scala 54:8]
    node _bankWord_WIRE_7_3 = io_dma_data_55 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node _bankWord_WIRE_7_2 = io_dma_data_39 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node bankWord_hi_7 = cat(_bankWord_WIRE_7_3, _bankWord_WIRE_7_2) @[src/main/scala/weightbuffer.scala 54:8]
    node bankWord_7 = cat(bankWord_hi_7, bankWord_lo_7) @[src/main/scala/weightbuffer.scala 54:8]
    node _GEN_11 = validif(dmaWrite, bankWord_7) @[src/main/scala/weightbuffer.scala 56:20 57:24]
    node _bankWord_WIRE_8_1 = io_dma_data_24 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node _bankWord_WIRE_8_0 = io_dma_data_8 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node bankWord_lo_8 = cat(_bankWord_WIRE_8_1, _bankWord_WIRE_8_0) @[src/main/scala/weightbuffer.scala 54:8]
    node _bankWord_WIRE_8_3 = io_dma_data_56 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node _bankWord_WIRE_8_2 = io_dma_data_40 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node bankWord_hi_8 = cat(_bankWord_WIRE_8_3, _bankWord_WIRE_8_2) @[src/main/scala/weightbuffer.scala 54:8]
    node bankWord_8 = cat(bankWord_hi_8, bankWord_lo_8) @[src/main/scala/weightbuffer.scala 54:8]
    node _GEN_12 = validif(dmaWrite, bankWord_8) @[src/main/scala/weightbuffer.scala 56:20 57:24]
    node _bankWord_WIRE_9_1 = io_dma_data_25 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node _bankWord_WIRE_9_0 = io_dma_data_9 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node bankWord_lo_9 = cat(_bankWord_WIRE_9_1, _bankWord_WIRE_9_0) @[src/main/scala/weightbuffer.scala 54:8]
    node _bankWord_WIRE_9_3 = io_dma_data_57 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node _bankWord_WIRE_9_2 = io_dma_data_41 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node bankWord_hi_9 = cat(_bankWord_WIRE_9_3, _bankWord_WIRE_9_2) @[src/main/scala/weightbuffer.scala 54:8]
    node bankWord_9 = cat(bankWord_hi_9, bankWord_lo_9) @[src/main/scala/weightbuffer.scala 54:8]
    node _GEN_13 = validif(dmaWrite, bankWord_9) @[src/main/scala/weightbuffer.scala 56:20 57:24]
    node _bankWord_WIRE_10_1 = io_dma_data_26 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node _bankWord_WIRE_10_0 = io_dma_data_10 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node bankWord_lo_10 = cat(_bankWord_WIRE_10_1, _bankWord_WIRE_10_0) @[src/main/scala/weightbuffer.scala 54:8]
    node _bankWord_WIRE_10_3 = io_dma_data_58 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node _bankWord_WIRE_10_2 = io_dma_data_42 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node bankWord_hi_10 = cat(_bankWord_WIRE_10_3, _bankWord_WIRE_10_2) @[src/main/scala/weightbuffer.scala 54:8]
    node bankWord_10 = cat(bankWord_hi_10, bankWord_lo_10) @[src/main/scala/weightbuffer.scala 54:8]
    node _GEN_14 = validif(dmaWrite, bankWord_10) @[src/main/scala/weightbuffer.scala 56:20 57:24]
    node _bankWord_WIRE_11_1 = io_dma_data_27 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node _bankWord_WIRE_11_0 = io_dma_data_11 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node bankWord_lo_11 = cat(_bankWord_WIRE_11_1, _bankWord_WIRE_11_0) @[src/main/scala/weightbuffer.scala 54:8]
    node _bankWord_WIRE_11_3 = io_dma_data_59 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node _bankWord_WIRE_11_2 = io_dma_data_43 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node bankWord_hi_11 = cat(_bankWord_WIRE_11_3, _bankWord_WIRE_11_2) @[src/main/scala/weightbuffer.scala 54:8]
    node bankWord_11 = cat(bankWord_hi_11, bankWord_lo_11) @[src/main/scala/weightbuffer.scala 54:8]
    node _GEN_15 = validif(dmaWrite, bankWord_11) @[src/main/scala/weightbuffer.scala 56:20 57:24]
    node _bankWord_WIRE_12_1 = io_dma_data_28 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node _bankWord_WIRE_12_0 = io_dma_data_12 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node bankWord_lo_12 = cat(_bankWord_WIRE_12_1, _bankWord_WIRE_12_0) @[src/main/scala/weightbuffer.scala 54:8]
    node _bankWord_WIRE_12_3 = io_dma_data_60 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node _bankWord_WIRE_12_2 = io_dma_data_44 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node bankWord_hi_12 = cat(_bankWord_WIRE_12_3, _bankWord_WIRE_12_2) @[src/main/scala/weightbuffer.scala 54:8]
    node bankWord_12 = cat(bankWord_hi_12, bankWord_lo_12) @[src/main/scala/weightbuffer.scala 54:8]
    node _GEN_16 = validif(dmaWrite, bankWord_12) @[src/main/scala/weightbuffer.scala 56:20 57:24]
    node _bankWord_WIRE_13_1 = io_dma_data_29 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node _bankWord_WIRE_13_0 = io_dma_data_13 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node bankWord_lo_13 = cat(_bankWord_WIRE_13_1, _bankWord_WIRE_13_0) @[src/main/scala/weightbuffer.scala 54:8]
    node _bankWord_WIRE_13_3 = io_dma_data_61 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node _bankWord_WIRE_13_2 = io_dma_data_45 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node bankWord_hi_13 = cat(_bankWord_WIRE_13_3, _bankWord_WIRE_13_2) @[src/main/scala/weightbuffer.scala 54:8]
    node bankWord_13 = cat(bankWord_hi_13, bankWord_lo_13) @[src/main/scala/weightbuffer.scala 54:8]
    node _GEN_17 = validif(dmaWrite, bankWord_13) @[src/main/scala/weightbuffer.scala 56:20 57:24]
    node _bankWord_WIRE_14_1 = io_dma_data_30 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node _bankWord_WIRE_14_0 = io_dma_data_14 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node bankWord_lo_14 = cat(_bankWord_WIRE_14_1, _bankWord_WIRE_14_0) @[src/main/scala/weightbuffer.scala 54:8]
    node _bankWord_WIRE_14_3 = io_dma_data_62 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node _bankWord_WIRE_14_2 = io_dma_data_46 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node bankWord_hi_14 = cat(_bankWord_WIRE_14_3, _bankWord_WIRE_14_2) @[src/main/scala/weightbuffer.scala 54:8]
    node bankWord_14 = cat(bankWord_hi_14, bankWord_lo_14) @[src/main/scala/weightbuffer.scala 54:8]
    node _GEN_18 = validif(dmaWrite, bankWord_14) @[src/main/scala/weightbuffer.scala 56:20 57:24]
    node _bankWord_WIRE_15_1 = io_dma_data_31 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node _bankWord_WIRE_15_0 = io_dma_data_15 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node bankWord_lo_15 = cat(_bankWord_WIRE_15_1, _bankWord_WIRE_15_0) @[src/main/scala/weightbuffer.scala 54:8]
    node _bankWord_WIRE_15_3 = io_dma_data_63 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node _bankWord_WIRE_15_2 = io_dma_data_47 @[src/main/scala/weightbuffer.scala 52:{27,27}]
    node bankWord_hi_15 = cat(_bankWord_WIRE_15_3, _bankWord_WIRE_15_2) @[src/main/scala/weightbuffer.scala 54:8]
    node bankWord_15 = cat(bankWord_hi_15, bankWord_lo_15) @[src/main/scala/weightbuffer.scala 54:8]
    node _GEN_19 = validif(dmaWrite, bankWord_15) @[src/main/scala/weightbuffer.scala 56:20 57:24]
    node _cuRead_T = eq(io_swap, UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 61:33]
    node cuRead = and(io_cu_read_en, _cuRead_T) @[src/main/scala/weightbuffer.scala 61:30]
    node _cuWordAddr_T = bits(io_cu_read_addr, 7, 2) @[src/main/scala/weightbuffer.scala 62:57]
    node cuWordAddr = cat(activeReadBuffer, _cuWordAddr_T) @[src/main/scala/weightbuffer.scala 62:23]
    node _cuByteSelect_T = bits(io_cu_read_addr, 1, 0) @[src/main/scala/weightbuffer.scala 63:47]
    reg cuByteSelect : UInt<2>, clock with :
      reset => (UInt<1>("h0"), cuByteSelect) @[src/main/scala/weightbuffer.scala 63:31]
    node _GEN_20 = mux(cuRead, _cuByteSelect_T, cuByteSelect) @[src/main/scala/weightbuffer.scala 63:{31,31,31}]
    node _GEN_21 = validif(cuRead, cuWordAddr) @[src/main/scala/weightbuffer.scala 66:{36,36}]
    node _GEN_22 = mux(cuRead, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 66:{36,36} 38:39]
    node _readWord_WIRE = _GEN_21 @[src/main/scala/weightbuffer.scala 66:36]
    node _GEN_23 = validif(cuRead, _readWord_WIRE) @[src/main/scala/weightbuffer.scala 66:{36,36}]
    node _GEN_24 = validif(cuRead, clock) @[src/main/scala/weightbuffer.scala 66:{36,36}]
    node _io_cu_read_data_0_WIRE_1 = banks_0.readWord.data @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _io_cu_read_data_0_T = bits(_io_cu_read_data_0_WIRE_1, 7, 0) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_0_T_1 = bits(_io_cu_read_data_0_WIRE_1, 15, 8) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_0_T_2 = bits(_io_cu_read_data_0_WIRE_1, 23, 16) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_0_T_3 = bits(_io_cu_read_data_0_WIRE_1, 31, 24) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_0_T_4 = or(cuByteSelect, UInt<2>("h0"))
    node _io_cu_read_data_0_T_5 = bits(_io_cu_read_data_0_T_4, 1, 0)
    node _io_cu_read_data_0_WIRE__0 = _io_cu_read_data_0_T @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_25 = validif(eq(UInt<1>("h0"), _io_cu_read_data_0_T_5), _io_cu_read_data_0_WIRE__0) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_0_WIRE__1 = _io_cu_read_data_0_T_1 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_26 = mux(eq(UInt<1>("h1"), _io_cu_read_data_0_T_5), _io_cu_read_data_0_WIRE__1, _GEN_25) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_0_WIRE__2 = _io_cu_read_data_0_T_2 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_27 = mux(eq(UInt<2>("h2"), _io_cu_read_data_0_T_5), _io_cu_read_data_0_WIRE__2, _GEN_26) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_0_WIRE__3 = _io_cu_read_data_0_T_3 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_28 = mux(eq(UInt<2>("h3"), _io_cu_read_data_0_T_5), _io_cu_read_data_0_WIRE__3, _GEN_27) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _readWord_WIRE_1 = _GEN_21 @[src/main/scala/weightbuffer.scala 66:36]
    node _GEN_29 = validif(cuRead, _readWord_WIRE_1) @[src/main/scala/weightbuffer.scala 66:{36,36}]
    node _io_cu_read_data_1_WIRE_1 = banks_1.readWord_1.data @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _io_cu_read_data_1_T = bits(_io_cu_read_data_1_WIRE_1, 7, 0) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_1_T_1 = bits(_io_cu_read_data_1_WIRE_1, 15, 8) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_1_T_2 = bits(_io_cu_read_data_1_WIRE_1, 23, 16) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_1_T_3 = bits(_io_cu_read_data_1_WIRE_1, 31, 24) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_1_T_4 = or(cuByteSelect, UInt<2>("h0"))
    node _io_cu_read_data_1_T_5 = bits(_io_cu_read_data_1_T_4, 1, 0)
    node _io_cu_read_data_1_WIRE__0 = _io_cu_read_data_1_T @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_30 = validif(eq(UInt<1>("h0"), _io_cu_read_data_1_T_5), _io_cu_read_data_1_WIRE__0) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_1_WIRE__1 = _io_cu_read_data_1_T_1 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_31 = mux(eq(UInt<1>("h1"), _io_cu_read_data_1_T_5), _io_cu_read_data_1_WIRE__1, _GEN_30) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_1_WIRE__2 = _io_cu_read_data_1_T_2 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_32 = mux(eq(UInt<2>("h2"), _io_cu_read_data_1_T_5), _io_cu_read_data_1_WIRE__2, _GEN_31) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_1_WIRE__3 = _io_cu_read_data_1_T_3 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_33 = mux(eq(UInt<2>("h3"), _io_cu_read_data_1_T_5), _io_cu_read_data_1_WIRE__3, _GEN_32) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _readWord_WIRE_2 = _GEN_21 @[src/main/scala/weightbuffer.scala 66:36]
    node _GEN_34 = validif(cuRead, _readWord_WIRE_2) @[src/main/scala/weightbuffer.scala 66:{36,36}]
    node _io_cu_read_data_2_WIRE_1 = banks_2.readWord_2.data @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _io_cu_read_data_2_T = bits(_io_cu_read_data_2_WIRE_1, 7, 0) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_2_T_1 = bits(_io_cu_read_data_2_WIRE_1, 15, 8) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_2_T_2 = bits(_io_cu_read_data_2_WIRE_1, 23, 16) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_2_T_3 = bits(_io_cu_read_data_2_WIRE_1, 31, 24) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_2_T_4 = or(cuByteSelect, UInt<2>("h0"))
    node _io_cu_read_data_2_T_5 = bits(_io_cu_read_data_2_T_4, 1, 0)
    node _io_cu_read_data_2_WIRE__0 = _io_cu_read_data_2_T @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_35 = validif(eq(UInt<1>("h0"), _io_cu_read_data_2_T_5), _io_cu_read_data_2_WIRE__0) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_2_WIRE__1 = _io_cu_read_data_2_T_1 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_36 = mux(eq(UInt<1>("h1"), _io_cu_read_data_2_T_5), _io_cu_read_data_2_WIRE__1, _GEN_35) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_2_WIRE__2 = _io_cu_read_data_2_T_2 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_37 = mux(eq(UInt<2>("h2"), _io_cu_read_data_2_T_5), _io_cu_read_data_2_WIRE__2, _GEN_36) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_2_WIRE__3 = _io_cu_read_data_2_T_3 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_38 = mux(eq(UInt<2>("h3"), _io_cu_read_data_2_T_5), _io_cu_read_data_2_WIRE__3, _GEN_37) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _readWord_WIRE_3 = _GEN_21 @[src/main/scala/weightbuffer.scala 66:36]
    node _GEN_39 = validif(cuRead, _readWord_WIRE_3) @[src/main/scala/weightbuffer.scala 66:{36,36}]
    node _io_cu_read_data_3_WIRE_1 = banks_3.readWord_3.data @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _io_cu_read_data_3_T = bits(_io_cu_read_data_3_WIRE_1, 7, 0) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_3_T_1 = bits(_io_cu_read_data_3_WIRE_1, 15, 8) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_3_T_2 = bits(_io_cu_read_data_3_WIRE_1, 23, 16) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_3_T_3 = bits(_io_cu_read_data_3_WIRE_1, 31, 24) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_3_T_4 = or(cuByteSelect, UInt<2>("h0"))
    node _io_cu_read_data_3_T_5 = bits(_io_cu_read_data_3_T_4, 1, 0)
    node _io_cu_read_data_3_WIRE__0 = _io_cu_read_data_3_T @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_40 = validif(eq(UInt<1>("h0"), _io_cu_read_data_3_T_5), _io_cu_read_data_3_WIRE__0) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_3_WIRE__1 = _io_cu_read_data_3_T_1 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_41 = mux(eq(UInt<1>("h1"), _io_cu_read_data_3_T_5), _io_cu_read_data_3_WIRE__1, _GEN_40) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_3_WIRE__2 = _io_cu_read_data_3_T_2 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_42 = mux(eq(UInt<2>("h2"), _io_cu_read_data_3_T_5), _io_cu_read_data_3_WIRE__2, _GEN_41) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_3_WIRE__3 = _io_cu_read_data_3_T_3 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_43 = mux(eq(UInt<2>("h3"), _io_cu_read_data_3_T_5), _io_cu_read_data_3_WIRE__3, _GEN_42) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _readWord_WIRE_4 = _GEN_21 @[src/main/scala/weightbuffer.scala 66:36]
    node _GEN_44 = validif(cuRead, _readWord_WIRE_4) @[src/main/scala/weightbuffer.scala 66:{36,36}]
    node _io_cu_read_data_4_WIRE_1 = banks_4.readWord_4.data @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _io_cu_read_data_4_T = bits(_io_cu_read_data_4_WIRE_1, 7, 0) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_4_T_1 = bits(_io_cu_read_data_4_WIRE_1, 15, 8) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_4_T_2 = bits(_io_cu_read_data_4_WIRE_1, 23, 16) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_4_T_3 = bits(_io_cu_read_data_4_WIRE_1, 31, 24) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_4_T_4 = or(cuByteSelect, UInt<2>("h0"))
    node _io_cu_read_data_4_T_5 = bits(_io_cu_read_data_4_T_4, 1, 0)
    node _io_cu_read_data_4_WIRE__0 = _io_cu_read_data_4_T @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_45 = validif(eq(UInt<1>("h0"), _io_cu_read_data_4_T_5), _io_cu_read_data_4_WIRE__0) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_4_WIRE__1 = _io_cu_read_data_4_T_1 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_46 = mux(eq(UInt<1>("h1"), _io_cu_read_data_4_T_5), _io_cu_read_data_4_WIRE__1, _GEN_45) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_4_WIRE__2 = _io_cu_read_data_4_T_2 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_47 = mux(eq(UInt<2>("h2"), _io_cu_read_data_4_T_5), _io_cu_read_data_4_WIRE__2, _GEN_46) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_4_WIRE__3 = _io_cu_read_data_4_T_3 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_48 = mux(eq(UInt<2>("h3"), _io_cu_read_data_4_T_5), _io_cu_read_data_4_WIRE__3, _GEN_47) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _readWord_WIRE_5 = _GEN_21 @[src/main/scala/weightbuffer.scala 66:36]
    node _GEN_49 = validif(cuRead, _readWord_WIRE_5) @[src/main/scala/weightbuffer.scala 66:{36,36}]
    node _io_cu_read_data_5_WIRE_1 = banks_5.readWord_5.data @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _io_cu_read_data_5_T = bits(_io_cu_read_data_5_WIRE_1, 7, 0) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_5_T_1 = bits(_io_cu_read_data_5_WIRE_1, 15, 8) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_5_T_2 = bits(_io_cu_read_data_5_WIRE_1, 23, 16) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_5_T_3 = bits(_io_cu_read_data_5_WIRE_1, 31, 24) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_5_T_4 = or(cuByteSelect, UInt<2>("h0"))
    node _io_cu_read_data_5_T_5 = bits(_io_cu_read_data_5_T_4, 1, 0)
    node _io_cu_read_data_5_WIRE__0 = _io_cu_read_data_5_T @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_50 = validif(eq(UInt<1>("h0"), _io_cu_read_data_5_T_5), _io_cu_read_data_5_WIRE__0) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_5_WIRE__1 = _io_cu_read_data_5_T_1 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_51 = mux(eq(UInt<1>("h1"), _io_cu_read_data_5_T_5), _io_cu_read_data_5_WIRE__1, _GEN_50) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_5_WIRE__2 = _io_cu_read_data_5_T_2 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_52 = mux(eq(UInt<2>("h2"), _io_cu_read_data_5_T_5), _io_cu_read_data_5_WIRE__2, _GEN_51) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_5_WIRE__3 = _io_cu_read_data_5_T_3 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_53 = mux(eq(UInt<2>("h3"), _io_cu_read_data_5_T_5), _io_cu_read_data_5_WIRE__3, _GEN_52) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _readWord_WIRE_6 = _GEN_21 @[src/main/scala/weightbuffer.scala 66:36]
    node _GEN_54 = validif(cuRead, _readWord_WIRE_6) @[src/main/scala/weightbuffer.scala 66:{36,36}]
    node _io_cu_read_data_6_WIRE_1 = banks_6.readWord_6.data @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _io_cu_read_data_6_T = bits(_io_cu_read_data_6_WIRE_1, 7, 0) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_6_T_1 = bits(_io_cu_read_data_6_WIRE_1, 15, 8) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_6_T_2 = bits(_io_cu_read_data_6_WIRE_1, 23, 16) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_6_T_3 = bits(_io_cu_read_data_6_WIRE_1, 31, 24) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_6_T_4 = or(cuByteSelect, UInt<2>("h0"))
    node _io_cu_read_data_6_T_5 = bits(_io_cu_read_data_6_T_4, 1, 0)
    node _io_cu_read_data_6_WIRE__0 = _io_cu_read_data_6_T @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_55 = validif(eq(UInt<1>("h0"), _io_cu_read_data_6_T_5), _io_cu_read_data_6_WIRE__0) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_6_WIRE__1 = _io_cu_read_data_6_T_1 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_56 = mux(eq(UInt<1>("h1"), _io_cu_read_data_6_T_5), _io_cu_read_data_6_WIRE__1, _GEN_55) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_6_WIRE__2 = _io_cu_read_data_6_T_2 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_57 = mux(eq(UInt<2>("h2"), _io_cu_read_data_6_T_5), _io_cu_read_data_6_WIRE__2, _GEN_56) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_6_WIRE__3 = _io_cu_read_data_6_T_3 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_58 = mux(eq(UInt<2>("h3"), _io_cu_read_data_6_T_5), _io_cu_read_data_6_WIRE__3, _GEN_57) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _readWord_WIRE_7 = _GEN_21 @[src/main/scala/weightbuffer.scala 66:36]
    node _GEN_59 = validif(cuRead, _readWord_WIRE_7) @[src/main/scala/weightbuffer.scala 66:{36,36}]
    node _io_cu_read_data_7_WIRE_1 = banks_7.readWord_7.data @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _io_cu_read_data_7_T = bits(_io_cu_read_data_7_WIRE_1, 7, 0) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_7_T_1 = bits(_io_cu_read_data_7_WIRE_1, 15, 8) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_7_T_2 = bits(_io_cu_read_data_7_WIRE_1, 23, 16) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_7_T_3 = bits(_io_cu_read_data_7_WIRE_1, 31, 24) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_7_T_4 = or(cuByteSelect, UInt<2>("h0"))
    node _io_cu_read_data_7_T_5 = bits(_io_cu_read_data_7_T_4, 1, 0)
    node _io_cu_read_data_7_WIRE__0 = _io_cu_read_data_7_T @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_60 = validif(eq(UInt<1>("h0"), _io_cu_read_data_7_T_5), _io_cu_read_data_7_WIRE__0) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_7_WIRE__1 = _io_cu_read_data_7_T_1 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_61 = mux(eq(UInt<1>("h1"), _io_cu_read_data_7_T_5), _io_cu_read_data_7_WIRE__1, _GEN_60) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_7_WIRE__2 = _io_cu_read_data_7_T_2 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_62 = mux(eq(UInt<2>("h2"), _io_cu_read_data_7_T_5), _io_cu_read_data_7_WIRE__2, _GEN_61) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_7_WIRE__3 = _io_cu_read_data_7_T_3 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_63 = mux(eq(UInt<2>("h3"), _io_cu_read_data_7_T_5), _io_cu_read_data_7_WIRE__3, _GEN_62) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _readWord_WIRE_8 = _GEN_21 @[src/main/scala/weightbuffer.scala 66:36]
    node _GEN_64 = validif(cuRead, _readWord_WIRE_8) @[src/main/scala/weightbuffer.scala 66:{36,36}]
    node _io_cu_read_data_8_WIRE_1 = banks_8.readWord_8.data @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _io_cu_read_data_8_T = bits(_io_cu_read_data_8_WIRE_1, 7, 0) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_8_T_1 = bits(_io_cu_read_data_8_WIRE_1, 15, 8) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_8_T_2 = bits(_io_cu_read_data_8_WIRE_1, 23, 16) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_8_T_3 = bits(_io_cu_read_data_8_WIRE_1, 31, 24) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_8_T_4 = or(cuByteSelect, UInt<2>("h0"))
    node _io_cu_read_data_8_T_5 = bits(_io_cu_read_data_8_T_4, 1, 0)
    node _io_cu_read_data_8_WIRE__0 = _io_cu_read_data_8_T @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_65 = validif(eq(UInt<1>("h0"), _io_cu_read_data_8_T_5), _io_cu_read_data_8_WIRE__0) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_8_WIRE__1 = _io_cu_read_data_8_T_1 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_66 = mux(eq(UInt<1>("h1"), _io_cu_read_data_8_T_5), _io_cu_read_data_8_WIRE__1, _GEN_65) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_8_WIRE__2 = _io_cu_read_data_8_T_2 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_67 = mux(eq(UInt<2>("h2"), _io_cu_read_data_8_T_5), _io_cu_read_data_8_WIRE__2, _GEN_66) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_8_WIRE__3 = _io_cu_read_data_8_T_3 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_68 = mux(eq(UInt<2>("h3"), _io_cu_read_data_8_T_5), _io_cu_read_data_8_WIRE__3, _GEN_67) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _readWord_WIRE_9 = _GEN_21 @[src/main/scala/weightbuffer.scala 66:36]
    node _GEN_69 = validif(cuRead, _readWord_WIRE_9) @[src/main/scala/weightbuffer.scala 66:{36,36}]
    node _io_cu_read_data_9_WIRE_1 = banks_9.readWord_9.data @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _io_cu_read_data_9_T = bits(_io_cu_read_data_9_WIRE_1, 7, 0) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_9_T_1 = bits(_io_cu_read_data_9_WIRE_1, 15, 8) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_9_T_2 = bits(_io_cu_read_data_9_WIRE_1, 23, 16) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_9_T_3 = bits(_io_cu_read_data_9_WIRE_1, 31, 24) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_9_T_4 = or(cuByteSelect, UInt<2>("h0"))
    node _io_cu_read_data_9_T_5 = bits(_io_cu_read_data_9_T_4, 1, 0)
    node _io_cu_read_data_9_WIRE__0 = _io_cu_read_data_9_T @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_70 = validif(eq(UInt<1>("h0"), _io_cu_read_data_9_T_5), _io_cu_read_data_9_WIRE__0) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_9_WIRE__1 = _io_cu_read_data_9_T_1 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_71 = mux(eq(UInt<1>("h1"), _io_cu_read_data_9_T_5), _io_cu_read_data_9_WIRE__1, _GEN_70) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_9_WIRE__2 = _io_cu_read_data_9_T_2 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_72 = mux(eq(UInt<2>("h2"), _io_cu_read_data_9_T_5), _io_cu_read_data_9_WIRE__2, _GEN_71) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_9_WIRE__3 = _io_cu_read_data_9_T_3 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_73 = mux(eq(UInt<2>("h3"), _io_cu_read_data_9_T_5), _io_cu_read_data_9_WIRE__3, _GEN_72) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _readWord_WIRE_10 = _GEN_21 @[src/main/scala/weightbuffer.scala 66:36]
    node _GEN_74 = validif(cuRead, _readWord_WIRE_10) @[src/main/scala/weightbuffer.scala 66:{36,36}]
    node _io_cu_read_data_10_WIRE_1 = banks_10.readWord_10.data @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _io_cu_read_data_10_T = bits(_io_cu_read_data_10_WIRE_1, 7, 0) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_10_T_1 = bits(_io_cu_read_data_10_WIRE_1, 15, 8) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_10_T_2 = bits(_io_cu_read_data_10_WIRE_1, 23, 16) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_10_T_3 = bits(_io_cu_read_data_10_WIRE_1, 31, 24) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_10_T_4 = or(cuByteSelect, UInt<2>("h0"))
    node _io_cu_read_data_10_T_5 = bits(_io_cu_read_data_10_T_4, 1, 0)
    node _io_cu_read_data_10_WIRE__0 = _io_cu_read_data_10_T @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_75 = validif(eq(UInt<1>("h0"), _io_cu_read_data_10_T_5), _io_cu_read_data_10_WIRE__0) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_10_WIRE__1 = _io_cu_read_data_10_T_1 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_76 = mux(eq(UInt<1>("h1"), _io_cu_read_data_10_T_5), _io_cu_read_data_10_WIRE__1, _GEN_75) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_10_WIRE__2 = _io_cu_read_data_10_T_2 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_77 = mux(eq(UInt<2>("h2"), _io_cu_read_data_10_T_5), _io_cu_read_data_10_WIRE__2, _GEN_76) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_10_WIRE__3 = _io_cu_read_data_10_T_3 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_78 = mux(eq(UInt<2>("h3"), _io_cu_read_data_10_T_5), _io_cu_read_data_10_WIRE__3, _GEN_77) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _readWord_WIRE_11 = _GEN_21 @[src/main/scala/weightbuffer.scala 66:36]
    node _GEN_79 = validif(cuRead, _readWord_WIRE_11) @[src/main/scala/weightbuffer.scala 66:{36,36}]
    node _io_cu_read_data_11_WIRE_1 = banks_11.readWord_11.data @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _io_cu_read_data_11_T = bits(_io_cu_read_data_11_WIRE_1, 7, 0) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_11_T_1 = bits(_io_cu_read_data_11_WIRE_1, 15, 8) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_11_T_2 = bits(_io_cu_read_data_11_WIRE_1, 23, 16) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_11_T_3 = bits(_io_cu_read_data_11_WIRE_1, 31, 24) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_11_T_4 = or(cuByteSelect, UInt<2>("h0"))
    node _io_cu_read_data_11_T_5 = bits(_io_cu_read_data_11_T_4, 1, 0)
    node _io_cu_read_data_11_WIRE__0 = _io_cu_read_data_11_T @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_80 = validif(eq(UInt<1>("h0"), _io_cu_read_data_11_T_5), _io_cu_read_data_11_WIRE__0) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_11_WIRE__1 = _io_cu_read_data_11_T_1 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_81 = mux(eq(UInt<1>("h1"), _io_cu_read_data_11_T_5), _io_cu_read_data_11_WIRE__1, _GEN_80) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_11_WIRE__2 = _io_cu_read_data_11_T_2 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_82 = mux(eq(UInt<2>("h2"), _io_cu_read_data_11_T_5), _io_cu_read_data_11_WIRE__2, _GEN_81) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_11_WIRE__3 = _io_cu_read_data_11_T_3 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_83 = mux(eq(UInt<2>("h3"), _io_cu_read_data_11_T_5), _io_cu_read_data_11_WIRE__3, _GEN_82) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _readWord_WIRE_12 = _GEN_21 @[src/main/scala/weightbuffer.scala 66:36]
    node _GEN_84 = validif(cuRead, _readWord_WIRE_12) @[src/main/scala/weightbuffer.scala 66:{36,36}]
    node _io_cu_read_data_12_WIRE_1 = banks_12.readWord_12.data @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _io_cu_read_data_12_T = bits(_io_cu_read_data_12_WIRE_1, 7, 0) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_12_T_1 = bits(_io_cu_read_data_12_WIRE_1, 15, 8) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_12_T_2 = bits(_io_cu_read_data_12_WIRE_1, 23, 16) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_12_T_3 = bits(_io_cu_read_data_12_WIRE_1, 31, 24) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_12_T_4 = or(cuByteSelect, UInt<2>("h0"))
    node _io_cu_read_data_12_T_5 = bits(_io_cu_read_data_12_T_4, 1, 0)
    node _io_cu_read_data_12_WIRE__0 = _io_cu_read_data_12_T @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_85 = validif(eq(UInt<1>("h0"), _io_cu_read_data_12_T_5), _io_cu_read_data_12_WIRE__0) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_12_WIRE__1 = _io_cu_read_data_12_T_1 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_86 = mux(eq(UInt<1>("h1"), _io_cu_read_data_12_T_5), _io_cu_read_data_12_WIRE__1, _GEN_85) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_12_WIRE__2 = _io_cu_read_data_12_T_2 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_87 = mux(eq(UInt<2>("h2"), _io_cu_read_data_12_T_5), _io_cu_read_data_12_WIRE__2, _GEN_86) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_12_WIRE__3 = _io_cu_read_data_12_T_3 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_88 = mux(eq(UInt<2>("h3"), _io_cu_read_data_12_T_5), _io_cu_read_data_12_WIRE__3, _GEN_87) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _readWord_WIRE_13 = _GEN_21 @[src/main/scala/weightbuffer.scala 66:36]
    node _GEN_89 = validif(cuRead, _readWord_WIRE_13) @[src/main/scala/weightbuffer.scala 66:{36,36}]
    node _io_cu_read_data_13_WIRE_1 = banks_13.readWord_13.data @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _io_cu_read_data_13_T = bits(_io_cu_read_data_13_WIRE_1, 7, 0) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_13_T_1 = bits(_io_cu_read_data_13_WIRE_1, 15, 8) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_13_T_2 = bits(_io_cu_read_data_13_WIRE_1, 23, 16) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_13_T_3 = bits(_io_cu_read_data_13_WIRE_1, 31, 24) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_13_T_4 = or(cuByteSelect, UInt<2>("h0"))
    node _io_cu_read_data_13_T_5 = bits(_io_cu_read_data_13_T_4, 1, 0)
    node _io_cu_read_data_13_WIRE__0 = _io_cu_read_data_13_T @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_90 = validif(eq(UInt<1>("h0"), _io_cu_read_data_13_T_5), _io_cu_read_data_13_WIRE__0) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_13_WIRE__1 = _io_cu_read_data_13_T_1 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_91 = mux(eq(UInt<1>("h1"), _io_cu_read_data_13_T_5), _io_cu_read_data_13_WIRE__1, _GEN_90) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_13_WIRE__2 = _io_cu_read_data_13_T_2 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_92 = mux(eq(UInt<2>("h2"), _io_cu_read_data_13_T_5), _io_cu_read_data_13_WIRE__2, _GEN_91) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_13_WIRE__3 = _io_cu_read_data_13_T_3 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_93 = mux(eq(UInt<2>("h3"), _io_cu_read_data_13_T_5), _io_cu_read_data_13_WIRE__3, _GEN_92) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _readWord_WIRE_14 = _GEN_21 @[src/main/scala/weightbuffer.scala 66:36]
    node _GEN_94 = validif(cuRead, _readWord_WIRE_14) @[src/main/scala/weightbuffer.scala 66:{36,36}]
    node _io_cu_read_data_14_WIRE_1 = banks_14.readWord_14.data @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _io_cu_read_data_14_T = bits(_io_cu_read_data_14_WIRE_1, 7, 0) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_14_T_1 = bits(_io_cu_read_data_14_WIRE_1, 15, 8) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_14_T_2 = bits(_io_cu_read_data_14_WIRE_1, 23, 16) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_14_T_3 = bits(_io_cu_read_data_14_WIRE_1, 31, 24) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_14_T_4 = or(cuByteSelect, UInt<2>("h0"))
    node _io_cu_read_data_14_T_5 = bits(_io_cu_read_data_14_T_4, 1, 0)
    node _io_cu_read_data_14_WIRE__0 = _io_cu_read_data_14_T @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_95 = validif(eq(UInt<1>("h0"), _io_cu_read_data_14_T_5), _io_cu_read_data_14_WIRE__0) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_14_WIRE__1 = _io_cu_read_data_14_T_1 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_96 = mux(eq(UInt<1>("h1"), _io_cu_read_data_14_T_5), _io_cu_read_data_14_WIRE__1, _GEN_95) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_14_WIRE__2 = _io_cu_read_data_14_T_2 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_97 = mux(eq(UInt<2>("h2"), _io_cu_read_data_14_T_5), _io_cu_read_data_14_WIRE__2, _GEN_96) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_14_WIRE__3 = _io_cu_read_data_14_T_3 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_98 = mux(eq(UInt<2>("h3"), _io_cu_read_data_14_T_5), _io_cu_read_data_14_WIRE__3, _GEN_97) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _readWord_WIRE_15 = _GEN_21 @[src/main/scala/weightbuffer.scala 66:36]
    node _GEN_99 = validif(cuRead, _readWord_WIRE_15) @[src/main/scala/weightbuffer.scala 66:{36,36}]
    node _io_cu_read_data_15_WIRE_1 = banks_15.readWord_15.data @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _io_cu_read_data_15_T = bits(_io_cu_read_data_15_WIRE_1, 7, 0) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_15_T_1 = bits(_io_cu_read_data_15_WIRE_1, 15, 8) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_15_T_2 = bits(_io_cu_read_data_15_WIRE_1, 23, 16) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_15_T_3 = bits(_io_cu_read_data_15_WIRE_1, 31, 24) @[src/main/scala/weightbuffer.scala 68:24]
    node _io_cu_read_data_15_T_4 = or(cuByteSelect, UInt<2>("h0"))
    node _io_cu_read_data_15_T_5 = bits(_io_cu_read_data_15_T_4, 1, 0)
    node _io_cu_read_data_15_WIRE__0 = _io_cu_read_data_15_T @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_100 = validif(eq(UInt<1>("h0"), _io_cu_read_data_15_T_5), _io_cu_read_data_15_WIRE__0) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_15_WIRE__1 = _io_cu_read_data_15_T_1 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_101 = mux(eq(UInt<1>("h1"), _io_cu_read_data_15_T_5), _io_cu_read_data_15_WIRE__1, _GEN_100) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_15_WIRE__2 = _io_cu_read_data_15_T_2 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_102 = mux(eq(UInt<2>("h2"), _io_cu_read_data_15_T_5), _io_cu_read_data_15_WIRE__2, _GEN_101) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    node _io_cu_read_data_15_WIRE__3 = _io_cu_read_data_15_T_3 @[src/main/scala/weightbuffer.scala 68:{24,24}]
    node _GEN_103 = mux(eq(UInt<2>("h3"), _io_cu_read_data_15_T_5), _io_cu_read_data_15_WIRE__3, _GEN_102) @[src/main/scala/weightbuffer.scala 67:{27,27}]
    reg io_cu_read_valid_REG : UInt<1>, clock with :
      reset => (UInt<1>("h0"), io_cu_read_valid_REG) @[src/main/scala/weightbuffer.scala 71:30]
    node _activeReadBuffer_T = eq(activeReadBuffer, UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 74:25]
    node _GEN_104 = mux(io_swap, _activeReadBuffer_T, activeReadBuffer) @[src/main/scala/weightbuffer.scala 73:17 74:22 37:33]
    node _io_cu_read_data_0_WIRE_io_cu_read_data_0_T_5 = _GEN_28 @[src/main/scala/weightbuffer.scala 67:27]
    node _io_cu_read_data_1_WIRE_io_cu_read_data_1_T_5 = _GEN_33 @[src/main/scala/weightbuffer.scala 67:27]
    node _io_cu_read_data_2_WIRE_io_cu_read_data_2_T_5 = _GEN_38 @[src/main/scala/weightbuffer.scala 67:27]
    node _io_cu_read_data_3_WIRE_io_cu_read_data_3_T_5 = _GEN_43 @[src/main/scala/weightbuffer.scala 67:27]
    node _io_cu_read_data_4_WIRE_io_cu_read_data_4_T_5 = _GEN_48 @[src/main/scala/weightbuffer.scala 67:27]
    node _io_cu_read_data_5_WIRE_io_cu_read_data_5_T_5 = _GEN_53 @[src/main/scala/weightbuffer.scala 67:27]
    node _io_cu_read_data_6_WIRE_io_cu_read_data_6_T_5 = _GEN_58 @[src/main/scala/weightbuffer.scala 67:27]
    node _io_cu_read_data_7_WIRE_io_cu_read_data_7_T_5 = _GEN_63 @[src/main/scala/weightbuffer.scala 67:27]
    node _io_cu_read_data_8_WIRE_io_cu_read_data_8_T_5 = _GEN_68 @[src/main/scala/weightbuffer.scala 67:27]
    node _io_cu_read_data_9_WIRE_io_cu_read_data_9_T_5 = _GEN_73 @[src/main/scala/weightbuffer.scala 67:27]
    node _io_cu_read_data_10_WIRE_io_cu_read_data_10_T_5 = _GEN_78 @[src/main/scala/weightbuffer.scala 67:27]
    node _io_cu_read_data_11_WIRE_io_cu_read_data_11_T_5 = _GEN_83 @[src/main/scala/weightbuffer.scala 67:27]
    node _io_cu_read_data_12_WIRE_io_cu_read_data_12_T_5 = _GEN_88 @[src/main/scala/weightbuffer.scala 67:27]
    node _io_cu_read_data_13_WIRE_io_cu_read_data_13_T_5 = _GEN_93 @[src/main/scala/weightbuffer.scala 67:27]
    node _io_cu_read_data_14_WIRE_io_cu_read_data_14_T_5 = _GEN_98 @[src/main/scala/weightbuffer.scala 67:27]
    node _io_cu_read_data_15_WIRE_io_cu_read_data_15_T_5 = _GEN_103 @[src/main/scala/weightbuffer.scala 67:27]
    io_dma_ready <= _io_dma_ready_T @[src/main/scala/weightbuffer.scala 44:16]
    io_cu_read_data_0 <= _io_cu_read_data_0_WIRE_io_cu_read_data_0_T_5 @[src/main/scala/weightbuffer.scala 67:27]
    io_cu_read_data_1 <= _io_cu_read_data_1_WIRE_io_cu_read_data_1_T_5 @[src/main/scala/weightbuffer.scala 67:27]
    io_cu_read_data_2 <= _io_cu_read_data_2_WIRE_io_cu_read_data_2_T_5 @[src/main/scala/weightbuffer.scala 67:27]
    io_cu_read_data_3 <= _io_cu_read_data_3_WIRE_io_cu_read_data_3_T_5 @[src/main/scala/weightbuffer.scala 67:27]
    io_cu_read_data_4 <= _io_cu_read_data_4_WIRE_io_cu_read_data_4_T_5 @[src/main/scala/weightbuffer.scala 67:27]
    io_cu_read_data_5 <= _io_cu_read_data_5_WIRE_io_cu_read_data_5_T_5 @[src/main/scala/weightbuffer.scala 67:27]
    io_cu_read_data_6 <= _io_cu_read_data_6_WIRE_io_cu_read_data_6_T_5 @[src/main/scala/weightbuffer.scala 67:27]
    io_cu_read_data_7 <= _io_cu_read_data_7_WIRE_io_cu_read_data_7_T_5 @[src/main/scala/weightbuffer.scala 67:27]
    io_cu_read_data_8 <= _io_cu_read_data_8_WIRE_io_cu_read_data_8_T_5 @[src/main/scala/weightbuffer.scala 67:27]
    io_cu_read_data_9 <= _io_cu_read_data_9_WIRE_io_cu_read_data_9_T_5 @[src/main/scala/weightbuffer.scala 67:27]
    io_cu_read_data_10 <= _io_cu_read_data_10_WIRE_io_cu_read_data_10_T_5 @[src/main/scala/weightbuffer.scala 67:27]
    io_cu_read_data_11 <= _io_cu_read_data_11_WIRE_io_cu_read_data_11_T_5 @[src/main/scala/weightbuffer.scala 67:27]
    io_cu_read_data_12 <= _io_cu_read_data_12_WIRE_io_cu_read_data_12_T_5 @[src/main/scala/weightbuffer.scala 67:27]
    io_cu_read_data_13 <= _io_cu_read_data_13_WIRE_io_cu_read_data_13_T_5 @[src/main/scala/weightbuffer.scala 67:27]
    io_cu_read_data_14 <= _io_cu_read_data_14_WIRE_io_cu_read_data_14_T_5 @[src/main/scala/weightbuffer.scala 67:27]
    io_cu_read_data_15 <= _io_cu_read_data_15_WIRE_io_cu_read_data_15_T_5 @[src/main/scala/weightbuffer.scala 67:27]
    io_cu_read_valid <= io_cu_read_valid_REG @[src/main/scala/weightbuffer.scala 71:20]
    io_read_buffer <= activeReadBuffer @[src/main/scala/weightbuffer.scala 40:19]
    io_write_buffer <= _io_write_buffer_T @[src/main/scala/weightbuffer.scala 41:19]
    activeReadBuffer <= mux(reset, UInt<1>("h0"), _GEN_104) @[src/main/scala/weightbuffer.scala 37:{33,33}]
    banks_0.readWord.addr <= _GEN_23
    banks_0.readWord.en <= _GEN_22
    banks_0.readWord.clk <= _GEN_24
    banks_0.MPORT.addr <= _GEN_0
    banks_0.MPORT.en <= _GEN_2
    banks_0.MPORT.clk <= _GEN_1
    banks_0.MPORT.data <= _GEN_4
    banks_0.MPORT.mask <= _GEN_3
    banks_1.readWord_1.addr <= _GEN_29
    banks_1.readWord_1.en <= _GEN_22
    banks_1.readWord_1.clk <= _GEN_24
    banks_1.MPORT_1.addr <= _GEN_0
    banks_1.MPORT_1.en <= _GEN_2
    banks_1.MPORT_1.clk <= _GEN_1
    banks_1.MPORT_1.data <= _GEN_5
    banks_1.MPORT_1.mask <= _GEN_3
    banks_2.readWord_2.addr <= _GEN_34
    banks_2.readWord_2.en <= _GEN_22
    banks_2.readWord_2.clk <= _GEN_24
    banks_2.MPORT_2.addr <= _GEN_0
    banks_2.MPORT_2.en <= _GEN_2
    banks_2.MPORT_2.clk <= _GEN_1
    banks_2.MPORT_2.data <= _GEN_6
    banks_2.MPORT_2.mask <= _GEN_3
    banks_3.readWord_3.addr <= _GEN_39
    banks_3.readWord_3.en <= _GEN_22
    banks_3.readWord_3.clk <= _GEN_24
    banks_3.MPORT_3.addr <= _GEN_0
    banks_3.MPORT_3.en <= _GEN_2
    banks_3.MPORT_3.clk <= _GEN_1
    banks_3.MPORT_3.data <= _GEN_7
    banks_3.MPORT_3.mask <= _GEN_3
    banks_4.readWord_4.addr <= _GEN_44
    banks_4.readWord_4.en <= _GEN_22
    banks_4.readWord_4.clk <= _GEN_24
    banks_4.MPORT_4.addr <= _GEN_0
    banks_4.MPORT_4.en <= _GEN_2
    banks_4.MPORT_4.clk <= _GEN_1
    banks_4.MPORT_4.data <= _GEN_8
    banks_4.MPORT_4.mask <= _GEN_3
    banks_5.readWord_5.addr <= _GEN_49
    banks_5.readWord_5.en <= _GEN_22
    banks_5.readWord_5.clk <= _GEN_24
    banks_5.MPORT_5.addr <= _GEN_0
    banks_5.MPORT_5.en <= _GEN_2
    banks_5.MPORT_5.clk <= _GEN_1
    banks_5.MPORT_5.data <= _GEN_9
    banks_5.MPORT_5.mask <= _GEN_3
    banks_6.readWord_6.addr <= _GEN_54
    banks_6.readWord_6.en <= _GEN_22
    banks_6.readWord_6.clk <= _GEN_24
    banks_6.MPORT_6.addr <= _GEN_0
    banks_6.MPORT_6.en <= _GEN_2
    banks_6.MPORT_6.clk <= _GEN_1
    banks_6.MPORT_6.data <= _GEN_10
    banks_6.MPORT_6.mask <= _GEN_3
    banks_7.readWord_7.addr <= _GEN_59
    banks_7.readWord_7.en <= _GEN_22
    banks_7.readWord_7.clk <= _GEN_24
    banks_7.MPORT_7.addr <= _GEN_0
    banks_7.MPORT_7.en <= _GEN_2
    banks_7.MPORT_7.clk <= _GEN_1
    banks_7.MPORT_7.data <= _GEN_11
    banks_7.MPORT_7.mask <= _GEN_3
    banks_8.readWord_8.addr <= _GEN_64
    banks_8.readWord_8.en <= _GEN_22
    banks_8.readWord_8.clk <= _GEN_24
    banks_8.MPORT_8.addr <= _GEN_0
    banks_8.MPORT_8.en <= _GEN_2
    banks_8.MPORT_8.clk <= _GEN_1
    banks_8.MPORT_8.data <= _GEN_12
    banks_8.MPORT_8.mask <= _GEN_3
    banks_9.readWord_9.addr <= _GEN_69
    banks_9.readWord_9.en <= _GEN_22
    banks_9.readWord_9.clk <= _GEN_24
    banks_9.MPORT_9.addr <= _GEN_0
    banks_9.MPORT_9.en <= _GEN_2
    banks_9.MPORT_9.clk <= _GEN_1
    banks_9.MPORT_9.data <= _GEN_13
    banks_9.MPORT_9.mask <= _GEN_3
    banks_10.readWord_10.addr <= _GEN_74
    banks_10.readWord_10.en <= _GEN_22
    banks_10.readWord_10.clk <= _GEN_24
    banks_10.MPORT_10.addr <= _GEN_0
    banks_10.MPORT_10.en <= _GEN_2
    banks_10.MPORT_10.clk <= _GEN_1
    banks_10.MPORT_10.data <= _GEN_14
    banks_10.MPORT_10.mask <= _GEN_3
    banks_11.readWord_11.addr <= _GEN_79
    banks_11.readWord_11.en <= _GEN_22
    banks_11.readWord_11.clk <= _GEN_24
    banks_11.MPORT_11.addr <= _GEN_0
    banks_11.MPORT_11.en <= _GEN_2
    banks_11.MPORT_11.clk <= _GEN_1
    banks_11.MPORT_11.data <= _GEN_15
    banks_11.MPORT_11.mask <= _GEN_3
    banks_12.readWord_12.addr <= _GEN_84
    banks_12.readWord_12.en <= _GEN_22
    banks_12.readWord_12.clk <= _GEN_24
    banks_12.MPORT_12.addr <= _GEN_0
    banks_12.MPORT_12.en <= _GEN_2
    banks_12.MPORT_12.clk <= _GEN_1
    banks_12.MPORT_12.data <= _GEN_16
    banks_12.MPORT_12.mask <= _GEN_3
    banks_13.readWord_13.addr <= _GEN_89
    banks_13.readWord_13.en <= _GEN_22
    banks_13.readWord_13.clk <= _GEN_24
    banks_13.MPORT_13.addr <= _GEN_0
    banks_13.MPORT_13.en <= _GEN_2
    banks_13.MPORT_13.clk <= _GEN_1
    banks_13.MPORT_13.data <= _GEN_17
    banks_13.MPORT_13.mask <= _GEN_3
    banks_14.readWord_14.addr <= _GEN_94
    banks_14.readWord_14.en <= _GEN_22
    banks_14.readWord_14.clk <= _GEN_24
    banks_14.MPORT_14.addr <= _GEN_0
    banks_14.MPORT_14.en <= _GEN_2
    banks_14.MPORT_14.clk <= _GEN_1
    banks_14.MPORT_14.data <= _GEN_18
    banks_14.MPORT_14.mask <= _GEN_3
    banks_15.readWord_15.addr <= _GEN_99
    banks_15.readWord_15.en <= _GEN_22
    banks_15.readWord_15.clk <= _GEN_24
    banks_15.MPORT_15.addr <= _GEN_0
    banks_15.MPORT_15.en <= _GEN_2
    banks_15.MPORT_15.clk <= _GEN_1
    banks_15.MPORT_15.data <= _GEN_19
    banks_15.MPORT_15.mask <= _GEN_3
    cuByteSelect <= mux(reset, UInt<1>("h0"), _GEN_20) @[src/main/scala/weightbuffer.scala 63:{31,31}]
    io_cu_read_valid_REG <= mux(reset, UInt<1>("h0"), cuRead) @[src/main/scala/weightbuffer.scala 71:{30,30,30}]
