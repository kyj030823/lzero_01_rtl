FIRRTL version 1.2.0
circuit WbControllerWithSram :
  module UbWbController : @[src/main/scala/OCM.scala 137:7]
    input clock : Clock @[src/main/scala/OCM.scala 137:7]
    input reset : UInt<1> @[src/main/scala/OCM.scala 137:7]
    input io_ctrl_soft_reset : UInt<1> @[src/main/scala/OCM.scala 138:14]
    input io_ctrl_enable : UInt<1> @[src/main/scala/OCM.scala 138:14]
    input io_ctrl_shoot : UInt<1> @[src/main/scala/OCM.scala 138:14]
    input io_ctrl_rlast : UInt<1> @[src/main/scala/OCM.scala 138:14]
    input io_ctrl_dma_data_valid : UInt<1> @[src/main/scala/OCM.scala 138:14]
    input io_ctrl_dma_data_last : UInt<1> @[src/main/scala/OCM.scala 138:14]
    input io_ctrl_dma_write_ready : UInt<1> @[src/main/scala/OCM.scala 138:14]
    output io_ctrl_dma_last_data_out : UInt<1> @[src/main/scala/OCM.scala 138:14]
    output io_ctrl_ready : UInt<1> @[src/main/scala/OCM.scala 138:14]
    output io_ctrl_hungry : UInt<1> @[src/main/scala/OCM.scala 138:14]
    output io_ctrl_impending : UInt<1> @[src/main/scala/OCM.scala 138:14]
    output io_ctrl_working : UInt<1> @[src/main/scala/OCM.scala 138:14]
    output io_ctrl_full : UInt<1> @[src/main/scala/OCM.scala 138:14]
    input io_lut_prog_mode : UInt<1> @[src/main/scala/OCM.scala 138:14]
    output io_rd_addr : UInt<9> @[src/main/scala/OCM.scala 138:14]
    output io_rd_en : UInt<1> @[src/main/scala/OCM.scala 138:14]
    output io_active_bank : UInt<1> @[src/main/scala/OCM.scala 138:14]
    input io_rd_data : UInt<128> @[src/main/scala/OCM.scala 138:14]
    output io_rd_data_to_cu : UInt<128> @[src/main/scala/OCM.scala 138:14]
    output io_rd_data_to_lut : UInt<128> @[src/main/scala/OCM.scala 138:14]
    output io_wr_en : UInt<1> @[src/main/scala/OCM.scala 138:14]
    output io_wr_addr : UInt<7> @[src/main/scala/OCM.scala 138:14]

    reg state : UInt<3>, clock with :
      reset => (UInt<1>("h0"), state) @[src/main/scala/OCM.scala 158:22]
    reg get_dma_last : UInt<1>, clock with :
      reset => (UInt<1>("h0"), get_dma_last) @[src/main/scala/OCM.scala 159:29]
    reg active_bank : UInt<1>, clock with :
      reset => (UInt<1>("h0"), active_bank) @[src/main/scala/OCM.scala 161:28]
    reg read_ptr : UInt<9>, clock with :
      reset => (UInt<1>("h0"), read_ptr) @[src/main/scala/OCM.scala 162:28]
    reg write_ptr : UInt<7>, clock with :
      reset => (UInt<1>("h0"), write_ptr) @[src/main/scala/OCM.scala 163:28]
    reg ping_last_write_ptr : UInt<7>, clock with :
      reset => (UInt<1>("h0"), ping_last_write_ptr) @[src/main/scala/OCM.scala 164:36]
    reg pong_last_write_ptr : UInt<7>, clock with :
      reset => (UInt<1>("h0"), pong_last_write_ptr) @[src/main/scala/OCM.scala 165:36]
    reg compact_cnt : UInt<4>, clock with :
      reset => (UInt<1>("h0"), compact_cnt) @[src/main/scala/OCM.scala 167:28]
    node _last_write_T = geq(write_ptr, UInt<7>("h3f")) @[src/main/scala/OCM.scala 169:33]
    node _last_write_T_1 = and(_last_write_T, io_ctrl_rlast) @[src/main/scala/OCM.scala 169:62]
    node _last_write_T_2 = or(_last_write_T_1, io_ctrl_dma_data_last) @[src/main/scala/OCM.scala 169:80]
    node last_write = and(_last_write_T_2, io_ctrl_dma_data_valid) @[src/main/scala/OCM.scala 169:106]
    reg pong_valid : UInt<1>, clock with :
      reset => (UInt<1>("h0"), pong_valid) @[src/main/scala/OCM.scala 170:28]
    node _GEN_0 = mux(last_write, UInt<1>("h1"), pong_valid) @[src/main/scala/OCM.scala 172:20 170:28 172:33]
    node _can_get_4KB_T = eq(pong_last_write_ptr, UInt<7>("h3f")) @[src/main/scala/OCM.scala 174:55]
    node can_get_4KB = and(pong_valid, _can_get_4KB_T) @[src/main/scala/OCM.scala 174:32]
    reg getting_4KB : UInt<1>, clock with :
      reset => (UInt<1>("h0"), getting_4KB) @[src/main/scala/OCM.scala 175:28]
    node _T = and(can_get_4KB, io_ctrl_dma_data_valid) @[src/main/scala/OCM.scala 176:20]
    node _GEN_1 = mux(_T, UInt<1>("h1"), getting_4KB) @[src/main/scala/OCM.scala 175:28 176:{47,61}]
    node _T_1 = and(getting_4KB, io_ctrl_rlast) @[src/main/scala/OCM.scala 177:20]
    node _GEN_2 = mux(_T_1, UInt<1>("h0"), _GEN_1) @[src/main/scala/OCM.scala 177:{38,52}]
    node is_working = eq(state, UInt<3>("h3")) @[src/main/scala/OCM.scala 180:27]
    node _read_ptr_T = add(read_ptr, UInt<1>("h1")) @[src/main/scala/OCM.scala 183:43]
    node _read_ptr_T_1 = tail(_read_ptr_T, 1) @[src/main/scala/OCM.scala 183:43]
    node _GEN_3 = mux(is_working, _read_ptr_T_1, read_ptr) @[src/main/scala/OCM.scala 183:20 162:28 183:31]
    node _T_2 = neq(state, UInt<3>("h0")) @[src/main/scala/OCM.scala 186:14]
    node _T_3 = and(_T_2, io_ctrl_dma_data_valid) @[src/main/scala/OCM.scala 186:34]
    node _write_ptr_T = add(write_ptr, UInt<1>("h1")) @[src/main/scala/OCM.scala 187:28]
    node _write_ptr_T_1 = tail(_write_ptr_T, 1) @[src/main/scala/OCM.scala 187:28]
    node _T_4 = and(io_ctrl_dma_data_valid, io_ctrl_dma_data_last) @[src/main/scala/OCM.scala 189:33]
    node _GEN_4 = mux(_T_4, UInt<1>("h1"), _GEN_0) @[src/main/scala/OCM.scala 189:59 191:18]
    node _GEN_5 = mux(_T_4, UInt<1>("h1"), get_dma_last) @[src/main/scala/OCM.scala 189:59 192:20 159:29]
    node _GEN_6 = mux(_T_3, _write_ptr_T_1, write_ptr) @[src/main/scala/OCM.scala 186:61 187:15 163:28]
    node _GEN_7 = mux(_T_3, write_ptr, pong_last_write_ptr) @[src/main/scala/OCM.scala 186:61 188:25 165:36]
    node _GEN_8 = mux(_T_3, _GEN_4, _GEN_0) @[src/main/scala/OCM.scala 186:61]
    node _GEN_9 = mux(_T_3, _GEN_5, get_dma_last) @[src/main/scala/OCM.scala 159:29 186:61]
    node _T_5 = eq(UInt<3>("h0"), state) @[src/main/scala/OCM.scala 197:17]
    node _T_6 = eq(io_ctrl_soft_reset, UInt<1>("h0")) @[src/main/scala/OCM.scala 199:30]
    node _T_7 = and(io_ctrl_enable, _T_6) @[src/main/scala/OCM.scala 199:27]
    node _GEN_10 = mux(_T_7, UInt<3>("h1"), state) @[src/main/scala/OCM.scala 158:22 199:{51,59}]
    node _T_8 = eq(UInt<3>("h1"), state) @[src/main/scala/OCM.scala 197:17]
    node _T_9 = or(pong_valid, last_write) @[src/main/scala/OCM.scala 202:23]
    node _active_bank_T = not(active_bank) @[src/main/scala/OCM.scala 204:24]
    node _ping_last_write_ptr_T = or(getting_4KB, last_write) @[src/main/scala/OCM.scala 205:48]
    node _ping_last_write_ptr_T_1 = add(pong_last_write_ptr, UInt<1>("h1")) @[src/main/scala/OCM.scala 205:83]
    node _ping_last_write_ptr_T_2 = tail(_ping_last_write_ptr_T_1, 1) @[src/main/scala/OCM.scala 205:83]
    node _ping_last_write_ptr_T_3 = mux(_ping_last_write_ptr_T, _ping_last_write_ptr_T_2, pong_last_write_ptr) @[src/main/scala/OCM.scala 205:35]
    node _GEN_11 = mux(_T_9, UInt<3>("h2"), state) @[src/main/scala/OCM.scala 202:38 203:15 158:22]
    node _GEN_12 = mux(_T_9, _active_bank_T, active_bank) @[src/main/scala/OCM.scala 202:38 204:21 161:28]
    node _GEN_13 = mux(_T_9, _ping_last_write_ptr_T_3, ping_last_write_ptr) @[src/main/scala/OCM.scala 202:38 205:29 164:36]
    node _GEN_14 = mux(_T_9, UInt<1>("h0"), _GEN_6) @[src/main/scala/OCM.scala 202:38 206:19]
    node _GEN_15 = mux(_T_9, UInt<1>("h0"), _GEN_8) @[src/main/scala/OCM.scala 202:38 207:20]
    node _T_10 = eq(UInt<3>("h2"), state) @[src/main/scala/OCM.scala 197:17]
    node _GEN_16 = mux(io_ctrl_shoot, UInt<3>("h3"), state) @[src/main/scala/OCM.scala 158:22 211:{27,35}]
    node _T_11 = eq(UInt<3>("h3"), state) @[src/main/scala/OCM.scala 197:17]
    node active_read_last = cat(ping_last_write_ptr, UInt<2>("h3")) @[src/main/scala/OCM.scala 214:33]
    node _T_12 = eq(read_ptr, active_read_last) @[src/main/scala/OCM.scala 215:21]
    node _T_13 = or(pong_valid, last_write) @[src/main/scala/OCM.scala 216:25]
    node _active_bank_T_1 = not(active_bank) @[src/main/scala/OCM.scala 217:26]
    node _ping_last_write_ptr_T_4 = or(getting_4KB, last_write) @[src/main/scala/OCM.scala 218:50]
    node _ping_last_write_ptr_T_5 = add(pong_last_write_ptr, UInt<1>("h1")) @[src/main/scala/OCM.scala 218:85]
    node _ping_last_write_ptr_T_6 = tail(_ping_last_write_ptr_T_5, 1) @[src/main/scala/OCM.scala 218:85]
    node _ping_last_write_ptr_T_7 = mux(_ping_last_write_ptr_T_4, _ping_last_write_ptr_T_6, pong_last_write_ptr) @[src/main/scala/OCM.scala 218:37]
    node _GEN_17 = mux(_T_13, _active_bank_T_1, active_bank) @[src/main/scala/OCM.scala 216:40 217:23 161:28]
    node _GEN_18 = mux(_T_13, _ping_last_write_ptr_T_7, ping_last_write_ptr) @[src/main/scala/OCM.scala 216:40 218:31 164:36]
    node _GEN_19 = mux(_T_13, UInt<1>("h0"), _GEN_3) @[src/main/scala/OCM.scala 216:40 219:20]
    node _GEN_20 = mux(_T_13, UInt<1>("h0"), _GEN_6) @[src/main/scala/OCM.scala 216:40 220:21]
    node _GEN_21 = mux(_T_13, UInt<1>("h0"), _GEN_8) @[src/main/scala/OCM.scala 216:40 221:22]
    node _GEN_22 = mux(_T_13, state, UInt<3>("h4")) @[src/main/scala/OCM.scala 158:22 216:40 223:17]
    node _GEN_23 = mux(_T_12, _GEN_17, active_bank) @[src/main/scala/OCM.scala 161:28 215:43]
    node _GEN_24 = mux(_T_12, _GEN_18, ping_last_write_ptr) @[src/main/scala/OCM.scala 164:36 215:43]
    node _GEN_25 = mux(_T_12, _GEN_19, _GEN_3) @[src/main/scala/OCM.scala 215:43]
    node _GEN_26 = mux(_T_12, _GEN_20, _GEN_6) @[src/main/scala/OCM.scala 215:43]
    node _GEN_27 = mux(_T_12, _GEN_21, _GEN_8) @[src/main/scala/OCM.scala 215:43]
    node _GEN_28 = mux(_T_12, _GEN_22, state) @[src/main/scala/OCM.scala 158:22 215:43]
    node _T_14 = eq(UInt<3>("h4"), state) @[src/main/scala/OCM.scala 197:17]
    node _T_15 = or(pong_valid, last_write) @[src/main/scala/OCM.scala 228:23]
    node _active_bank_T_2 = not(active_bank) @[src/main/scala/OCM.scala 230:24]
    node _GEN_29 = mux(_T_15, UInt<3>("h3"), state) @[src/main/scala/OCM.scala 228:38 229:15 158:22]
    node _GEN_30 = mux(_T_15, _active_bank_T_2, active_bank) @[src/main/scala/OCM.scala 228:38 230:21 161:28]
    node _GEN_31 = mux(_T_15, UInt<1>("h0"), _GEN_3) @[src/main/scala/OCM.scala 228:38 231:18]
    node _GEN_32 = mux(_T_15, UInt<1>("h0"), _GEN_6) @[src/main/scala/OCM.scala 228:38 232:19]
    node _GEN_33 = mux(_T_15, UInt<1>("h0"), _GEN_8) @[src/main/scala/OCM.scala 228:38 233:20]
    node _GEN_34 = mux(_T_14, _GEN_29, state) @[src/main/scala/OCM.scala 197:17 158:22]
    node _GEN_35 = mux(_T_14, _GEN_30, active_bank) @[src/main/scala/OCM.scala 197:17 161:28]
    node _GEN_36 = mux(_T_14, _GEN_31, _GEN_3) @[src/main/scala/OCM.scala 197:17]
    node _GEN_37 = mux(_T_14, _GEN_32, _GEN_6) @[src/main/scala/OCM.scala 197:17]
    node _GEN_38 = mux(_T_14, _GEN_33, _GEN_8) @[src/main/scala/OCM.scala 197:17]
    node _GEN_39 = mux(_T_11, _GEN_23, _GEN_35) @[src/main/scala/OCM.scala 197:17]
    node _GEN_40 = mux(_T_11, _GEN_24, ping_last_write_ptr) @[src/main/scala/OCM.scala 197:17 164:36]
    node _GEN_41 = mux(_T_11, _GEN_25, _GEN_36) @[src/main/scala/OCM.scala 197:17]
    node _GEN_42 = mux(_T_11, _GEN_26, _GEN_37) @[src/main/scala/OCM.scala 197:17]
    node _GEN_43 = mux(_T_11, _GEN_27, _GEN_38) @[src/main/scala/OCM.scala 197:17]
    node _GEN_44 = mux(_T_11, _GEN_28, _GEN_34) @[src/main/scala/OCM.scala 197:17]
    node _GEN_45 = mux(_T_10, _GEN_16, _GEN_44) @[src/main/scala/OCM.scala 197:17]
    node _GEN_46 = mux(_T_10, active_bank, _GEN_39) @[src/main/scala/OCM.scala 197:17 161:28]
    node _GEN_47 = mux(_T_10, ping_last_write_ptr, _GEN_40) @[src/main/scala/OCM.scala 197:17 164:36]
    node _GEN_48 = mux(_T_10, _GEN_3, _GEN_41) @[src/main/scala/OCM.scala 197:17]
    node _GEN_49 = mux(_T_10, _GEN_6, _GEN_42) @[src/main/scala/OCM.scala 197:17]
    node _GEN_50 = mux(_T_10, _GEN_8, _GEN_43) @[src/main/scala/OCM.scala 197:17]
    node _GEN_51 = mux(_T_8, _GEN_11, _GEN_45) @[src/main/scala/OCM.scala 197:17]
    node _GEN_52 = mux(_T_8, _GEN_12, _GEN_46) @[src/main/scala/OCM.scala 197:17]
    node _GEN_53 = mux(_T_8, _GEN_13, _GEN_47) @[src/main/scala/OCM.scala 197:17]
    node _GEN_54 = mux(_T_8, _GEN_14, _GEN_49) @[src/main/scala/OCM.scala 197:17]
    node _GEN_55 = mux(_T_8, _GEN_15, _GEN_50) @[src/main/scala/OCM.scala 197:17]
    node _GEN_56 = mux(_T_8, _GEN_3, _GEN_48) @[src/main/scala/OCM.scala 197:17]
    node _GEN_57 = mux(_T_5, _GEN_10, _GEN_51) @[src/main/scala/OCM.scala 197:17]
    node _GEN_58 = mux(_T_5, active_bank, _GEN_52) @[src/main/scala/OCM.scala 197:17 161:28]
    node _GEN_59 = mux(_T_5, ping_last_write_ptr, _GEN_53) @[src/main/scala/OCM.scala 197:17 164:36]
    node _GEN_60 = mux(_T_5, _GEN_6, _GEN_54) @[src/main/scala/OCM.scala 197:17]
    node _GEN_61 = mux(_T_5, _GEN_8, _GEN_55) @[src/main/scala/OCM.scala 197:17]
    node _GEN_62 = mux(_T_5, _GEN_3, _GEN_56) @[src/main/scala/OCM.scala 197:17]
    node _T_16 = eq(io_ctrl_enable, UInt<1>("h0")) @[src/main/scala/OCM.scala 238:30]
    node _T_17 = or(io_ctrl_soft_reset, _T_16) @[src/main/scala/OCM.scala 238:27]
    node _GEN_63 = mux(_T_17, UInt<3>("h0"), _GEN_57) @[src/main/scala/OCM.scala 238:47 239:11]
    node _GEN_64 = mux(_T_17, UInt<1>("h0"), _GEN_58) @[src/main/scala/OCM.scala 238:47 240:17]
    node _GEN_65 = mux(_T_17, UInt<1>("h0"), _GEN_62) @[src/main/scala/OCM.scala 238:47 241:14]
    node _GEN_66 = mux(_T_17, UInt<1>("h0"), _GEN_60) @[src/main/scala/OCM.scala 238:47 242:15]
    node _GEN_67 = mux(_T_17, UInt<1>("h0"), _GEN_59) @[src/main/scala/OCM.scala 238:47 243:25]
    node _GEN_68 = mux(_T_17, UInt<1>("h0"), _GEN_7) @[src/main/scala/OCM.scala 238:47 244:25]
    node _GEN_69 = mux(_T_17, UInt<1>("h0"), _GEN_61) @[src/main/scala/OCM.scala 238:47 245:16]
    node _active_bank_cnt_T = sub(UInt<9>("h1ff"), read_ptr) @[src/main/scala/OCM.scala 250:49]
    node active_bank_cnt = tail(_active_bank_cnt_T, 1) @[src/main/scala/OCM.scala 250:49]
    node _io_ctrl_ready_T = eq(state, UInt<3>("h2")) @[src/main/scala/OCM.scala 253:31]
    node _io_ctrl_ready_T_1 = eq(io_ctrl_enable, UInt<1>("h0")) @[src/main/scala/OCM.scala 253:56]
    node _io_ctrl_ready_T_2 = or(_io_ctrl_ready_T, _io_ctrl_ready_T_1) @[src/main/scala/OCM.scala 253:53]
    node _io_ctrl_hungry_T = eq(state, UInt<3>("h3")) @[src/main/scala/OCM.scala 254:31]
    node _io_ctrl_hungry_T_1 = eq(state, UInt<3>("h1")) @[src/main/scala/OCM.scala 254:63]
    node _io_ctrl_hungry_T_2 = or(_io_ctrl_hungry_T, _io_ctrl_hungry_T_1) @[src/main/scala/OCM.scala 254:54]
    node _io_ctrl_hungry_T_3 = or(pong_valid, last_write) @[src/main/scala/OCM.scala 254:103]
    node _io_ctrl_hungry_T_4 = eq(_io_ctrl_hungry_T_3, UInt<1>("h0")) @[src/main/scala/OCM.scala 254:90]
    node _io_ctrl_hungry_T_5 = and(_io_ctrl_hungry_T_2, _io_ctrl_hungry_T_4) @[src/main/scala/OCM.scala 254:87]
    node _io_ctrl_impending_T = leq(active_bank_cnt, UInt<8>("h8")) @[src/main/scala/OCM.scala 255:55]
    node _io_ctrl_impending_T_1 = and(is_working, _io_ctrl_impending_T) @[src/main/scala/OCM.scala 255:35]
    node _io_ctrl_impending_T_2 = or(pong_valid, last_write) @[src/main/scala/OCM.scala 255:94]
    node _io_ctrl_impending_T_3 = eq(_io_ctrl_impending_T_2, UInt<1>("h0")) @[src/main/scala/OCM.scala 255:81]
    node _io_ctrl_impending_T_4 = and(_io_ctrl_impending_T_1, _io_ctrl_impending_T_3) @[src/main/scala/OCM.scala 255:78]
    node _io_ctrl_full_T = or(pong_valid, last_write) @[src/main/scala/OCM.scala 256:33]
    node _io_ctrl_full_T_1 = and(_io_ctrl_full_T, can_get_4KB) @[src/main/scala/OCM.scala 256:48]
    node _io_ctrl_full_T_2 = eq(_io_ctrl_full_T_1, UInt<1>("h0")) @[src/main/scala/OCM.scala 256:19]
    node _GEN_70 = mux(io_lut_prog_mode, UInt<1>("h0"), io_rd_data) @[src/main/scala/OCM.scala 268:19 269:24 272:24]
    node _GEN_71 = mux(io_lut_prog_mode, io_rd_data, UInt<1>("h0")) @[src/main/scala/OCM.scala 268:19 270:29 273:29]
    io_ctrl_dma_last_data_out <= get_dma_last @[src/main/scala/OCM.scala 277:29]
    io_ctrl_ready <= _io_ctrl_ready_T_2 @[src/main/scala/OCM.scala 253:21]
    io_ctrl_hungry <= _io_ctrl_hungry_T_5 @[src/main/scala/OCM.scala 254:21]
    io_ctrl_impending <= _io_ctrl_impending_T_4 @[src/main/scala/OCM.scala 255:21]
    io_ctrl_working <= is_working @[src/main/scala/OCM.scala 252:21]
    io_ctrl_full <= _io_ctrl_full_T_2 @[src/main/scala/OCM.scala 256:16]
    io_rd_addr <= read_ptr @[src/main/scala/OCM.scala 258:18]
    io_rd_en <= is_working @[src/main/scala/OCM.scala 259:18]
    io_active_bank <= active_bank @[src/main/scala/OCM.scala 260:18]
    io_rd_data_to_cu <= _GEN_70
    io_rd_data_to_lut <= _GEN_71
    io_wr_en <= io_ctrl_dma_data_valid @[src/main/scala/OCM.scala 280:14]
    io_wr_addr <= write_ptr @[src/main/scala/OCM.scala 281:14]
    state <= mux(reset, UInt<3>("h0"), _GEN_63) @[src/main/scala/OCM.scala 158:{22,22}]
    get_dma_last <= mux(reset, UInt<1>("h0"), _GEN_9) @[src/main/scala/OCM.scala 159:{29,29}]
    active_bank <= mux(reset, UInt<1>("h0"), _GEN_64) @[src/main/scala/OCM.scala 161:{28,28}]
    read_ptr <= mux(reset, UInt<9>("h0"), _GEN_65) @[src/main/scala/OCM.scala 162:{28,28}]
    write_ptr <= mux(reset, UInt<7>("h0"), _GEN_66) @[src/main/scala/OCM.scala 163:{28,28}]
    ping_last_write_ptr <= mux(reset, UInt<7>("h0"), _GEN_67) @[src/main/scala/OCM.scala 164:{36,36}]
    pong_last_write_ptr <= mux(reset, UInt<7>("h0"), _GEN_68) @[src/main/scala/OCM.scala 165:{36,36}]
    compact_cnt <= mux(reset, UInt<4>("h0"), compact_cnt) @[src/main/scala/OCM.scala 167:{28,28,28}]
    pong_valid <= mux(reset, UInt<1>("h0"), _GEN_69) @[src/main/scala/OCM.scala 170:{28,28}]
    getting_4KB <= mux(reset, UInt<1>("h0"), _GEN_2) @[src/main/scala/OCM.scala 175:{28,28}]

  module AsymmetricPingPongSRAM : @[src/main/scala/OCM.scala 39:7]
    input clock : Clock @[src/main/scala/OCM.scala 39:7]
    input reset : UInt<1> @[src/main/scala/OCM.scala 39:7]
    input io_ping_wr_en : UInt<1> @[src/main/scala/OCM.scala 50:14]
    input io_ping_wr_addr : UInt<7> @[src/main/scala/OCM.scala 50:14]
    input io_ping_wr_data : UInt<512> @[src/main/scala/OCM.scala 50:14]
    input io_ping_rd_en : UInt<1> @[src/main/scala/OCM.scala 50:14]
    input io_ping_rd_addr : UInt<9> @[src/main/scala/OCM.scala 50:14]
    output io_ping_rd_data : UInt<128> @[src/main/scala/OCM.scala 50:14]
    input io_pong_wr_en : UInt<1> @[src/main/scala/OCM.scala 50:14]
    input io_pong_wr_addr : UInt<7> @[src/main/scala/OCM.scala 50:14]
    input io_pong_wr_data : UInt<512> @[src/main/scala/OCM.scala 50:14]
    input io_pong_rd_en : UInt<1> @[src/main/scala/OCM.scala 50:14]
    input io_pong_rd_addr : UInt<9> @[src/main/scala/OCM.scala 50:14]
    output io_pong_rd_data : UInt<128> @[src/main/scala/OCM.scala 50:14]

    mem io_ping_rd_data_subBanks_0 : @[src/main/scala/OCM.scala 75:47]
      data-type => UInt<128>
      depth => 128
      read-latency => 1
      write-latency => 1
      reader => io_ping_rd_data_rdDataVec_0_MPORT
      writer => io_ping_rd_data_MPORT
      read-under-write => undefined
    mem io_ping_rd_data_subBanks_1 : @[src/main/scala/OCM.scala 75:47]
      data-type => UInt<128>
      depth => 128
      read-latency => 1
      write-latency => 1
      reader => io_ping_rd_data_rdDataVec_1_MPORT
      writer => io_ping_rd_data_MPORT_1
      read-under-write => undefined
    mem io_ping_rd_data_subBanks_2 : @[src/main/scala/OCM.scala 75:47]
      data-type => UInt<128>
      depth => 128
      read-latency => 1
      write-latency => 1
      reader => io_ping_rd_data_rdDataVec_2_MPORT
      writer => io_ping_rd_data_MPORT_2
      read-under-write => undefined
    mem io_ping_rd_data_subBanks_3 : @[src/main/scala/OCM.scala 75:47]
      data-type => UInt<128>
      depth => 128
      read-latency => 1
      write-latency => 1
      reader => io_ping_rd_data_rdDataVec_3_MPORT
      writer => io_ping_rd_data_MPORT_3
      read-under-write => undefined
    mem io_pong_rd_data_subBanks_0 : @[src/main/scala/OCM.scala 75:47]
      data-type => UInt<128>
      depth => 128
      read-latency => 1
      write-latency => 1
      reader => io_pong_rd_data_rdDataVec_0_MPORT
      writer => io_pong_rd_data_MPORT
      read-under-write => undefined
    mem io_pong_rd_data_subBanks_1 : @[src/main/scala/OCM.scala 75:47]
      data-type => UInt<128>
      depth => 128
      read-latency => 1
      write-latency => 1
      reader => io_pong_rd_data_rdDataVec_1_MPORT
      writer => io_pong_rd_data_MPORT_1
      read-under-write => undefined
    mem io_pong_rd_data_subBanks_2 : @[src/main/scala/OCM.scala 75:47]
      data-type => UInt<128>
      depth => 128
      read-latency => 1
      write-latency => 1
      reader => io_pong_rd_data_rdDataVec_2_MPORT
      writer => io_pong_rd_data_MPORT_2
      read-under-write => undefined
    mem io_pong_rd_data_subBanks_3 : @[src/main/scala/OCM.scala 75:47]
      data-type => UInt<128>
      depth => 128
      read-latency => 1
      write-latency => 1
      reader => io_pong_rd_data_rdDataVec_3_MPORT
      writer => io_pong_rd_data_MPORT_3
      read-under-write => undefined
    node io_ping_rd_data_wordAddr = bits(io_ping_rd_addr, 8, 2) @[src/main/scala/OCM.scala 78:27]
    node io_ping_rd_data_bankSel = bits(io_ping_rd_addr, 1, 0) @[src/main/scala/OCM.scala 79:26]
    node io_ping_rd_data_sliceData = bits(io_ping_wr_data, 127, 0) @[src/main/scala/OCM.scala 82:30]
    node _GEN_0 = validif(io_ping_wr_en, io_ping_wr_addr) @[src/main/scala/OCM.scala 83:19 84:26]
    node _GEN_1 = validif(io_ping_wr_en, clock) @[src/main/scala/OCM.scala 83:19 84:26]
    node _GEN_2 = mux(io_ping_wr_en, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/OCM.scala 83:19 84:26 75:47]
    node _GEN_3 = validif(io_ping_wr_en, UInt<1>("h1")) @[src/main/scala/OCM.scala 83:19 84:26]
    node _GEN_4 = validif(io_ping_wr_en, io_ping_rd_data_sliceData) @[src/main/scala/OCM.scala 83:19 84:26]
    node _io_ping_rd_data_rdDataVec_0_T = eq(io_ping_rd_data_bankSel, UInt<1>("h0")) @[src/main/scala/OCM.scala 86:67]
    node _io_ping_rd_data_rdDataVec_0_T_1 = and(io_ping_rd_en, _io_ping_rd_data_rdDataVec_0_T) @[src/main/scala/OCM.scala 86:56]
    node _GEN_5 = validif(_io_ping_rd_data_rdDataVec_0_T_1, io_ping_rd_data_wordAddr) @[src/main/scala/OCM.scala 86:{39,39}]
    node _GEN_6 = mux(_io_ping_rd_data_rdDataVec_0_T_1, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/OCM.scala 86:{39,39} 75:47]
    node _io_ping_rd_data_rdDataVec_0_WIRE = _GEN_5 @[src/main/scala/OCM.scala 86:39]
    node _GEN_7 = validif(_io_ping_rd_data_rdDataVec_0_T_1, _io_ping_rd_data_rdDataVec_0_WIRE) @[src/main/scala/OCM.scala 86:{39,39}]
    node _GEN_8 = validif(_io_ping_rd_data_rdDataVec_0_T_1, clock) @[src/main/scala/OCM.scala 86:{39,39}]
    node io_ping_rd_data_sliceData_1 = bits(io_ping_wr_data, 255, 128) @[src/main/scala/OCM.scala 82:30]
    node _GEN_9 = validif(io_ping_wr_en, io_ping_rd_data_sliceData_1) @[src/main/scala/OCM.scala 83:19 84:26]
    node _io_ping_rd_data_rdDataVec_1_T = eq(io_ping_rd_data_bankSel, UInt<1>("h1")) @[src/main/scala/OCM.scala 86:67]
    node _io_ping_rd_data_rdDataVec_1_T_1 = and(io_ping_rd_en, _io_ping_rd_data_rdDataVec_1_T) @[src/main/scala/OCM.scala 86:56]
    node _GEN_10 = validif(_io_ping_rd_data_rdDataVec_1_T_1, io_ping_rd_data_wordAddr) @[src/main/scala/OCM.scala 86:{39,39}]
    node _GEN_11 = mux(_io_ping_rd_data_rdDataVec_1_T_1, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/OCM.scala 86:{39,39} 75:47]
    node _io_ping_rd_data_rdDataVec_1_WIRE = _GEN_10 @[src/main/scala/OCM.scala 86:39]
    node _GEN_12 = validif(_io_ping_rd_data_rdDataVec_1_T_1, _io_ping_rd_data_rdDataVec_1_WIRE) @[src/main/scala/OCM.scala 86:{39,39}]
    node _GEN_13 = validif(_io_ping_rd_data_rdDataVec_1_T_1, clock) @[src/main/scala/OCM.scala 86:{39,39}]
    node io_ping_rd_data_sliceData_2 = bits(io_ping_wr_data, 383, 256) @[src/main/scala/OCM.scala 82:30]
    node _GEN_14 = validif(io_ping_wr_en, io_ping_rd_data_sliceData_2) @[src/main/scala/OCM.scala 83:19 84:26]
    node _io_ping_rd_data_rdDataVec_2_T = eq(io_ping_rd_data_bankSel, UInt<2>("h2")) @[src/main/scala/OCM.scala 86:67]
    node _io_ping_rd_data_rdDataVec_2_T_1 = and(io_ping_rd_en, _io_ping_rd_data_rdDataVec_2_T) @[src/main/scala/OCM.scala 86:56]
    node _GEN_15 = validif(_io_ping_rd_data_rdDataVec_2_T_1, io_ping_rd_data_wordAddr) @[src/main/scala/OCM.scala 86:{39,39}]
    node _GEN_16 = mux(_io_ping_rd_data_rdDataVec_2_T_1, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/OCM.scala 86:{39,39} 75:47]
    node _io_ping_rd_data_rdDataVec_2_WIRE = _GEN_15 @[src/main/scala/OCM.scala 86:39]
    node _GEN_17 = validif(_io_ping_rd_data_rdDataVec_2_T_1, _io_ping_rd_data_rdDataVec_2_WIRE) @[src/main/scala/OCM.scala 86:{39,39}]
    node _GEN_18 = validif(_io_ping_rd_data_rdDataVec_2_T_1, clock) @[src/main/scala/OCM.scala 86:{39,39}]
    node io_ping_rd_data_sliceData_3 = bits(io_ping_wr_data, 511, 384) @[src/main/scala/OCM.scala 82:30]
    node _GEN_19 = validif(io_ping_wr_en, io_ping_rd_data_sliceData_3) @[src/main/scala/OCM.scala 83:19 84:26]
    node _io_ping_rd_data_rdDataVec_3_T = eq(io_ping_rd_data_bankSel, UInt<2>("h3")) @[src/main/scala/OCM.scala 86:67]
    node _io_ping_rd_data_rdDataVec_3_T_1 = and(io_ping_rd_en, _io_ping_rd_data_rdDataVec_3_T) @[src/main/scala/OCM.scala 86:56]
    node _GEN_20 = validif(_io_ping_rd_data_rdDataVec_3_T_1, io_ping_rd_data_wordAddr) @[src/main/scala/OCM.scala 86:{39,39}]
    node _GEN_21 = mux(_io_ping_rd_data_rdDataVec_3_T_1, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/OCM.scala 86:{39,39} 75:47]
    node _io_ping_rd_data_rdDataVec_3_WIRE = _GEN_20 @[src/main/scala/OCM.scala 86:39]
    node _GEN_22 = validif(_io_ping_rd_data_rdDataVec_3_T_1, _io_ping_rd_data_rdDataVec_3_WIRE) @[src/main/scala/OCM.scala 86:{39,39}]
    node _GEN_23 = validif(_io_ping_rd_data_rdDataVec_3_T_1, clock) @[src/main/scala/OCM.scala 86:{39,39}]
    reg io_ping_rd_data_bankSelD1 : UInt<2>, clock with :
      reset => (UInt<1>("h0"), io_ping_rd_data_bankSelD1) @[src/main/scala/OCM.scala 89:30]
    node _GEN_24 = mux(io_ping_rd_en, io_ping_rd_data_bankSel, io_ping_rd_data_bankSelD1) @[src/main/scala/OCM.scala 89:{30,30,30}]
    node _io_ping_rd_data_T = or(io_ping_rd_data_bankSelD1, UInt<2>("h0"))
    node _io_ping_rd_data_T_1 = bits(_io_ping_rd_data_T, 1, 0)
    node io_ping_rd_data_rdDataVec_0 = io_ping_rd_data_subBanks_0.io_ping_rd_data_rdDataVec_0_MPORT.data @[src/main/scala/OCM.scala 76:25 86:20]
    node _GEN_25 = validif(eq(UInt<1>("h0"), _io_ping_rd_data_T_1), io_ping_rd_data_rdDataVec_0) @[src/main/scala/OCM.scala 93:{19,19}]
    node io_ping_rd_data_rdDataVec_1 = io_ping_rd_data_subBanks_1.io_ping_rd_data_rdDataVec_1_MPORT.data @[src/main/scala/OCM.scala 76:25 86:20]
    node _GEN_26 = mux(eq(UInt<1>("h1"), _io_ping_rd_data_T_1), io_ping_rd_data_rdDataVec_1, _GEN_25) @[src/main/scala/OCM.scala 93:{19,19}]
    node io_ping_rd_data_rdDataVec_2 = io_ping_rd_data_subBanks_2.io_ping_rd_data_rdDataVec_2_MPORT.data @[src/main/scala/OCM.scala 76:25 86:20]
    node _GEN_27 = mux(eq(UInt<2>("h2"), _io_ping_rd_data_T_1), io_ping_rd_data_rdDataVec_2, _GEN_26) @[src/main/scala/OCM.scala 93:{19,19}]
    node io_ping_rd_data_rdDataVec_3 = io_ping_rd_data_subBanks_3.io_ping_rd_data_rdDataVec_3_MPORT.data @[src/main/scala/OCM.scala 76:25 86:20]
    node _GEN_28 = mux(eq(UInt<2>("h3"), _io_ping_rd_data_T_1), io_ping_rd_data_rdDataVec_3, _GEN_27) @[src/main/scala/OCM.scala 93:{19,19}]
    node io_pong_rd_data_wordAddr = bits(io_pong_rd_addr, 8, 2) @[src/main/scala/OCM.scala 78:27]
    node io_pong_rd_data_bankSel = bits(io_pong_rd_addr, 1, 0) @[src/main/scala/OCM.scala 79:26]
    node io_pong_rd_data_sliceData = bits(io_pong_wr_data, 127, 0) @[src/main/scala/OCM.scala 82:30]
    node _GEN_29 = validif(io_pong_wr_en, io_pong_wr_addr) @[src/main/scala/OCM.scala 83:19 84:26]
    node _GEN_30 = validif(io_pong_wr_en, clock) @[src/main/scala/OCM.scala 83:19 84:26]
    node _GEN_31 = mux(io_pong_wr_en, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/OCM.scala 83:19 84:26 75:47]
    node _GEN_32 = validif(io_pong_wr_en, UInt<1>("h1")) @[src/main/scala/OCM.scala 83:19 84:26]
    node _GEN_33 = validif(io_pong_wr_en, io_pong_rd_data_sliceData) @[src/main/scala/OCM.scala 83:19 84:26]
    node _io_pong_rd_data_rdDataVec_0_T = eq(io_pong_rd_data_bankSel, UInt<1>("h0")) @[src/main/scala/OCM.scala 86:67]
    node _io_pong_rd_data_rdDataVec_0_T_1 = and(io_pong_rd_en, _io_pong_rd_data_rdDataVec_0_T) @[src/main/scala/OCM.scala 86:56]
    node _GEN_34 = validif(_io_pong_rd_data_rdDataVec_0_T_1, io_pong_rd_data_wordAddr) @[src/main/scala/OCM.scala 86:{39,39}]
    node _GEN_35 = mux(_io_pong_rd_data_rdDataVec_0_T_1, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/OCM.scala 86:{39,39} 75:47]
    node _io_pong_rd_data_rdDataVec_0_WIRE = _GEN_34 @[src/main/scala/OCM.scala 86:39]
    node _GEN_36 = validif(_io_pong_rd_data_rdDataVec_0_T_1, _io_pong_rd_data_rdDataVec_0_WIRE) @[src/main/scala/OCM.scala 86:{39,39}]
    node _GEN_37 = validif(_io_pong_rd_data_rdDataVec_0_T_1, clock) @[src/main/scala/OCM.scala 86:{39,39}]
    node io_pong_rd_data_sliceData_1 = bits(io_pong_wr_data, 255, 128) @[src/main/scala/OCM.scala 82:30]
    node _GEN_38 = validif(io_pong_wr_en, io_pong_rd_data_sliceData_1) @[src/main/scala/OCM.scala 83:19 84:26]
    node _io_pong_rd_data_rdDataVec_1_T = eq(io_pong_rd_data_bankSel, UInt<1>("h1")) @[src/main/scala/OCM.scala 86:67]
    node _io_pong_rd_data_rdDataVec_1_T_1 = and(io_pong_rd_en, _io_pong_rd_data_rdDataVec_1_T) @[src/main/scala/OCM.scala 86:56]
    node _GEN_39 = validif(_io_pong_rd_data_rdDataVec_1_T_1, io_pong_rd_data_wordAddr) @[src/main/scala/OCM.scala 86:{39,39}]
    node _GEN_40 = mux(_io_pong_rd_data_rdDataVec_1_T_1, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/OCM.scala 86:{39,39} 75:47]
    node _io_pong_rd_data_rdDataVec_1_WIRE = _GEN_39 @[src/main/scala/OCM.scala 86:39]
    node _GEN_41 = validif(_io_pong_rd_data_rdDataVec_1_T_1, _io_pong_rd_data_rdDataVec_1_WIRE) @[src/main/scala/OCM.scala 86:{39,39}]
    node _GEN_42 = validif(_io_pong_rd_data_rdDataVec_1_T_1, clock) @[src/main/scala/OCM.scala 86:{39,39}]
    node io_pong_rd_data_sliceData_2 = bits(io_pong_wr_data, 383, 256) @[src/main/scala/OCM.scala 82:30]
    node _GEN_43 = validif(io_pong_wr_en, io_pong_rd_data_sliceData_2) @[src/main/scala/OCM.scala 83:19 84:26]
    node _io_pong_rd_data_rdDataVec_2_T = eq(io_pong_rd_data_bankSel, UInt<2>("h2")) @[src/main/scala/OCM.scala 86:67]
    node _io_pong_rd_data_rdDataVec_2_T_1 = and(io_pong_rd_en, _io_pong_rd_data_rdDataVec_2_T) @[src/main/scala/OCM.scala 86:56]
    node _GEN_44 = validif(_io_pong_rd_data_rdDataVec_2_T_1, io_pong_rd_data_wordAddr) @[src/main/scala/OCM.scala 86:{39,39}]
    node _GEN_45 = mux(_io_pong_rd_data_rdDataVec_2_T_1, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/OCM.scala 86:{39,39} 75:47]
    node _io_pong_rd_data_rdDataVec_2_WIRE = _GEN_44 @[src/main/scala/OCM.scala 86:39]
    node _GEN_46 = validif(_io_pong_rd_data_rdDataVec_2_T_1, _io_pong_rd_data_rdDataVec_2_WIRE) @[src/main/scala/OCM.scala 86:{39,39}]
    node _GEN_47 = validif(_io_pong_rd_data_rdDataVec_2_T_1, clock) @[src/main/scala/OCM.scala 86:{39,39}]
    node io_pong_rd_data_sliceData_3 = bits(io_pong_wr_data, 511, 384) @[src/main/scala/OCM.scala 82:30]
    node _GEN_48 = validif(io_pong_wr_en, io_pong_rd_data_sliceData_3) @[src/main/scala/OCM.scala 83:19 84:26]
    node _io_pong_rd_data_rdDataVec_3_T = eq(io_pong_rd_data_bankSel, UInt<2>("h3")) @[src/main/scala/OCM.scala 86:67]
    node _io_pong_rd_data_rdDataVec_3_T_1 = and(io_pong_rd_en, _io_pong_rd_data_rdDataVec_3_T) @[src/main/scala/OCM.scala 86:56]
    node _GEN_49 = validif(_io_pong_rd_data_rdDataVec_3_T_1, io_pong_rd_data_wordAddr) @[src/main/scala/OCM.scala 86:{39,39}]
    node _GEN_50 = mux(_io_pong_rd_data_rdDataVec_3_T_1, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/OCM.scala 86:{39,39} 75:47]
    node _io_pong_rd_data_rdDataVec_3_WIRE = _GEN_49 @[src/main/scala/OCM.scala 86:39]
    node _GEN_51 = validif(_io_pong_rd_data_rdDataVec_3_T_1, _io_pong_rd_data_rdDataVec_3_WIRE) @[src/main/scala/OCM.scala 86:{39,39}]
    node _GEN_52 = validif(_io_pong_rd_data_rdDataVec_3_T_1, clock) @[src/main/scala/OCM.scala 86:{39,39}]
    reg io_pong_rd_data_bankSelD1 : UInt<2>, clock with :
      reset => (UInt<1>("h0"), io_pong_rd_data_bankSelD1) @[src/main/scala/OCM.scala 89:30]
    node _GEN_53 = mux(io_pong_rd_en, io_pong_rd_data_bankSel, io_pong_rd_data_bankSelD1) @[src/main/scala/OCM.scala 89:{30,30,30}]
    node _io_pong_rd_data_T = or(io_pong_rd_data_bankSelD1, UInt<2>("h0"))
    node _io_pong_rd_data_T_1 = bits(_io_pong_rd_data_T, 1, 0)
    node io_pong_rd_data_rdDataVec_0 = io_pong_rd_data_subBanks_0.io_pong_rd_data_rdDataVec_0_MPORT.data @[src/main/scala/OCM.scala 76:25 86:20]
    node _GEN_54 = validif(eq(UInt<1>("h0"), _io_pong_rd_data_T_1), io_pong_rd_data_rdDataVec_0) @[src/main/scala/OCM.scala 100:{19,19}]
    node io_pong_rd_data_rdDataVec_1 = io_pong_rd_data_subBanks_1.io_pong_rd_data_rdDataVec_1_MPORT.data @[src/main/scala/OCM.scala 76:25 86:20]
    node _GEN_55 = mux(eq(UInt<1>("h1"), _io_pong_rd_data_T_1), io_pong_rd_data_rdDataVec_1, _GEN_54) @[src/main/scala/OCM.scala 100:{19,19}]
    node io_pong_rd_data_rdDataVec_2 = io_pong_rd_data_subBanks_2.io_pong_rd_data_rdDataVec_2_MPORT.data @[src/main/scala/OCM.scala 76:25 86:20]
    node _GEN_56 = mux(eq(UInt<2>("h2"), _io_pong_rd_data_T_1), io_pong_rd_data_rdDataVec_2, _GEN_55) @[src/main/scala/OCM.scala 100:{19,19}]
    node io_pong_rd_data_rdDataVec_3 = io_pong_rd_data_subBanks_3.io_pong_rd_data_rdDataVec_3_MPORT.data @[src/main/scala/OCM.scala 76:25 86:20]
    node _GEN_57 = mux(eq(UInt<2>("h3"), _io_pong_rd_data_T_1), io_pong_rd_data_rdDataVec_3, _GEN_56) @[src/main/scala/OCM.scala 100:{19,19}]
    node _io_ping_rd_data_rdDataVec_io_ping_rd_data_T_1 = _GEN_28 @[src/main/scala/OCM.scala 93:19]
    node _io_pong_rd_data_rdDataVec_io_pong_rd_data_T_1 = _GEN_57 @[src/main/scala/OCM.scala 100:19]
    io_ping_rd_data <= _io_ping_rd_data_rdDataVec_io_ping_rd_data_T_1 @[src/main/scala/OCM.scala 93:19]
    io_pong_rd_data <= _io_pong_rd_data_rdDataVec_io_pong_rd_data_T_1 @[src/main/scala/OCM.scala 100:19]
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
    io_ping_rd_data_bankSelD1 <= mux(reset, UInt<1>("h0"), _GEN_24) @[src/main/scala/OCM.scala 89:{30,30}]
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
    io_pong_rd_data_bankSelD1 <= mux(reset, UInt<1>("h0"), _GEN_53) @[src/main/scala/OCM.scala 89:{30,30}]

  module WbControllerWithSram : @[src/main/scala/wb.scala 7:7]
    input clock : Clock @[src/main/scala/wb.scala 7:7]
    input reset : UInt<1> @[src/main/scala/wb.scala 7:7]
    input io_soft_reset : UInt<1> @[src/main/scala/wb.scala 8:14]
    input io_enable : UInt<1> @[src/main/scala/wb.scala 8:14]
    input io_shoot : UInt<1> @[src/main/scala/wb.scala 8:14]
    input io_lut_prog_mode : UInt<1> @[src/main/scala/wb.scala 8:14]
    input io_rlast : UInt<1> @[src/main/scala/wb.scala 8:14]
    input io_dma_data : UInt<512> @[src/main/scala/wb.scala 8:14]
    input io_dma_data_valid : UInt<1> @[src/main/scala/wb.scala 8:14]
    input io_dma_data_last : UInt<1> @[src/main/scala/wb.scala 8:14]
    input io_dma_write_ready : UInt<1> @[src/main/scala/wb.scala 8:14]
    output io_ready : UInt<1> @[src/main/scala/wb.scala 8:14]
    output io_hungry : UInt<1> @[src/main/scala/wb.scala 8:14]
    output io_impending : UInt<1> @[src/main/scala/wb.scala 8:14]
    output io_working : UInt<1> @[src/main/scala/wb.scala 8:14]
    output io_write_buffer_has_space : UInt<1> @[src/main/scala/wb.scala 8:14]
    output io_full : UInt<1> @[src/main/scala/wb.scala 8:14]
    output io_dma_last_data_out : UInt<1> @[src/main/scala/wb.scala 8:14]
    output io_rd_data_to_cu : UInt<128> @[src/main/scala/wb.scala 8:14]
    output io_rd_data_to_lut : UInt<128> @[src/main/scala/wb.scala 8:14]
    output io_rd_data_valid : UInt<1> @[src/main/scala/wb.scala 8:14]
    output io_dbg_ping_wr_en : UInt<1> @[src/main/scala/wb.scala 8:14]
    output io_dbg_pong_wr_en : UInt<1> @[src/main/scala/wb.scala 8:14]
    output io_dbg_ping_wr_addr : UInt<7> @[src/main/scala/wb.scala 8:14]
    output io_dbg_pong_wr_addr : UInt<7> @[src/main/scala/wb.scala 8:14]
    output io_dbg_ping_wr_data : UInt<512> @[src/main/scala/wb.scala 8:14]
    output io_dbg_pong_wr_data : UInt<512> @[src/main/scala/wb.scala 8:14]

    inst controller of UbWbController @[src/main/scala/wb.scala 41:26]
    inst sram of AsymmetricPingPongSRAM @[src/main/scala/wb.scala 42:20]
    node readPing = eq(controller.io_active_bank, UInt<1>("h0")) @[src/main/scala/wb.scala 53:45]
    node writePing = eq(readPing, UInt<1>("h0")) @[src/main/scala/wb.scala 54:19]
    node _sram_io_ping_wr_en_T = and(controller.io_wr_en, writePing) @[src/main/scala/wb.scala 57:47]
    node _sram_io_pong_wr_en_T = eq(writePing, UInt<1>("h0")) @[src/main/scala/wb.scala 58:50]
    node _sram_io_pong_wr_en_T_1 = and(controller.io_wr_en, _sram_io_pong_wr_en_T) @[src/main/scala/wb.scala 58:47]
    node _sram_io_ping_rd_en_T = and(controller.io_rd_en, readPing) @[src/main/scala/wb.scala 65:47]
    node _sram_io_pong_rd_en_T = eq(readPing, UInt<1>("h0")) @[src/main/scala/wb.scala 66:50]
    node _sram_io_pong_rd_en_T_1 = and(controller.io_rd_en, _sram_io_pong_rd_en_T) @[src/main/scala/wb.scala 66:47]
    reg readPingD1 : UInt<1>, clock with :
      reset => (UInt<1>("h0"), readPingD1) @[src/main/scala/wb.scala 71:29]
    node _GEN_0 = mux(controller.io_rd_en, readPing, readPingD1) @[src/main/scala/wb.scala 71:{29,29,29}]
    node _controller_io_rd_data_T = mux(readPingD1, sram.io_ping_rd_data, sram.io_pong_rd_data) @[src/main/scala/wb.scala 72:31]
    node _io_dma_last_data_out_T = and(io_dma_data_valid, io_dma_data_last) @[src/main/scala/wb.scala 84:45]
    reg io_rd_data_valid_REG : UInt<1>, clock with :
      reset => (UInt<1>("h0"), io_rd_data_valid_REG) @[src/main/scala/wb.scala 87:31]
    io_ready <= controller.io_ctrl_ready @[src/main/scala/wb.scala 78:21]
    io_hungry <= controller.io_ctrl_hungry @[src/main/scala/wb.scala 79:21]
    io_impending <= controller.io_ctrl_impending @[src/main/scala/wb.scala 80:21]
    io_working <= controller.io_ctrl_working @[src/main/scala/wb.scala 81:21]
    io_write_buffer_has_space <= io_hungry @[src/main/scala/wb.scala 82:29]
    io_full <= controller.io_ctrl_full @[src/main/scala/wb.scala 83:11]
    io_dma_last_data_out <= _io_dma_last_data_out_T @[src/main/scala/wb.scala 84:24]
    io_rd_data_to_cu <= controller.io_rd_data_to_cu @[src/main/scala/wb.scala 85:21]
    io_rd_data_to_lut <= controller.io_rd_data_to_lut @[src/main/scala/wb.scala 86:21]
    io_rd_data_valid <= io_rd_data_valid_REG @[src/main/scala/wb.scala 87:21]
    io_dbg_ping_wr_en <= sram.io_ping_wr_en @[src/main/scala/wb.scala 89:23]
    io_dbg_pong_wr_en <= sram.io_pong_wr_en @[src/main/scala/wb.scala 90:23]
    io_dbg_ping_wr_addr <= sram.io_ping_wr_addr @[src/main/scala/wb.scala 91:23]
    io_dbg_pong_wr_addr <= sram.io_pong_wr_addr @[src/main/scala/wb.scala 92:23]
    io_dbg_ping_wr_data <= sram.io_ping_wr_data @[src/main/scala/wb.scala 93:23]
    io_dbg_pong_wr_data <= sram.io_pong_wr_data @[src/main/scala/wb.scala 94:23]
    controller.clock <= clock
    controller.reset <= reset
    controller.io_ctrl_soft_reset <= io_soft_reset @[src/main/scala/wb.scala 44:38]
    controller.io_ctrl_enable <= io_enable @[src/main/scala/wb.scala 45:38]
    controller.io_ctrl_shoot <= io_shoot @[src/main/scala/wb.scala 46:38]
    controller.io_ctrl_rlast <= io_rlast @[src/main/scala/wb.scala 47:38]
    controller.io_ctrl_dma_data_valid <= io_dma_data_valid @[src/main/scala/wb.scala 48:38]
    controller.io_ctrl_dma_data_last <= io_dma_data_last @[src/main/scala/wb.scala 49:38]
    controller.io_ctrl_dma_write_ready <= io_dma_write_ready @[src/main/scala/wb.scala 50:38]
    controller.io_lut_prog_mode <= io_lut_prog_mode @[src/main/scala/wb.scala 51:38]
    controller.io_rd_data <= _controller_io_rd_data_T @[src/main/scala/wb.scala 72:25]
    sram.clock <= clock
    sram.reset <= reset
    sram.io_ping_wr_en <= _sram_io_ping_wr_en_T @[src/main/scala/wb.scala 57:24]
    sram.io_ping_wr_addr <= controller.io_wr_addr @[src/main/scala/wb.scala 59:24]
    sram.io_ping_wr_data <= io_dma_data @[src/main/scala/wb.scala 61:24]
    sram.io_ping_rd_en <= _sram_io_ping_rd_en_T @[src/main/scala/wb.scala 65:24]
    sram.io_ping_rd_addr <= controller.io_rd_addr @[src/main/scala/wb.scala 67:24]
    sram.io_pong_wr_en <= _sram_io_pong_wr_en_T_1 @[src/main/scala/wb.scala 58:24]
    sram.io_pong_wr_addr <= controller.io_wr_addr @[src/main/scala/wb.scala 60:24]
    sram.io_pong_wr_data <= io_dma_data @[src/main/scala/wb.scala 62:24]
    sram.io_pong_rd_en <= _sram_io_pong_rd_en_T_1 @[src/main/scala/wb.scala 66:24]
    sram.io_pong_rd_addr <= controller.io_rd_addr @[src/main/scala/wb.scala 68:24]
    readPingD1 <= mux(reset, UInt<1>("h1"), _GEN_0) @[src/main/scala/wb.scala 71:{29,29}]
    io_rd_data_valid_REG <= mux(reset, UInt<1>("h0"), controller.io_rd_en) @[src/main/scala/wb.scala 87:{31,31,31}]
