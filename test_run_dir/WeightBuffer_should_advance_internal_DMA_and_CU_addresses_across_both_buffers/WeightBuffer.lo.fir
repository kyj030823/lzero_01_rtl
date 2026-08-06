FIRRTL version 1.2.0
circuit WeightBuffer :
  module WeightBuffer : @[src/main/scala/weightbuffer.scala 12:7]
    input clock : Clock @[src/main/scala/weightbuffer.scala 12:7]
    input reset : UInt<1> @[src/main/scala/weightbuffer.scala 12:7]
    input io_dma_valid : UInt<1> @[src/main/scala/weightbuffer.scala 13:14]
    output io_dma_ready : UInt<1> @[src/main/scala/weightbuffer.scala 13:14]
    input io_dma_data_0 : UInt<8> @[src/main/scala/weightbuffer.scala 13:14]
    input io_dma_data_1 : UInt<8> @[src/main/scala/weightbuffer.scala 13:14]
    input io_dma_data_2 : UInt<8> @[src/main/scala/weightbuffer.scala 13:14]
    input io_dma_data_3 : UInt<8> @[src/main/scala/weightbuffer.scala 13:14]
    input io_dma_data_4 : UInt<8> @[src/main/scala/weightbuffer.scala 13:14]
    input io_dma_data_5 : UInt<8> @[src/main/scala/weightbuffer.scala 13:14]
    input io_dma_data_6 : UInt<8> @[src/main/scala/weightbuffer.scala 13:14]
    input io_dma_data_7 : UInt<8> @[src/main/scala/weightbuffer.scala 13:14]
    input io_dma_data_8 : UInt<8> @[src/main/scala/weightbuffer.scala 13:14]
    input io_dma_data_9 : UInt<8> @[src/main/scala/weightbuffer.scala 13:14]
    input io_dma_data_10 : UInt<8> @[src/main/scala/weightbuffer.scala 13:14]
    input io_dma_data_11 : UInt<8> @[src/main/scala/weightbuffer.scala 13:14]
    input io_dma_data_12 : UInt<8> @[src/main/scala/weightbuffer.scala 13:14]
    input io_dma_data_13 : UInt<8> @[src/main/scala/weightbuffer.scala 13:14]
    input io_dma_data_14 : UInt<8> @[src/main/scala/weightbuffer.scala 13:14]
    input io_dma_data_15 : UInt<8> @[src/main/scala/weightbuffer.scala 13:14]
    input io_load_start : UInt<1> @[src/main/scala/weightbuffer.scala 13:14]
    output io_load_done : UInt<1> @[src/main/scala/weightbuffer.scala 13:14]
    input io_cu_read_en : UInt<1> @[src/main/scala/weightbuffer.scala 13:14]
    output io_cu_read_data_0 : UInt<8> @[src/main/scala/weightbuffer.scala 13:14]
    output io_cu_read_data_1 : UInt<8> @[src/main/scala/weightbuffer.scala 13:14]
    output io_cu_read_data_2 : UInt<8> @[src/main/scala/weightbuffer.scala 13:14]
    output io_cu_read_data_3 : UInt<8> @[src/main/scala/weightbuffer.scala 13:14]
    output io_cu_read_valid : UInt<1> @[src/main/scala/weightbuffer.scala 13:14]
    input io_read_start : UInt<1> @[src/main/scala/weightbuffer.scala 13:14]
    output io_read_done : UInt<1> @[src/main/scala/weightbuffer.scala 13:14]
    input io_swap : UInt<1> @[src/main/scala/weightbuffer.scala 13:14]
    output io_read_buffer : UInt<1> @[src/main/scala/weightbuffer.scala 13:14]
    output io_write_buffer : UInt<1> @[src/main/scala/weightbuffer.scala 13:14]

    mem banks_0 : @[src/main/scala/weightbuffer.scala 33:38]
      data-type => UInt<32>
      depth => 512
      read-latency => 1
      write-latency => 1
      reader => bankReadData_0
      writer => MPORT
      read-under-write => undefined
    mem banks_1 : @[src/main/scala/weightbuffer.scala 33:38]
      data-type => UInt<32>
      depth => 512
      read-latency => 1
      write-latency => 1
      reader => bankReadData_1
      writer => MPORT_1
      read-under-write => undefined
    mem banks_2 : @[src/main/scala/weightbuffer.scala 33:38]
      data-type => UInt<32>
      depth => 512
      read-latency => 1
      write-latency => 1
      reader => bankReadData_2
      writer => MPORT_2
      read-under-write => undefined
    mem banks_3 : @[src/main/scala/weightbuffer.scala 33:38]
      data-type => UInt<32>
      depth => 512
      read-latency => 1
      write-latency => 1
      reader => bankReadData_3
      writer => MPORT_3
      read-under-write => undefined
    reg activeReadBuffer : UInt<1>, clock with :
      reset => (UInt<1>("h0"), activeReadBuffer) @[src/main/scala/weightbuffer.scala 32:33]
    reg writeAddr : UInt<8>, clock with :
      reset => (UInt<1>("h0"), writeAddr) @[src/main/scala/weightbuffer.scala 34:26]
    reg readAddr : UInt<10>, clock with :
      reset => (UInt<1>("h0"), readAddr) @[src/main/scala/weightbuffer.scala 35:26]
    node _io_write_buffer_T = eq(activeReadBuffer, UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 38:22]
    node _io_dma_ready_T = eq(io_swap, UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 41:19]
    node _io_dma_ready_T_1 = eq(io_load_start, UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 41:31]
    node _io_dma_ready_T_2 = and(_io_dma_ready_T, _io_dma_ready_T_1) @[src/main/scala/weightbuffer.scala 41:28]
    node dmaWrite = and(io_dma_valid, io_dma_ready) @[src/main/scala/weightbuffer.scala 42:31]
    node _dmaWordAddr_T = eq(activeReadBuffer, UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 43:25]
    node dmaWordAddr = cat(_dmaWordAddr_T, writeAddr) @[src/main/scala/weightbuffer.scala 43:24]
    node _io_load_done_T = eq(writeAddr, UInt<8>("hff")) @[src/main/scala/weightbuffer.scala 45:41]
    node _io_load_done_T_1 = and(dmaWrite, _io_load_done_T) @[src/main/scala/weightbuffer.scala 45:28]
    node _writeAddr_T = eq(writeAddr, UInt<8>("hff")) @[src/main/scala/weightbuffer.scala 50:32]
    node _writeAddr_T_1 = add(writeAddr, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 50:58]
    node _writeAddr_T_2 = tail(_writeAddr_T_1, 1) @[src/main/scala/weightbuffer.scala 50:58]
    node _writeAddr_T_3 = mux(_writeAddr_T, UInt<1>("h0"), _writeAddr_T_2) @[src/main/scala/weightbuffer.scala 50:21]
    node _GEN_0 = mux(dmaWrite, _writeAddr_T_3, writeAddr) @[src/main/scala/weightbuffer.scala 49:24 50:15 34:26]
    node _GEN_1 = mux(io_load_start, UInt<1>("h0"), _GEN_0) @[src/main/scala/weightbuffer.scala 47:23 48:15]
    node _bankWord_WIRE__1 = io_dma_data_1 @[src/main/scala/weightbuffer.scala 55:{27,27}]
    node _bankWord_WIRE__0 = io_dma_data_0 @[src/main/scala/weightbuffer.scala 55:{27,27}]
    node bankWord_lo = cat(_bankWord_WIRE__1, _bankWord_WIRE__0) @[src/main/scala/weightbuffer.scala 57:8]
    node _bankWord_WIRE__3 = io_dma_data_3 @[src/main/scala/weightbuffer.scala 55:{27,27}]
    node _bankWord_WIRE__2 = io_dma_data_2 @[src/main/scala/weightbuffer.scala 55:{27,27}]
    node bankWord_hi = cat(_bankWord_WIRE__3, _bankWord_WIRE__2) @[src/main/scala/weightbuffer.scala 57:8]
    node bankWord = cat(bankWord_hi, bankWord_lo) @[src/main/scala/weightbuffer.scala 57:8]
    node _GEN_2 = validif(dmaWrite, dmaWordAddr) @[src/main/scala/weightbuffer.scala 59:20 60:24]
    node _GEN_3 = validif(dmaWrite, clock) @[src/main/scala/weightbuffer.scala 59:20 60:24]
    node _GEN_4 = mux(dmaWrite, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 59:20 60:24 33:38]
    node _GEN_5 = validif(dmaWrite, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 59:20 60:24]
    node _GEN_6 = validif(dmaWrite, bankWord) @[src/main/scala/weightbuffer.scala 59:20 60:24]
    node _bankWord_WIRE_1_1 = io_dma_data_5 @[src/main/scala/weightbuffer.scala 55:{27,27}]
    node _bankWord_WIRE_1_0 = io_dma_data_4 @[src/main/scala/weightbuffer.scala 55:{27,27}]
    node bankWord_lo_1 = cat(_bankWord_WIRE_1_1, _bankWord_WIRE_1_0) @[src/main/scala/weightbuffer.scala 57:8]
    node _bankWord_WIRE_1_3 = io_dma_data_7 @[src/main/scala/weightbuffer.scala 55:{27,27}]
    node _bankWord_WIRE_1_2 = io_dma_data_6 @[src/main/scala/weightbuffer.scala 55:{27,27}]
    node bankWord_hi_1 = cat(_bankWord_WIRE_1_3, _bankWord_WIRE_1_2) @[src/main/scala/weightbuffer.scala 57:8]
    node bankWord_1 = cat(bankWord_hi_1, bankWord_lo_1) @[src/main/scala/weightbuffer.scala 57:8]
    node _GEN_7 = validif(dmaWrite, bankWord_1) @[src/main/scala/weightbuffer.scala 59:20 60:24]
    node _bankWord_WIRE_2_1 = io_dma_data_9 @[src/main/scala/weightbuffer.scala 55:{27,27}]
    node _bankWord_WIRE_2_0 = io_dma_data_8 @[src/main/scala/weightbuffer.scala 55:{27,27}]
    node bankWord_lo_2 = cat(_bankWord_WIRE_2_1, _bankWord_WIRE_2_0) @[src/main/scala/weightbuffer.scala 57:8]
    node _bankWord_WIRE_2_3 = io_dma_data_11 @[src/main/scala/weightbuffer.scala 55:{27,27}]
    node _bankWord_WIRE_2_2 = io_dma_data_10 @[src/main/scala/weightbuffer.scala 55:{27,27}]
    node bankWord_hi_2 = cat(_bankWord_WIRE_2_3, _bankWord_WIRE_2_2) @[src/main/scala/weightbuffer.scala 57:8]
    node bankWord_2 = cat(bankWord_hi_2, bankWord_lo_2) @[src/main/scala/weightbuffer.scala 57:8]
    node _GEN_8 = validif(dmaWrite, bankWord_2) @[src/main/scala/weightbuffer.scala 59:20 60:24]
    node _bankWord_WIRE_3_1 = io_dma_data_13 @[src/main/scala/weightbuffer.scala 55:{27,27}]
    node _bankWord_WIRE_3_0 = io_dma_data_12 @[src/main/scala/weightbuffer.scala 55:{27,27}]
    node bankWord_lo_3 = cat(_bankWord_WIRE_3_1, _bankWord_WIRE_3_0) @[src/main/scala/weightbuffer.scala 57:8]
    node _bankWord_WIRE_3_3 = io_dma_data_15 @[src/main/scala/weightbuffer.scala 55:{27,27}]
    node _bankWord_WIRE_3_2 = io_dma_data_14 @[src/main/scala/weightbuffer.scala 55:{27,27}]
    node bankWord_hi_3 = cat(_bankWord_WIRE_3_3, _bankWord_WIRE_3_2) @[src/main/scala/weightbuffer.scala 57:8]
    node bankWord_3 = cat(bankWord_hi_3, bankWord_lo_3) @[src/main/scala/weightbuffer.scala 57:8]
    node _GEN_9 = validif(dmaWrite, bankWord_3) @[src/main/scala/weightbuffer.scala 59:20 60:24]
    node _cuRead_T = eq(io_swap, UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 66:33]
    node _cuRead_T_1 = and(io_cu_read_en, _cuRead_T) @[src/main/scala/weightbuffer.scala 66:30]
    node _cuRead_T_2 = eq(io_read_start, UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 66:45]
    node cuRead = and(_cuRead_T_1, _cuRead_T_2) @[src/main/scala/weightbuffer.scala 66:42]
    node selectedBank = bits(readAddr, 1, 0) @[src/main/scala/weightbuffer.scala 67:30]
    node _cuWordAddr_T = bits(readAddr, 9, 2) @[src/main/scala/weightbuffer.scala 68:50]
    node cuWordAddr = cat(activeReadBuffer, _cuWordAddr_T) @[src/main/scala/weightbuffer.scala 68:23]
    reg selectedBankReg : UInt<2>, clock with :
      reset => (UInt<1>("h0"), selectedBankReg) @[src/main/scala/weightbuffer.scala 69:34]
    node _GEN_10 = mux(cuRead, selectedBank, selectedBankReg) @[src/main/scala/weightbuffer.scala 69:{34,34,34}]
    node _readAddr_T = eq(readAddr, UInt<10>("h3ff")) @[src/main/scala/weightbuffer.scala 74:30]
    node _readAddr_T_1 = add(readAddr, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 74:56]
    node _readAddr_T_2 = tail(_readAddr_T_1, 1) @[src/main/scala/weightbuffer.scala 74:56]
    node _readAddr_T_3 = mux(_readAddr_T, UInt<1>("h0"), _readAddr_T_2) @[src/main/scala/weightbuffer.scala 74:20]
    node _GEN_11 = mux(cuRead, _readAddr_T_3, readAddr) @[src/main/scala/weightbuffer.scala 73:22 74:14 35:26]
    node _GEN_12 = mux(io_read_start, UInt<1>("h0"), _GEN_11) @[src/main/scala/weightbuffer.scala 71:23 72:14]
    node _bankReadData_T = eq(selectedBank, UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 78:57]
    node _bankReadData_T_1 = and(cuRead, _bankReadData_T) @[src/main/scala/weightbuffer.scala 78:41]
    node _GEN_13 = validif(_bankReadData_T_1, cuWordAddr) @[src/main/scala/weightbuffer.scala 78:{21,21}]
    node _GEN_14 = mux(_bankReadData_T_1, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 78:{21,21} 33:38]
    node _bankReadData_WIRE = _GEN_13 @[src/main/scala/weightbuffer.scala 78:21]
    node _GEN_15 = validif(_bankReadData_T_1, _bankReadData_WIRE) @[src/main/scala/weightbuffer.scala 78:{21,21}]
    node _GEN_16 = validif(_bankReadData_T_1, clock) @[src/main/scala/weightbuffer.scala 78:{21,21}]
    node _bankReadData_T_2 = eq(selectedBank, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 78:57]
    node _bankReadData_T_3 = and(cuRead, _bankReadData_T_2) @[src/main/scala/weightbuffer.scala 78:41]
    node _GEN_17 = validif(_bankReadData_T_3, cuWordAddr) @[src/main/scala/weightbuffer.scala 78:{21,21}]
    node _GEN_18 = mux(_bankReadData_T_3, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 78:{21,21} 33:38]
    node _bankReadData_WIRE_1 = _GEN_17 @[src/main/scala/weightbuffer.scala 78:21]
    node _GEN_19 = validif(_bankReadData_T_3, _bankReadData_WIRE_1) @[src/main/scala/weightbuffer.scala 78:{21,21}]
    node _GEN_20 = validif(_bankReadData_T_3, clock) @[src/main/scala/weightbuffer.scala 78:{21,21}]
    node _bankReadData_T_4 = eq(selectedBank, UInt<2>("h2")) @[src/main/scala/weightbuffer.scala 78:57]
    node _bankReadData_T_5 = and(cuRead, _bankReadData_T_4) @[src/main/scala/weightbuffer.scala 78:41]
    node _GEN_21 = validif(_bankReadData_T_5, cuWordAddr) @[src/main/scala/weightbuffer.scala 78:{21,21}]
    node _GEN_22 = mux(_bankReadData_T_5, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 78:{21,21} 33:38]
    node _bankReadData_WIRE_2 = _GEN_21 @[src/main/scala/weightbuffer.scala 78:21]
    node _GEN_23 = validif(_bankReadData_T_5, _bankReadData_WIRE_2) @[src/main/scala/weightbuffer.scala 78:{21,21}]
    node _GEN_24 = validif(_bankReadData_T_5, clock) @[src/main/scala/weightbuffer.scala 78:{21,21}]
    node _bankReadData_T_6 = eq(selectedBank, UInt<2>("h3")) @[src/main/scala/weightbuffer.scala 78:57]
    node _bankReadData_T_7 = and(cuRead, _bankReadData_T_6) @[src/main/scala/weightbuffer.scala 78:41]
    node _GEN_25 = validif(_bankReadData_T_7, cuWordAddr) @[src/main/scala/weightbuffer.scala 78:{21,21}]
    node _GEN_26 = mux(_bankReadData_T_7, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 78:{21,21} 33:38]
    node _bankReadData_WIRE_3 = _GEN_25 @[src/main/scala/weightbuffer.scala 78:21]
    node _GEN_27 = validif(_bankReadData_T_7, _bankReadData_WIRE_3) @[src/main/scala/weightbuffer.scala 78:{21,21}]
    node _GEN_28 = validif(_bankReadData_T_7, clock) @[src/main/scala/weightbuffer.scala 78:{21,21}]
    node _selectedWord_T = eq(selectedBankReg, UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 81:22]
    node _selectedWord_T_1 = eq(selectedBankReg, UInt<1>("h1")) @[src/main/scala/weightbuffer.scala 81:22]
    node _selectedWord_T_2 = eq(selectedBankReg, UInt<2>("h2")) @[src/main/scala/weightbuffer.scala 81:22]
    node _selectedWord_T_3 = eq(selectedBankReg, UInt<2>("h3")) @[src/main/scala/weightbuffer.scala 81:22]
    node _selectedWord_T_4 = mux(_selectedWord_T, banks_0.bankReadData_0.data, UInt<1>("h0")) @[src/main/scala/chisel3/util/Mux.scala 30:73]
    node _selectedWord_T_5 = mux(_selectedWord_T_1, banks_1.bankReadData_1.data, UInt<1>("h0")) @[src/main/scala/chisel3/util/Mux.scala 30:73]
    node _selectedWord_T_6 = mux(_selectedWord_T_2, banks_2.bankReadData_2.data, UInt<1>("h0")) @[src/main/scala/chisel3/util/Mux.scala 30:73]
    node _selectedWord_T_7 = mux(_selectedWord_T_3, banks_3.bankReadData_3.data, UInt<1>("h0")) @[src/main/scala/chisel3/util/Mux.scala 30:73]
    node _selectedWord_T_8 = or(_selectedWord_T_4, _selectedWord_T_5) @[src/main/scala/chisel3/util/Mux.scala 30:73]
    node _selectedWord_T_9 = or(_selectedWord_T_8, _selectedWord_T_6) @[src/main/scala/chisel3/util/Mux.scala 30:73]
    node _selectedWord_T_10 = or(_selectedWord_T_9, _selectedWord_T_7) @[src/main/scala/chisel3/util/Mux.scala 30:73]
    node selectedWord = _selectedWord_T_10 @[src/main/scala/chisel3/util/Mux.scala 30:{73,73}]
    node _WIRE_1 = selectedWord @[src/main/scala/weightbuffer.scala 84:{43,43}]
    node _T = bits(_WIRE_1, 7, 0) @[src/main/scala/weightbuffer.scala 84:43]
    node _T_1 = bits(_WIRE_1, 15, 8) @[src/main/scala/weightbuffer.scala 84:43]
    node _T_2 = bits(_WIRE_1, 23, 16) @[src/main/scala/weightbuffer.scala 84:43]
    node _T_3 = bits(_WIRE_1, 31, 24) @[src/main/scala/weightbuffer.scala 84:43]
    reg io_cu_read_valid_REG : UInt<1>, clock with :
      reset => (UInt<1>("h0"), io_cu_read_valid_REG) @[src/main/scala/weightbuffer.scala 85:30]
    node _io_read_done_T = eq(readAddr, UInt<10>("h3ff")) @[src/main/scala/weightbuffer.scala 86:46]
    node _io_read_done_T_1 = and(cuRead, _io_read_done_T) @[src/main/scala/weightbuffer.scala 86:34]
    reg io_read_done_REG : UInt<1>, clock with :
      reset => (UInt<1>("h0"), io_read_done_REG) @[src/main/scala/weightbuffer.scala 86:26]
    node _activeReadBuffer_T = eq(activeReadBuffer, UInt<1>("h0")) @[src/main/scala/weightbuffer.scala 89:25]
    node _GEN_29 = mux(io_swap, _activeReadBuffer_T, activeReadBuffer) @[src/main/scala/weightbuffer.scala 88:17 89:22 32:33]
    node _WIRE__0 = _T @[src/main/scala/weightbuffer.scala 84:{43,43}]
    node _WIRE__1 = _T_1 @[src/main/scala/weightbuffer.scala 84:{43,43}]
    node _WIRE__2 = _T_2 @[src/main/scala/weightbuffer.scala 84:{43,43}]
    node _WIRE__3 = _T_3 @[src/main/scala/weightbuffer.scala 84:{43,43}]
    io_dma_ready <= _io_dma_ready_T_2 @[src/main/scala/weightbuffer.scala 41:16]
    io_load_done <= _io_load_done_T_1 @[src/main/scala/weightbuffer.scala 45:16]
    io_cu_read_data_0 <= _WIRE__0 @[src/main/scala/weightbuffer.scala 84:19]
    io_cu_read_data_1 <= _WIRE__1 @[src/main/scala/weightbuffer.scala 84:19]
    io_cu_read_data_2 <= _WIRE__2 @[src/main/scala/weightbuffer.scala 84:19]
    io_cu_read_data_3 <= _WIRE__3 @[src/main/scala/weightbuffer.scala 84:19]
    io_cu_read_valid <= io_cu_read_valid_REG @[src/main/scala/weightbuffer.scala 85:20]
    io_read_done <= io_read_done_REG @[src/main/scala/weightbuffer.scala 86:16]
    io_read_buffer <= activeReadBuffer @[src/main/scala/weightbuffer.scala 37:19]
    io_write_buffer <= _io_write_buffer_T @[src/main/scala/weightbuffer.scala 38:19]
    activeReadBuffer <= mux(reset, UInt<1>("h0"), _GEN_29) @[src/main/scala/weightbuffer.scala 32:{33,33}]
    banks_0.bankReadData_0.addr <= _GEN_15
    banks_0.bankReadData_0.en <= _GEN_14
    banks_0.bankReadData_0.clk <= _GEN_16
    banks_0.MPORT.addr <= _GEN_2
    banks_0.MPORT.en <= _GEN_4
    banks_0.MPORT.clk <= _GEN_3
    banks_0.MPORT.data <= _GEN_6
    banks_0.MPORT.mask <= _GEN_5
    banks_1.bankReadData_1.addr <= _GEN_19
    banks_1.bankReadData_1.en <= _GEN_18
    banks_1.bankReadData_1.clk <= _GEN_20
    banks_1.MPORT_1.addr <= _GEN_2
    banks_1.MPORT_1.en <= _GEN_4
    banks_1.MPORT_1.clk <= _GEN_3
    banks_1.MPORT_1.data <= _GEN_7
    banks_1.MPORT_1.mask <= _GEN_5
    banks_2.bankReadData_2.addr <= _GEN_23
    banks_2.bankReadData_2.en <= _GEN_22
    banks_2.bankReadData_2.clk <= _GEN_24
    banks_2.MPORT_2.addr <= _GEN_2
    banks_2.MPORT_2.en <= _GEN_4
    banks_2.MPORT_2.clk <= _GEN_3
    banks_2.MPORT_2.data <= _GEN_8
    banks_2.MPORT_2.mask <= _GEN_5
    banks_3.bankReadData_3.addr <= _GEN_27
    banks_3.bankReadData_3.en <= _GEN_26
    banks_3.bankReadData_3.clk <= _GEN_28
    banks_3.MPORT_3.addr <= _GEN_2
    banks_3.MPORT_3.en <= _GEN_4
    banks_3.MPORT_3.clk <= _GEN_3
    banks_3.MPORT_3.data <= _GEN_9
    banks_3.MPORT_3.mask <= _GEN_5
    writeAddr <= mux(reset, UInt<8>("h0"), _GEN_1) @[src/main/scala/weightbuffer.scala 34:{26,26}]
    readAddr <= mux(reset, UInt<10>("h0"), _GEN_12) @[src/main/scala/weightbuffer.scala 35:{26,26}]
    selectedBankReg <= mux(reset, UInt<1>("h0"), _GEN_10) @[src/main/scala/weightbuffer.scala 69:{34,34}]
    io_cu_read_valid_REG <= mux(reset, UInt<1>("h0"), cuRead) @[src/main/scala/weightbuffer.scala 85:{30,30,30}]
    io_read_done_REG <= mux(reset, UInt<1>("h0"), _io_read_done_T_1) @[src/main/scala/weightbuffer.scala 86:{26,26,26}]
