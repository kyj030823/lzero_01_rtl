FIRRTL version 1.2.0
circuit WbCircularHarness :
  module WbObserved : @[src/test/scala/WbCircularRegression_Test.scala 9:7]
    input clock : Clock @[src/test/scala/WbCircularRegression_Test.scala 9:7]
    input reset : UInt<1> @[src/test/scala/WbCircularRegression_Test.scala 9:7]
    input io_ctrl_soft_reset : UInt<1> @[src/main/scala/WbController.scala 58:14]
    input io_ctrl_enable : UInt<1> @[src/main/scala/WbController.scala 58:14]
    input io_ctrl_shoot : UInt<1> @[src/main/scala/WbController.scala 58:14]
    input io_ctrl_rlast : UInt<1> @[src/main/scala/WbController.scala 58:14]
    input io_ctrl_dma_data_valid : UInt<1> @[src/main/scala/WbController.scala 58:14]
    input io_ctrl_dma_data_last : UInt<1> @[src/main/scala/WbController.scala 58:14]
    output io_ctrl_last_data_out : UInt<1> @[src/main/scala/WbController.scala 58:14]
    output io_ctrl_ready : UInt<1> @[src/main/scala/WbController.scala 58:14]
    output io_ctrl_hungry : UInt<1> @[src/main/scala/WbController.scala 58:14]
    output io_ctrl_impending : UInt<1> @[src/main/scala/WbController.scala 58:14]
    output io_ctrl_full : UInt<1> @[src/main/scala/WbController.scala 58:14]
    input io_is_lut_load : UInt<1> @[src/main/scala/WbController.scala 58:14]
    output io_rd_addr : UInt<10> @[src/main/scala/WbController.scala 58:14]
    output io_rd_en : UInt<1> @[src/main/scala/WbController.scala 58:14]
    input io_rd_data : UInt<128> @[src/main/scala/WbController.scala 58:14]
    output io_rd_data_to_cu : UInt<128> @[src/main/scala/WbController.scala 58:14]
    output io_rd_data_to_lut : UInt<128> @[src/main/scala/WbController.scala 58:14]
    output io_wr_en : UInt<1> @[src/main/scala/WbController.scala 58:14]
    output io_wr_addr : UInt<8> @[src/main/scala/WbController.scala 58:14]
    output debug_used : UInt<14> @[src/test/scala/WbCircularRegression_Test.scala 10:17]
    output debug_soon : UInt<1> @[src/test/scala/WbCircularRegression_Test.scala 10:17]
    output debug_full : UInt<1> @[src/test/scala/WbCircularRegression_Test.scala 10:17]
    output debug_state : UInt<3> @[src/test/scala/WbCircularRegression_Test.scala 10:17]
    output debug_count : UInt<4> @[src/test/scala/WbCircularRegression_Test.scala 10:17]

    reg state : UInt<3>, clock with :
      reset => (UInt<1>("h0"), state) @[src/main/scala/WbController.scala 74:22]
    node isIdle = eq(state, UInt<3>("h0")) @[src/main/scala/WbController.scala 75:22]
    node isReady = eq(state, UInt<3>("h2")) @[src/main/scala/WbController.scala 76:23]
    node isWorking = eq(state, UInt<3>("h3")) @[src/main/scala/WbController.scala 77:25]
    reg writePtr : UInt<8>, clock with :
      reset => (UInt<1>("h0"), writePtr) @[src/main/scala/WbController.scala 80:25]
    reg readPtr : UInt<10>, clock with :
      reset => (UInt<1>("h0"), readPtr) @[src/main/scala/WbController.scala 81:24]
    reg isempty : UInt<1>, clock with :
      reset => (UInt<1>("h0"), isempty) @[src/main/scala/WbController.scala 82:24]
    reg blockLastqueue_0 : UInt<8>, clock with :
      reset => (UInt<1>("h0"), blockLastqueue_0) @[src/main/scala/WbController.scala 85:31]
    reg blockLastqueue_1 : UInt<8>, clock with :
      reset => (UInt<1>("h0"), blockLastqueue_1) @[src/main/scala/WbController.scala 85:31]
    reg blockLastqueue_2 : UInt<8>, clock with :
      reset => (UInt<1>("h0"), blockLastqueue_2) @[src/main/scala/WbController.scala 85:31]
    reg blockLastqueue_3 : UInt<8>, clock with :
      reset => (UInt<1>("h0"), blockLastqueue_3) @[src/main/scala/WbController.scala 85:31]
    reg blockLastqueue_4 : UInt<8>, clock with :
      reset => (UInt<1>("h0"), blockLastqueue_4) @[src/main/scala/WbController.scala 85:31]
    reg blockLastqueue_5 : UInt<8>, clock with :
      reset => (UInt<1>("h0"), blockLastqueue_5) @[src/main/scala/WbController.scala 85:31]
    reg blockLastqueue_6 : UInt<8>, clock with :
      reset => (UInt<1>("h0"), blockLastqueue_6) @[src/main/scala/WbController.scala 85:31]
    reg blockLastqueue_7 : UInt<8>, clock with :
      reset => (UInt<1>("h0"), blockLastqueue_7) @[src/main/scala/WbController.scala 85:31]
    reg blFront : UInt<3>, clock with :
      reset => (UInt<1>("h0"), blFront) @[src/main/scala/WbController.scala 86:24]
    reg blNum : UInt<3>, clock with :
      reset => (UInt<1>("h0"), blNum) @[src/main/scala/WbController.scala 87:22]
    node hasBlockData = gt(blNum, UInt<1>("h1")) @[src/main/scala/WbController.scala 88:28]
    reg gotDmaLast : UInt<1>, clock with :
      reset => (UInt<1>("h0"), gotDmaLast) @[src/main/scala/WbController.scala 91:27]
    reg dataToLut : UInt<1>, clock with :
      reset => (UInt<1>("h0"), dataToLut) @[src/main/scala/WbController.scala 92:26]
    node writeBytePtr = shl(writePtr, 6) @[src/main/scala/WbController.scala 96:31]
    node readBytePtr = shl(readPtr, 4) @[src/main/scala/WbController.scala 97:31]
    node _emptyBytes_T = sub(readBytePtr, writeBytePtr) @[src/main/scala/WbController.scala 98:33]
    node _emptyBytes_T_1 = tail(_emptyBytes_T, 1) @[src/main/scala/WbController.scala 98:33]
    node emptyBytes = bits(_emptyBytes_T_1, 13, 0) @[src/main/scala/WbController.scala 98:49]
    node _usedBytes_T = sub(writeBytePtr, readBytePtr) @[src/main/scala/WbController.scala 99:33]
    node _usedBytes_T_1 = tail(_usedBytes_T, 1) @[src/main/scala/WbController.scala 99:33]
    node usedBytes = bits(_usedBytes_T_1, 13, 0) @[src/main/scala/WbController.scala 99:48]
    node _soonempty_T = neq(usedBytes, UInt<1>("h0")) @[src/main/scala/WbController.scala 100:31]
    node _soonempty_T_1 = leq(usedBytes, UInt<8>("h80")) @[src/main/scala/WbController.scala 100:54]
    node soonempty = and(_soonempty_T, _soonempty_T_1) @[src/main/scala/WbController.scala 100:40]
    node _queueFull_T = lt(emptyBytes, UInt<13>("h1000")) @[src/main/scala/WbController.scala 101:30]
    node _queueFull_T_1 = eq(isempty, UInt<1>("h0")) @[src/main/scala/WbController.scala 101:52]
    node queueFull = and(_queueFull_T, _queueFull_T_1) @[src/main/scala/WbController.scala 101:49]
    node _writeActive_T = eq(isIdle, UInt<1>("h0")) @[src/main/scala/WbController.scala 104:47]
    node writeActive = and(io_ctrl_dma_data_valid, _writeActive_T) @[src/main/scala/WbController.scala 104:44]
    node _writeLast_T = or(io_ctrl_rlast, io_ctrl_dma_data_last) @[src/main/scala/WbController.scala 105:34]
    node writeLast = and(_writeLast_T, io_ctrl_dma_data_valid) @[src/main/scala/WbController.scala 105:60]
    node _readLast_T = mux(UInt<1>("h1"), UInt<2>("h3"), UInt<2>("h0")) @[src/main/scala/WbController.scala 106:62]
    node _GEN_0 = validif(eq(UInt<1>("h0"), blFront), blockLastqueue_0) @[src/main/scala/WbController.scala 106:{33,33}]
    node _GEN_1 = mux(eq(UInt<1>("h1"), blFront), blockLastqueue_1, _GEN_0) @[src/main/scala/WbController.scala 106:{33,33}]
    node _GEN_2 = mux(eq(UInt<2>("h2"), blFront), blockLastqueue_2, _GEN_1) @[src/main/scala/WbController.scala 106:{33,33}]
    node _GEN_3 = mux(eq(UInt<2>("h3"), blFront), blockLastqueue_3, _GEN_2) @[src/main/scala/WbController.scala 106:{33,33}]
    node _GEN_4 = mux(eq(UInt<3>("h4"), blFront), blockLastqueue_4, _GEN_3) @[src/main/scala/WbController.scala 106:{33,33}]
    node _GEN_5 = mux(eq(UInt<3>("h5"), blFront), blockLastqueue_5, _GEN_4) @[src/main/scala/WbController.scala 106:{33,33}]
    node _GEN_6 = mux(eq(UInt<3>("h6"), blFront), blockLastqueue_6, _GEN_5) @[src/main/scala/WbController.scala 106:{33,33}]
    node _GEN_7 = mux(eq(UInt<3>("h7"), blFront), blockLastqueue_7, _GEN_6) @[src/main/scala/WbController.scala 106:{33,33}]
    node _blockLastqueue_blFront = _GEN_7 @[src/main/scala/WbController.scala 106:33]
    node _readLast_T_1 = cat(_blockLastqueue_blFront, _readLast_T) @[src/main/scala/WbController.scala 106:33]
    node _readLast_T_2 = eq(readPtr, _readLast_T_1) @[src/main/scala/WbController.scala 106:26]
    node _readLast_T_3 = gt(blNum, UInt<1>("h0")) @[src/main/scala/WbController.scala 106:136]
    node readLast = and(_readLast_T_2, _readLast_T_3) @[src/main/scala/WbController.scala 106:127]
    node blpop = and(isWorking, readLast) @[src/main/scala/WbController.scala 107:25]
    node blpush = and(writeActive, writeLast) @[src/main/scala/WbController.scala 108:28]
    node _readLastD1_T = and(isWorking, readLast) @[src/main/scala/WbController.scala 111:38]
    reg readLastD1 : UInt<1>, clock with :
      reset => (UInt<1>("h0"), readLastD1) @[src/main/scala/WbController.scala 111:27]
    node _T = eq(UInt<3>("h0"), state) @[src/main/scala/WbController.scala 114:17]
    node _T_1 = eq(io_ctrl_soft_reset, UInt<1>("h0")) @[src/main/scala/WbController.scala 116:30]
    node _T_2 = and(io_ctrl_enable, _T_1) @[src/main/scala/WbController.scala 116:27]
    node _GEN_8 = mux(_T_2, UInt<3>("h1"), state) @[src/main/scala/WbController.scala 116:51 117:15 74:22]
    node _T_3 = eq(UInt<3>("h1"), state) @[src/main/scala/WbController.scala 114:17]
    node _GEN_9 = mux(writeLast, UInt<3>("h2"), state) @[src/main/scala/WbController.scala 122:23 123:15 74:22]
    node _T_4 = eq(UInt<3>("h2"), state) @[src/main/scala/WbController.scala 114:17]
    node _GEN_10 = mux(io_ctrl_shoot, UInt<3>("h3"), state) @[src/main/scala/WbController.scala 128:27 129:15 74:22]
    node _T_5 = eq(UInt<3>("h3"), state) @[src/main/scala/WbController.scala 114:17]
    node _T_6 = or(hasBlockData, blpush) @[src/main/scala/WbController.scala 135:27]
    node _GEN_11 = mux(gotDmaLast, UInt<3>("h0"), UInt<3>("h4")) @[src/main/scala/WbController.scala 138:29 139:19 141:19]
    node _GEN_12 = mux(_T_6, UInt<3>("h3"), _GEN_11) @[src/main/scala/WbController.scala 135:38 136:17]
    node _GEN_13 = mux(readLast, _GEN_12, state) @[src/main/scala/WbController.scala 134:22 74:22]
    node _T_7 = eq(UInt<3>("h4"), state) @[src/main/scala/WbController.scala 114:17]
    node _GEN_14 = mux(writeLast, UInt<3>("h3"), state) @[src/main/scala/WbController.scala 148:23 149:15 74:22]
    node _GEN_15 = mux(_T_7, _GEN_14, state) @[src/main/scala/WbController.scala 114:17 74:22]
    node _GEN_16 = mux(_T_5, _GEN_13, _GEN_15) @[src/main/scala/WbController.scala 114:17]
    node _GEN_17 = mux(_T_4, _GEN_10, _GEN_16) @[src/main/scala/WbController.scala 114:17]
    node _GEN_18 = mux(_T_3, _GEN_9, _GEN_17) @[src/main/scala/WbController.scala 114:17]
    node _GEN_19 = mux(_T, _GEN_8, _GEN_18) @[src/main/scala/WbController.scala 114:17]
    node _writePtr_T = add(writePtr, UInt<1>("h1")) @[src/main/scala/WbController.scala 156:26]
    node _writePtr_T_1 = tail(_writePtr_T, 1) @[src/main/scala/WbController.scala 156:26]
    node _T_8 = add(blFront, blNum) @[src/main/scala/WbController.scala 158:30]
    node _T_9 = tail(_T_8, 1) @[src/main/scala/WbController.scala 158:30]
    node _blockLastqueue_T_9 = writePtr @[src/main/scala/WbController.scala 158:{39,39}]
    node _GEN_20 = mux(eq(UInt<1>("h0"), _T_9), _blockLastqueue_T_9, blockLastqueue_0) @[src/main/scala/WbController.scala 158:{39,39} 85:31]
    node _GEN_21 = mux(eq(UInt<1>("h1"), _T_9), _blockLastqueue_T_9, blockLastqueue_1) @[src/main/scala/WbController.scala 158:{39,39} 85:31]
    node _GEN_22 = mux(eq(UInt<2>("h2"), _T_9), _blockLastqueue_T_9, blockLastqueue_2) @[src/main/scala/WbController.scala 158:{39,39} 85:31]
    node _GEN_23 = mux(eq(UInt<2>("h3"), _T_9), _blockLastqueue_T_9, blockLastqueue_3) @[src/main/scala/WbController.scala 158:{39,39} 85:31]
    node _GEN_24 = mux(eq(UInt<3>("h4"), _T_9), _blockLastqueue_T_9, blockLastqueue_4) @[src/main/scala/WbController.scala 158:{39,39} 85:31]
    node _GEN_25 = mux(eq(UInt<3>("h5"), _T_9), _blockLastqueue_T_9, blockLastqueue_5) @[src/main/scala/WbController.scala 158:{39,39} 85:31]
    node _GEN_26 = mux(eq(UInt<3>("h6"), _T_9), _blockLastqueue_T_9, blockLastqueue_6) @[src/main/scala/WbController.scala 158:{39,39} 85:31]
    node _GEN_27 = mux(eq(UInt<3>("h7"), _T_9), _blockLastqueue_T_9, blockLastqueue_7) @[src/main/scala/WbController.scala 158:{39,39} 85:31]
    node _GEN_28 = mux(writeLast, _GEN_20, blockLastqueue_0) @[src/main/scala/WbController.scala 157:21 85:31]
    node _GEN_29 = mux(writeLast, _GEN_21, blockLastqueue_1) @[src/main/scala/WbController.scala 157:21 85:31]
    node _GEN_30 = mux(writeLast, _GEN_22, blockLastqueue_2) @[src/main/scala/WbController.scala 157:21 85:31]
    node _GEN_31 = mux(writeLast, _GEN_23, blockLastqueue_3) @[src/main/scala/WbController.scala 157:21 85:31]
    node _GEN_32 = mux(writeLast, _GEN_24, blockLastqueue_4) @[src/main/scala/WbController.scala 157:21 85:31]
    node _GEN_33 = mux(writeLast, _GEN_25, blockLastqueue_5) @[src/main/scala/WbController.scala 157:21 85:31]
    node _GEN_34 = mux(writeLast, _GEN_26, blockLastqueue_6) @[src/main/scala/WbController.scala 157:21 85:31]
    node _GEN_35 = mux(writeLast, _GEN_27, blockLastqueue_7) @[src/main/scala/WbController.scala 157:21 85:31]
    node _GEN_36 = mux(io_ctrl_dma_data_last, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/WbController.scala 160:33 161:18 163:18]
    node _GEN_37 = mux(writeActive, _writePtr_T_1, writePtr) @[src/main/scala/WbController.scala 155:21 156:14 80:25]
    node _GEN_38 = mux(writeActive, _GEN_28, blockLastqueue_0) @[src/main/scala/WbController.scala 155:21 85:31]
    node _GEN_39 = mux(writeActive, _GEN_29, blockLastqueue_1) @[src/main/scala/WbController.scala 155:21 85:31]
    node _GEN_40 = mux(writeActive, _GEN_30, blockLastqueue_2) @[src/main/scala/WbController.scala 155:21 85:31]
    node _GEN_41 = mux(writeActive, _GEN_31, blockLastqueue_3) @[src/main/scala/WbController.scala 155:21 85:31]
    node _GEN_42 = mux(writeActive, _GEN_32, blockLastqueue_4) @[src/main/scala/WbController.scala 155:21 85:31]
    node _GEN_43 = mux(writeActive, _GEN_33, blockLastqueue_5) @[src/main/scala/WbController.scala 155:21 85:31]
    node _GEN_44 = mux(writeActive, _GEN_34, blockLastqueue_6) @[src/main/scala/WbController.scala 155:21 85:31]
    node _GEN_45 = mux(writeActive, _GEN_35, blockLastqueue_7) @[src/main/scala/WbController.scala 155:21 85:31]
    node _GEN_46 = mux(writeActive, _GEN_36, gotDmaLast) @[src/main/scala/WbController.scala 155:21 91:27]
    node _GEN_47 = mux(writeActive, UInt<1>("h0"), isempty) @[src/main/scala/WbController.scala 155:21 165:13 82:24]
    node _readPtr_T = add(readPtr, UInt<1>("h1")) @[src/main/scala/WbController.scala 170:24]
    node _readPtr_T_1 = tail(_readPtr_T, 1) @[src/main/scala/WbController.scala 170:24]
    node _blFront_T = add(blFront, UInt<1>("h1")) @[src/main/scala/WbController.scala 173:26]
    node _blFront_T_1 = tail(_blFront_T, 1) @[src/main/scala/WbController.scala 173:26]
    node _GEN_48 = mux(readLast, _blFront_T_1, blFront) @[src/main/scala/WbController.scala 172:20 173:15 86:24]
    node _T_10 = eq(usedBytes, UInt<5>("h10")) @[src/main/scala/WbController.scala 175:21]
    node _T_11 = eq(writeActive, UInt<1>("h0")) @[src/main/scala/WbController.scala 175:46]
    node _T_12 = and(_T_10, _T_11) @[src/main/scala/WbController.scala 175:43]
    node _GEN_49 = mux(_T_12, UInt<1>("h1"), _GEN_47) @[src/main/scala/WbController.scala 175:60 176:15]
    node _GEN_50 = mux(isWorking, _readPtr_T_1, readPtr) @[src/main/scala/WbController.scala 169:19 170:13 81:24]
    node _GEN_51 = mux(isWorking, _GEN_48, blFront) @[src/main/scala/WbController.scala 169:19 86:24]
    node _GEN_52 = mux(isWorking, _GEN_49, _GEN_47) @[src/main/scala/WbController.scala 169:19]
    node _T_13 = eq(blpop, UInt<1>("h0")) @[src/main/scala/WbController.scala 181:18]
    node _T_14 = and(blpush, _T_13) @[src/main/scala/WbController.scala 181:15]
    node _blNum_T = add(blNum, UInt<1>("h1")) @[src/main/scala/WbController.scala 182:20]
    node _blNum_T_1 = tail(_blNum_T, 1) @[src/main/scala/WbController.scala 182:20]
    node _T_15 = eq(blpush, UInt<1>("h0")) @[src/main/scala/WbController.scala 183:23]
    node _T_16 = and(blpop, _T_15) @[src/main/scala/WbController.scala 183:20]
    node _blNum_T_2 = sub(blNum, UInt<1>("h1")) @[src/main/scala/WbController.scala 184:20]
    node _blNum_T_3 = tail(_blNum_T_2, 1) @[src/main/scala/WbController.scala 184:20]
    node _GEN_53 = mux(_T_16, _blNum_T_3, blNum) @[src/main/scala/WbController.scala 183:32 184:11 87:22]
    node _GEN_54 = mux(_T_14, _blNum_T_1, _GEN_53) @[src/main/scala/WbController.scala 181:26 182:11]
    node _T_17 = eq(io_ctrl_enable, UInt<1>("h0")) @[src/main/scala/WbController.scala 188:30]
    node _T_18 = or(io_ctrl_soft_reset, _T_17) @[src/main/scala/WbController.scala 188:27]
    node _GEN_55 = mux(_T_18, UInt<3>("h0"), _GEN_19) @[src/main/scala/WbController.scala 188:47 189:11]
    node _T_19 = eq(state, UInt<3>("h0")) @[src/main/scala/WbController.scala 192:14]
    node _T_20 = or(_T_19, io_ctrl_soft_reset) @[src/main/scala/WbController.scala 192:34]
    node _T_21 = eq(io_ctrl_enable, UInt<1>("h0")) @[src/main/scala/WbController.scala 192:59]
    node _T_22 = or(_T_20, _T_21) @[src/main/scala/WbController.scala 192:56]
    node _GEN_56 = mux(_T_22, UInt<1>("h0"), _GEN_37) @[src/main/scala/WbController.scala 192:76 193:14]
    node _GEN_57 = mux(_T_22, UInt<1>("h0"), _GEN_50) @[src/main/scala/WbController.scala 192:76 194:13]
    node _GEN_58 = mux(_T_22, UInt<1>("h0"), _GEN_51) @[src/main/scala/WbController.scala 192:76 195:13]
    node _GEN_59 = mux(_T_22, UInt<1>("h0"), _GEN_54) @[src/main/scala/WbController.scala 192:76 196:11]
    node _GEN_60 = mux(_T_22, UInt<1>("h0"), _GEN_46) @[src/main/scala/WbController.scala 192:76 197:16]
    node _GEN_61 = mux(_T_22, UInt<1>("h1"), _GEN_52) @[src/main/scala/WbController.scala 192:76 198:13]
    node _GEN_62 = mux(dataToLut, UInt<1>("h0"), io_rd_data) @[src/main/scala/WbController.scala 210:19 211:22 214:22]
    node _GEN_63 = mux(dataToLut, io_rd_data, UInt<1>("h0")) @[src/main/scala/WbController.scala 210:19 212:23 215:23]
    node _io_ctrl_ready_T = eq(io_ctrl_enable, UInt<1>("h0")) @[src/main/scala/WbController.scala 219:31]
    node _io_ctrl_ready_T_1 = or(isReady, _io_ctrl_ready_T) @[src/main/scala/WbController.scala 219:28]
    node _io_ctrl_hungry_T = eq(isIdle, UInt<1>("h0")) @[src/main/scala/WbController.scala 220:21]
    node _io_ctrl_hungry_T_1 = eq(hasBlockData, UInt<1>("h0")) @[src/main/scala/WbController.scala 220:32]
    node _io_ctrl_hungry_T_2 = and(_io_ctrl_hungry_T, _io_ctrl_hungry_T_1) @[src/main/scala/WbController.scala 220:29]
    node _io_ctrl_hungry_T_3 = eq(gotDmaLast, UInt<1>("h0")) @[src/main/scala/WbController.scala 220:49]
    node _io_ctrl_hungry_T_4 = and(_io_ctrl_hungry_T_2, _io_ctrl_hungry_T_3) @[src/main/scala/WbController.scala 220:46]
    node _io_ctrl_impending_T = and(isWorking, soonempty) @[src/main/scala/WbController.scala 221:34]
    node _io_ctrl_impending_T_1 = eq(gotDmaLast, UInt<1>("h0")) @[src/main/scala/WbController.scala 221:50]
    node _io_ctrl_impending_T_2 = and(_io_ctrl_impending_T, _io_ctrl_impending_T_1) @[src/main/scala/WbController.scala 221:47]
    node _io_ctrl_full_T = eq(isIdle, UInt<1>("h0")) @[src/main/scala/WbController.scala 222:19]
    node _io_ctrl_full_T_1 = eq(queueFull, UInt<1>("h0")) @[src/main/scala/WbController.scala 222:30]
    node _io_ctrl_full_T_2 = and(_io_ctrl_full_T, _io_ctrl_full_T_1) @[src/main/scala/WbController.scala 222:27]
    node _blockLastqueue_WIRE_0 = UInt<8>("h0") @[src/main/scala/WbController.scala 85:{39,39}]
    node _blockLastqueue_WIRE_1 = UInt<8>("h0") @[src/main/scala/WbController.scala 85:{39,39}]
    node _blockLastqueue_WIRE_2 = UInt<8>("h0") @[src/main/scala/WbController.scala 85:{39,39}]
    node _blockLastqueue_WIRE_3 = UInt<8>("h0") @[src/main/scala/WbController.scala 85:{39,39}]
    node _blockLastqueue_WIRE_4 = UInt<8>("h0") @[src/main/scala/WbController.scala 85:{39,39}]
    node _blockLastqueue_WIRE_5 = UInt<8>("h0") @[src/main/scala/WbController.scala 85:{39,39}]
    node _blockLastqueue_WIRE_6 = UInt<8>("h0") @[src/main/scala/WbController.scala 85:{39,39}]
    node _blockLastqueue_WIRE_7 = UInt<8>("h0") @[src/main/scala/WbController.scala 85:{39,39}]
    io_ctrl_last_data_out <= readLastD1 @[src/main/scala/WbController.scala 223:25]
    io_ctrl_ready <= _io_ctrl_ready_T_1 @[src/main/scala/WbController.scala 219:17]
    io_ctrl_hungry <= _io_ctrl_hungry_T_4 @[src/main/scala/WbController.scala 220:18]
    io_ctrl_impending <= _io_ctrl_impending_T_2 @[src/main/scala/WbController.scala 221:21]
    io_ctrl_full <= _io_ctrl_full_T_2 @[src/main/scala/WbController.scala 222:16]
    io_rd_addr <= readPtr @[src/main/scala/WbController.scala 206:14]
    io_rd_en <= isWorking @[src/main/scala/WbController.scala 205:12]
    io_rd_data_to_cu <= _GEN_62
    io_rd_data_to_lut <= _GEN_63
    io_wr_en <= writeActive @[src/main/scala/WbController.scala 202:12]
    io_wr_addr <= writePtr @[src/main/scala/WbController.scala 203:14]
    debug_used <= usedBytes @[src/test/scala/WbCircularRegression_Test.scala 17:14]
    debug_soon <= soonempty @[src/test/scala/WbCircularRegression_Test.scala 18:14]
    debug_full <= queueFull @[src/test/scala/WbCircularRegression_Test.scala 19:14]
    debug_state <= state @[src/test/scala/WbCircularRegression_Test.scala 20:15]
    debug_count <= pad(blNum, 4) @[src/test/scala/WbCircularRegression_Test.scala 21:15]
    state <= mux(reset, UInt<3>("h0"), _GEN_55) @[src/main/scala/WbController.scala 74:{22,22}]
    writePtr <= mux(reset, UInt<8>("h0"), _GEN_56) @[src/main/scala/WbController.scala 80:{25,25}]
    readPtr <= mux(reset, UInt<10>("h0"), _GEN_57) @[src/main/scala/WbController.scala 81:{24,24}]
    isempty <= mux(reset, UInt<1>("h1"), _GEN_61) @[src/main/scala/WbController.scala 82:{24,24}]
    blockLastqueue_0 <= mux(reset, _blockLastqueue_WIRE_0, _GEN_38) @[src/main/scala/WbController.scala 85:{31,31}]
    blockLastqueue_1 <= mux(reset, _blockLastqueue_WIRE_1, _GEN_39) @[src/main/scala/WbController.scala 85:{31,31}]
    blockLastqueue_2 <= mux(reset, _blockLastqueue_WIRE_2, _GEN_40) @[src/main/scala/WbController.scala 85:{31,31}]
    blockLastqueue_3 <= mux(reset, _blockLastqueue_WIRE_3, _GEN_41) @[src/main/scala/WbController.scala 85:{31,31}]
    blockLastqueue_4 <= mux(reset, _blockLastqueue_WIRE_4, _GEN_42) @[src/main/scala/WbController.scala 85:{31,31}]
    blockLastqueue_5 <= mux(reset, _blockLastqueue_WIRE_5, _GEN_43) @[src/main/scala/WbController.scala 85:{31,31}]
    blockLastqueue_6 <= mux(reset, _blockLastqueue_WIRE_6, _GEN_44) @[src/main/scala/WbController.scala 85:{31,31}]
    blockLastqueue_7 <= mux(reset, _blockLastqueue_WIRE_7, _GEN_45) @[src/main/scala/WbController.scala 85:{31,31}]
    blFront <= mux(reset, UInt<3>("h0"), _GEN_58) @[src/main/scala/WbController.scala 86:{24,24}]
    blNum <= mux(reset, UInt<3>("h0"), _GEN_59) @[src/main/scala/WbController.scala 87:{22,22}]
    gotDmaLast <= mux(reset, UInt<1>("h0"), _GEN_60) @[src/main/scala/WbController.scala 91:{27,27}]
    dataToLut <= mux(reset, UInt<1>("h0"), dataToLut) @[src/main/scala/WbController.scala 92:{26,26,26}]
    readLastD1 <= mux(reset, UInt<1>("h0"), _readLastD1_T) @[src/main/scala/WbController.scala 111:{27,27,27}]

  module AsymmetricSRAM : @[src/main/scala/WbController.scala 8:7]
    input clock : Clock @[src/main/scala/WbController.scala 8:7]
    input reset : UInt<1> @[src/main/scala/WbController.scala 8:7]
    input io_wr_en : UInt<1> @[src/main/scala/WbController.scala 19:14]
    input io_wr_addr : UInt<8> @[src/main/scala/WbController.scala 19:14]
    input io_wr_data : UInt<512> @[src/main/scala/WbController.scala 19:14]
    input io_rd_en : UInt<1> @[src/main/scala/WbController.scala 19:14]
    input io_rd_addr : UInt<10> @[src/main/scala/WbController.scala 19:14]
    output io_rd_data : UInt<128> @[src/main/scala/WbController.scala 19:14]

    mem subBanks_0 : @[src/main/scala/WbController.scala 29:45]
      data-type => UInt<128>
      depth => 256
      read-latency => 1
      write-latency => 1
      reader => rdDataVec_0_MPORT
      writer => MPORT
      read-under-write => undefined
    mem subBanks_1 : @[src/main/scala/WbController.scala 29:45]
      data-type => UInt<128>
      depth => 256
      read-latency => 1
      write-latency => 1
      reader => rdDataVec_1_MPORT
      writer => MPORT_1
      read-under-write => undefined
    mem subBanks_2 : @[src/main/scala/WbController.scala 29:45]
      data-type => UInt<128>
      depth => 256
      read-latency => 1
      write-latency => 1
      reader => rdDataVec_2_MPORT
      writer => MPORT_2
      read-under-write => undefined
    mem subBanks_3 : @[src/main/scala/WbController.scala 29:45]
      data-type => UInt<128>
      depth => 256
      read-latency => 1
      write-latency => 1
      reader => rdDataVec_3_MPORT
      writer => MPORT_3
      read-under-write => undefined
    node wordAddr = bits(io_rd_addr, 9, 2) @[src/main/scala/WbController.scala 32:28]
    node bankSel = bits(io_rd_addr, 1, 0) @[src/main/scala/WbController.scala 33:27]
    node sliceData = bits(io_wr_data, 127, 0) @[src/main/scala/WbController.scala 36:31]
    node _GEN_0 = validif(io_wr_en, io_wr_addr) @[src/main/scala/WbController.scala 37:20 38:24]
    node _GEN_1 = validif(io_wr_en, clock) @[src/main/scala/WbController.scala 37:20 38:24]
    node _GEN_2 = mux(io_wr_en, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/WbController.scala 37:20 38:24 29:45]
    node _GEN_3 = validif(io_wr_en, UInt<1>("h1")) @[src/main/scala/WbController.scala 37:20 38:24]
    node _GEN_4 = validif(io_wr_en, sliceData) @[src/main/scala/WbController.scala 37:20 38:24]
    node _rdDataVec_0_T = eq(bankSel, UInt<1>("h0")) @[src/main/scala/WbController.scala 40:68]
    node _rdDataVec_0_T_1 = and(io_rd_en, _rdDataVec_0_T) @[src/main/scala/WbController.scala 40:57]
    node _GEN_5 = validif(_rdDataVec_0_T_1, wordAddr) @[src/main/scala/WbController.scala 40:{37,37}]
    node _GEN_6 = mux(_rdDataVec_0_T_1, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/WbController.scala 40:{37,37} 29:45]
    node _rdDataVec_0_WIRE = _GEN_5 @[src/main/scala/WbController.scala 40:37]
    node _GEN_7 = validif(_rdDataVec_0_T_1, _rdDataVec_0_WIRE) @[src/main/scala/WbController.scala 40:{37,37}]
    node _GEN_8 = validif(_rdDataVec_0_T_1, clock) @[src/main/scala/WbController.scala 40:{37,37}]
    node sliceData_1 = bits(io_wr_data, 255, 128) @[src/main/scala/WbController.scala 36:31]
    node _GEN_9 = validif(io_wr_en, sliceData_1) @[src/main/scala/WbController.scala 37:20 38:24]
    node _rdDataVec_1_T = eq(bankSel, UInt<1>("h1")) @[src/main/scala/WbController.scala 40:68]
    node _rdDataVec_1_T_1 = and(io_rd_en, _rdDataVec_1_T) @[src/main/scala/WbController.scala 40:57]
    node _GEN_10 = validif(_rdDataVec_1_T_1, wordAddr) @[src/main/scala/WbController.scala 40:{37,37}]
    node _GEN_11 = mux(_rdDataVec_1_T_1, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/WbController.scala 40:{37,37} 29:45]
    node _rdDataVec_1_WIRE = _GEN_10 @[src/main/scala/WbController.scala 40:37]
    node _GEN_12 = validif(_rdDataVec_1_T_1, _rdDataVec_1_WIRE) @[src/main/scala/WbController.scala 40:{37,37}]
    node _GEN_13 = validif(_rdDataVec_1_T_1, clock) @[src/main/scala/WbController.scala 40:{37,37}]
    node sliceData_2 = bits(io_wr_data, 383, 256) @[src/main/scala/WbController.scala 36:31]
    node _GEN_14 = validif(io_wr_en, sliceData_2) @[src/main/scala/WbController.scala 37:20 38:24]
    node _rdDataVec_2_T = eq(bankSel, UInt<2>("h2")) @[src/main/scala/WbController.scala 40:68]
    node _rdDataVec_2_T_1 = and(io_rd_en, _rdDataVec_2_T) @[src/main/scala/WbController.scala 40:57]
    node _GEN_15 = validif(_rdDataVec_2_T_1, wordAddr) @[src/main/scala/WbController.scala 40:{37,37}]
    node _GEN_16 = mux(_rdDataVec_2_T_1, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/WbController.scala 40:{37,37} 29:45]
    node _rdDataVec_2_WIRE = _GEN_15 @[src/main/scala/WbController.scala 40:37]
    node _GEN_17 = validif(_rdDataVec_2_T_1, _rdDataVec_2_WIRE) @[src/main/scala/WbController.scala 40:{37,37}]
    node _GEN_18 = validif(_rdDataVec_2_T_1, clock) @[src/main/scala/WbController.scala 40:{37,37}]
    node sliceData_3 = bits(io_wr_data, 511, 384) @[src/main/scala/WbController.scala 36:31]
    node _GEN_19 = validif(io_wr_en, sliceData_3) @[src/main/scala/WbController.scala 37:20 38:24]
    node _rdDataVec_3_T = eq(bankSel, UInt<2>("h3")) @[src/main/scala/WbController.scala 40:68]
    node _rdDataVec_3_T_1 = and(io_rd_en, _rdDataVec_3_T) @[src/main/scala/WbController.scala 40:57]
    node _GEN_20 = validif(_rdDataVec_3_T_1, wordAddr) @[src/main/scala/WbController.scala 40:{37,37}]
    node _GEN_21 = mux(_rdDataVec_3_T_1, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/WbController.scala 40:{37,37} 29:45]
    node _rdDataVec_3_WIRE = _GEN_20 @[src/main/scala/WbController.scala 40:37]
    node _GEN_22 = validif(_rdDataVec_3_T_1, _rdDataVec_3_WIRE) @[src/main/scala/WbController.scala 40:{37,37}]
    node _GEN_23 = validif(_rdDataVec_3_T_1, clock) @[src/main/scala/WbController.scala 40:{37,37}]
    reg bankSelD1 : UInt<2>, clock with :
      reset => (UInt<1>("h0"), bankSelD1) @[src/main/scala/WbController.scala 43:28]
    node _GEN_24 = mux(io_rd_en, bankSel, bankSelD1) @[src/main/scala/WbController.scala 43:{28,28,28}]
    node _io_rd_data_T = or(bankSelD1, UInt<2>("h0"))
    node _io_rd_data_T_1 = bits(_io_rd_data_T, 1, 0)
    node rdDataVec_0 = subBanks_0.rdDataVec_0_MPORT.data @[src/main/scala/WbController.scala 30:23 40:18]
    node _GEN_25 = validif(eq(UInt<1>("h0"), _io_rd_data_T_1), rdDataVec_0) @[src/main/scala/WbController.scala 44:{14,14}]
    node rdDataVec_1 = subBanks_1.rdDataVec_1_MPORT.data @[src/main/scala/WbController.scala 30:23 40:18]
    node _GEN_26 = mux(eq(UInt<1>("h1"), _io_rd_data_T_1), rdDataVec_1, _GEN_25) @[src/main/scala/WbController.scala 44:{14,14}]
    node rdDataVec_2 = subBanks_2.rdDataVec_2_MPORT.data @[src/main/scala/WbController.scala 30:23 40:18]
    node _GEN_27 = mux(eq(UInt<2>("h2"), _io_rd_data_T_1), rdDataVec_2, _GEN_26) @[src/main/scala/WbController.scala 44:{14,14}]
    node rdDataVec_3 = subBanks_3.rdDataVec_3_MPORT.data @[src/main/scala/WbController.scala 30:23 40:18]
    node _GEN_28 = mux(eq(UInt<2>("h3"), _io_rd_data_T_1), rdDataVec_3, _GEN_27) @[src/main/scala/WbController.scala 44:{14,14}]
    node _rdDataVec_io_rd_data_T_1 = _GEN_28 @[src/main/scala/WbController.scala 44:14]
    io_rd_data <= _rdDataVec_io_rd_data_T_1 @[src/main/scala/WbController.scala 44:14]
    subBanks_0.rdDataVec_0_MPORT.addr <= _GEN_7
    subBanks_0.rdDataVec_0_MPORT.en <= _GEN_6
    subBanks_0.rdDataVec_0_MPORT.clk <= _GEN_8
    subBanks_0.MPORT.addr <= _GEN_0
    subBanks_0.MPORT.en <= _GEN_2
    subBanks_0.MPORT.clk <= _GEN_1
    subBanks_0.MPORT.data <= _GEN_4
    subBanks_0.MPORT.mask <= _GEN_3
    subBanks_1.rdDataVec_1_MPORT.addr <= _GEN_12
    subBanks_1.rdDataVec_1_MPORT.en <= _GEN_11
    subBanks_1.rdDataVec_1_MPORT.clk <= _GEN_13
    subBanks_1.MPORT_1.addr <= _GEN_0
    subBanks_1.MPORT_1.en <= _GEN_2
    subBanks_1.MPORT_1.clk <= _GEN_1
    subBanks_1.MPORT_1.data <= _GEN_9
    subBanks_1.MPORT_1.mask <= _GEN_3
    subBanks_2.rdDataVec_2_MPORT.addr <= _GEN_17
    subBanks_2.rdDataVec_2_MPORT.en <= _GEN_16
    subBanks_2.rdDataVec_2_MPORT.clk <= _GEN_18
    subBanks_2.MPORT_2.addr <= _GEN_0
    subBanks_2.MPORT_2.en <= _GEN_2
    subBanks_2.MPORT_2.clk <= _GEN_1
    subBanks_2.MPORT_2.data <= _GEN_14
    subBanks_2.MPORT_2.mask <= _GEN_3
    subBanks_3.rdDataVec_3_MPORT.addr <= _GEN_22
    subBanks_3.rdDataVec_3_MPORT.en <= _GEN_21
    subBanks_3.rdDataVec_3_MPORT.clk <= _GEN_23
    subBanks_3.MPORT_3.addr <= _GEN_0
    subBanks_3.MPORT_3.en <= _GEN_2
    subBanks_3.MPORT_3.clk <= _GEN_1
    subBanks_3.MPORT_3.data <= _GEN_19
    subBanks_3.MPORT_3.mask <= _GEN_3
    bankSelD1 <= mux(reset, UInt<1>("h0"), _GEN_24) @[src/main/scala/WbController.scala 43:{28,28}]

  module WbCircularHarness : @[src/test/scala/WbCircularRegression_Test.scala 24:7]
    input clock : Clock @[src/test/scala/WbCircularRegression_Test.scala 24:7]
    input reset : UInt<1> @[src/test/scala/WbCircularRegression_Test.scala 24:7]
    input io_ctrl_soft_reset : UInt<1> @[src/test/scala/WbCircularRegression_Test.scala 25:14]
    input io_ctrl_enable : UInt<1> @[src/test/scala/WbCircularRegression_Test.scala 25:14]
    input io_ctrl_shoot : UInt<1> @[src/test/scala/WbCircularRegression_Test.scala 25:14]
    input io_ctrl_rlast : UInt<1> @[src/test/scala/WbCircularRegression_Test.scala 25:14]
    input io_ctrl_dma_data_valid : UInt<1> @[src/test/scala/WbCircularRegression_Test.scala 25:14]
    input io_ctrl_dma_data_last : UInt<1> @[src/test/scala/WbCircularRegression_Test.scala 25:14]
    output io_ctrl_last_data_out : UInt<1> @[src/test/scala/WbCircularRegression_Test.scala 25:14]
    output io_ctrl_ready : UInt<1> @[src/test/scala/WbCircularRegression_Test.scala 25:14]
    output io_ctrl_hungry : UInt<1> @[src/test/scala/WbCircularRegression_Test.scala 25:14]
    output io_ctrl_impending : UInt<1> @[src/test/scala/WbCircularRegression_Test.scala 25:14]
    output io_ctrl_full : UInt<1> @[src/test/scala/WbCircularRegression_Test.scala 25:14]
    input io_data : UInt<512> @[src/test/scala/WbCircularRegression_Test.scala 25:14]
    output io_out : UInt<128> @[src/test/scala/WbCircularRegression_Test.scala 25:14]
    output io_rd : UInt<1> @[src/test/scala/WbCircularRegression_Test.scala 25:14]
    output io_wr : UInt<1> @[src/test/scala/WbCircularRegression_Test.scala 25:14]
    output io_addr : UInt<10> @[src/test/scala/WbCircularRegression_Test.scala 25:14]
    output io_used : UInt<14> @[src/test/scala/WbCircularRegression_Test.scala 25:14]
    output io_soon : UInt<1> @[src/test/scala/WbCircularRegression_Test.scala 25:14]
    output io_full : UInt<1> @[src/test/scala/WbCircularRegression_Test.scala 25:14]
    output io_state : UInt<3> @[src/test/scala/WbCircularRegression_Test.scala 25:14]
    output io_count : UInt<4> @[src/test/scala/WbCircularRegression_Test.scala 25:14]

    inst c of WbObserved @[src/test/scala/WbCircularRegression_Test.scala 38:17]
    inst m of AsymmetricSRAM @[src/test/scala/WbCircularRegression_Test.scala 39:17]
    io_ctrl_last_data_out <= c.io_ctrl_last_data_out @[src/test/scala/WbCircularRegression_Test.scala 40:13]
    io_ctrl_ready <= c.io_ctrl_ready @[src/test/scala/WbCircularRegression_Test.scala 40:13]
    io_ctrl_hungry <= c.io_ctrl_hungry @[src/test/scala/WbCircularRegression_Test.scala 40:13]
    io_ctrl_impending <= c.io_ctrl_impending @[src/test/scala/WbCircularRegression_Test.scala 40:13]
    io_ctrl_full <= c.io_ctrl_full @[src/test/scala/WbCircularRegression_Test.scala 40:13]
    io_out <= c.io_rd_data_to_cu @[src/test/scala/WbCircularRegression_Test.scala 48:10]
    io_rd <= c.io_rd_en @[src/test/scala/WbCircularRegression_Test.scala 49:9]
    io_wr <= c.io_wr_en @[src/test/scala/WbCircularRegression_Test.scala 50:9]
    io_addr <= c.io_rd_addr @[src/test/scala/WbCircularRegression_Test.scala 51:11]
    io_used <= c.debug_used @[src/test/scala/WbCircularRegression_Test.scala 52:11]
    io_soon <= c.debug_soon @[src/test/scala/WbCircularRegression_Test.scala 53:11]
    io_full <= c.debug_full @[src/test/scala/WbCircularRegression_Test.scala 54:11]
    io_state <= c.debug_state @[src/test/scala/WbCircularRegression_Test.scala 55:12]
    io_count <= c.debug_count @[src/test/scala/WbCircularRegression_Test.scala 56:12]
    c.clock <= clock
    c.reset <= reset
    c.io_ctrl_soft_reset <= io_ctrl_soft_reset @[src/test/scala/WbCircularRegression_Test.scala 40:13]
    c.io_ctrl_enable <= io_ctrl_enable @[src/test/scala/WbCircularRegression_Test.scala 40:13]
    c.io_ctrl_shoot <= io_ctrl_shoot @[src/test/scala/WbCircularRegression_Test.scala 40:13]
    c.io_ctrl_rlast <= io_ctrl_rlast @[src/test/scala/WbCircularRegression_Test.scala 40:13]
    c.io_ctrl_dma_data_valid <= io_ctrl_dma_data_valid @[src/test/scala/WbCircularRegression_Test.scala 40:13]
    c.io_ctrl_dma_data_last <= io_ctrl_dma_data_last @[src/test/scala/WbCircularRegression_Test.scala 40:13]
    c.io_is_lut_load <= UInt<1>("h0") @[src/test/scala/WbCircularRegression_Test.scala 41:20]
    c.io_rd_data <= m.io_rd_data @[src/test/scala/WbCircularRegression_Test.scala 47:16]
    m.clock <= clock
    m.reset <= reset
    m.io_wr_en <= c.io_wr_en @[src/test/scala/WbCircularRegression_Test.scala 42:14]
    m.io_wr_addr <= c.io_wr_addr @[src/test/scala/WbCircularRegression_Test.scala 43:16]
    m.io_wr_data <= io_data @[src/test/scala/WbCircularRegression_Test.scala 44:16]
    m.io_rd_en <= c.io_rd_en @[src/test/scala/WbCircularRegression_Test.scala 45:14]
    m.io_rd_addr <= c.io_rd_addr @[src/test/scala/WbCircularRegression_Test.scala 46:16]
