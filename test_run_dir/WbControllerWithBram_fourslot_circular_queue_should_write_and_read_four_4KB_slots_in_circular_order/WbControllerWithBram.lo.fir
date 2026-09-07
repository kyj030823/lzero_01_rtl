FIRRTL version 1.2.0
circuit WbControllerWithBram :
  module WbController : @[src/main/scala/WbController.scala 17:7]
    input clock : Clock @[src/main/scala/WbController.scala 17:7]
    input reset : UInt<1> @[src/main/scala/WbController.scala 17:7]
    input io_ctrl_soft_reset : UInt<1> @[src/main/scala/WbController.scala 18:14]
    input io_ctrl_enable : UInt<1> @[src/main/scala/WbController.scala 18:14]
    input io_ctrl_shoot : UInt<1> @[src/main/scala/WbController.scala 18:14]
    input io_ctrl_rlast : UInt<1> @[src/main/scala/WbController.scala 18:14]
    input io_ctrl_dma_data_valid : UInt<1> @[src/main/scala/WbController.scala 18:14]
    input io_ctrl_dma_data_last : UInt<1> @[src/main/scala/WbController.scala 18:14]
    input io_ctrl_dma_write_ready : UInt<1> @[src/main/scala/WbController.scala 18:14]
    output io_ctrl_last_data_out : UInt<1> @[src/main/scala/WbController.scala 18:14]
    output io_ctrl_ready : UInt<1> @[src/main/scala/WbController.scala 18:14]
    output io_ctrl_hungry : UInt<1> @[src/main/scala/WbController.scala 18:14]
    output io_ctrl_impending : UInt<1> @[src/main/scala/WbController.scala 18:14]
    output io_ctrl_working : UInt<1> @[src/main/scala/WbController.scala 18:14]
    output io_ctrl_full : UInt<1> @[src/main/scala/WbController.scala 18:14]
    input io_lut_prog_mode : UInt<1> @[src/main/scala/WbController.scala 18:14]
    output io_rd_addr : UInt<9> @[src/main/scala/WbController.scala 18:14]
    output io_rd_en : UInt<1> @[src/main/scala/WbController.scala 18:14]
    output io_active_bank : UInt<1> @[src/main/scala/WbController.scala 18:14]
    input io_rd_data : UInt<128> @[src/main/scala/WbController.scala 18:14]
    output io_rd_data_to_cu : UInt<128> @[src/main/scala/WbController.scala 18:14]
    output io_rd_data_to_lut : UInt<128> @[src/main/scala/WbController.scala 18:14]
    output io_wr_en : UInt<1> @[src/main/scala/WbController.scala 18:14]
    output io_wr_addr : UInt<7> @[src/main/scala/WbController.scala 18:14]
    output io_write_bank : UInt<1> @[src/main/scala/WbController.scala 18:14]

    reg state : UInt<3>, clock with :
      reset => (UInt<1>("h0"), state) @[src/main/scala/WbController.scala 35:22]
    reg i : UInt<2>, clock with :
      reset => (UInt<1>("h0"), i) @[src/main/scala/WbController.scala 37:18]
    reg j : UInt<2>, clock with :
      reset => (UInt<1>("h0"), j) @[src/main/scala/WbController.scala 38:18]
    reg writePtr : UInt<6>, clock with :
      reset => (UInt<1>("h0"), writePtr) @[src/main/scala/WbController.scala 40:25]
    reg readPtr : UInt<8>, clock with :
      reset => (UInt<1>("h0"), readPtr) @[src/main/scala/WbController.scala 41:25]
    reg validCnt : UInt<3>, clock with :
      reset => (UInt<1>("h0"), validCnt) @[src/main/scala/WbController.scala 42:25]
    reg gotDmaLast : UInt<1>, clock with :
      reset => (UInt<1>("h0"), gotDmaLast) @[src/main/scala/WbController.scala 43:27]
    node isIdle = eq(state, UInt<3>("h0")) @[src/main/scala/WbController.scala 45:25]
    node isReady = eq(state, UInt<3>("h2")) @[src/main/scala/WbController.scala 46:25]
    node isWorking = eq(state, UInt<3>("h3")) @[src/main/scala/WbController.scala 47:25]
    node queueFull = eq(validCnt, UInt<3>("h4")) @[src/main/scala/WbController.scala 49:29]
    node queueEmpty = eq(validCnt, UInt<1>("h0")) @[src/main/scala/WbController.scala 50:29]
    node _readActive_T = eq(queueEmpty, UInt<1>("h0")) @[src/main/scala/WbController.scala 52:33]
    node readActive = and(isWorking, _readActive_T) @[src/main/scala/WbController.scala 52:30]
    node _readLast_T = eq(readPtr, UInt<8>("hff")) @[src/main/scala/WbController.scala 53:42]
    node readLast = and(readActive, _readLast_T) @[src/main/scala/WbController.scala 53:31]
    node _writeActive_T = eq(isIdle, UInt<1>("h0")) @[src/main/scala/WbController.scala 55:21]
    node _writeActive_T_1 = and(_writeActive_T, io_ctrl_dma_data_valid) @[src/main/scala/WbController.scala 55:29]
    node _writeActive_T_2 = eq(queueFull, UInt<1>("h0")) @[src/main/scala/WbController.scala 55:59]
    node _writeActive_T_3 = or(_writeActive_T_2, readLast) @[src/main/scala/WbController.scala 55:70]
    node writeActive = and(_writeActive_T_1, _writeActive_T_3) @[src/main/scala/WbController.scala 55:55]
    node _writeLast_T = or(io_ctrl_rlast, io_ctrl_dma_data_last) @[src/main/scala/WbController.scala 56:51]
    node _writeLast_T_1 = eq(writePtr, UInt<6>("h3f")) @[src/main/scala/WbController.scala 56:88]
    node _writeLast_T_2 = or(_writeLast_T, _writeLast_T_1) @[src/main/scala/WbController.scala 56:76]
    node writeLast = and(writeActive, _writeLast_T_2) @[src/main/scala/WbController.scala 56:33]
    node writeSlotBank = bits(i, 1, 1) @[src/main/scala/WbController.scala 58:24]
    node writeSlotBase = bits(i, 0, 0) @[src/main/scala/WbController.scala 59:24]
    node readSlotBank = bits(j, 1, 1) @[src/main/scala/WbController.scala 60:24]
    node readSlotBase = bits(j, 0, 0) @[src/main/scala/WbController.scala 61:24]
    node _T = eq(UInt<3>("h0"), state) @[src/main/scala/WbController.scala 63:17]
    node _T_1 = eq(io_ctrl_soft_reset, UInt<1>("h0")) @[src/main/scala/WbController.scala 65:30]
    node _T_2 = and(io_ctrl_enable, _T_1) @[src/main/scala/WbController.scala 65:27]
    node _GEN_0 = mux(_T_2, UInt<3>("h1"), state) @[src/main/scala/WbController.scala 65:51 66:15 35:22]
    node _T_3 = eq(UInt<3>("h1"), state) @[src/main/scala/WbController.scala 63:17]
    node _GEN_1 = mux(writeLast, UInt<3>("h2"), state) @[src/main/scala/WbController.scala 71:23 72:15 35:22]
    node _T_4 = eq(UInt<3>("h2"), state) @[src/main/scala/WbController.scala 63:17]
    node _GEN_2 = mux(io_ctrl_shoot, UInt<3>("h3"), state) @[src/main/scala/WbController.scala 77:27 78:15 35:22]
    node _T_5 = eq(UInt<3>("h3"), state) @[src/main/scala/WbController.scala 63:17]
    node _T_6 = gt(validCnt, UInt<1>("h1")) @[src/main/scala/WbController.scala 84:23]
    node _T_7 = or(_T_6, writeLast) @[src/main/scala/WbController.scala 84:29]
    node _GEN_3 = mux(_T_7, UInt<3>("h3"), UInt<3>("h4")) @[src/main/scala/WbController.scala 84:43 85:17 87:17]
    node _GEN_4 = mux(readLast, _GEN_3, state) @[src/main/scala/WbController.scala 35:22 83:22]
    node _T_8 = eq(UInt<3>("h4"), state) @[src/main/scala/WbController.scala 63:17]
    node _GEN_5 = mux(writeLast, UInt<3>("h3"), state) @[src/main/scala/WbController.scala 93:23 94:15 35:22]
    node _GEN_6 = mux(_T_8, _GEN_5, state) @[src/main/scala/WbController.scala 63:17 35:22]
    node _GEN_7 = mux(_T_5, _GEN_4, _GEN_6) @[src/main/scala/WbController.scala 63:17]
    node _GEN_8 = mux(_T_4, _GEN_2, _GEN_7) @[src/main/scala/WbController.scala 63:17]
    node _GEN_9 = mux(_T_3, _GEN_1, _GEN_8) @[src/main/scala/WbController.scala 63:17]
    node _GEN_10 = mux(_T, _GEN_0, _GEN_9) @[src/main/scala/WbController.scala 63:17]
    node _i_T = add(i, UInt<1>("h1")) @[src/main/scala/WbController.scala 102:14]
    node _i_T_1 = tail(_i_T, 1) @[src/main/scala/WbController.scala 102:14]
    node _writePtr_T = add(writePtr, UInt<1>("h1")) @[src/main/scala/WbController.scala 104:28]
    node _writePtr_T_1 = tail(_writePtr_T, 1) @[src/main/scala/WbController.scala 104:28]
    node _GEN_11 = mux(writeLast, UInt<1>("h0"), _writePtr_T_1) @[src/main/scala/WbController.scala 100:21 101:16 104:16]
    node _GEN_12 = mux(writeLast, _i_T_1, i) @[src/main/scala/WbController.scala 100:21 102:9 37:18]
    node _GEN_13 = mux(io_ctrl_dma_data_last, UInt<1>("h1"), gotDmaLast) @[src/main/scala/WbController.scala 107:33 108:18 43:27]
    node _GEN_14 = mux(writeActive, _GEN_11, writePtr) @[src/main/scala/WbController.scala 99:21 40:25]
    node _GEN_15 = mux(writeActive, _GEN_12, i) @[src/main/scala/WbController.scala 37:18 99:21]
    node _GEN_16 = mux(writeActive, _GEN_13, gotDmaLast) @[src/main/scala/WbController.scala 99:21 43:27]
    node _j_T = add(j, UInt<1>("h1")) @[src/main/scala/WbController.scala 115:14]
    node _j_T_1 = tail(_j_T, 1) @[src/main/scala/WbController.scala 115:14]
    node _readPtr_T = add(readPtr, UInt<1>("h1")) @[src/main/scala/WbController.scala 117:26]
    node _readPtr_T_1 = tail(_readPtr_T, 1) @[src/main/scala/WbController.scala 117:26]
    node _GEN_17 = mux(readLast, UInt<1>("h0"), _readPtr_T_1) @[src/main/scala/WbController.scala 113:20 114:15 117:15]
    node _GEN_18 = mux(readLast, _j_T_1, j) @[src/main/scala/WbController.scala 113:20 115:9 38:18]
    node _GEN_19 = mux(readActive, _GEN_17, readPtr) @[src/main/scala/WbController.scala 112:20 41:25]
    node _GEN_20 = mux(readActive, _GEN_18, j) @[src/main/scala/WbController.scala 112:20 38:18]
    node _T_9 = eq(readLast, UInt<1>("h0")) @[src/main/scala/WbController.scala 121:21]
    node _T_10 = and(writeLast, _T_9) @[src/main/scala/WbController.scala 121:18]
    node _validCnt_T = add(validCnt, UInt<1>("h1")) @[src/main/scala/WbController.scala 122:26]
    node _validCnt_T_1 = tail(_validCnt_T, 1) @[src/main/scala/WbController.scala 122:26]
    node _T_11 = eq(writeLast, UInt<1>("h0")) @[src/main/scala/WbController.scala 123:26]
    node _T_12 = and(readLast, _T_11) @[src/main/scala/WbController.scala 123:23]
    node _validCnt_T_2 = sub(validCnt, UInt<1>("h1")) @[src/main/scala/WbController.scala 124:26]
    node _validCnt_T_3 = tail(_validCnt_T_2, 1) @[src/main/scala/WbController.scala 124:26]
    node _GEN_21 = mux(_T_12, _validCnt_T_3, validCnt) @[src/main/scala/WbController.scala 123:38 124:14 42:25]
    node _GEN_22 = mux(_T_10, _validCnt_T_1, _GEN_21) @[src/main/scala/WbController.scala 121:32 122:14]
    node _T_13 = eq(io_ctrl_enable, UInt<1>("h0")) @[src/main/scala/WbController.scala 127:30]
    node _T_14 = or(io_ctrl_soft_reset, _T_13) @[src/main/scala/WbController.scala 127:27]
    node _GEN_23 = mux(_T_14, UInt<3>("h0"), _GEN_10) @[src/main/scala/WbController.scala 127:47 128:11]
    node _GEN_24 = mux(_T_14, UInt<1>("h0"), _GEN_15) @[src/main/scala/WbController.scala 127:47 129:7]
    node _GEN_25 = mux(_T_14, UInt<1>("h0"), _GEN_20) @[src/main/scala/WbController.scala 127:47 130:7]
    node _GEN_26 = mux(_T_14, UInt<1>("h0"), _GEN_14) @[src/main/scala/WbController.scala 127:47 131:14]
    node _GEN_27 = mux(_T_14, UInt<1>("h0"), _GEN_19) @[src/main/scala/WbController.scala 127:47 132:13]
    node _GEN_28 = mux(_T_14, UInt<1>("h0"), _GEN_22) @[src/main/scala/WbController.scala 127:47 133:14]
    node _GEN_29 = mux(_T_14, UInt<1>("h0"), _GEN_16) @[src/main/scala/WbController.scala 127:47 134:16]
    node _io_wr_addr_T = cat(writeSlotBase, writePtr) @[src/main/scala/WbController.scala 138:20]
    node _io_rd_addr_T = cat(readSlotBase, readPtr) @[src/main/scala/WbController.scala 142:20]
    node _GEN_30 = mux(io_lut_prog_mode, UInt<1>("h0"), io_rd_data) @[src/main/scala/WbController.scala 145:26 146:22 149:22]
    node _GEN_31 = mux(io_lut_prog_mode, io_rd_data, UInt<1>("h0")) @[src/main/scala/WbController.scala 145:26 147:23 150:23]
    node _io_ctrl_ready_T = eq(io_ctrl_enable, UInt<1>("h0")) @[src/main/scala/WbController.scala 154:31]
    node _io_ctrl_ready_T_1 = or(isReady, _io_ctrl_ready_T) @[src/main/scala/WbController.scala 154:28]
    node _io_ctrl_hungry_T = eq(isIdle, UInt<1>("h0")) @[src/main/scala/WbController.scala 155:21]
    node _io_ctrl_hungry_T_1 = eq(queueFull, UInt<1>("h0")) @[src/main/scala/WbController.scala 155:32]
    node _io_ctrl_hungry_T_2 = and(_io_ctrl_hungry_T, _io_ctrl_hungry_T_1) @[src/main/scala/WbController.scala 155:29]
    node _io_ctrl_impending_T = leq(validCnt, UInt<1>("h1")) @[src/main/scala/WbController.scala 156:46]
    node _io_ctrl_impending_T_1 = and(isWorking, _io_ctrl_impending_T) @[src/main/scala/WbController.scala 156:34]
    node _io_ctrl_impending_T_2 = eq(queueFull, UInt<1>("h0")) @[src/main/scala/WbController.scala 156:56]
    node _io_ctrl_impending_T_3 = and(_io_ctrl_impending_T_1, _io_ctrl_impending_T_2) @[src/main/scala/WbController.scala 156:53]
    node _io_ctrl_full_T = gt(validCnt, UInt<1>("h1")) @[src/main/scala/WbController.scala 157:28]
    io_ctrl_last_data_out <= gotDmaLast @[src/main/scala/WbController.scala 158:25]
    io_ctrl_ready <= _io_ctrl_ready_T_1 @[src/main/scala/WbController.scala 154:17]
    io_ctrl_hungry <= _io_ctrl_hungry_T_2 @[src/main/scala/WbController.scala 155:18]
    io_ctrl_impending <= _io_ctrl_impending_T_3 @[src/main/scala/WbController.scala 156:21]
    io_ctrl_working <= isWorking @[src/main/scala/WbController.scala 153:19]
    io_ctrl_full <= _io_ctrl_full_T @[src/main/scala/WbController.scala 157:16]
    io_rd_addr <= _io_rd_addr_T @[src/main/scala/WbController.scala 142:14]
    io_rd_en <= readActive @[src/main/scala/WbController.scala 141:12]
    io_active_bank <= readSlotBank @[src/main/scala/WbController.scala 143:18]
    io_rd_data_to_cu <= _GEN_30
    io_rd_data_to_lut <= _GEN_31
    io_wr_en <= writeActive @[src/main/scala/WbController.scala 137:12]
    io_wr_addr <= _io_wr_addr_T @[src/main/scala/WbController.scala 138:14]
    io_write_bank <= writeSlotBank @[src/main/scala/WbController.scala 139:17]
    state <= mux(reset, UInt<3>("h0"), _GEN_23) @[src/main/scala/WbController.scala 35:{22,22}]
    i <= mux(reset, UInt<2>("h0"), _GEN_24) @[src/main/scala/WbController.scala 37:{18,18}]
    j <= mux(reset, UInt<2>("h0"), _GEN_25) @[src/main/scala/WbController.scala 38:{18,18}]
    writePtr <= mux(reset, UInt<6>("h0"), _GEN_26) @[src/main/scala/WbController.scala 40:{25,25}]
    readPtr <= mux(reset, UInt<8>("h0"), _GEN_27) @[src/main/scala/WbController.scala 41:{25,25}]
    validCnt <= mux(reset, UInt<3>("h0"), _GEN_28) @[src/main/scala/WbController.scala 42:{25,25}]
    gotDmaLast <= mux(reset, UInt<1>("h0"), _GEN_29) @[src/main/scala/WbController.scala 43:{27,27}]

  module AsymmetricPingPongSRAM : @[src/main/scala/OCM.scala 40:7]
    input clock : Clock @[src/main/scala/OCM.scala 40:7]
    input reset : UInt<1> @[src/main/scala/OCM.scala 40:7]
    input io_ping_wr_en : UInt<1> @[src/main/scala/OCM.scala 51:14]
    input io_ping_wr_addr : UInt<7> @[src/main/scala/OCM.scala 51:14]
    input io_ping_wr_data : UInt<512> @[src/main/scala/OCM.scala 51:14]
    input io_ping_rd_en : UInt<1> @[src/main/scala/OCM.scala 51:14]
    input io_ping_rd_addr : UInt<9> @[src/main/scala/OCM.scala 51:14]
    output io_ping_rd_data : UInt<128> @[src/main/scala/OCM.scala 51:14]
    input io_pong_wr_en : UInt<1> @[src/main/scala/OCM.scala 51:14]
    input io_pong_wr_addr : UInt<7> @[src/main/scala/OCM.scala 51:14]
    input io_pong_wr_data : UInt<512> @[src/main/scala/OCM.scala 51:14]
    input io_pong_rd_en : UInt<1> @[src/main/scala/OCM.scala 51:14]
    input io_pong_rd_addr : UInt<9> @[src/main/scala/OCM.scala 51:14]
    output io_pong_rd_data : UInt<128> @[src/main/scala/OCM.scala 51:14]

    mem io_ping_rd_data_subBanks_0 : @[src/main/scala/OCM.scala 76:47]
      data-type => UInt<128>
      depth => 128
      read-latency => 1
      write-latency => 1
      reader => io_ping_rd_data_rdDataVec_0_MPORT
      writer => io_ping_rd_data_MPORT
      read-under-write => undefined
    mem io_ping_rd_data_subBanks_1 : @[src/main/scala/OCM.scala 76:47]
      data-type => UInt<128>
      depth => 128
      read-latency => 1
      write-latency => 1
      reader => io_ping_rd_data_rdDataVec_1_MPORT
      writer => io_ping_rd_data_MPORT_1
      read-under-write => undefined
    mem io_ping_rd_data_subBanks_2 : @[src/main/scala/OCM.scala 76:47]
      data-type => UInt<128>
      depth => 128
      read-latency => 1
      write-latency => 1
      reader => io_ping_rd_data_rdDataVec_2_MPORT
      writer => io_ping_rd_data_MPORT_2
      read-under-write => undefined
    mem io_ping_rd_data_subBanks_3 : @[src/main/scala/OCM.scala 76:47]
      data-type => UInt<128>
      depth => 128
      read-latency => 1
      write-latency => 1
      reader => io_ping_rd_data_rdDataVec_3_MPORT
      writer => io_ping_rd_data_MPORT_3
      read-under-write => undefined
    mem io_pong_rd_data_subBanks_0 : @[src/main/scala/OCM.scala 76:47]
      data-type => UInt<128>
      depth => 128
      read-latency => 1
      write-latency => 1
      reader => io_pong_rd_data_rdDataVec_0_MPORT
      writer => io_pong_rd_data_MPORT
      read-under-write => undefined
    mem io_pong_rd_data_subBanks_1 : @[src/main/scala/OCM.scala 76:47]
      data-type => UInt<128>
      depth => 128
      read-latency => 1
      write-latency => 1
      reader => io_pong_rd_data_rdDataVec_1_MPORT
      writer => io_pong_rd_data_MPORT_1
      read-under-write => undefined
    mem io_pong_rd_data_subBanks_2 : @[src/main/scala/OCM.scala 76:47]
      data-type => UInt<128>
      depth => 128
      read-latency => 1
      write-latency => 1
      reader => io_pong_rd_data_rdDataVec_2_MPORT
      writer => io_pong_rd_data_MPORT_2
      read-under-write => undefined
    mem io_pong_rd_data_subBanks_3 : @[src/main/scala/OCM.scala 76:47]
      data-type => UInt<128>
      depth => 128
      read-latency => 1
      write-latency => 1
      reader => io_pong_rd_data_rdDataVec_3_MPORT
      writer => io_pong_rd_data_MPORT_3
      read-under-write => undefined
    node io_ping_rd_data_wordAddr = bits(io_ping_rd_addr, 8, 2) @[src/main/scala/OCM.scala 79:27]
    node io_ping_rd_data_bankSel = bits(io_ping_rd_addr, 1, 0) @[src/main/scala/OCM.scala 80:26]
    node io_ping_rd_data_sliceData = bits(io_ping_wr_data, 127, 0) @[src/main/scala/OCM.scala 83:30]
    node _GEN_0 = validif(io_ping_wr_en, io_ping_wr_addr) @[src/main/scala/OCM.scala 84:19 85:26]
    node _GEN_1 = validif(io_ping_wr_en, clock) @[src/main/scala/OCM.scala 84:19 85:26]
    node _GEN_2 = mux(io_ping_wr_en, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/OCM.scala 84:19 85:26 76:47]
    node _GEN_3 = validif(io_ping_wr_en, UInt<1>("h1")) @[src/main/scala/OCM.scala 84:19 85:26]
    node _GEN_4 = validif(io_ping_wr_en, io_ping_rd_data_sliceData) @[src/main/scala/OCM.scala 84:19 85:26]
    node _io_ping_rd_data_rdDataVec_0_T = eq(io_ping_rd_data_bankSel, UInt<1>("h0")) @[src/main/scala/OCM.scala 87:67]
    node _io_ping_rd_data_rdDataVec_0_T_1 = and(io_ping_rd_en, _io_ping_rd_data_rdDataVec_0_T) @[src/main/scala/OCM.scala 87:56]
    node _GEN_5 = validif(_io_ping_rd_data_rdDataVec_0_T_1, io_ping_rd_data_wordAddr) @[src/main/scala/OCM.scala 87:{39,39}]
    node _GEN_6 = mux(_io_ping_rd_data_rdDataVec_0_T_1, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/OCM.scala 87:{39,39} 76:47]
    node _io_ping_rd_data_rdDataVec_0_WIRE = _GEN_5 @[src/main/scala/OCM.scala 87:39]
    node _GEN_7 = validif(_io_ping_rd_data_rdDataVec_0_T_1, _io_ping_rd_data_rdDataVec_0_WIRE) @[src/main/scala/OCM.scala 87:{39,39}]
    node _GEN_8 = validif(_io_ping_rd_data_rdDataVec_0_T_1, clock) @[src/main/scala/OCM.scala 87:{39,39}]
    node io_ping_rd_data_sliceData_1 = bits(io_ping_wr_data, 255, 128) @[src/main/scala/OCM.scala 83:30]
    node _GEN_9 = validif(io_ping_wr_en, io_ping_rd_data_sliceData_1) @[src/main/scala/OCM.scala 84:19 85:26]
    node _io_ping_rd_data_rdDataVec_1_T = eq(io_ping_rd_data_bankSel, UInt<1>("h1")) @[src/main/scala/OCM.scala 87:67]
    node _io_ping_rd_data_rdDataVec_1_T_1 = and(io_ping_rd_en, _io_ping_rd_data_rdDataVec_1_T) @[src/main/scala/OCM.scala 87:56]
    node _GEN_10 = validif(_io_ping_rd_data_rdDataVec_1_T_1, io_ping_rd_data_wordAddr) @[src/main/scala/OCM.scala 87:{39,39}]
    node _GEN_11 = mux(_io_ping_rd_data_rdDataVec_1_T_1, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/OCM.scala 87:{39,39} 76:47]
    node _io_ping_rd_data_rdDataVec_1_WIRE = _GEN_10 @[src/main/scala/OCM.scala 87:39]
    node _GEN_12 = validif(_io_ping_rd_data_rdDataVec_1_T_1, _io_ping_rd_data_rdDataVec_1_WIRE) @[src/main/scala/OCM.scala 87:{39,39}]
    node _GEN_13 = validif(_io_ping_rd_data_rdDataVec_1_T_1, clock) @[src/main/scala/OCM.scala 87:{39,39}]
    node io_ping_rd_data_sliceData_2 = bits(io_ping_wr_data, 383, 256) @[src/main/scala/OCM.scala 83:30]
    node _GEN_14 = validif(io_ping_wr_en, io_ping_rd_data_sliceData_2) @[src/main/scala/OCM.scala 84:19 85:26]
    node _io_ping_rd_data_rdDataVec_2_T = eq(io_ping_rd_data_bankSel, UInt<2>("h2")) @[src/main/scala/OCM.scala 87:67]
    node _io_ping_rd_data_rdDataVec_2_T_1 = and(io_ping_rd_en, _io_ping_rd_data_rdDataVec_2_T) @[src/main/scala/OCM.scala 87:56]
    node _GEN_15 = validif(_io_ping_rd_data_rdDataVec_2_T_1, io_ping_rd_data_wordAddr) @[src/main/scala/OCM.scala 87:{39,39}]
    node _GEN_16 = mux(_io_ping_rd_data_rdDataVec_2_T_1, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/OCM.scala 87:{39,39} 76:47]
    node _io_ping_rd_data_rdDataVec_2_WIRE = _GEN_15 @[src/main/scala/OCM.scala 87:39]
    node _GEN_17 = validif(_io_ping_rd_data_rdDataVec_2_T_1, _io_ping_rd_data_rdDataVec_2_WIRE) @[src/main/scala/OCM.scala 87:{39,39}]
    node _GEN_18 = validif(_io_ping_rd_data_rdDataVec_2_T_1, clock) @[src/main/scala/OCM.scala 87:{39,39}]
    node io_ping_rd_data_sliceData_3 = bits(io_ping_wr_data, 511, 384) @[src/main/scala/OCM.scala 83:30]
    node _GEN_19 = validif(io_ping_wr_en, io_ping_rd_data_sliceData_3) @[src/main/scala/OCM.scala 84:19 85:26]
    node _io_ping_rd_data_rdDataVec_3_T = eq(io_ping_rd_data_bankSel, UInt<2>("h3")) @[src/main/scala/OCM.scala 87:67]
    node _io_ping_rd_data_rdDataVec_3_T_1 = and(io_ping_rd_en, _io_ping_rd_data_rdDataVec_3_T) @[src/main/scala/OCM.scala 87:56]
    node _GEN_20 = validif(_io_ping_rd_data_rdDataVec_3_T_1, io_ping_rd_data_wordAddr) @[src/main/scala/OCM.scala 87:{39,39}]
    node _GEN_21 = mux(_io_ping_rd_data_rdDataVec_3_T_1, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/OCM.scala 87:{39,39} 76:47]
    node _io_ping_rd_data_rdDataVec_3_WIRE = _GEN_20 @[src/main/scala/OCM.scala 87:39]
    node _GEN_22 = validif(_io_ping_rd_data_rdDataVec_3_T_1, _io_ping_rd_data_rdDataVec_3_WIRE) @[src/main/scala/OCM.scala 87:{39,39}]
    node _GEN_23 = validif(_io_ping_rd_data_rdDataVec_3_T_1, clock) @[src/main/scala/OCM.scala 87:{39,39}]
    reg io_ping_rd_data_bankSelD1 : UInt<2>, clock with :
      reset => (UInt<1>("h0"), io_ping_rd_data_bankSelD1) @[src/main/scala/OCM.scala 90:30]
    node _GEN_24 = mux(io_ping_rd_en, io_ping_rd_data_bankSel, io_ping_rd_data_bankSelD1) @[src/main/scala/OCM.scala 90:{30,30,30}]
    node _io_ping_rd_data_T = or(io_ping_rd_data_bankSelD1, UInt<2>("h0"))
    node _io_ping_rd_data_T_1 = bits(_io_ping_rd_data_T, 1, 0)
    node io_ping_rd_data_rdDataVec_0 = io_ping_rd_data_subBanks_0.io_ping_rd_data_rdDataVec_0_MPORT.data @[src/main/scala/OCM.scala 77:25 87:20]
    node _GEN_25 = validif(eq(UInt<1>("h0"), _io_ping_rd_data_T_1), io_ping_rd_data_rdDataVec_0) @[src/main/scala/OCM.scala 94:{19,19}]
    node io_ping_rd_data_rdDataVec_1 = io_ping_rd_data_subBanks_1.io_ping_rd_data_rdDataVec_1_MPORT.data @[src/main/scala/OCM.scala 77:25 87:20]
    node _GEN_26 = mux(eq(UInt<1>("h1"), _io_ping_rd_data_T_1), io_ping_rd_data_rdDataVec_1, _GEN_25) @[src/main/scala/OCM.scala 94:{19,19}]
    node io_ping_rd_data_rdDataVec_2 = io_ping_rd_data_subBanks_2.io_ping_rd_data_rdDataVec_2_MPORT.data @[src/main/scala/OCM.scala 77:25 87:20]
    node _GEN_27 = mux(eq(UInt<2>("h2"), _io_ping_rd_data_T_1), io_ping_rd_data_rdDataVec_2, _GEN_26) @[src/main/scala/OCM.scala 94:{19,19}]
    node io_ping_rd_data_rdDataVec_3 = io_ping_rd_data_subBanks_3.io_ping_rd_data_rdDataVec_3_MPORT.data @[src/main/scala/OCM.scala 77:25 87:20]
    node _GEN_28 = mux(eq(UInt<2>("h3"), _io_ping_rd_data_T_1), io_ping_rd_data_rdDataVec_3, _GEN_27) @[src/main/scala/OCM.scala 94:{19,19}]
    node io_pong_rd_data_wordAddr = bits(io_pong_rd_addr, 8, 2) @[src/main/scala/OCM.scala 79:27]
    node io_pong_rd_data_bankSel = bits(io_pong_rd_addr, 1, 0) @[src/main/scala/OCM.scala 80:26]
    node io_pong_rd_data_sliceData = bits(io_pong_wr_data, 127, 0) @[src/main/scala/OCM.scala 83:30]
    node _GEN_29 = validif(io_pong_wr_en, io_pong_wr_addr) @[src/main/scala/OCM.scala 84:19 85:26]
    node _GEN_30 = validif(io_pong_wr_en, clock) @[src/main/scala/OCM.scala 84:19 85:26]
    node _GEN_31 = mux(io_pong_wr_en, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/OCM.scala 84:19 85:26 76:47]
    node _GEN_32 = validif(io_pong_wr_en, UInt<1>("h1")) @[src/main/scala/OCM.scala 84:19 85:26]
    node _GEN_33 = validif(io_pong_wr_en, io_pong_rd_data_sliceData) @[src/main/scala/OCM.scala 84:19 85:26]
    node _io_pong_rd_data_rdDataVec_0_T = eq(io_pong_rd_data_bankSel, UInt<1>("h0")) @[src/main/scala/OCM.scala 87:67]
    node _io_pong_rd_data_rdDataVec_0_T_1 = and(io_pong_rd_en, _io_pong_rd_data_rdDataVec_0_T) @[src/main/scala/OCM.scala 87:56]
    node _GEN_34 = validif(_io_pong_rd_data_rdDataVec_0_T_1, io_pong_rd_data_wordAddr) @[src/main/scala/OCM.scala 87:{39,39}]
    node _GEN_35 = mux(_io_pong_rd_data_rdDataVec_0_T_1, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/OCM.scala 87:{39,39} 76:47]
    node _io_pong_rd_data_rdDataVec_0_WIRE = _GEN_34 @[src/main/scala/OCM.scala 87:39]
    node _GEN_36 = validif(_io_pong_rd_data_rdDataVec_0_T_1, _io_pong_rd_data_rdDataVec_0_WIRE) @[src/main/scala/OCM.scala 87:{39,39}]
    node _GEN_37 = validif(_io_pong_rd_data_rdDataVec_0_T_1, clock) @[src/main/scala/OCM.scala 87:{39,39}]
    node io_pong_rd_data_sliceData_1 = bits(io_pong_wr_data, 255, 128) @[src/main/scala/OCM.scala 83:30]
    node _GEN_38 = validif(io_pong_wr_en, io_pong_rd_data_sliceData_1) @[src/main/scala/OCM.scala 84:19 85:26]
    node _io_pong_rd_data_rdDataVec_1_T = eq(io_pong_rd_data_bankSel, UInt<1>("h1")) @[src/main/scala/OCM.scala 87:67]
    node _io_pong_rd_data_rdDataVec_1_T_1 = and(io_pong_rd_en, _io_pong_rd_data_rdDataVec_1_T) @[src/main/scala/OCM.scala 87:56]
    node _GEN_39 = validif(_io_pong_rd_data_rdDataVec_1_T_1, io_pong_rd_data_wordAddr) @[src/main/scala/OCM.scala 87:{39,39}]
    node _GEN_40 = mux(_io_pong_rd_data_rdDataVec_1_T_1, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/OCM.scala 87:{39,39} 76:47]
    node _io_pong_rd_data_rdDataVec_1_WIRE = _GEN_39 @[src/main/scala/OCM.scala 87:39]
    node _GEN_41 = validif(_io_pong_rd_data_rdDataVec_1_T_1, _io_pong_rd_data_rdDataVec_1_WIRE) @[src/main/scala/OCM.scala 87:{39,39}]
    node _GEN_42 = validif(_io_pong_rd_data_rdDataVec_1_T_1, clock) @[src/main/scala/OCM.scala 87:{39,39}]
    node io_pong_rd_data_sliceData_2 = bits(io_pong_wr_data, 383, 256) @[src/main/scala/OCM.scala 83:30]
    node _GEN_43 = validif(io_pong_wr_en, io_pong_rd_data_sliceData_2) @[src/main/scala/OCM.scala 84:19 85:26]
    node _io_pong_rd_data_rdDataVec_2_T = eq(io_pong_rd_data_bankSel, UInt<2>("h2")) @[src/main/scala/OCM.scala 87:67]
    node _io_pong_rd_data_rdDataVec_2_T_1 = and(io_pong_rd_en, _io_pong_rd_data_rdDataVec_2_T) @[src/main/scala/OCM.scala 87:56]
    node _GEN_44 = validif(_io_pong_rd_data_rdDataVec_2_T_1, io_pong_rd_data_wordAddr) @[src/main/scala/OCM.scala 87:{39,39}]
    node _GEN_45 = mux(_io_pong_rd_data_rdDataVec_2_T_1, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/OCM.scala 87:{39,39} 76:47]
    node _io_pong_rd_data_rdDataVec_2_WIRE = _GEN_44 @[src/main/scala/OCM.scala 87:39]
    node _GEN_46 = validif(_io_pong_rd_data_rdDataVec_2_T_1, _io_pong_rd_data_rdDataVec_2_WIRE) @[src/main/scala/OCM.scala 87:{39,39}]
    node _GEN_47 = validif(_io_pong_rd_data_rdDataVec_2_T_1, clock) @[src/main/scala/OCM.scala 87:{39,39}]
    node io_pong_rd_data_sliceData_3 = bits(io_pong_wr_data, 511, 384) @[src/main/scala/OCM.scala 83:30]
    node _GEN_48 = validif(io_pong_wr_en, io_pong_rd_data_sliceData_3) @[src/main/scala/OCM.scala 84:19 85:26]
    node _io_pong_rd_data_rdDataVec_3_T = eq(io_pong_rd_data_bankSel, UInt<2>("h3")) @[src/main/scala/OCM.scala 87:67]
    node _io_pong_rd_data_rdDataVec_3_T_1 = and(io_pong_rd_en, _io_pong_rd_data_rdDataVec_3_T) @[src/main/scala/OCM.scala 87:56]
    node _GEN_49 = validif(_io_pong_rd_data_rdDataVec_3_T_1, io_pong_rd_data_wordAddr) @[src/main/scala/OCM.scala 87:{39,39}]
    node _GEN_50 = mux(_io_pong_rd_data_rdDataVec_3_T_1, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/OCM.scala 87:{39,39} 76:47]
    node _io_pong_rd_data_rdDataVec_3_WIRE = _GEN_49 @[src/main/scala/OCM.scala 87:39]
    node _GEN_51 = validif(_io_pong_rd_data_rdDataVec_3_T_1, _io_pong_rd_data_rdDataVec_3_WIRE) @[src/main/scala/OCM.scala 87:{39,39}]
    node _GEN_52 = validif(_io_pong_rd_data_rdDataVec_3_T_1, clock) @[src/main/scala/OCM.scala 87:{39,39}]
    reg io_pong_rd_data_bankSelD1 : UInt<2>, clock with :
      reset => (UInt<1>("h0"), io_pong_rd_data_bankSelD1) @[src/main/scala/OCM.scala 90:30]
    node _GEN_53 = mux(io_pong_rd_en, io_pong_rd_data_bankSel, io_pong_rd_data_bankSelD1) @[src/main/scala/OCM.scala 90:{30,30,30}]
    node _io_pong_rd_data_T = or(io_pong_rd_data_bankSelD1, UInt<2>("h0"))
    node _io_pong_rd_data_T_1 = bits(_io_pong_rd_data_T, 1, 0)
    node io_pong_rd_data_rdDataVec_0 = io_pong_rd_data_subBanks_0.io_pong_rd_data_rdDataVec_0_MPORT.data @[src/main/scala/OCM.scala 77:25 87:20]
    node _GEN_54 = validif(eq(UInt<1>("h0"), _io_pong_rd_data_T_1), io_pong_rd_data_rdDataVec_0) @[src/main/scala/OCM.scala 101:{19,19}]
    node io_pong_rd_data_rdDataVec_1 = io_pong_rd_data_subBanks_1.io_pong_rd_data_rdDataVec_1_MPORT.data @[src/main/scala/OCM.scala 77:25 87:20]
    node _GEN_55 = mux(eq(UInt<1>("h1"), _io_pong_rd_data_T_1), io_pong_rd_data_rdDataVec_1, _GEN_54) @[src/main/scala/OCM.scala 101:{19,19}]
    node io_pong_rd_data_rdDataVec_2 = io_pong_rd_data_subBanks_2.io_pong_rd_data_rdDataVec_2_MPORT.data @[src/main/scala/OCM.scala 77:25 87:20]
    node _GEN_56 = mux(eq(UInt<2>("h2"), _io_pong_rd_data_T_1), io_pong_rd_data_rdDataVec_2, _GEN_55) @[src/main/scala/OCM.scala 101:{19,19}]
    node io_pong_rd_data_rdDataVec_3 = io_pong_rd_data_subBanks_3.io_pong_rd_data_rdDataVec_3_MPORT.data @[src/main/scala/OCM.scala 77:25 87:20]
    node _GEN_57 = mux(eq(UInt<2>("h3"), _io_pong_rd_data_T_1), io_pong_rd_data_rdDataVec_3, _GEN_56) @[src/main/scala/OCM.scala 101:{19,19}]
    node _io_ping_rd_data_rdDataVec_io_ping_rd_data_T_1 = _GEN_28 @[src/main/scala/OCM.scala 94:19]
    node _io_pong_rd_data_rdDataVec_io_pong_rd_data_T_1 = _GEN_57 @[src/main/scala/OCM.scala 101:19]
    io_ping_rd_data <= _io_ping_rd_data_rdDataVec_io_ping_rd_data_T_1 @[src/main/scala/OCM.scala 94:19]
    io_pong_rd_data <= _io_pong_rd_data_rdDataVec_io_pong_rd_data_T_1 @[src/main/scala/OCM.scala 101:19]
    io_ping_rd_data_subBanks_0.io_ping_rd_data_rdDataVec_0_MPORT.addr <= _GEN_7
    io_ping_rd_data_subBanks_0.io_ping_rd_data_rdDataVec_0_MPORT.en <= _GEN_6
    io_ping_rd_data_subBanks_0.io_ping_rd_data_rdDataVec_0_MPORT.clk <= _GEN_8
    io_ping_rd_data_subBanks_0.io_ping_rd_data_MPORT.addr <= _GEN_0
    io_ping_rd_data_subBanks_0.io_ping_rd_data_MPORT.en <= _GEN_2
    io_ping_rd_data_subBanks_0.io_ping_rd_data_MPORT.clk <= _GEN_1
    io_ping_rd_data_subBanks_0.io_ping_rd_data_MPORT.data <= _GEN_4
    io_ping_rd_data_subBanks_0.io_ping_rd_data_MPORT.mask <= _GEN_3
    io_ping_rd_data_subBanks_1.io_ping_rd_data_rdDataVec_1_MPORT.addr <= _GEN_12
    io_ping_rd_data_subBanks_1.io_ping_rd_data_rdDataVec_1_MPORT.en <= _GEN_11
    io_ping_rd_data_subBanks_1.io_ping_rd_data_rdDataVec_1_MPORT.clk <= _GEN_13
    io_ping_rd_data_subBanks_1.io_ping_rd_data_MPORT_1.addr <= _GEN_0
    io_ping_rd_data_subBanks_1.io_ping_rd_data_MPORT_1.en <= _GEN_2
    io_ping_rd_data_subBanks_1.io_ping_rd_data_MPORT_1.clk <= _GEN_1
    io_ping_rd_data_subBanks_1.io_ping_rd_data_MPORT_1.data <= _GEN_9
    io_ping_rd_data_subBanks_1.io_ping_rd_data_MPORT_1.mask <= _GEN_3
    io_ping_rd_data_subBanks_2.io_ping_rd_data_rdDataVec_2_MPORT.addr <= _GEN_17
    io_ping_rd_data_subBanks_2.io_ping_rd_data_rdDataVec_2_MPORT.en <= _GEN_16
    io_ping_rd_data_subBanks_2.io_ping_rd_data_rdDataVec_2_MPORT.clk <= _GEN_18
    io_ping_rd_data_subBanks_2.io_ping_rd_data_MPORT_2.addr <= _GEN_0
    io_ping_rd_data_subBanks_2.io_ping_rd_data_MPORT_2.en <= _GEN_2
    io_ping_rd_data_subBanks_2.io_ping_rd_data_MPORT_2.clk <= _GEN_1
    io_ping_rd_data_subBanks_2.io_ping_rd_data_MPORT_2.data <= _GEN_14
    io_ping_rd_data_subBanks_2.io_ping_rd_data_MPORT_2.mask <= _GEN_3
    io_ping_rd_data_subBanks_3.io_ping_rd_data_rdDataVec_3_MPORT.addr <= _GEN_22
    io_ping_rd_data_subBanks_3.io_ping_rd_data_rdDataVec_3_MPORT.en <= _GEN_21
    io_ping_rd_data_subBanks_3.io_ping_rd_data_rdDataVec_3_MPORT.clk <= _GEN_23
    io_ping_rd_data_subBanks_3.io_ping_rd_data_MPORT_3.addr <= _GEN_0
    io_ping_rd_data_subBanks_3.io_ping_rd_data_MPORT_3.en <= _GEN_2
    io_ping_rd_data_subBanks_3.io_ping_rd_data_MPORT_3.clk <= _GEN_1
    io_ping_rd_data_subBanks_3.io_ping_rd_data_MPORT_3.data <= _GEN_19
    io_ping_rd_data_subBanks_3.io_ping_rd_data_MPORT_3.mask <= _GEN_3
    io_ping_rd_data_bankSelD1 <= mux(reset, UInt<1>("h0"), _GEN_24) @[src/main/scala/OCM.scala 90:{30,30}]
    io_pong_rd_data_subBanks_0.io_pong_rd_data_rdDataVec_0_MPORT.addr <= _GEN_36
    io_pong_rd_data_subBanks_0.io_pong_rd_data_rdDataVec_0_MPORT.en <= _GEN_35
    io_pong_rd_data_subBanks_0.io_pong_rd_data_rdDataVec_0_MPORT.clk <= _GEN_37
    io_pong_rd_data_subBanks_0.io_pong_rd_data_MPORT.addr <= _GEN_29
    io_pong_rd_data_subBanks_0.io_pong_rd_data_MPORT.en <= _GEN_31
    io_pong_rd_data_subBanks_0.io_pong_rd_data_MPORT.clk <= _GEN_30
    io_pong_rd_data_subBanks_0.io_pong_rd_data_MPORT.data <= _GEN_33
    io_pong_rd_data_subBanks_0.io_pong_rd_data_MPORT.mask <= _GEN_32
    io_pong_rd_data_subBanks_1.io_pong_rd_data_rdDataVec_1_MPORT.addr <= _GEN_41
    io_pong_rd_data_subBanks_1.io_pong_rd_data_rdDataVec_1_MPORT.en <= _GEN_40
    io_pong_rd_data_subBanks_1.io_pong_rd_data_rdDataVec_1_MPORT.clk <= _GEN_42
    io_pong_rd_data_subBanks_1.io_pong_rd_data_MPORT_1.addr <= _GEN_29
    io_pong_rd_data_subBanks_1.io_pong_rd_data_MPORT_1.en <= _GEN_31
    io_pong_rd_data_subBanks_1.io_pong_rd_data_MPORT_1.clk <= _GEN_30
    io_pong_rd_data_subBanks_1.io_pong_rd_data_MPORT_1.data <= _GEN_38
    io_pong_rd_data_subBanks_1.io_pong_rd_data_MPORT_1.mask <= _GEN_32
    io_pong_rd_data_subBanks_2.io_pong_rd_data_rdDataVec_2_MPORT.addr <= _GEN_46
    io_pong_rd_data_subBanks_2.io_pong_rd_data_rdDataVec_2_MPORT.en <= _GEN_45
    io_pong_rd_data_subBanks_2.io_pong_rd_data_rdDataVec_2_MPORT.clk <= _GEN_47
    io_pong_rd_data_subBanks_2.io_pong_rd_data_MPORT_2.addr <= _GEN_29
    io_pong_rd_data_subBanks_2.io_pong_rd_data_MPORT_2.en <= _GEN_31
    io_pong_rd_data_subBanks_2.io_pong_rd_data_MPORT_2.clk <= _GEN_30
    io_pong_rd_data_subBanks_2.io_pong_rd_data_MPORT_2.data <= _GEN_43
    io_pong_rd_data_subBanks_2.io_pong_rd_data_MPORT_2.mask <= _GEN_32
    io_pong_rd_data_subBanks_3.io_pong_rd_data_rdDataVec_3_MPORT.addr <= _GEN_51
    io_pong_rd_data_subBanks_3.io_pong_rd_data_rdDataVec_3_MPORT.en <= _GEN_50
    io_pong_rd_data_subBanks_3.io_pong_rd_data_rdDataVec_3_MPORT.clk <= _GEN_52
    io_pong_rd_data_subBanks_3.io_pong_rd_data_MPORT_3.addr <= _GEN_29
    io_pong_rd_data_subBanks_3.io_pong_rd_data_MPORT_3.en <= _GEN_31
    io_pong_rd_data_subBanks_3.io_pong_rd_data_MPORT_3.clk <= _GEN_30
    io_pong_rd_data_subBanks_3.io_pong_rd_data_MPORT_3.data <= _GEN_48
    io_pong_rd_data_subBanks_3.io_pong_rd_data_MPORT_3.mask <= _GEN_32
    io_pong_rd_data_bankSelD1 <= mux(reset, UInt<1>("h0"), _GEN_53) @[src/main/scala/OCM.scala 90:{30,30}]

  module WbControllerWithBram : @[src/main/scala/WbController.scala 162:7]
    input clock : Clock @[src/main/scala/WbController.scala 162:7]
    input reset : UInt<1> @[src/main/scala/WbController.scala 162:7]
    input io_soft_reset : UInt<1> @[src/main/scala/WbController.scala 163:14]
    input io_enable : UInt<1> @[src/main/scala/WbController.scala 163:14]
    input io_shoot : UInt<1> @[src/main/scala/WbController.scala 163:14]
    input io_lut_prog_mode : UInt<1> @[src/main/scala/WbController.scala 163:14]
    input io_rlast : UInt<1> @[src/main/scala/WbController.scala 163:14]
    input io_dma_data : UInt<512> @[src/main/scala/WbController.scala 163:14]
    input io_dma_data_valid : UInt<1> @[src/main/scala/WbController.scala 163:14]
    input io_dma_data_last : UInt<1> @[src/main/scala/WbController.scala 163:14]
    input io_dma_write_ready : UInt<1> @[src/main/scala/WbController.scala 163:14]
    output io_ready : UInt<1> @[src/main/scala/WbController.scala 163:14]
    output io_hungry : UInt<1> @[src/main/scala/WbController.scala 163:14]
    output io_impending : UInt<1> @[src/main/scala/WbController.scala 163:14]
    output io_working : UInt<1> @[src/main/scala/WbController.scala 163:14]
    output io_full : UInt<1> @[src/main/scala/WbController.scala 163:14]
    output io_dma_last_data_out : UInt<1> @[src/main/scala/WbController.scala 163:14]
    output io_rd_data_to_cu : UInt<128> @[src/main/scala/WbController.scala 163:14]
    output io_rd_data_to_lut : UInt<128> @[src/main/scala/WbController.scala 163:14]
    output io_rd_data_valid : UInt<1> @[src/main/scala/WbController.scala 163:14]
    output io_dbg_active_bank : UInt<1> @[src/main/scala/WbController.scala 163:14]
    output io_dbg_write_bank : UInt<1> @[src/main/scala/WbController.scala 163:14]
    output io_dbg_rd_addr : UInt<9> @[src/main/scala/WbController.scala 163:14]
    output io_dbg_wr_addr : UInt<7> @[src/main/scala/WbController.scala 163:14]
    output io_dbg_ping_wr_en : UInt<1> @[src/main/scala/WbController.scala 163:14]
    output io_dbg_pong_wr_en : UInt<1> @[src/main/scala/WbController.scala 163:14]
    output io_dbg_ping_wr_addr : UInt<7> @[src/main/scala/WbController.scala 163:14]
    output io_dbg_pong_wr_addr : UInt<7> @[src/main/scala/WbController.scala 163:14]
    output io_dbg_ping_wr_data : UInt<512> @[src/main/scala/WbController.scala 163:14]
    output io_dbg_pong_wr_data : UInt<512> @[src/main/scala/WbController.scala 163:14]

    inst controller of WbController @[src/main/scala/WbController.scala 199:26]
    inst bram of AsymmetricPingPongSRAM @[src/main/scala/WbController.scala 200:20]
    node _controller_io_ctrl_dma_data_valid_T = and(io_dma_data_valid, io_dma_write_ready) @[src/main/scala/WbController.scala 206:59]
    node readPing = eq(controller.io_active_bank, UInt<1>("h0")) @[src/main/scala/WbController.scala 211:45]
    node writePing = eq(controller.io_write_bank, UInt<1>("h0")) @[src/main/scala/WbController.scala 212:44]
    node _bram_io_ping_wr_en_T = and(controller.io_wr_en, writePing) @[src/main/scala/WbController.scala 214:47]
    node _bram_io_pong_wr_en_T = eq(writePing, UInt<1>("h0")) @[src/main/scala/WbController.scala 215:50]
    node _bram_io_pong_wr_en_T_1 = and(controller.io_wr_en, _bram_io_pong_wr_en_T) @[src/main/scala/WbController.scala 215:47]
    node _bram_io_ping_rd_en_T = and(controller.io_rd_en, readPing) @[src/main/scala/WbController.scala 221:47]
    node _bram_io_pong_rd_en_T = eq(readPing, UInt<1>("h0")) @[src/main/scala/WbController.scala 222:50]
    node _bram_io_pong_rd_en_T_1 = and(controller.io_rd_en, _bram_io_pong_rd_en_T) @[src/main/scala/WbController.scala 222:47]
    reg readPingD1 : UInt<1>, clock with :
      reset => (UInt<1>("h0"), readPingD1) @[src/main/scala/WbController.scala 226:29]
    node _GEN_0 = mux(controller.io_rd_en, readPing, readPingD1) @[src/main/scala/WbController.scala 226:{29,29,29}]
    node _controller_io_rd_data_T = mux(readPingD1, bram.io_ping_rd_data, bram.io_pong_rd_data) @[src/main/scala/WbController.scala 227:31]
    reg io_rd_data_valid_REG : UInt<1>, clock with :
      reset => (UInt<1>("h0"), io_rd_data_valid_REG) @[src/main/scala/WbController.scala 238:31]
    io_ready <= controller.io_ctrl_ready @[src/main/scala/WbController.scala 229:16]
    io_hungry <= controller.io_ctrl_hungry @[src/main/scala/WbController.scala 230:16]
    io_impending <= controller.io_ctrl_impending @[src/main/scala/WbController.scala 231:16]
    io_working <= controller.io_ctrl_working @[src/main/scala/WbController.scala 232:16]
    io_full <= controller.io_ctrl_full @[src/main/scala/WbController.scala 233:11]
    io_dma_last_data_out <= controller.io_ctrl_last_data_out @[src/main/scala/WbController.scala 234:24]
    io_rd_data_to_cu <= controller.io_rd_data_to_cu @[src/main/scala/WbController.scala 236:21]
    io_rd_data_to_lut <= controller.io_rd_data_to_lut @[src/main/scala/WbController.scala 237:21]
    io_rd_data_valid <= io_rd_data_valid_REG @[src/main/scala/WbController.scala 238:21]
    io_dbg_active_bank <= controller.io_active_bank @[src/main/scala/WbController.scala 240:22]
    io_dbg_write_bank <= controller.io_write_bank @[src/main/scala/WbController.scala 241:22]
    io_dbg_rd_addr <= controller.io_rd_addr @[src/main/scala/WbController.scala 242:22]
    io_dbg_wr_addr <= controller.io_wr_addr @[src/main/scala/WbController.scala 243:22]
    io_dbg_ping_wr_en <= bram.io_ping_wr_en @[src/main/scala/WbController.scala 244:23]
    io_dbg_pong_wr_en <= bram.io_pong_wr_en @[src/main/scala/WbController.scala 245:23]
    io_dbg_ping_wr_addr <= bram.io_ping_wr_addr @[src/main/scala/WbController.scala 246:23]
    io_dbg_pong_wr_addr <= bram.io_pong_wr_addr @[src/main/scala/WbController.scala 247:23]
    io_dbg_ping_wr_data <= bram.io_ping_wr_data @[src/main/scala/WbController.scala 248:23]
    io_dbg_pong_wr_data <= bram.io_pong_wr_data @[src/main/scala/WbController.scala 249:23]
    controller.clock <= clock
    controller.reset <= reset
    controller.io_ctrl_soft_reset <= io_soft_reset @[src/main/scala/WbController.scala 202:38]
    controller.io_ctrl_enable <= io_enable @[src/main/scala/WbController.scala 203:38]
    controller.io_ctrl_shoot <= io_shoot @[src/main/scala/WbController.scala 204:38]
    controller.io_ctrl_rlast <= io_rlast @[src/main/scala/WbController.scala 205:38]
    controller.io_ctrl_dma_data_valid <= _controller_io_ctrl_dma_data_valid_T @[src/main/scala/WbController.scala 206:38]
    controller.io_ctrl_dma_data_last <= io_dma_data_last @[src/main/scala/WbController.scala 207:38]
    controller.io_ctrl_dma_write_ready <= io_dma_write_ready @[src/main/scala/WbController.scala 208:38]
    controller.io_lut_prog_mode <= io_lut_prog_mode @[src/main/scala/WbController.scala 209:38]
    controller.io_rd_data <= _controller_io_rd_data_T @[src/main/scala/WbController.scala 227:25]
    bram.clock <= clock
    bram.reset <= reset
    bram.io_ping_wr_en <= _bram_io_ping_wr_en_T @[src/main/scala/WbController.scala 214:24]
    bram.io_ping_wr_addr <= controller.io_wr_addr @[src/main/scala/WbController.scala 216:24]
    bram.io_ping_wr_data <= io_dma_data @[src/main/scala/WbController.scala 218:24]
    bram.io_ping_rd_en <= _bram_io_ping_rd_en_T @[src/main/scala/WbController.scala 221:24]
    bram.io_ping_rd_addr <= controller.io_rd_addr @[src/main/scala/WbController.scala 223:24]
    bram.io_pong_wr_en <= _bram_io_pong_wr_en_T_1 @[src/main/scala/WbController.scala 215:24]
    bram.io_pong_wr_addr <= controller.io_wr_addr @[src/main/scala/WbController.scala 217:24]
    bram.io_pong_wr_data <= io_dma_data @[src/main/scala/WbController.scala 219:24]
    bram.io_pong_rd_en <= _bram_io_pong_rd_en_T_1 @[src/main/scala/WbController.scala 222:24]
    bram.io_pong_rd_addr <= controller.io_rd_addr @[src/main/scala/WbController.scala 224:24]
    readPingD1 <= mux(reset, UInt<1>("h1"), _GEN_0) @[src/main/scala/WbController.scala 226:{29,29}]
    io_rd_data_valid_REG <= mux(reset, UInt<1>("h0"), controller.io_rd_en) @[src/main/scala/WbController.scala 238:{31,31,31}]
