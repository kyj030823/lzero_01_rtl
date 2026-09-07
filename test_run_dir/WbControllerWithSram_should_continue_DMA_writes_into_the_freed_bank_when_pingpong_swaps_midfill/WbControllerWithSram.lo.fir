FIRRTL version 1.2.0
circuit WbControllerWithSram :
  module UbWbController : @[src/main/scala/OCM.scala 133:7]
    input clock : Clock @[src/main/scala/OCM.scala 133:7]
    input reset : UInt<1> @[src/main/scala/OCM.scala 133:7]
    input io_ctrl_soft_reset : UInt<1> @[src/main/scala/OCM.scala 134:14]
    input io_ctrl_enable : UInt<1> @[src/main/scala/OCM.scala 134:14]
    input io_ctrl_shoot : UInt<1> @[src/main/scala/OCM.scala 134:14]
    input io_ctrl_dma_data_valid : UInt<1> @[src/main/scala/OCM.scala 134:14]
    input io_ctrl_dma_data_last : UInt<1> @[src/main/scala/OCM.scala 134:14]
    input io_ctrl_dma_write_ready : UInt<1> @[src/main/scala/OCM.scala 134:14]
    output io_ctrl_ready : UInt<1> @[src/main/scala/OCM.scala 134:14]
    output io_ctrl_hungry : UInt<1> @[src/main/scala/OCM.scala 134:14]
    output io_ctrl_impending : UInt<1> @[src/main/scala/OCM.scala 134:14]
    output io_ctrl_working : UInt<1> @[src/main/scala/OCM.scala 134:14]
    input io_lut_prog_mode : UInt<1> @[src/main/scala/OCM.scala 134:14]
    output io_rd_addr : UInt<8> @[src/main/scala/OCM.scala 134:14]
    output io_rd_en : UInt<1> @[src/main/scala/OCM.scala 134:14]
    output io_active_bank : UInt<1> @[src/main/scala/OCM.scala 134:14]
    output io_write_bank : UInt<1> @[src/main/scala/OCM.scala 134:14]
    output io_write_buffer_has_space : UInt<1> @[src/main/scala/OCM.scala 134:14]
    input io_rd_data : UInt<128> @[src/main/scala/OCM.scala 134:14]
    output io_rd_data_to_cu : UInt<128> @[src/main/scala/OCM.scala 134:14]
    output io_rd_data_to_lut : UInt<128> @[src/main/scala/OCM.scala 134:14]
    output io_wr_en : UInt<1> @[src/main/scala/OCM.scala 134:14]
    output io_wr_addr : UInt<6> @[src/main/scala/OCM.scala 134:14]

    reg state : UInt<3>, clock with :
      reset => (UInt<1>("h0"), state) @[src/main/scala/OCM.scala 154:22]
    reg activeBank : UInt<1>, clock with :
      reset => (UInt<1>("h0"), activeBank) @[src/main/scala/OCM.scala 155:27]
    reg writeBank : UInt<1>, clock with :
      reset => (UInt<1>("h0"), writeBank) @[src/main/scala/OCM.scala 156:26]
    reg readPtr : UInt<8>, clock with :
      reset => (UInt<1>("h0"), readPtr) @[src/main/scala/OCM.scala 157:24]
    reg writePtr : UInt<6>, clock with :
      reset => (UInt<1>("h0"), writePtr) @[src/main/scala/OCM.scala 158:25]
    reg compactCnt : UInt<4>, clock with :
      reset => (UInt<1>("h0"), compactCnt) @[src/main/scala/OCM.scala 159:27]
    reg writeBufferFull : UInt<1>, clock with :
      reset => (UInt<1>("h0"), writeBufferFull) @[src/main/scala/OCM.scala 160:32]
    node isWorking = eq(state, UInt<3>("h3")) @[src/main/scala/OCM.scala 162:25]
    node _readLast_T = and(isWorking, UInt<1>("h1")) @[src/main/scala/OCM.scala 164:28]
    node _readLast_T_1 = eq(readPtr, UInt<8>("hff")) @[src/main/scala/OCM.scala 164:54]
    node readLast = and(_readLast_T, _readLast_T_1) @[src/main/scala/OCM.scala 164:43]
    node swapFreesReadBank = and(readLast, writeBufferFull) @[src/main/scala/OCM.scala 166:36]
    node _canAcceptCurrentWriteBank_T = neq(state, UInt<3>("h0")) @[src/main/scala/OCM.scala 167:41]
    node _canAcceptCurrentWriteBank_T_1 = eq(writeBufferFull, UInt<1>("h0")) @[src/main/scala/OCM.scala 167:64]
    node _canAcceptCurrentWriteBank_T_2 = and(_canAcceptCurrentWriteBank_T, _canAcceptCurrentWriteBank_T_1) @[src/main/scala/OCM.scala 167:61]
    node canAcceptCurrentWriteBank = and(_canAcceptCurrentWriteBank_T_2, io_ctrl_dma_write_ready) @[src/main/scala/OCM.scala 167:81]
    node acceptCurrentWrite = and(canAcceptCurrentWriteBank, io_ctrl_dma_data_valid) @[src/main/scala/OCM.scala 168:54]
    node _acceptFreedBankWrite_T = and(swapFreesReadBank, io_ctrl_dma_write_ready) @[src/main/scala/OCM.scala 169:48]
    node acceptFreedBankWrite = and(_acceptFreedBankWrite_T, io_ctrl_dma_data_valid) @[src/main/scala/OCM.scala 169:75]
    node acceptWrite = or(acceptCurrentWrite, acceptFreedBankWrite) @[src/main/scala/OCM.scala 170:40]
    node _currentWriteLast_T = eq(writePtr, UInt<6>("h3f")) @[src/main/scala/OCM.scala 172:58]
    node _currentWriteLast_T_1 = or(_currentWriteLast_T, io_ctrl_dma_data_last) @[src/main/scala/OCM.scala 172:87]
    node currentWriteLast = and(acceptCurrentWrite, _currentWriteLast_T_1) @[src/main/scala/OCM.scala 172:45]
    node freedBankWriteLast = and(acceptFreedBankWrite, io_ctrl_dma_data_last) @[src/main/scala/OCM.scala 173:49]
    node pendingWriteBuffer = or(writeBufferFull, currentWriteLast) @[src/main/scala/OCM.scala 174:44]
    node _writePtr_T = add(writePtr, UInt<1>("h1")) @[src/main/scala/OCM.scala 181:28]
    node _writePtr_T_1 = tail(_writePtr_T, 1) @[src/main/scala/OCM.scala 181:28]
    node _GEN_0 = mux(currentWriteLast, UInt<1>("h0"), _writePtr_T_1) @[src/main/scala/OCM.scala 177:28 178:16 181:16]
    node _GEN_1 = mux(currentWriteLast, UInt<1>("h1"), writeBufferFull) @[src/main/scala/OCM.scala 177:28 179:23 160:32]
    node _GEN_2 = mux(acceptCurrentWrite, _GEN_0, writePtr) @[src/main/scala/OCM.scala 158:25 176:28]
    node _GEN_3 = mux(acceptCurrentWrite, _GEN_1, writeBufferFull) @[src/main/scala/OCM.scala 176:28 160:32]
    node _T = eq(UInt<3>("h0"), state) @[src/main/scala/OCM.scala 185:17]
    node _T_1 = eq(io_ctrl_soft_reset, UInt<1>("h0")) @[src/main/scala/OCM.scala 187:30]
    node _T_2 = and(io_ctrl_enable, _T_1) @[src/main/scala/OCM.scala 187:27]
    node _GEN_4 = mux(_T_2, UInt<3>("h1"), state) @[src/main/scala/OCM.scala 187:51 188:15 154:22]
    node _T_3 = eq(UInt<3>("h1"), state) @[src/main/scala/OCM.scala 185:17]
    node _GEN_5 = mux(pendingWriteBuffer, UInt<3>("h2"), state) @[src/main/scala/OCM.scala 193:32 194:15 154:22]
    node _GEN_6 = mux(pendingWriteBuffer, writeBank, activeBank) @[src/main/scala/OCM.scala 193:32 195:20 155:27]
    node _GEN_7 = mux(pendingWriteBuffer, activeBank, writeBank) @[src/main/scala/OCM.scala 193:32 196:19 156:26]
    node _GEN_8 = mux(pendingWriteBuffer, UInt<1>("h0"), _GEN_2) @[src/main/scala/OCM.scala 193:32 197:18]
    node _GEN_9 = mux(pendingWriteBuffer, UInt<1>("h0"), _GEN_3) @[src/main/scala/OCM.scala 193:32 198:25]
    node _T_4 = eq(UInt<3>("h2"), state) @[src/main/scala/OCM.scala 185:17]
    node _GEN_10 = mux(io_ctrl_shoot, UInt<3>("h3"), state) @[src/main/scala/OCM.scala 203:27 204:15 154:22]
    node _T_5 = eq(UInt<3>("h3"), state) @[src/main/scala/OCM.scala 185:17]
    node _readPtr_T = add(readPtr, UInt<1>("h1")) @[src/main/scala/OCM.scala 212:46]
    node _readPtr_T_1 = tail(_readPtr_T, 1) @[src/main/scala/OCM.scala 212:46]
    node _GEN_11 = mux(UInt<1>("h1"), _readPtr_T_1, readPtr) @[src/main/scala/OCM.scala 157:24 212:{25,35}]
    node _writePtr_T_2 = eq(freedBankWriteLast, UInt<1>("h0")) @[src/main/scala/OCM.scala 219:51]
    node _writePtr_T_3 = and(acceptFreedBankWrite, _writePtr_T_2) @[src/main/scala/OCM.scala 219:48]
    node _writePtr_T_4 = mux(_writePtr_T_3, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/OCM.scala 219:26]
    node _GEN_12 = mux(pendingWriteBuffer, UInt<1>("h0"), _GEN_11) @[src/main/scala/OCM.scala 215:34 218:19]
    node _GEN_13 = mux(pendingWriteBuffer, _writePtr_T_4, _GEN_2) @[src/main/scala/OCM.scala 215:34 219:20]
    node _GEN_14 = mux(pendingWriteBuffer, freedBankWriteLast, _GEN_3) @[src/main/scala/OCM.scala 215:34 220:27]
    node _GEN_15 = mux(pendingWriteBuffer, state, UInt<3>("h4")) @[src/main/scala/OCM.scala 154:22 215:34 222:17]
    node _GEN_16 = mux(readLast, _GEN_6, activeBank) @[src/main/scala/OCM.scala 214:22 155:27]
    node _GEN_17 = mux(readLast, _GEN_7, writeBank) @[src/main/scala/OCM.scala 214:22 156:26]
    node _GEN_18 = mux(readLast, _GEN_12, _GEN_11) @[src/main/scala/OCM.scala 214:22]
    node _GEN_19 = mux(readLast, _GEN_13, _GEN_2) @[src/main/scala/OCM.scala 214:22]
    node _GEN_20 = mux(readLast, _GEN_14, _GEN_3) @[src/main/scala/OCM.scala 214:22]
    node _GEN_21 = mux(readLast, _GEN_15, state) @[src/main/scala/OCM.scala 154:22 214:22]
    node _T_6 = eq(UInt<3>("h4"), state) @[src/main/scala/OCM.scala 185:17]
    node _GEN_22 = mux(pendingWriteBuffer, UInt<3>("h3"), state) @[src/main/scala/OCM.scala 228:32 229:15 154:22]
    node _GEN_23 = mux(pendingWriteBuffer, UInt<1>("h0"), readPtr) @[src/main/scala/OCM.scala 228:32 232:17 157:24]
    node _GEN_24 = mux(_T_6, _GEN_22, state) @[src/main/scala/OCM.scala 185:17 154:22]
    node _GEN_25 = mux(_T_6, _GEN_6, activeBank) @[src/main/scala/OCM.scala 185:17 155:27]
    node _GEN_26 = mux(_T_6, _GEN_7, writeBank) @[src/main/scala/OCM.scala 185:17 156:26]
    node _GEN_27 = mux(_T_6, _GEN_23, readPtr) @[src/main/scala/OCM.scala 185:17 157:24]
    node _GEN_28 = mux(_T_6, _GEN_8, _GEN_2) @[src/main/scala/OCM.scala 185:17]
    node _GEN_29 = mux(_T_6, _GEN_9, _GEN_3) @[src/main/scala/OCM.scala 185:17]
    node _GEN_30 = mux(_T_5, _GEN_18, _GEN_27) @[src/main/scala/OCM.scala 185:17]
    node _GEN_31 = mux(_T_5, _GEN_16, _GEN_25) @[src/main/scala/OCM.scala 185:17]
    node _GEN_32 = mux(_T_5, _GEN_17, _GEN_26) @[src/main/scala/OCM.scala 185:17]
    node _GEN_33 = mux(_T_5, _GEN_19, _GEN_28) @[src/main/scala/OCM.scala 185:17]
    node _GEN_34 = mux(_T_5, _GEN_20, _GEN_29) @[src/main/scala/OCM.scala 185:17]
    node _GEN_35 = mux(_T_5, _GEN_21, _GEN_24) @[src/main/scala/OCM.scala 185:17]
    node _GEN_36 = mux(_T_4, _GEN_10, _GEN_35) @[src/main/scala/OCM.scala 185:17]
    node _GEN_37 = mux(_T_4, readPtr, _GEN_30) @[src/main/scala/OCM.scala 185:17 157:24]
    node _GEN_38 = mux(_T_4, activeBank, _GEN_31) @[src/main/scala/OCM.scala 185:17 155:27]
    node _GEN_39 = mux(_T_4, writeBank, _GEN_32) @[src/main/scala/OCM.scala 185:17 156:26]
    node _GEN_40 = mux(_T_4, _GEN_2, _GEN_33) @[src/main/scala/OCM.scala 185:17]
    node _GEN_41 = mux(_T_4, _GEN_3, _GEN_34) @[src/main/scala/OCM.scala 185:17]
    node _GEN_42 = mux(_T_3, _GEN_5, _GEN_36) @[src/main/scala/OCM.scala 185:17]
    node _GEN_43 = mux(_T_3, _GEN_6, _GEN_38) @[src/main/scala/OCM.scala 185:17]
    node _GEN_44 = mux(_T_3, _GEN_7, _GEN_39) @[src/main/scala/OCM.scala 185:17]
    node _GEN_45 = mux(_T_3, _GEN_8, _GEN_40) @[src/main/scala/OCM.scala 185:17]
    node _GEN_46 = mux(_T_3, _GEN_9, _GEN_41) @[src/main/scala/OCM.scala 185:17]
    node _GEN_47 = mux(_T_3, readPtr, _GEN_37) @[src/main/scala/OCM.scala 185:17 157:24]
    node _GEN_48 = mux(_T, _GEN_4, _GEN_42) @[src/main/scala/OCM.scala 185:17]
    node _GEN_49 = mux(_T, activeBank, _GEN_43) @[src/main/scala/OCM.scala 185:17 155:27]
    node _GEN_50 = mux(_T, writeBank, _GEN_44) @[src/main/scala/OCM.scala 185:17 156:26]
    node _GEN_51 = mux(_T, _GEN_2, _GEN_45) @[src/main/scala/OCM.scala 185:17]
    node _GEN_52 = mux(_T, _GEN_3, _GEN_46) @[src/main/scala/OCM.scala 185:17]
    node _GEN_53 = mux(_T, readPtr, _GEN_47) @[src/main/scala/OCM.scala 185:17 157:24]
    node _T_7 = eq(io_ctrl_enable, UInt<1>("h0")) @[src/main/scala/OCM.scala 239:30]
    node _T_8 = or(io_ctrl_soft_reset, _T_7) @[src/main/scala/OCM.scala 239:27]
    node _GEN_54 = mux(_T_8, UInt<3>("h0"), _GEN_48) @[src/main/scala/OCM.scala 239:47 240:11]
    node _GEN_55 = mux(_T_8, UInt<1>("h0"), _GEN_49) @[src/main/scala/OCM.scala 239:47 241:16]
    node _GEN_56 = mux(_T_8, UInt<1>("h1"), _GEN_50) @[src/main/scala/OCM.scala 239:47 242:15]
    node _GEN_57 = mux(_T_8, UInt<1>("h0"), _GEN_53) @[src/main/scala/OCM.scala 239:47 243:13]
    node _GEN_58 = mux(_T_8, UInt<1>("h0"), _GEN_51) @[src/main/scala/OCM.scala 239:47 244:14]
    node _GEN_59 = mux(_T_8, UInt<1>("h0"), compactCnt) @[src/main/scala/OCM.scala 239:47 245:16 159:27]
    node _GEN_60 = mux(_T_8, UInt<1>("h0"), _GEN_52) @[src/main/scala/OCM.scala 239:47 246:21]
    node _activeBankCnt_T = sub(UInt<8>("hff"), readPtr) @[src/main/scala/OCM.scala 249:47]
    node activeBankCnt = tail(_activeBankCnt_T, 1) @[src/main/scala/OCM.scala 249:47]
    node writePortBank = mux(swapFreesReadBank, activeBank, writeBank) @[src/main/scala/OCM.scala 250:26]
    node writePortAddr = mux(acceptFreedBankWrite, UInt<1>("h0"), writePtr) @[src/main/scala/OCM.scala 251:26]
    node _writeHasSpace_T = neq(state, UInt<3>("h0")) @[src/main/scala/OCM.scala 252:29]
    node _writeHasSpace_T_1 = eq(writeBufferFull, UInt<1>("h0")) @[src/main/scala/OCM.scala 252:53]
    node _writeHasSpace_T_2 = or(_writeHasSpace_T_1, swapFreesReadBank) @[src/main/scala/OCM.scala 252:70]
    node writeHasSpace = and(_writeHasSpace_T, _writeHasSpace_T_2) @[src/main/scala/OCM.scala 252:49]
    node _io_ctrl_ready_T = eq(state, UInt<3>("h2")) @[src/main/scala/OCM.scala 255:26]
    node _io_ctrl_ready_T_1 = eq(io_ctrl_enable, UInt<1>("h0")) @[src/main/scala/OCM.scala 255:50]
    node _io_ctrl_ready_T_2 = or(_io_ctrl_ready_T, _io_ctrl_ready_T_1) @[src/main/scala/OCM.scala 255:47]
    node _io_ctrl_hungry_T = neq(state, UInt<3>("h0")) @[src/main/scala/OCM.scala 256:27]
    node _io_ctrl_hungry_T_1 = eq(pendingWriteBuffer, UInt<1>("h0")) @[src/main/scala/OCM.scala 256:50]
    node _io_ctrl_hungry_T_2 = and(_io_ctrl_hungry_T, _io_ctrl_hungry_T_1) @[src/main/scala/OCM.scala 256:47]
    node _io_ctrl_impending_T = leq(activeBankCnt, UInt<8>("h8")) @[src/main/scala/OCM.scala 257:51]
    node _io_ctrl_impending_T_1 = and(isWorking, _io_ctrl_impending_T) @[src/main/scala/OCM.scala 257:34]
    node _io_ctrl_impending_T_2 = eq(pendingWriteBuffer, UInt<1>("h0")) @[src/main/scala/OCM.scala 257:76]
    node _io_ctrl_impending_T_3 = and(_io_ctrl_impending_T_1, _io_ctrl_impending_T_2) @[src/main/scala/OCM.scala 257:73]
    node _GEN_61 = mux(io_lut_prog_mode, UInt<1>("h0"), io_rd_data) @[src/main/scala/OCM.scala 270:19 271:24 274:24]
    node _GEN_62 = mux(io_lut_prog_mode, io_rd_data, UInt<1>("h0")) @[src/main/scala/OCM.scala 270:19 272:29 275:29]
    io_ctrl_ready <= _io_ctrl_ready_T_2 @[src/main/scala/OCM.scala 255:17]
    io_ctrl_hungry <= _io_ctrl_hungry_T_2 @[src/main/scala/OCM.scala 256:18]
    io_ctrl_impending <= _io_ctrl_impending_T_3 @[src/main/scala/OCM.scala 257:21]
    io_ctrl_working <= isWorking @[src/main/scala/OCM.scala 254:19]
    io_rd_addr <= readPtr @[src/main/scala/OCM.scala 259:14]
    io_rd_en <= isWorking @[src/main/scala/OCM.scala 260:12]
    io_active_bank <= activeBank @[src/main/scala/OCM.scala 261:18]
    io_write_bank <= writePortBank @[src/main/scala/OCM.scala 262:17]
    io_write_buffer_has_space <= writeHasSpace @[src/main/scala/OCM.scala 263:29]
    io_rd_data_to_cu <= _GEN_61
    io_rd_data_to_lut <= _GEN_62
    io_wr_en <= acceptWrite @[src/main/scala/OCM.scala 279:12]
    io_wr_addr <= writePortAddr @[src/main/scala/OCM.scala 280:14]
    state <= mux(reset, UInt<3>("h0"), _GEN_54) @[src/main/scala/OCM.scala 154:{22,22}]
    activeBank <= mux(reset, UInt<1>("h0"), _GEN_55) @[src/main/scala/OCM.scala 155:{27,27}]
    writeBank <= mux(reset, UInt<1>("h1"), _GEN_56) @[src/main/scala/OCM.scala 156:{26,26}]
    readPtr <= mux(reset, UInt<8>("h0"), _GEN_57) @[src/main/scala/OCM.scala 157:{24,24}]
    writePtr <= mux(reset, UInt<6>("h0"), _GEN_58) @[src/main/scala/OCM.scala 158:{25,25}]
    compactCnt <= mux(reset, UInt<4>("h0"), _GEN_59) @[src/main/scala/OCM.scala 159:{27,27}]
    writeBufferFull <= mux(reset, UInt<1>("h0"), _GEN_60) @[src/main/scala/OCM.scala 160:{32,32}]

  module AsymmetricPingPongSRAM : @[src/main/scala/OCM.scala 35:7]
    input clock : Clock @[src/main/scala/OCM.scala 35:7]
    input reset : UInt<1> @[src/main/scala/OCM.scala 35:7]
    input io_ping_wr_en : UInt<1> @[src/main/scala/OCM.scala 46:14]
    input io_ping_wr_addr : UInt<6> @[src/main/scala/OCM.scala 46:14]
    input io_ping_wr_data : UInt<512> @[src/main/scala/OCM.scala 46:14]
    input io_ping_rd_en : UInt<1> @[src/main/scala/OCM.scala 46:14]
    input io_ping_rd_addr : UInt<8> @[src/main/scala/OCM.scala 46:14]
    output io_ping_rd_data : UInt<128> @[src/main/scala/OCM.scala 46:14]
    input io_pong_wr_en : UInt<1> @[src/main/scala/OCM.scala 46:14]
    input io_pong_wr_addr : UInt<6> @[src/main/scala/OCM.scala 46:14]
    input io_pong_wr_data : UInt<512> @[src/main/scala/OCM.scala 46:14]
    input io_pong_rd_en : UInt<1> @[src/main/scala/OCM.scala 46:14]
    input io_pong_rd_addr : UInt<8> @[src/main/scala/OCM.scala 46:14]
    output io_pong_rd_data : UInt<128> @[src/main/scala/OCM.scala 46:14]

    mem io_ping_rd_data_subBanks_0 : @[src/main/scala/OCM.scala 71:47]
      data-type => UInt<128>
      depth => 64
      read-latency => 1
      write-latency => 1
      reader => io_ping_rd_data_rdDataVec_0_MPORT
      writer => io_ping_rd_data_MPORT
      read-under-write => undefined
    mem io_ping_rd_data_subBanks_1 : @[src/main/scala/OCM.scala 71:47]
      data-type => UInt<128>
      depth => 64
      read-latency => 1
      write-latency => 1
      reader => io_ping_rd_data_rdDataVec_1_MPORT
      writer => io_ping_rd_data_MPORT_1
      read-under-write => undefined
    mem io_ping_rd_data_subBanks_2 : @[src/main/scala/OCM.scala 71:47]
      data-type => UInt<128>
      depth => 64
      read-latency => 1
      write-latency => 1
      reader => io_ping_rd_data_rdDataVec_2_MPORT
      writer => io_ping_rd_data_MPORT_2
      read-under-write => undefined
    mem io_ping_rd_data_subBanks_3 : @[src/main/scala/OCM.scala 71:47]
      data-type => UInt<128>
      depth => 64
      read-latency => 1
      write-latency => 1
      reader => io_ping_rd_data_rdDataVec_3_MPORT
      writer => io_ping_rd_data_MPORT_3
      read-under-write => undefined
    mem io_pong_rd_data_subBanks_0 : @[src/main/scala/OCM.scala 71:47]
      data-type => UInt<128>
      depth => 64
      read-latency => 1
      write-latency => 1
      reader => io_pong_rd_data_rdDataVec_0_MPORT
      writer => io_pong_rd_data_MPORT
      read-under-write => undefined
    mem io_pong_rd_data_subBanks_1 : @[src/main/scala/OCM.scala 71:47]
      data-type => UInt<128>
      depth => 64
      read-latency => 1
      write-latency => 1
      reader => io_pong_rd_data_rdDataVec_1_MPORT
      writer => io_pong_rd_data_MPORT_1
      read-under-write => undefined
    mem io_pong_rd_data_subBanks_2 : @[src/main/scala/OCM.scala 71:47]
      data-type => UInt<128>
      depth => 64
      read-latency => 1
      write-latency => 1
      reader => io_pong_rd_data_rdDataVec_2_MPORT
      writer => io_pong_rd_data_MPORT_2
      read-under-write => undefined
    mem io_pong_rd_data_subBanks_3 : @[src/main/scala/OCM.scala 71:47]
      data-type => UInt<128>
      depth => 64
      read-latency => 1
      write-latency => 1
      reader => io_pong_rd_data_rdDataVec_3_MPORT
      writer => io_pong_rd_data_MPORT_3
      read-under-write => undefined
    node io_ping_rd_data_wordAddr = bits(io_ping_rd_addr, 7, 2) @[src/main/scala/OCM.scala 74:27]
    node io_ping_rd_data_bankSel = bits(io_ping_rd_addr, 1, 0) @[src/main/scala/OCM.scala 75:26]
    node io_ping_rd_data_sliceData = bits(io_ping_wr_data, 127, 0) @[src/main/scala/OCM.scala 78:30]
    node _GEN_0 = validif(io_ping_wr_en, io_ping_wr_addr) @[src/main/scala/OCM.scala 79:19 80:26]
    node _GEN_1 = validif(io_ping_wr_en, clock) @[src/main/scala/OCM.scala 79:19 80:26]
    node _GEN_2 = mux(io_ping_wr_en, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/OCM.scala 79:19 80:26 71:47]
    node _GEN_3 = validif(io_ping_wr_en, UInt<1>("h1")) @[src/main/scala/OCM.scala 79:19 80:26]
    node _GEN_4 = validif(io_ping_wr_en, io_ping_rd_data_sliceData) @[src/main/scala/OCM.scala 79:19 80:26]
    node _io_ping_rd_data_rdDataVec_0_T = eq(io_ping_rd_data_bankSel, UInt<1>("h0")) @[src/main/scala/OCM.scala 82:67]
    node _io_ping_rd_data_rdDataVec_0_T_1 = and(io_ping_rd_en, _io_ping_rd_data_rdDataVec_0_T) @[src/main/scala/OCM.scala 82:56]
    node _GEN_5 = validif(_io_ping_rd_data_rdDataVec_0_T_1, io_ping_rd_data_wordAddr) @[src/main/scala/OCM.scala 82:{39,39}]
    node _GEN_6 = mux(_io_ping_rd_data_rdDataVec_0_T_1, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/OCM.scala 82:{39,39} 71:47]
    node _io_ping_rd_data_rdDataVec_0_WIRE = _GEN_5 @[src/main/scala/OCM.scala 82:39]
    node _GEN_7 = validif(_io_ping_rd_data_rdDataVec_0_T_1, _io_ping_rd_data_rdDataVec_0_WIRE) @[src/main/scala/OCM.scala 82:{39,39}]
    node _GEN_8 = validif(_io_ping_rd_data_rdDataVec_0_T_1, clock) @[src/main/scala/OCM.scala 82:{39,39}]
    node io_ping_rd_data_sliceData_1 = bits(io_ping_wr_data, 255, 128) @[src/main/scala/OCM.scala 78:30]
    node _GEN_9 = validif(io_ping_wr_en, io_ping_rd_data_sliceData_1) @[src/main/scala/OCM.scala 79:19 80:26]
    node _io_ping_rd_data_rdDataVec_1_T = eq(io_ping_rd_data_bankSel, UInt<1>("h1")) @[src/main/scala/OCM.scala 82:67]
    node _io_ping_rd_data_rdDataVec_1_T_1 = and(io_ping_rd_en, _io_ping_rd_data_rdDataVec_1_T) @[src/main/scala/OCM.scala 82:56]
    node _GEN_10 = validif(_io_ping_rd_data_rdDataVec_1_T_1, io_ping_rd_data_wordAddr) @[src/main/scala/OCM.scala 82:{39,39}]
    node _GEN_11 = mux(_io_ping_rd_data_rdDataVec_1_T_1, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/OCM.scala 82:{39,39} 71:47]
    node _io_ping_rd_data_rdDataVec_1_WIRE = _GEN_10 @[src/main/scala/OCM.scala 82:39]
    node _GEN_12 = validif(_io_ping_rd_data_rdDataVec_1_T_1, _io_ping_rd_data_rdDataVec_1_WIRE) @[src/main/scala/OCM.scala 82:{39,39}]
    node _GEN_13 = validif(_io_ping_rd_data_rdDataVec_1_T_1, clock) @[src/main/scala/OCM.scala 82:{39,39}]
    node io_ping_rd_data_sliceData_2 = bits(io_ping_wr_data, 383, 256) @[src/main/scala/OCM.scala 78:30]
    node _GEN_14 = validif(io_ping_wr_en, io_ping_rd_data_sliceData_2) @[src/main/scala/OCM.scala 79:19 80:26]
    node _io_ping_rd_data_rdDataVec_2_T = eq(io_ping_rd_data_bankSel, UInt<2>("h2")) @[src/main/scala/OCM.scala 82:67]
    node _io_ping_rd_data_rdDataVec_2_T_1 = and(io_ping_rd_en, _io_ping_rd_data_rdDataVec_2_T) @[src/main/scala/OCM.scala 82:56]
    node _GEN_15 = validif(_io_ping_rd_data_rdDataVec_2_T_1, io_ping_rd_data_wordAddr) @[src/main/scala/OCM.scala 82:{39,39}]
    node _GEN_16 = mux(_io_ping_rd_data_rdDataVec_2_T_1, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/OCM.scala 82:{39,39} 71:47]
    node _io_ping_rd_data_rdDataVec_2_WIRE = _GEN_15 @[src/main/scala/OCM.scala 82:39]
    node _GEN_17 = validif(_io_ping_rd_data_rdDataVec_2_T_1, _io_ping_rd_data_rdDataVec_2_WIRE) @[src/main/scala/OCM.scala 82:{39,39}]
    node _GEN_18 = validif(_io_ping_rd_data_rdDataVec_2_T_1, clock) @[src/main/scala/OCM.scala 82:{39,39}]
    node io_ping_rd_data_sliceData_3 = bits(io_ping_wr_data, 511, 384) @[src/main/scala/OCM.scala 78:30]
    node _GEN_19 = validif(io_ping_wr_en, io_ping_rd_data_sliceData_3) @[src/main/scala/OCM.scala 79:19 80:26]
    node _io_ping_rd_data_rdDataVec_3_T = eq(io_ping_rd_data_bankSel, UInt<2>("h3")) @[src/main/scala/OCM.scala 82:67]
    node _io_ping_rd_data_rdDataVec_3_T_1 = and(io_ping_rd_en, _io_ping_rd_data_rdDataVec_3_T) @[src/main/scala/OCM.scala 82:56]
    node _GEN_20 = validif(_io_ping_rd_data_rdDataVec_3_T_1, io_ping_rd_data_wordAddr) @[src/main/scala/OCM.scala 82:{39,39}]
    node _GEN_21 = mux(_io_ping_rd_data_rdDataVec_3_T_1, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/OCM.scala 82:{39,39} 71:47]
    node _io_ping_rd_data_rdDataVec_3_WIRE = _GEN_20 @[src/main/scala/OCM.scala 82:39]
    node _GEN_22 = validif(_io_ping_rd_data_rdDataVec_3_T_1, _io_ping_rd_data_rdDataVec_3_WIRE) @[src/main/scala/OCM.scala 82:{39,39}]
    node _GEN_23 = validif(_io_ping_rd_data_rdDataVec_3_T_1, clock) @[src/main/scala/OCM.scala 82:{39,39}]
    reg io_ping_rd_data_bankSelD1 : UInt<2>, clock with :
      reset => (UInt<1>("h0"), io_ping_rd_data_bankSelD1) @[src/main/scala/OCM.scala 85:30]
    node _GEN_24 = mux(io_ping_rd_en, io_ping_rd_data_bankSel, io_ping_rd_data_bankSelD1) @[src/main/scala/OCM.scala 85:{30,30,30}]
    node _io_ping_rd_data_T = or(io_ping_rd_data_bankSelD1, UInt<2>("h0"))
    node _io_ping_rd_data_T_1 = bits(_io_ping_rd_data_T, 1, 0)
    node io_ping_rd_data_rdDataVec_0 = io_ping_rd_data_subBanks_0.io_ping_rd_data_rdDataVec_0_MPORT.data @[src/main/scala/OCM.scala 72:25 82:20]
    node _GEN_25 = validif(eq(UInt<1>("h0"), _io_ping_rd_data_T_1), io_ping_rd_data_rdDataVec_0) @[src/main/scala/OCM.scala 89:{19,19}]
    node io_ping_rd_data_rdDataVec_1 = io_ping_rd_data_subBanks_1.io_ping_rd_data_rdDataVec_1_MPORT.data @[src/main/scala/OCM.scala 72:25 82:20]
    node _GEN_26 = mux(eq(UInt<1>("h1"), _io_ping_rd_data_T_1), io_ping_rd_data_rdDataVec_1, _GEN_25) @[src/main/scala/OCM.scala 89:{19,19}]
    node io_ping_rd_data_rdDataVec_2 = io_ping_rd_data_subBanks_2.io_ping_rd_data_rdDataVec_2_MPORT.data @[src/main/scala/OCM.scala 72:25 82:20]
    node _GEN_27 = mux(eq(UInt<2>("h2"), _io_ping_rd_data_T_1), io_ping_rd_data_rdDataVec_2, _GEN_26) @[src/main/scala/OCM.scala 89:{19,19}]
    node io_ping_rd_data_rdDataVec_3 = io_ping_rd_data_subBanks_3.io_ping_rd_data_rdDataVec_3_MPORT.data @[src/main/scala/OCM.scala 72:25 82:20]
    node _GEN_28 = mux(eq(UInt<2>("h3"), _io_ping_rd_data_T_1), io_ping_rd_data_rdDataVec_3, _GEN_27) @[src/main/scala/OCM.scala 89:{19,19}]
    node io_pong_rd_data_wordAddr = bits(io_pong_rd_addr, 7, 2) @[src/main/scala/OCM.scala 74:27]
    node io_pong_rd_data_bankSel = bits(io_pong_rd_addr, 1, 0) @[src/main/scala/OCM.scala 75:26]
    node io_pong_rd_data_sliceData = bits(io_pong_wr_data, 127, 0) @[src/main/scala/OCM.scala 78:30]
    node _GEN_29 = validif(io_pong_wr_en, io_pong_wr_addr) @[src/main/scala/OCM.scala 79:19 80:26]
    node _GEN_30 = validif(io_pong_wr_en, clock) @[src/main/scala/OCM.scala 79:19 80:26]
    node _GEN_31 = mux(io_pong_wr_en, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/OCM.scala 79:19 80:26 71:47]
    node _GEN_32 = validif(io_pong_wr_en, UInt<1>("h1")) @[src/main/scala/OCM.scala 79:19 80:26]
    node _GEN_33 = validif(io_pong_wr_en, io_pong_rd_data_sliceData) @[src/main/scala/OCM.scala 79:19 80:26]
    node _io_pong_rd_data_rdDataVec_0_T = eq(io_pong_rd_data_bankSel, UInt<1>("h0")) @[src/main/scala/OCM.scala 82:67]
    node _io_pong_rd_data_rdDataVec_0_T_1 = and(io_pong_rd_en, _io_pong_rd_data_rdDataVec_0_T) @[src/main/scala/OCM.scala 82:56]
    node _GEN_34 = validif(_io_pong_rd_data_rdDataVec_0_T_1, io_pong_rd_data_wordAddr) @[src/main/scala/OCM.scala 82:{39,39}]
    node _GEN_35 = mux(_io_pong_rd_data_rdDataVec_0_T_1, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/OCM.scala 82:{39,39} 71:47]
    node _io_pong_rd_data_rdDataVec_0_WIRE = _GEN_34 @[src/main/scala/OCM.scala 82:39]
    node _GEN_36 = validif(_io_pong_rd_data_rdDataVec_0_T_1, _io_pong_rd_data_rdDataVec_0_WIRE) @[src/main/scala/OCM.scala 82:{39,39}]
    node _GEN_37 = validif(_io_pong_rd_data_rdDataVec_0_T_1, clock) @[src/main/scala/OCM.scala 82:{39,39}]
    node io_pong_rd_data_sliceData_1 = bits(io_pong_wr_data, 255, 128) @[src/main/scala/OCM.scala 78:30]
    node _GEN_38 = validif(io_pong_wr_en, io_pong_rd_data_sliceData_1) @[src/main/scala/OCM.scala 79:19 80:26]
    node _io_pong_rd_data_rdDataVec_1_T = eq(io_pong_rd_data_bankSel, UInt<1>("h1")) @[src/main/scala/OCM.scala 82:67]
    node _io_pong_rd_data_rdDataVec_1_T_1 = and(io_pong_rd_en, _io_pong_rd_data_rdDataVec_1_T) @[src/main/scala/OCM.scala 82:56]
    node _GEN_39 = validif(_io_pong_rd_data_rdDataVec_1_T_1, io_pong_rd_data_wordAddr) @[src/main/scala/OCM.scala 82:{39,39}]
    node _GEN_40 = mux(_io_pong_rd_data_rdDataVec_1_T_1, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/OCM.scala 82:{39,39} 71:47]
    node _io_pong_rd_data_rdDataVec_1_WIRE = _GEN_39 @[src/main/scala/OCM.scala 82:39]
    node _GEN_41 = validif(_io_pong_rd_data_rdDataVec_1_T_1, _io_pong_rd_data_rdDataVec_1_WIRE) @[src/main/scala/OCM.scala 82:{39,39}]
    node _GEN_42 = validif(_io_pong_rd_data_rdDataVec_1_T_1, clock) @[src/main/scala/OCM.scala 82:{39,39}]
    node io_pong_rd_data_sliceData_2 = bits(io_pong_wr_data, 383, 256) @[src/main/scala/OCM.scala 78:30]
    node _GEN_43 = validif(io_pong_wr_en, io_pong_rd_data_sliceData_2) @[src/main/scala/OCM.scala 79:19 80:26]
    node _io_pong_rd_data_rdDataVec_2_T = eq(io_pong_rd_data_bankSel, UInt<2>("h2")) @[src/main/scala/OCM.scala 82:67]
    node _io_pong_rd_data_rdDataVec_2_T_1 = and(io_pong_rd_en, _io_pong_rd_data_rdDataVec_2_T) @[src/main/scala/OCM.scala 82:56]
    node _GEN_44 = validif(_io_pong_rd_data_rdDataVec_2_T_1, io_pong_rd_data_wordAddr) @[src/main/scala/OCM.scala 82:{39,39}]
    node _GEN_45 = mux(_io_pong_rd_data_rdDataVec_2_T_1, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/OCM.scala 82:{39,39} 71:47]
    node _io_pong_rd_data_rdDataVec_2_WIRE = _GEN_44 @[src/main/scala/OCM.scala 82:39]
    node _GEN_46 = validif(_io_pong_rd_data_rdDataVec_2_T_1, _io_pong_rd_data_rdDataVec_2_WIRE) @[src/main/scala/OCM.scala 82:{39,39}]
    node _GEN_47 = validif(_io_pong_rd_data_rdDataVec_2_T_1, clock) @[src/main/scala/OCM.scala 82:{39,39}]
    node io_pong_rd_data_sliceData_3 = bits(io_pong_wr_data, 511, 384) @[src/main/scala/OCM.scala 78:30]
    node _GEN_48 = validif(io_pong_wr_en, io_pong_rd_data_sliceData_3) @[src/main/scala/OCM.scala 79:19 80:26]
    node _io_pong_rd_data_rdDataVec_3_T = eq(io_pong_rd_data_bankSel, UInt<2>("h3")) @[src/main/scala/OCM.scala 82:67]
    node _io_pong_rd_data_rdDataVec_3_T_1 = and(io_pong_rd_en, _io_pong_rd_data_rdDataVec_3_T) @[src/main/scala/OCM.scala 82:56]
    node _GEN_49 = validif(_io_pong_rd_data_rdDataVec_3_T_1, io_pong_rd_data_wordAddr) @[src/main/scala/OCM.scala 82:{39,39}]
    node _GEN_50 = mux(_io_pong_rd_data_rdDataVec_3_T_1, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/OCM.scala 82:{39,39} 71:47]
    node _io_pong_rd_data_rdDataVec_3_WIRE = _GEN_49 @[src/main/scala/OCM.scala 82:39]
    node _GEN_51 = validif(_io_pong_rd_data_rdDataVec_3_T_1, _io_pong_rd_data_rdDataVec_3_WIRE) @[src/main/scala/OCM.scala 82:{39,39}]
    node _GEN_52 = validif(_io_pong_rd_data_rdDataVec_3_T_1, clock) @[src/main/scala/OCM.scala 82:{39,39}]
    reg io_pong_rd_data_bankSelD1 : UInt<2>, clock with :
      reset => (UInt<1>("h0"), io_pong_rd_data_bankSelD1) @[src/main/scala/OCM.scala 85:30]
    node _GEN_53 = mux(io_pong_rd_en, io_pong_rd_data_bankSel, io_pong_rd_data_bankSelD1) @[src/main/scala/OCM.scala 85:{30,30,30}]
    node _io_pong_rd_data_T = or(io_pong_rd_data_bankSelD1, UInt<2>("h0"))
    node _io_pong_rd_data_T_1 = bits(_io_pong_rd_data_T, 1, 0)
    node io_pong_rd_data_rdDataVec_0 = io_pong_rd_data_subBanks_0.io_pong_rd_data_rdDataVec_0_MPORT.data @[src/main/scala/OCM.scala 72:25 82:20]
    node _GEN_54 = validif(eq(UInt<1>("h0"), _io_pong_rd_data_T_1), io_pong_rd_data_rdDataVec_0) @[src/main/scala/OCM.scala 96:{19,19}]
    node io_pong_rd_data_rdDataVec_1 = io_pong_rd_data_subBanks_1.io_pong_rd_data_rdDataVec_1_MPORT.data @[src/main/scala/OCM.scala 72:25 82:20]
    node _GEN_55 = mux(eq(UInt<1>("h1"), _io_pong_rd_data_T_1), io_pong_rd_data_rdDataVec_1, _GEN_54) @[src/main/scala/OCM.scala 96:{19,19}]
    node io_pong_rd_data_rdDataVec_2 = io_pong_rd_data_subBanks_2.io_pong_rd_data_rdDataVec_2_MPORT.data @[src/main/scala/OCM.scala 72:25 82:20]
    node _GEN_56 = mux(eq(UInt<2>("h2"), _io_pong_rd_data_T_1), io_pong_rd_data_rdDataVec_2, _GEN_55) @[src/main/scala/OCM.scala 96:{19,19}]
    node io_pong_rd_data_rdDataVec_3 = io_pong_rd_data_subBanks_3.io_pong_rd_data_rdDataVec_3_MPORT.data @[src/main/scala/OCM.scala 72:25 82:20]
    node _GEN_57 = mux(eq(UInt<2>("h3"), _io_pong_rd_data_T_1), io_pong_rd_data_rdDataVec_3, _GEN_56) @[src/main/scala/OCM.scala 96:{19,19}]
    node _io_ping_rd_data_rdDataVec_io_ping_rd_data_T_1 = _GEN_28 @[src/main/scala/OCM.scala 89:19]
    node _io_pong_rd_data_rdDataVec_io_pong_rd_data_T_1 = _GEN_57 @[src/main/scala/OCM.scala 96:19]
    io_ping_rd_data <= _io_ping_rd_data_rdDataVec_io_ping_rd_data_T_1 @[src/main/scala/OCM.scala 89:19]
    io_pong_rd_data <= _io_pong_rd_data_rdDataVec_io_pong_rd_data_T_1 @[src/main/scala/OCM.scala 96:19]
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
    io_ping_rd_data_bankSelD1 <= mux(reset, UInt<1>("h0"), _GEN_24) @[src/main/scala/OCM.scala 85:{30,30}]
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
    io_pong_rd_data_bankSelD1 <= mux(reset, UInt<1>("h0"), _GEN_53) @[src/main/scala/OCM.scala 85:{30,30}]

  module WbControllerWithSram : @[src/main/scala/wb.scala 7:7]
    input clock : Clock @[src/main/scala/wb.scala 7:7]
    input reset : UInt<1> @[src/main/scala/wb.scala 7:7]
    input io_soft_reset : UInt<1> @[src/main/scala/wb.scala 8:14]
    input io_enable : UInt<1> @[src/main/scala/wb.scala 8:14]
    input io_shoot : UInt<1> @[src/main/scala/wb.scala 8:14]
    input io_lut_prog_mode : UInt<1> @[src/main/scala/wb.scala 8:14]
    input io_dma_data : UInt<512> @[src/main/scala/wb.scala 8:14]
    input io_dma_data_valid : UInt<1> @[src/main/scala/wb.scala 8:14]
    input io_dma_data_last : UInt<1> @[src/main/scala/wb.scala 8:14]
    input io_dma_write_ready : UInt<1> @[src/main/scala/wb.scala 8:14]
    output io_ready : UInt<1> @[src/main/scala/wb.scala 8:14]
    output io_hungry : UInt<1> @[src/main/scala/wb.scala 8:14]
    output io_impending : UInt<1> @[src/main/scala/wb.scala 8:14]
    output io_working : UInt<1> @[src/main/scala/wb.scala 8:14]
    output io_write_buffer_has_space : UInt<1> @[src/main/scala/wb.scala 8:14]
    output io_rd_data_to_cu : UInt<128> @[src/main/scala/wb.scala 8:14]
    output io_rd_data_to_lut : UInt<128> @[src/main/scala/wb.scala 8:14]
    output io_rd_data_valid : UInt<1> @[src/main/scala/wb.scala 8:14]

    inst controller of UbWbController @[src/main/scala/wb.scala 30:26]
    inst sram of AsymmetricPingPongSRAM @[src/main/scala/wb.scala 31:20]
    node readPing = eq(controller.io_active_bank, UInt<1>("h0")) @[src/main/scala/wb.scala 41:45]
    node writePing = eq(controller.io_write_bank, UInt<1>("h0")) @[src/main/scala/wb.scala 42:44]
    node _sram_io_ping_wr_en_T = and(controller.io_wr_en, writePing) @[src/main/scala/wb.scala 45:47]
    node _sram_io_pong_wr_en_T = eq(writePing, UInt<1>("h0")) @[src/main/scala/wb.scala 46:50]
    node _sram_io_pong_wr_en_T_1 = and(controller.io_wr_en, _sram_io_pong_wr_en_T) @[src/main/scala/wb.scala 46:47]
    node _sram_io_ping_rd_en_T = and(controller.io_rd_en, readPing) @[src/main/scala/wb.scala 53:47]
    node _sram_io_pong_rd_en_T = eq(readPing, UInt<1>("h0")) @[src/main/scala/wb.scala 54:50]
    node _sram_io_pong_rd_en_T_1 = and(controller.io_rd_en, _sram_io_pong_rd_en_T) @[src/main/scala/wb.scala 54:47]
    reg readPingD1 : UInt<1>, clock with :
      reset => (UInt<1>("h0"), readPingD1) @[src/main/scala/wb.scala 59:29]
    node _GEN_0 = mux(controller.io_rd_en, readPing, readPingD1) @[src/main/scala/wb.scala 59:{29,29,29}]
    node _controller_io_rd_data_T = mux(readPingD1, sram.io_ping_rd_data, sram.io_pong_rd_data) @[src/main/scala/wb.scala 60:31]
    reg io_rd_data_valid_REG : UInt<1>, clock with :
      reset => (UInt<1>("h0"), io_rd_data_valid_REG) @[src/main/scala/wb.scala 73:31]
    io_ready <= controller.io_ctrl_ready @[src/main/scala/wb.scala 66:21]
    io_hungry <= controller.io_ctrl_hungry @[src/main/scala/wb.scala 67:21]
    io_impending <= controller.io_ctrl_impending @[src/main/scala/wb.scala 68:21]
    io_working <= controller.io_ctrl_working @[src/main/scala/wb.scala 69:21]
    io_write_buffer_has_space <= controller.io_write_buffer_has_space @[src/main/scala/wb.scala 70:29]
    io_rd_data_to_cu <= controller.io_rd_data_to_cu @[src/main/scala/wb.scala 71:21]
    io_rd_data_to_lut <= controller.io_rd_data_to_lut @[src/main/scala/wb.scala 72:21]
    io_rd_data_valid <= io_rd_data_valid_REG @[src/main/scala/wb.scala 73:21]
    controller.clock <= clock
    controller.reset <= reset
    controller.io_ctrl_soft_reset <= io_soft_reset @[src/main/scala/wb.scala 33:38]
    controller.io_ctrl_enable <= io_enable @[src/main/scala/wb.scala 34:38]
    controller.io_ctrl_shoot <= io_shoot @[src/main/scala/wb.scala 35:38]
    controller.io_ctrl_dma_data_valid <= io_dma_data_valid @[src/main/scala/wb.scala 36:38]
    controller.io_ctrl_dma_data_last <= io_dma_data_last @[src/main/scala/wb.scala 37:38]
    controller.io_ctrl_dma_write_ready <= io_dma_write_ready @[src/main/scala/wb.scala 38:38]
    controller.io_lut_prog_mode <= io_lut_prog_mode @[src/main/scala/wb.scala 39:38]
    controller.io_rd_data <= _controller_io_rd_data_T @[src/main/scala/wb.scala 60:25]
    sram.clock <= clock
    sram.reset <= reset
    sram.io_ping_wr_en <= _sram_io_ping_wr_en_T @[src/main/scala/wb.scala 45:24]
    sram.io_ping_wr_addr <= controller.io_wr_addr @[src/main/scala/wb.scala 47:24]
    sram.io_ping_wr_data <= io_dma_data @[src/main/scala/wb.scala 49:24]
    sram.io_ping_rd_en <= _sram_io_ping_rd_en_T @[src/main/scala/wb.scala 53:24]
    sram.io_ping_rd_addr <= controller.io_rd_addr @[src/main/scala/wb.scala 55:24]
    sram.io_pong_wr_en <= _sram_io_pong_wr_en_T_1 @[src/main/scala/wb.scala 46:24]
    sram.io_pong_wr_addr <= controller.io_wr_addr @[src/main/scala/wb.scala 48:24]
    sram.io_pong_wr_data <= io_dma_data @[src/main/scala/wb.scala 50:24]
    sram.io_pong_rd_en <= _sram_io_pong_rd_en_T_1 @[src/main/scala/wb.scala 54:24]
    sram.io_pong_rd_addr <= controller.io_rd_addr @[src/main/scala/wb.scala 56:24]
    readPingD1 <= mux(reset, UInt<1>("h1"), _GEN_0) @[src/main/scala/wb.scala 59:{29,29}]
    io_rd_data_valid_REG <= mux(reset, UInt<1>("h0"), controller.io_rd_en) @[src/main/scala/wb.scala 73:{31,31,31}]
