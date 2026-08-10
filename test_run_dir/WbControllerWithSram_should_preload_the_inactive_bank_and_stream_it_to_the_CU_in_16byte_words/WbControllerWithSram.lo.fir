FIRRTL version 1.2.0
circuit WbControllerWithSram :
  module UbWbController : @[src/main/scala/weightcontroller.scala 127:7]
    input clock : Clock @[src/main/scala/weightcontroller.scala 127:7]
    input reset : UInt<1> @[src/main/scala/weightcontroller.scala 127:7]
    input io_ctrl_soft_reset : UInt<1> @[src/main/scala/weightcontroller.scala 128:14]
    input io_ctrl_enable : UInt<1> @[src/main/scala/weightcontroller.scala 128:14]
    input io_ctrl_shoot : UInt<1> @[src/main/scala/weightcontroller.scala 128:14]
    input io_ctrl_dma_data_valid : UInt<1> @[src/main/scala/weightcontroller.scala 128:14]
    input io_ctrl_dma_data_last : UInt<1> @[src/main/scala/weightcontroller.scala 128:14]
    input io_ctrl_dma_write_ready : UInt<1> @[src/main/scala/weightcontroller.scala 128:14]
    output io_ctrl_ready : UInt<1> @[src/main/scala/weightcontroller.scala 128:14]
    output io_ctrl_hungry : UInt<1> @[src/main/scala/weightcontroller.scala 128:14]
    output io_ctrl_impending : UInt<1> @[src/main/scala/weightcontroller.scala 128:14]
    output io_ctrl_working : UInt<1> @[src/main/scala/weightcontroller.scala 128:14]
    input io_lut_prog_mode : UInt<1> @[src/main/scala/weightcontroller.scala 128:14]
    output io_rd_addr : UInt<8> @[src/main/scala/weightcontroller.scala 128:14]
    output io_rd_en : UInt<1> @[src/main/scala/weightcontroller.scala 128:14]
    output io_active_bank : UInt<1> @[src/main/scala/weightcontroller.scala 128:14]
    input io_rd_data : UInt<128> @[src/main/scala/weightcontroller.scala 128:14]
    output io_rd_data_to_cu : UInt<128> @[src/main/scala/weightcontroller.scala 128:14]
    output io_rd_data_to_lut : UInt<128> @[src/main/scala/weightcontroller.scala 128:14]
    output io_wr_en : UInt<1> @[src/main/scala/weightcontroller.scala 128:14]
    output io_wr_addr : UInt<6> @[src/main/scala/weightcontroller.scala 128:14]

    reg state : UInt<3>, clock with :
      reset => (UInt<1>("h0"), state) @[src/main/scala/weightcontroller.scala 147:22]
    reg active_bank : UInt<1>, clock with :
      reset => (UInt<1>("h0"), active_bank) @[src/main/scala/weightcontroller.scala 149:28]
    reg read_ptr : UInt<8>, clock with :
      reset => (UInt<1>("h0"), read_ptr) @[src/main/scala/weightcontroller.scala 150:28]
    reg write_ptr : UInt<6>, clock with :
      reset => (UInt<1>("h0"), write_ptr) @[src/main/scala/weightcontroller.scala 151:28]
    reg compact_cnt : UInt<4>, clock with :
      reset => (UInt<1>("h0"), compact_cnt) @[src/main/scala/weightcontroller.scala 152:28]
    node _last_write_T = eq(write_ptr, UInt<6>("h3f")) @[src/main/scala/weightcontroller.scala 153:31]
    node last_write = and(_last_write_T, io_ctrl_dma_data_valid) @[src/main/scala/weightcontroller.scala 153:60]
    reg pong_valid : UInt<1>, clock with :
      reset => (UInt<1>("h0"), pong_valid) @[src/main/scala/weightcontroller.scala 154:28]
    node _GEN_0 = mux(last_write, UInt<1>("h1"), pong_valid) @[src/main/scala/weightcontroller.scala 156:20 154:28 156:33]
    node _T = eq(UInt<3>("h0"), state) @[src/main/scala/weightcontroller.scala 159:17]
    node _T_1 = eq(io_ctrl_soft_reset, UInt<1>("h0")) @[src/main/scala/weightcontroller.scala 161:30]
    node _T_2 = and(io_ctrl_enable, _T_1) @[src/main/scala/weightcontroller.scala 161:27]
    node _GEN_1 = mux(_T_2, UInt<3>("h1"), state) @[src/main/scala/weightcontroller.scala 147:22 161:{51,59}]
    node _T_3 = eq(UInt<3>("h1"), state) @[src/main/scala/weightcontroller.scala 159:17]
    node _T_4 = or(pong_valid, last_write) @[src/main/scala/weightcontroller.scala 164:23]
    node _active_bank_T = not(active_bank) @[src/main/scala/weightcontroller.scala 166:24]
    node _GEN_2 = mux(_T_4, UInt<3>("h2"), state) @[src/main/scala/weightcontroller.scala 164:38 165:15 147:22]
    node _GEN_3 = mux(_T_4, _active_bank_T, active_bank) @[src/main/scala/weightcontroller.scala 164:38 166:21 149:28]
    node _GEN_4 = mux(_T_4, UInt<1>("h0"), write_ptr) @[src/main/scala/weightcontroller.scala 164:38 167:19 151:28]
    node _GEN_5 = mux(_T_4, UInt<1>("h0"), _GEN_0) @[src/main/scala/weightcontroller.scala 164:38 168:20]
    node _T_5 = eq(UInt<3>("h2"), state) @[src/main/scala/weightcontroller.scala 159:17]
    node _GEN_6 = mux(io_ctrl_shoot, UInt<3>("h3"), state) @[src/main/scala/weightcontroller.scala 147:22 172:{27,35}]
    node _T_6 = eq(UInt<3>("h3"), state) @[src/main/scala/weightcontroller.scala 159:17]
    node _T_7 = eq(read_ptr, UInt<8>("hff")) @[src/main/scala/weightcontroller.scala 177:21]
    node _T_8 = and(_T_7, UInt<1>("h1")) @[src/main/scala/weightcontroller.scala 177:49]
    node _T_9 = or(pong_valid, last_write) @[src/main/scala/weightcontroller.scala 178:25]
    node _active_bank_T_1 = not(active_bank) @[src/main/scala/weightcontroller.scala 179:26]
    node _GEN_7 = mux(_T_9, _active_bank_T_1, active_bank) @[src/main/scala/weightcontroller.scala 178:40 179:23 149:28]
    node _GEN_8 = mux(_T_9, UInt<1>("h0"), read_ptr) @[src/main/scala/weightcontroller.scala 178:40 180:20 150:28]
    node _GEN_9 = mux(_T_9, UInt<1>("h0"), write_ptr) @[src/main/scala/weightcontroller.scala 178:40 181:21 151:28]
    node _GEN_10 = mux(_T_9, UInt<1>("h0"), _GEN_0) @[src/main/scala/weightcontroller.scala 178:40 182:22]
    node _GEN_11 = mux(_T_9, state, UInt<3>("h4")) @[src/main/scala/weightcontroller.scala 147:22 178:40 184:17]
    node _GEN_12 = mux(_T_8, _GEN_7, active_bank) @[src/main/scala/weightcontroller.scala 149:28 177:65]
    node _GEN_13 = mux(_T_8, _GEN_8, read_ptr) @[src/main/scala/weightcontroller.scala 150:28 177:65]
    node _GEN_14 = mux(_T_8, _GEN_9, write_ptr) @[src/main/scala/weightcontroller.scala 151:28 177:65]
    node _GEN_15 = mux(_T_8, _GEN_10, _GEN_0) @[src/main/scala/weightcontroller.scala 177:65]
    node _GEN_16 = mux(_T_8, _GEN_11, state) @[src/main/scala/weightcontroller.scala 147:22 177:65]
    node _T_10 = eq(UInt<3>("h4"), state) @[src/main/scala/weightcontroller.scala 159:17]
    node _T_11 = or(pong_valid, last_write) @[src/main/scala/weightcontroller.scala 189:23]
    node _active_bank_T_2 = not(active_bank) @[src/main/scala/weightcontroller.scala 191:24]
    node _GEN_17 = mux(_T_11, UInt<3>("h3"), state) @[src/main/scala/weightcontroller.scala 189:38 190:15 147:22]
    node _GEN_18 = mux(_T_11, _active_bank_T_2, active_bank) @[src/main/scala/weightcontroller.scala 189:38 191:21 149:28]
    node _GEN_19 = mux(_T_11, UInt<1>("h0"), read_ptr) @[src/main/scala/weightcontroller.scala 189:38 192:18 150:28]
    node _GEN_20 = mux(_T_11, UInt<1>("h0"), write_ptr) @[src/main/scala/weightcontroller.scala 189:38 193:19 151:28]
    node _GEN_21 = mux(_T_11, UInt<1>("h0"), _GEN_0) @[src/main/scala/weightcontroller.scala 189:38 194:20]
    node _GEN_22 = mux(_T_10, _GEN_17, state) @[src/main/scala/weightcontroller.scala 159:17 147:22]
    node _GEN_23 = mux(_T_10, _GEN_18, active_bank) @[src/main/scala/weightcontroller.scala 159:17 149:28]
    node _GEN_24 = mux(_T_10, _GEN_19, read_ptr) @[src/main/scala/weightcontroller.scala 159:17 150:28]
    node _GEN_25 = mux(_T_10, _GEN_20, write_ptr) @[src/main/scala/weightcontroller.scala 159:17 151:28]
    node _GEN_26 = mux(_T_10, _GEN_21, _GEN_0) @[src/main/scala/weightcontroller.scala 159:17]
    node _GEN_27 = mux(_T_6, _GEN_12, _GEN_23) @[src/main/scala/weightcontroller.scala 159:17]
    node _GEN_28 = mux(_T_6, _GEN_13, _GEN_24) @[src/main/scala/weightcontroller.scala 159:17]
    node _GEN_29 = mux(_T_6, _GEN_14, _GEN_25) @[src/main/scala/weightcontroller.scala 159:17]
    node _GEN_30 = mux(_T_6, _GEN_15, _GEN_26) @[src/main/scala/weightcontroller.scala 159:17]
    node _GEN_31 = mux(_T_6, _GEN_16, _GEN_22) @[src/main/scala/weightcontroller.scala 159:17]
    node _GEN_32 = mux(_T_5, _GEN_6, _GEN_31) @[src/main/scala/weightcontroller.scala 159:17]
    node _GEN_33 = mux(_T_5, active_bank, _GEN_27) @[src/main/scala/weightcontroller.scala 159:17 149:28]
    node _GEN_34 = mux(_T_5, read_ptr, _GEN_28) @[src/main/scala/weightcontroller.scala 159:17 150:28]
    node _GEN_35 = mux(_T_5, write_ptr, _GEN_29) @[src/main/scala/weightcontroller.scala 159:17 151:28]
    node _GEN_36 = mux(_T_5, _GEN_0, _GEN_30) @[src/main/scala/weightcontroller.scala 159:17]
    node _GEN_37 = mux(_T_3, _GEN_2, _GEN_32) @[src/main/scala/weightcontroller.scala 159:17]
    node _GEN_38 = mux(_T_3, _GEN_3, _GEN_33) @[src/main/scala/weightcontroller.scala 159:17]
    node _GEN_39 = mux(_T_3, _GEN_4, _GEN_35) @[src/main/scala/weightcontroller.scala 159:17]
    node _GEN_40 = mux(_T_3, _GEN_5, _GEN_36) @[src/main/scala/weightcontroller.scala 159:17]
    node _GEN_41 = mux(_T_3, read_ptr, _GEN_34) @[src/main/scala/weightcontroller.scala 159:17 150:28]
    node _GEN_42 = mux(_T, _GEN_1, _GEN_37) @[src/main/scala/weightcontroller.scala 159:17]
    node _GEN_43 = mux(_T, active_bank, _GEN_38) @[src/main/scala/weightcontroller.scala 159:17 149:28]
    node _GEN_44 = mux(_T, write_ptr, _GEN_39) @[src/main/scala/weightcontroller.scala 159:17 151:28]
    node _GEN_45 = mux(_T, _GEN_0, _GEN_40) @[src/main/scala/weightcontroller.scala 159:17]
    node _GEN_46 = mux(_T, read_ptr, _GEN_41) @[src/main/scala/weightcontroller.scala 159:17 150:28]
    node _GEN_47 = mux(io_ctrl_soft_reset, UInt<3>("h0"), _GEN_42) @[src/main/scala/weightcontroller.scala 199:28 200:11]
    node _GEN_48 = mux(io_ctrl_soft_reset, UInt<1>("h0"), _GEN_43) @[src/main/scala/weightcontroller.scala 199:28 201:17]
    node _GEN_49 = mux(io_ctrl_soft_reset, UInt<1>("h0"), _GEN_46) @[src/main/scala/weightcontroller.scala 199:28 202:14]
    node _GEN_50 = mux(io_ctrl_soft_reset, UInt<1>("h0"), _GEN_44) @[src/main/scala/weightcontroller.scala 199:28 203:15]
    node is_working = eq(state, UInt<3>("h3")) @[src/main/scala/weightcontroller.scala 207:27]
    node _read_ptr_T = add(read_ptr, UInt<1>("h1")) @[src/main/scala/weightcontroller.scala 214:47]
    node _read_ptr_T_1 = tail(_read_ptr_T, 1) @[src/main/scala/weightcontroller.scala 214:47]
    node _GEN_51 = mux(UInt<1>("h1"), _read_ptr_T_1, _GEN_49) @[src/main/scala/weightcontroller.scala 214:{24,35}]
    node _GEN_52 = mux(is_working, _GEN_51, _GEN_49) @[src/main/scala/weightcontroller.scala 210:20]
    node _T_12 = neq(state, UInt<3>("h0")) @[src/main/scala/weightcontroller.scala 218:14]
    node _T_13 = and(_T_12, io_ctrl_dma_data_valid) @[src/main/scala/weightcontroller.scala 218:34]
    node _T_14 = or(pong_valid, last_write) @[src/main/scala/weightcontroller.scala 218:76]
    node _T_15 = eq(_T_14, UInt<1>("h0")) @[src/main/scala/weightcontroller.scala 218:63]
    node _T_16 = and(_T_13, _T_15) @[src/main/scala/weightcontroller.scala 218:60]
    node _write_ptr_T = add(write_ptr, UInt<1>("h1")) @[src/main/scala/weightcontroller.scala 219:28]
    node _write_ptr_T_1 = tail(_write_ptr_T, 1) @[src/main/scala/weightcontroller.scala 219:28]
    node _T_17 = and(io_ctrl_dma_data_valid, io_ctrl_dma_data_last) @[src/main/scala/weightcontroller.scala 220:37]
    node _GEN_53 = mux(_T_17, UInt<1>("h1"), _GEN_45) @[src/main/scala/weightcontroller.scala 220:63 222:16]
    node _GEN_54 = mux(_T_16, _write_ptr_T_1, _GEN_50) @[src/main/scala/weightcontroller.scala 218:92 219:15]
    node _GEN_55 = mux(_T_16, _GEN_45, _GEN_53) @[src/main/scala/weightcontroller.scala 218:92]
    node _active_bank_cnt_T = sub(UInt<8>("hff"), read_ptr) @[src/main/scala/weightcontroller.scala 227:49]
    node active_bank_cnt = tail(_active_bank_cnt_T, 1) @[src/main/scala/weightcontroller.scala 227:49]
    node _io_ctrl_ready_T = eq(state, UInt<3>("h2")) @[src/main/scala/weightcontroller.scala 230:31]
    node _io_ctrl_ready_T_1 = eq(io_ctrl_enable, UInt<1>("h0")) @[src/main/scala/weightcontroller.scala 230:56]
    node _io_ctrl_ready_T_2 = or(_io_ctrl_ready_T, _io_ctrl_ready_T_1) @[src/main/scala/weightcontroller.scala 230:53]
    node _io_ctrl_hungry_T = eq(state, UInt<3>("h3")) @[src/main/scala/weightcontroller.scala 231:31]
    node _io_ctrl_hungry_T_1 = eq(state, UInt<3>("h1")) @[src/main/scala/weightcontroller.scala 231:63]
    node _io_ctrl_hungry_T_2 = or(_io_ctrl_hungry_T, _io_ctrl_hungry_T_1) @[src/main/scala/weightcontroller.scala 231:54]
    node _io_ctrl_hungry_T_3 = or(pong_valid, last_write) @[src/main/scala/weightcontroller.scala 231:103]
    node _io_ctrl_hungry_T_4 = eq(_io_ctrl_hungry_T_3, UInt<1>("h0")) @[src/main/scala/weightcontroller.scala 231:90]
    node _io_ctrl_hungry_T_5 = and(_io_ctrl_hungry_T_2, _io_ctrl_hungry_T_4) @[src/main/scala/weightcontroller.scala 231:87]
    node _io_ctrl_impending_T = leq(active_bank_cnt, UInt<8>("h8")) @[src/main/scala/weightcontroller.scala 232:55]
    node _io_ctrl_impending_T_1 = and(is_working, _io_ctrl_impending_T) @[src/main/scala/weightcontroller.scala 232:35]
    node _io_ctrl_impending_T_2 = or(pong_valid, last_write) @[src/main/scala/weightcontroller.scala 232:94]
    node _io_ctrl_impending_T_3 = eq(_io_ctrl_impending_T_2, UInt<1>("h0")) @[src/main/scala/weightcontroller.scala 232:81]
    node _io_ctrl_impending_T_4 = and(_io_ctrl_impending_T_1, _io_ctrl_impending_T_3) @[src/main/scala/weightcontroller.scala 232:78]
    node _GEN_56 = mux(io_lut_prog_mode, UInt<1>("h0"), io_rd_data) @[src/main/scala/weightcontroller.scala 243:19 244:24 247:24]
    node _GEN_57 = mux(io_lut_prog_mode, io_rd_data, UInt<1>("h0")) @[src/main/scala/weightcontroller.scala 243:19 245:29 248:29]
    node _io_wr_en_T = eq(pong_valid, UInt<1>("h0")) @[src/main/scala/weightcontroller.scala 253:43]
    node _io_wr_en_T_1 = and(io_ctrl_dma_data_valid, _io_wr_en_T) @[src/main/scala/weightcontroller.scala 253:40]
    io_ctrl_ready <= _io_ctrl_ready_T_2 @[src/main/scala/weightcontroller.scala 230:21]
    io_ctrl_hungry <= _io_ctrl_hungry_T_5 @[src/main/scala/weightcontroller.scala 231:21]
    io_ctrl_impending <= _io_ctrl_impending_T_4 @[src/main/scala/weightcontroller.scala 232:21]
    io_ctrl_working <= is_working @[src/main/scala/weightcontroller.scala 229:21]
    io_rd_addr <= read_ptr @[src/main/scala/weightcontroller.scala 234:18]
    io_rd_en <= is_working @[src/main/scala/weightcontroller.scala 235:18]
    io_active_bank <= active_bank @[src/main/scala/weightcontroller.scala 236:18]
    io_rd_data_to_cu <= _GEN_56
    io_rd_data_to_lut <= _GEN_57
    io_wr_en <= _io_wr_en_T_1 @[src/main/scala/weightcontroller.scala 253:14]
    io_wr_addr <= write_ptr @[src/main/scala/weightcontroller.scala 254:14]
    state <= mux(reset, UInt<3>("h0"), _GEN_47) @[src/main/scala/weightcontroller.scala 147:{22,22}]
    active_bank <= mux(reset, UInt<1>("h0"), _GEN_48) @[src/main/scala/weightcontroller.scala 149:{28,28}]
    read_ptr <= mux(reset, UInt<8>("h0"), _GEN_52) @[src/main/scala/weightcontroller.scala 150:{28,28}]
    write_ptr <= mux(reset, UInt<6>("h0"), _GEN_54) @[src/main/scala/weightcontroller.scala 151:{28,28}]
    compact_cnt <= mux(reset, UInt<4>("h0"), compact_cnt) @[src/main/scala/weightcontroller.scala 152:{28,28,28}]
    pong_valid <= mux(reset, UInt<1>("h0"), _GEN_55) @[src/main/scala/weightcontroller.scala 154:{28,28}]

  module AsymmetricPingPongSRAM : @[src/main/scala/weightcontroller.scala 43:7]
    input clock : Clock @[src/main/scala/weightcontroller.scala 43:7]
    input reset : UInt<1> @[src/main/scala/weightcontroller.scala 43:7]
    input io_ping_wr_en : UInt<1> @[src/main/scala/weightcontroller.scala 59:14]
    input io_ping_wr_addr : UInt<6> @[src/main/scala/weightcontroller.scala 59:14]
    input io_ping_wr_data : UInt<512> @[src/main/scala/weightcontroller.scala 59:14]
    input io_ping_rd_en : UInt<1> @[src/main/scala/weightcontroller.scala 59:14]
    input io_ping_rd_addr : UInt<8> @[src/main/scala/weightcontroller.scala 59:14]
    output io_ping_rd_data : UInt<128> @[src/main/scala/weightcontroller.scala 59:14]
    input io_pong_wr_en : UInt<1> @[src/main/scala/weightcontroller.scala 59:14]
    input io_pong_wr_addr : UInt<6> @[src/main/scala/weightcontroller.scala 59:14]
    input io_pong_wr_data : UInt<512> @[src/main/scala/weightcontroller.scala 59:14]
    input io_pong_rd_en : UInt<1> @[src/main/scala/weightcontroller.scala 59:14]
    input io_pong_rd_addr : UInt<8> @[src/main/scala/weightcontroller.scala 59:14]
    output io_pong_rd_data : UInt<128> @[src/main/scala/weightcontroller.scala 59:14]

    mem io_ping_rd_data_sub_banks_0 : @[src/main/scala/weightcontroller.scala 91:48]
      data-type => UInt<128>
      depth => 64
      read-latency => 1
      write-latency => 1
      reader => io_ping_rd_data_rd_data_vec_0_MPORT
      writer => io_ping_rd_data_MPORT
      read-under-write => undefined
    mem io_ping_rd_data_sub_banks_1 : @[src/main/scala/weightcontroller.scala 91:48]
      data-type => UInt<128>
      depth => 64
      read-latency => 1
      write-latency => 1
      reader => io_ping_rd_data_rd_data_vec_1_MPORT
      writer => io_ping_rd_data_MPORT_1
      read-under-write => undefined
    mem io_ping_rd_data_sub_banks_2 : @[src/main/scala/weightcontroller.scala 91:48]
      data-type => UInt<128>
      depth => 64
      read-latency => 1
      write-latency => 1
      reader => io_ping_rd_data_rd_data_vec_2_MPORT
      writer => io_ping_rd_data_MPORT_2
      read-under-write => undefined
    mem io_ping_rd_data_sub_banks_3 : @[src/main/scala/weightcontroller.scala 91:48]
      data-type => UInt<128>
      depth => 64
      read-latency => 1
      write-latency => 1
      reader => io_ping_rd_data_rd_data_vec_3_MPORT
      writer => io_ping_rd_data_MPORT_3
      read-under-write => undefined
    mem io_pong_rd_data_sub_banks_0 : @[src/main/scala/weightcontroller.scala 91:48]
      data-type => UInt<128>
      depth => 64
      read-latency => 1
      write-latency => 1
      reader => io_pong_rd_data_rd_data_vec_0_MPORT
      writer => io_pong_rd_data_MPORT
      read-under-write => undefined
    mem io_pong_rd_data_sub_banks_1 : @[src/main/scala/weightcontroller.scala 91:48]
      data-type => UInt<128>
      depth => 64
      read-latency => 1
      write-latency => 1
      reader => io_pong_rd_data_rd_data_vec_1_MPORT
      writer => io_pong_rd_data_MPORT_1
      read-under-write => undefined
    mem io_pong_rd_data_sub_banks_2 : @[src/main/scala/weightcontroller.scala 91:48]
      data-type => UInt<128>
      depth => 64
      read-latency => 1
      write-latency => 1
      reader => io_pong_rd_data_rd_data_vec_2_MPORT
      writer => io_pong_rd_data_MPORT_2
      read-under-write => undefined
    mem io_pong_rd_data_sub_banks_3 : @[src/main/scala/weightcontroller.scala 91:48]
      data-type => UInt<128>
      depth => 64
      read-latency => 1
      write-latency => 1
      reader => io_pong_rd_data_rd_data_vec_3_MPORT
      writer => io_pong_rd_data_MPORT_3
      read-under-write => undefined
    node io_ping_rd_data_word_addr = bits(io_ping_rd_addr, 7, 2) @[src/main/scala/weightcontroller.scala 95:28]
    node io_ping_rd_data_bank_sel = bits(io_ping_rd_addr, 1, 0) @[src/main/scala/weightcontroller.scala 98:27]
    node io_ping_rd_data_slice_data = bits(io_ping_wr_data, 127, 0) @[src/main/scala/weightcontroller.scala 102:31]
    node _GEN_0 = validif(io_ping_wr_en, io_ping_wr_addr) @[src/main/scala/weightcontroller.scala 103:19 104:27]
    node _GEN_1 = validif(io_ping_wr_en, clock) @[src/main/scala/weightcontroller.scala 103:19 104:27]
    node _GEN_2 = mux(io_ping_wr_en, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightcontroller.scala 103:19 104:27 91:48]
    node _GEN_3 = validif(io_ping_wr_en, UInt<1>("h1")) @[src/main/scala/weightcontroller.scala 103:19 104:27]
    node _GEN_4 = validif(io_ping_wr_en, io_ping_rd_data_slice_data) @[src/main/scala/weightcontroller.scala 103:19 104:27]
    node _io_ping_rd_data_bankReadEnable_T = eq(io_ping_rd_data_bank_sel, UInt<1>("h0")) @[src/main/scala/weightcontroller.scala 107:46]
    node io_ping_rd_data_bankReadEnable = and(io_ping_rd_en, _io_ping_rd_data_bankReadEnable_T) @[src/main/scala/weightcontroller.scala 107:34]
    node _GEN_5 = validif(io_ping_rd_data_bankReadEnable, io_ping_rd_data_word_addr) @[src/main/scala/weightcontroller.scala 109:{42,42}]
    node _GEN_6 = mux(io_ping_rd_data_bankReadEnable, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightcontroller.scala 109:{42,42} 91:48]
    node _io_ping_rd_data_rd_data_vec_0_WIRE = _GEN_5 @[src/main/scala/weightcontroller.scala 109:42]
    node _GEN_7 = validif(io_ping_rd_data_bankReadEnable, _io_ping_rd_data_rd_data_vec_0_WIRE) @[src/main/scala/weightcontroller.scala 109:{42,42}]
    node _GEN_8 = validif(io_ping_rd_data_bankReadEnable, clock) @[src/main/scala/weightcontroller.scala 109:{42,42}]
    node io_ping_rd_data_slice_data_1 = bits(io_ping_wr_data, 255, 128) @[src/main/scala/weightcontroller.scala 102:31]
    node _GEN_9 = validif(io_ping_wr_en, io_ping_rd_data_slice_data_1) @[src/main/scala/weightcontroller.scala 103:19 104:27]
    node _io_ping_rd_data_bankReadEnable_T_1 = eq(io_ping_rd_data_bank_sel, UInt<1>("h1")) @[src/main/scala/weightcontroller.scala 107:46]
    node io_ping_rd_data_bankReadEnable_1 = and(io_ping_rd_en, _io_ping_rd_data_bankReadEnable_T_1) @[src/main/scala/weightcontroller.scala 107:34]
    node _GEN_10 = validif(io_ping_rd_data_bankReadEnable_1, io_ping_rd_data_word_addr) @[src/main/scala/weightcontroller.scala 109:{42,42}]
    node _GEN_11 = mux(io_ping_rd_data_bankReadEnable_1, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightcontroller.scala 109:{42,42} 91:48]
    node _io_ping_rd_data_rd_data_vec_1_WIRE = _GEN_10 @[src/main/scala/weightcontroller.scala 109:42]
    node _GEN_12 = validif(io_ping_rd_data_bankReadEnable_1, _io_ping_rd_data_rd_data_vec_1_WIRE) @[src/main/scala/weightcontroller.scala 109:{42,42}]
    node _GEN_13 = validif(io_ping_rd_data_bankReadEnable_1, clock) @[src/main/scala/weightcontroller.scala 109:{42,42}]
    node io_ping_rd_data_slice_data_2 = bits(io_ping_wr_data, 383, 256) @[src/main/scala/weightcontroller.scala 102:31]
    node _GEN_14 = validif(io_ping_wr_en, io_ping_rd_data_slice_data_2) @[src/main/scala/weightcontroller.scala 103:19 104:27]
    node _io_ping_rd_data_bankReadEnable_T_2 = eq(io_ping_rd_data_bank_sel, UInt<2>("h2")) @[src/main/scala/weightcontroller.scala 107:46]
    node io_ping_rd_data_bankReadEnable_2 = and(io_ping_rd_en, _io_ping_rd_data_bankReadEnable_T_2) @[src/main/scala/weightcontroller.scala 107:34]
    node _GEN_15 = validif(io_ping_rd_data_bankReadEnable_2, io_ping_rd_data_word_addr) @[src/main/scala/weightcontroller.scala 109:{42,42}]
    node _GEN_16 = mux(io_ping_rd_data_bankReadEnable_2, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightcontroller.scala 109:{42,42} 91:48]
    node _io_ping_rd_data_rd_data_vec_2_WIRE = _GEN_15 @[src/main/scala/weightcontroller.scala 109:42]
    node _GEN_17 = validif(io_ping_rd_data_bankReadEnable_2, _io_ping_rd_data_rd_data_vec_2_WIRE) @[src/main/scala/weightcontroller.scala 109:{42,42}]
    node _GEN_18 = validif(io_ping_rd_data_bankReadEnable_2, clock) @[src/main/scala/weightcontroller.scala 109:{42,42}]
    node io_ping_rd_data_slice_data_3 = bits(io_ping_wr_data, 511, 384) @[src/main/scala/weightcontroller.scala 102:31]
    node _GEN_19 = validif(io_ping_wr_en, io_ping_rd_data_slice_data_3) @[src/main/scala/weightcontroller.scala 103:19 104:27]
    node _io_ping_rd_data_bankReadEnable_T_3 = eq(io_ping_rd_data_bank_sel, UInt<2>("h3")) @[src/main/scala/weightcontroller.scala 107:46]
    node io_ping_rd_data_bankReadEnable_3 = and(io_ping_rd_en, _io_ping_rd_data_bankReadEnable_T_3) @[src/main/scala/weightcontroller.scala 107:34]
    node _GEN_20 = validif(io_ping_rd_data_bankReadEnable_3, io_ping_rd_data_word_addr) @[src/main/scala/weightcontroller.scala 109:{42,42}]
    node _GEN_21 = mux(io_ping_rd_data_bankReadEnable_3, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightcontroller.scala 109:{42,42} 91:48]
    node _io_ping_rd_data_rd_data_vec_3_WIRE = _GEN_20 @[src/main/scala/weightcontroller.scala 109:42]
    node _GEN_22 = validif(io_ping_rd_data_bankReadEnable_3, _io_ping_rd_data_rd_data_vec_3_WIRE) @[src/main/scala/weightcontroller.scala 109:{42,42}]
    node _GEN_23 = validif(io_ping_rd_data_bankReadEnable_3, clock) @[src/main/scala/weightcontroller.scala 109:{42,42}]
    reg io_ping_rd_data_bank_sel_d1 : UInt<2>, clock with :
      reset => (UInt<1>("h0"), io_ping_rd_data_bank_sel_d1) @[src/main/scala/weightcontroller.scala 113:32]
    node _GEN_24 = mux(io_ping_rd_en, io_ping_rd_data_bank_sel, io_ping_rd_data_bank_sel_d1) @[src/main/scala/weightcontroller.scala 113:{32,32,32}]
    node _io_ping_rd_data_T = or(io_ping_rd_data_bank_sel_d1, UInt<2>("h0"))
    node _io_ping_rd_data_T_1 = bits(_io_ping_rd_data_T, 1, 0)
    node io_ping_rd_data_rd_data_vec_0 = io_ping_rd_data_sub_banks_0.io_ping_rd_data_rd_data_vec_0_MPORT.data @[src/main/scala/weightcontroller.scala 109:22 92:27]
    node _GEN_25 = validif(eq(UInt<1>("h0"), _io_ping_rd_data_T_1), io_ping_rd_data_rd_data_vec_0) @[src/main/scala/weightcontroller.scala 120:{19,19}]
    node io_ping_rd_data_rd_data_vec_1 = io_ping_rd_data_sub_banks_1.io_ping_rd_data_rd_data_vec_1_MPORT.data @[src/main/scala/weightcontroller.scala 109:22 92:27]
    node _GEN_26 = mux(eq(UInt<1>("h1"), _io_ping_rd_data_T_1), io_ping_rd_data_rd_data_vec_1, _GEN_25) @[src/main/scala/weightcontroller.scala 120:{19,19}]
    node io_ping_rd_data_rd_data_vec_2 = io_ping_rd_data_sub_banks_2.io_ping_rd_data_rd_data_vec_2_MPORT.data @[src/main/scala/weightcontroller.scala 109:22 92:27]
    node _GEN_27 = mux(eq(UInt<2>("h2"), _io_ping_rd_data_T_1), io_ping_rd_data_rd_data_vec_2, _GEN_26) @[src/main/scala/weightcontroller.scala 120:{19,19}]
    node io_ping_rd_data_rd_data_vec_3 = io_ping_rd_data_sub_banks_3.io_ping_rd_data_rd_data_vec_3_MPORT.data @[src/main/scala/weightcontroller.scala 109:22 92:27]
    node _GEN_28 = mux(eq(UInt<2>("h3"), _io_ping_rd_data_T_1), io_ping_rd_data_rd_data_vec_3, _GEN_27) @[src/main/scala/weightcontroller.scala 120:{19,19}]
    node io_pong_rd_data_word_addr = bits(io_pong_rd_addr, 7, 2) @[src/main/scala/weightcontroller.scala 95:28]
    node io_pong_rd_data_bank_sel = bits(io_pong_rd_addr, 1, 0) @[src/main/scala/weightcontroller.scala 98:27]
    node io_pong_rd_data_slice_data = bits(io_pong_wr_data, 127, 0) @[src/main/scala/weightcontroller.scala 102:31]
    node _GEN_29 = validif(io_pong_wr_en, io_pong_wr_addr) @[src/main/scala/weightcontroller.scala 103:19 104:27]
    node _GEN_30 = validif(io_pong_wr_en, clock) @[src/main/scala/weightcontroller.scala 103:19 104:27]
    node _GEN_31 = mux(io_pong_wr_en, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightcontroller.scala 103:19 104:27 91:48]
    node _GEN_32 = validif(io_pong_wr_en, UInt<1>("h1")) @[src/main/scala/weightcontroller.scala 103:19 104:27]
    node _GEN_33 = validif(io_pong_wr_en, io_pong_rd_data_slice_data) @[src/main/scala/weightcontroller.scala 103:19 104:27]
    node _io_pong_rd_data_bankReadEnable_T = eq(io_pong_rd_data_bank_sel, UInt<1>("h0")) @[src/main/scala/weightcontroller.scala 107:46]
    node io_pong_rd_data_bankReadEnable = and(io_pong_rd_en, _io_pong_rd_data_bankReadEnable_T) @[src/main/scala/weightcontroller.scala 107:34]
    node _GEN_34 = validif(io_pong_rd_data_bankReadEnable, io_pong_rd_data_word_addr) @[src/main/scala/weightcontroller.scala 109:{42,42}]
    node _GEN_35 = mux(io_pong_rd_data_bankReadEnable, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightcontroller.scala 109:{42,42} 91:48]
    node _io_pong_rd_data_rd_data_vec_0_WIRE = _GEN_34 @[src/main/scala/weightcontroller.scala 109:42]
    node _GEN_36 = validif(io_pong_rd_data_bankReadEnable, _io_pong_rd_data_rd_data_vec_0_WIRE) @[src/main/scala/weightcontroller.scala 109:{42,42}]
    node _GEN_37 = validif(io_pong_rd_data_bankReadEnable, clock) @[src/main/scala/weightcontroller.scala 109:{42,42}]
    node io_pong_rd_data_slice_data_1 = bits(io_pong_wr_data, 255, 128) @[src/main/scala/weightcontroller.scala 102:31]
    node _GEN_38 = validif(io_pong_wr_en, io_pong_rd_data_slice_data_1) @[src/main/scala/weightcontroller.scala 103:19 104:27]
    node _io_pong_rd_data_bankReadEnable_T_1 = eq(io_pong_rd_data_bank_sel, UInt<1>("h1")) @[src/main/scala/weightcontroller.scala 107:46]
    node io_pong_rd_data_bankReadEnable_1 = and(io_pong_rd_en, _io_pong_rd_data_bankReadEnable_T_1) @[src/main/scala/weightcontroller.scala 107:34]
    node _GEN_39 = validif(io_pong_rd_data_bankReadEnable_1, io_pong_rd_data_word_addr) @[src/main/scala/weightcontroller.scala 109:{42,42}]
    node _GEN_40 = mux(io_pong_rd_data_bankReadEnable_1, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightcontroller.scala 109:{42,42} 91:48]
    node _io_pong_rd_data_rd_data_vec_1_WIRE = _GEN_39 @[src/main/scala/weightcontroller.scala 109:42]
    node _GEN_41 = validif(io_pong_rd_data_bankReadEnable_1, _io_pong_rd_data_rd_data_vec_1_WIRE) @[src/main/scala/weightcontroller.scala 109:{42,42}]
    node _GEN_42 = validif(io_pong_rd_data_bankReadEnable_1, clock) @[src/main/scala/weightcontroller.scala 109:{42,42}]
    node io_pong_rd_data_slice_data_2 = bits(io_pong_wr_data, 383, 256) @[src/main/scala/weightcontroller.scala 102:31]
    node _GEN_43 = validif(io_pong_wr_en, io_pong_rd_data_slice_data_2) @[src/main/scala/weightcontroller.scala 103:19 104:27]
    node _io_pong_rd_data_bankReadEnable_T_2 = eq(io_pong_rd_data_bank_sel, UInt<2>("h2")) @[src/main/scala/weightcontroller.scala 107:46]
    node io_pong_rd_data_bankReadEnable_2 = and(io_pong_rd_en, _io_pong_rd_data_bankReadEnable_T_2) @[src/main/scala/weightcontroller.scala 107:34]
    node _GEN_44 = validif(io_pong_rd_data_bankReadEnable_2, io_pong_rd_data_word_addr) @[src/main/scala/weightcontroller.scala 109:{42,42}]
    node _GEN_45 = mux(io_pong_rd_data_bankReadEnable_2, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightcontroller.scala 109:{42,42} 91:48]
    node _io_pong_rd_data_rd_data_vec_2_WIRE = _GEN_44 @[src/main/scala/weightcontroller.scala 109:42]
    node _GEN_46 = validif(io_pong_rd_data_bankReadEnable_2, _io_pong_rd_data_rd_data_vec_2_WIRE) @[src/main/scala/weightcontroller.scala 109:{42,42}]
    node _GEN_47 = validif(io_pong_rd_data_bankReadEnable_2, clock) @[src/main/scala/weightcontroller.scala 109:{42,42}]
    node io_pong_rd_data_slice_data_3 = bits(io_pong_wr_data, 511, 384) @[src/main/scala/weightcontroller.scala 102:31]
    node _GEN_48 = validif(io_pong_wr_en, io_pong_rd_data_slice_data_3) @[src/main/scala/weightcontroller.scala 103:19 104:27]
    node _io_pong_rd_data_bankReadEnable_T_3 = eq(io_pong_rd_data_bank_sel, UInt<2>("h3")) @[src/main/scala/weightcontroller.scala 107:46]
    node io_pong_rd_data_bankReadEnable_3 = and(io_pong_rd_en, _io_pong_rd_data_bankReadEnable_T_3) @[src/main/scala/weightcontroller.scala 107:34]
    node _GEN_49 = validif(io_pong_rd_data_bankReadEnable_3, io_pong_rd_data_word_addr) @[src/main/scala/weightcontroller.scala 109:{42,42}]
    node _GEN_50 = mux(io_pong_rd_data_bankReadEnable_3, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/weightcontroller.scala 109:{42,42} 91:48]
    node _io_pong_rd_data_rd_data_vec_3_WIRE = _GEN_49 @[src/main/scala/weightcontroller.scala 109:42]
    node _GEN_51 = validif(io_pong_rd_data_bankReadEnable_3, _io_pong_rd_data_rd_data_vec_3_WIRE) @[src/main/scala/weightcontroller.scala 109:{42,42}]
    node _GEN_52 = validif(io_pong_rd_data_bankReadEnable_3, clock) @[src/main/scala/weightcontroller.scala 109:{42,42}]
    reg io_pong_rd_data_bank_sel_d1 : UInt<2>, clock with :
      reset => (UInt<1>("h0"), io_pong_rd_data_bank_sel_d1) @[src/main/scala/weightcontroller.scala 113:32]
    node _GEN_53 = mux(io_pong_rd_en, io_pong_rd_data_bank_sel, io_pong_rd_data_bank_sel_d1) @[src/main/scala/weightcontroller.scala 113:{32,32,32}]
    node _io_pong_rd_data_T = or(io_pong_rd_data_bank_sel_d1, UInt<2>("h0"))
    node _io_pong_rd_data_T_1 = bits(_io_pong_rd_data_T, 1, 0)
    node io_pong_rd_data_rd_data_vec_0 = io_pong_rd_data_sub_banks_0.io_pong_rd_data_rd_data_vec_0_MPORT.data @[src/main/scala/weightcontroller.scala 109:22 92:27]
    node _GEN_54 = validif(eq(UInt<1>("h0"), _io_pong_rd_data_T_1), io_pong_rd_data_rd_data_vec_0) @[src/main/scala/weightcontroller.scala 121:{19,19}]
    node io_pong_rd_data_rd_data_vec_1 = io_pong_rd_data_sub_banks_1.io_pong_rd_data_rd_data_vec_1_MPORT.data @[src/main/scala/weightcontroller.scala 109:22 92:27]
    node _GEN_55 = mux(eq(UInt<1>("h1"), _io_pong_rd_data_T_1), io_pong_rd_data_rd_data_vec_1, _GEN_54) @[src/main/scala/weightcontroller.scala 121:{19,19}]
    node io_pong_rd_data_rd_data_vec_2 = io_pong_rd_data_sub_banks_2.io_pong_rd_data_rd_data_vec_2_MPORT.data @[src/main/scala/weightcontroller.scala 109:22 92:27]
    node _GEN_56 = mux(eq(UInt<2>("h2"), _io_pong_rd_data_T_1), io_pong_rd_data_rd_data_vec_2, _GEN_55) @[src/main/scala/weightcontroller.scala 121:{19,19}]
    node io_pong_rd_data_rd_data_vec_3 = io_pong_rd_data_sub_banks_3.io_pong_rd_data_rd_data_vec_3_MPORT.data @[src/main/scala/weightcontroller.scala 109:22 92:27]
    node _GEN_57 = mux(eq(UInt<2>("h3"), _io_pong_rd_data_T_1), io_pong_rd_data_rd_data_vec_3, _GEN_56) @[src/main/scala/weightcontroller.scala 121:{19,19}]
    node _io_ping_rd_data_rd_data_vec_io_ping_rd_data_T_1 = _GEN_28 @[src/main/scala/weightcontroller.scala 120:19]
    node _io_pong_rd_data_rd_data_vec_io_pong_rd_data_T_1 = _GEN_57 @[src/main/scala/weightcontroller.scala 121:19]
    io_ping_rd_data <= _io_ping_rd_data_rd_data_vec_io_ping_rd_data_T_1 @[src/main/scala/weightcontroller.scala 120:19]
    io_pong_rd_data <= _io_pong_rd_data_rd_data_vec_io_pong_rd_data_T_1 @[src/main/scala/weightcontroller.scala 121:19]
    io_ping_rd_data_sub_banks_0.io_ping_rd_data_rd_data_vec_0_MPORT.addr <= _GEN_7
    io_ping_rd_data_sub_banks_0.io_ping_rd_data_rd_data_vec_0_MPORT.en <= _GEN_6
    io_ping_rd_data_sub_banks_0.io_ping_rd_data_rd_data_vec_0_MPORT.clk <= _GEN_8
    io_ping_rd_data_sub_banks_0.io_ping_rd_data_MPORT.addr <= _GEN_0
    io_ping_rd_data_sub_banks_0.io_ping_rd_data_MPORT.en <= _GEN_2
    io_ping_rd_data_sub_banks_0.io_ping_rd_data_MPORT.clk <= _GEN_1
    io_ping_rd_data_sub_banks_0.io_ping_rd_data_MPORT.data <= _GEN_4
    io_ping_rd_data_sub_banks_0.io_ping_rd_data_MPORT.mask <= _GEN_3
    io_ping_rd_data_sub_banks_1.io_ping_rd_data_rd_data_vec_1_MPORT.addr <= _GEN_12
    io_ping_rd_data_sub_banks_1.io_ping_rd_data_rd_data_vec_1_MPORT.en <= _GEN_11
    io_ping_rd_data_sub_banks_1.io_ping_rd_data_rd_data_vec_1_MPORT.clk <= _GEN_13
    io_ping_rd_data_sub_banks_1.io_ping_rd_data_MPORT_1.addr <= _GEN_0
    io_ping_rd_data_sub_banks_1.io_ping_rd_data_MPORT_1.en <= _GEN_2
    io_ping_rd_data_sub_banks_1.io_ping_rd_data_MPORT_1.clk <= _GEN_1
    io_ping_rd_data_sub_banks_1.io_ping_rd_data_MPORT_1.data <= _GEN_9
    io_ping_rd_data_sub_banks_1.io_ping_rd_data_MPORT_1.mask <= _GEN_3
    io_ping_rd_data_sub_banks_2.io_ping_rd_data_rd_data_vec_2_MPORT.addr <= _GEN_17
    io_ping_rd_data_sub_banks_2.io_ping_rd_data_rd_data_vec_2_MPORT.en <= _GEN_16
    io_ping_rd_data_sub_banks_2.io_ping_rd_data_rd_data_vec_2_MPORT.clk <= _GEN_18
    io_ping_rd_data_sub_banks_2.io_ping_rd_data_MPORT_2.addr <= _GEN_0
    io_ping_rd_data_sub_banks_2.io_ping_rd_data_MPORT_2.en <= _GEN_2
    io_ping_rd_data_sub_banks_2.io_ping_rd_data_MPORT_2.clk <= _GEN_1
    io_ping_rd_data_sub_banks_2.io_ping_rd_data_MPORT_2.data <= _GEN_14
    io_ping_rd_data_sub_banks_2.io_ping_rd_data_MPORT_2.mask <= _GEN_3
    io_ping_rd_data_sub_banks_3.io_ping_rd_data_rd_data_vec_3_MPORT.addr <= _GEN_22
    io_ping_rd_data_sub_banks_3.io_ping_rd_data_rd_data_vec_3_MPORT.en <= _GEN_21
    io_ping_rd_data_sub_banks_3.io_ping_rd_data_rd_data_vec_3_MPORT.clk <= _GEN_23
    io_ping_rd_data_sub_banks_3.io_ping_rd_data_MPORT_3.addr <= _GEN_0
    io_ping_rd_data_sub_banks_3.io_ping_rd_data_MPORT_3.en <= _GEN_2
    io_ping_rd_data_sub_banks_3.io_ping_rd_data_MPORT_3.clk <= _GEN_1
    io_ping_rd_data_sub_banks_3.io_ping_rd_data_MPORT_3.data <= _GEN_19
    io_ping_rd_data_sub_banks_3.io_ping_rd_data_MPORT_3.mask <= _GEN_3
    io_ping_rd_data_bank_sel_d1 <= mux(reset, UInt<1>("h0"), _GEN_24) @[src/main/scala/weightcontroller.scala 113:{32,32}]
    io_pong_rd_data_sub_banks_0.io_pong_rd_data_rd_data_vec_0_MPORT.addr <= _GEN_36
    io_pong_rd_data_sub_banks_0.io_pong_rd_data_rd_data_vec_0_MPORT.en <= _GEN_35
    io_pong_rd_data_sub_banks_0.io_pong_rd_data_rd_data_vec_0_MPORT.clk <= _GEN_37
    io_pong_rd_data_sub_banks_0.io_pong_rd_data_MPORT.addr <= _GEN_29
    io_pong_rd_data_sub_banks_0.io_pong_rd_data_MPORT.en <= _GEN_31
    io_pong_rd_data_sub_banks_0.io_pong_rd_data_MPORT.clk <= _GEN_30
    io_pong_rd_data_sub_banks_0.io_pong_rd_data_MPORT.data <= _GEN_33
    io_pong_rd_data_sub_banks_0.io_pong_rd_data_MPORT.mask <= _GEN_32
    io_pong_rd_data_sub_banks_1.io_pong_rd_data_rd_data_vec_1_MPORT.addr <= _GEN_41
    io_pong_rd_data_sub_banks_1.io_pong_rd_data_rd_data_vec_1_MPORT.en <= _GEN_40
    io_pong_rd_data_sub_banks_1.io_pong_rd_data_rd_data_vec_1_MPORT.clk <= _GEN_42
    io_pong_rd_data_sub_banks_1.io_pong_rd_data_MPORT_1.addr <= _GEN_29
    io_pong_rd_data_sub_banks_1.io_pong_rd_data_MPORT_1.en <= _GEN_31
    io_pong_rd_data_sub_banks_1.io_pong_rd_data_MPORT_1.clk <= _GEN_30
    io_pong_rd_data_sub_banks_1.io_pong_rd_data_MPORT_1.data <= _GEN_38
    io_pong_rd_data_sub_banks_1.io_pong_rd_data_MPORT_1.mask <= _GEN_32
    io_pong_rd_data_sub_banks_2.io_pong_rd_data_rd_data_vec_2_MPORT.addr <= _GEN_46
    io_pong_rd_data_sub_banks_2.io_pong_rd_data_rd_data_vec_2_MPORT.en <= _GEN_45
    io_pong_rd_data_sub_banks_2.io_pong_rd_data_rd_data_vec_2_MPORT.clk <= _GEN_47
    io_pong_rd_data_sub_banks_2.io_pong_rd_data_MPORT_2.addr <= _GEN_29
    io_pong_rd_data_sub_banks_2.io_pong_rd_data_MPORT_2.en <= _GEN_31
    io_pong_rd_data_sub_banks_2.io_pong_rd_data_MPORT_2.clk <= _GEN_30
    io_pong_rd_data_sub_banks_2.io_pong_rd_data_MPORT_2.data <= _GEN_43
    io_pong_rd_data_sub_banks_2.io_pong_rd_data_MPORT_2.mask <= _GEN_32
    io_pong_rd_data_sub_banks_3.io_pong_rd_data_rd_data_vec_3_MPORT.addr <= _GEN_51
    io_pong_rd_data_sub_banks_3.io_pong_rd_data_rd_data_vec_3_MPORT.en <= _GEN_50
    io_pong_rd_data_sub_banks_3.io_pong_rd_data_rd_data_vec_3_MPORT.clk <= _GEN_52
    io_pong_rd_data_sub_banks_3.io_pong_rd_data_MPORT_3.addr <= _GEN_29
    io_pong_rd_data_sub_banks_3.io_pong_rd_data_MPORT_3.en <= _GEN_31
    io_pong_rd_data_sub_banks_3.io_pong_rd_data_MPORT_3.clk <= _GEN_30
    io_pong_rd_data_sub_banks_3.io_pong_rd_data_MPORT_3.data <= _GEN_48
    io_pong_rd_data_sub_banks_3.io_pong_rd_data_MPORT_3.mask <= _GEN_32
    io_pong_rd_data_bank_sel_d1 <= mux(reset, UInt<1>("h0"), _GEN_53) @[src/main/scala/weightcontroller.scala 113:{32,32}]

  module WbControllerWithSram : @[src/main/scala/wbcontrollersystem.scala 7:7]
    input clock : Clock @[src/main/scala/wbcontrollersystem.scala 7:7]
    input reset : UInt<1> @[src/main/scala/wbcontrollersystem.scala 7:7]
    input io_soft_reset : UInt<1> @[src/main/scala/wbcontrollersystem.scala 8:14]
    input io_enable : UInt<1> @[src/main/scala/wbcontrollersystem.scala 8:14]
    input io_shoot : UInt<1> @[src/main/scala/wbcontrollersystem.scala 8:14]
    input io_lut_prog_mode : UInt<1> @[src/main/scala/wbcontrollersystem.scala 8:14]
    input io_dma_data : UInt<512> @[src/main/scala/wbcontrollersystem.scala 8:14]
    input io_dma_data_valid : UInt<1> @[src/main/scala/wbcontrollersystem.scala 8:14]
    input io_dma_data_last : UInt<1> @[src/main/scala/wbcontrollersystem.scala 8:14]
    input io_dma_write_ready : UInt<1> @[src/main/scala/wbcontrollersystem.scala 8:14]
    output io_ready : UInt<1> @[src/main/scala/wbcontrollersystem.scala 8:14]
    output io_hungry : UInt<1> @[src/main/scala/wbcontrollersystem.scala 8:14]
    output io_impending : UInt<1> @[src/main/scala/wbcontrollersystem.scala 8:14]
    output io_working : UInt<1> @[src/main/scala/wbcontrollersystem.scala 8:14]
    output io_rd_data_to_cu : UInt<128> @[src/main/scala/wbcontrollersystem.scala 8:14]
    output io_rd_data_to_lut : UInt<128> @[src/main/scala/wbcontrollersystem.scala 8:14]
    output io_rd_data_valid : UInt<1> @[src/main/scala/wbcontrollersystem.scala 8:14]

    inst controller of UbWbController @[src/main/scala/wbcontrollersystem.scala 29:26]
    inst sram of AsymmetricPingPongSRAM @[src/main/scala/wbcontrollersystem.scala 30:20]
    node readPing = eq(controller.io_active_bank, UInt<1>("h0")) @[src/main/scala/wbcontrollersystem.scala 40:45]
    node writePing = eq(readPing, UInt<1>("h0")) @[src/main/scala/wbcontrollersystem.scala 41:19]
    node _sram_io_ping_wr_en_T = and(controller.io_wr_en, writePing) @[src/main/scala/wbcontrollersystem.scala 44:47]
    node _sram_io_pong_wr_en_T = eq(writePing, UInt<1>("h0")) @[src/main/scala/wbcontrollersystem.scala 45:50]
    node _sram_io_pong_wr_en_T_1 = and(controller.io_wr_en, _sram_io_pong_wr_en_T) @[src/main/scala/wbcontrollersystem.scala 45:47]
    node _sram_io_ping_rd_en_T = and(controller.io_rd_en, readPing) @[src/main/scala/wbcontrollersystem.scala 52:47]
    node _sram_io_pong_rd_en_T = eq(readPing, UInt<1>("h0")) @[src/main/scala/wbcontrollersystem.scala 53:50]
    node _sram_io_pong_rd_en_T_1 = and(controller.io_rd_en, _sram_io_pong_rd_en_T) @[src/main/scala/wbcontrollersystem.scala 53:47]
    reg readPingD1 : UInt<1>, clock with :
      reset => (UInt<1>("h0"), readPingD1) @[src/main/scala/wbcontrollersystem.scala 58:29]
    node _GEN_0 = mux(controller.io_rd_en, readPing, readPingD1) @[src/main/scala/wbcontrollersystem.scala 58:{29,29,29}]
    node _controller_io_rd_data_T = mux(readPingD1, sram.io_ping_rd_data, sram.io_pong_rd_data) @[src/main/scala/wbcontrollersystem.scala 59:31]
    reg io_rd_data_valid_REG : UInt<1>, clock with :
      reset => (UInt<1>("h0"), io_rd_data_valid_REG) @[src/main/scala/wbcontrollersystem.scala 71:31]
    io_ready <= controller.io_ctrl_ready @[src/main/scala/wbcontrollersystem.scala 65:21]
    io_hungry <= controller.io_ctrl_hungry @[src/main/scala/wbcontrollersystem.scala 66:21]
    io_impending <= controller.io_ctrl_impending @[src/main/scala/wbcontrollersystem.scala 67:21]
    io_working <= controller.io_ctrl_working @[src/main/scala/wbcontrollersystem.scala 68:21]
    io_rd_data_to_cu <= controller.io_rd_data_to_cu @[src/main/scala/wbcontrollersystem.scala 69:21]
    io_rd_data_to_lut <= controller.io_rd_data_to_lut @[src/main/scala/wbcontrollersystem.scala 70:21]
    io_rd_data_valid <= io_rd_data_valid_REG @[src/main/scala/wbcontrollersystem.scala 71:21]
    controller.clock <= clock
    controller.reset <= reset
    controller.io_ctrl_soft_reset <= io_soft_reset @[src/main/scala/wbcontrollersystem.scala 32:38]
    controller.io_ctrl_enable <= io_enable @[src/main/scala/wbcontrollersystem.scala 33:38]
    controller.io_ctrl_shoot <= io_shoot @[src/main/scala/wbcontrollersystem.scala 34:38]
    controller.io_ctrl_dma_data_valid <= io_dma_data_valid @[src/main/scala/wbcontrollersystem.scala 35:38]
    controller.io_ctrl_dma_data_last <= io_dma_data_last @[src/main/scala/wbcontrollersystem.scala 36:38]
    controller.io_ctrl_dma_write_ready <= io_dma_write_ready @[src/main/scala/wbcontrollersystem.scala 37:38]
    controller.io_lut_prog_mode <= io_lut_prog_mode @[src/main/scala/wbcontrollersystem.scala 38:38]
    controller.io_rd_data <= _controller_io_rd_data_T @[src/main/scala/wbcontrollersystem.scala 59:25]
    sram.clock <= clock
    sram.reset <= reset
    sram.io_ping_wr_en <= _sram_io_ping_wr_en_T @[src/main/scala/wbcontrollersystem.scala 44:24]
    sram.io_ping_wr_addr <= controller.io_wr_addr @[src/main/scala/wbcontrollersystem.scala 46:24]
    sram.io_ping_wr_data <= io_dma_data @[src/main/scala/wbcontrollersystem.scala 48:24]
    sram.io_ping_rd_en <= _sram_io_ping_rd_en_T @[src/main/scala/wbcontrollersystem.scala 52:24]
    sram.io_ping_rd_addr <= controller.io_rd_addr @[src/main/scala/wbcontrollersystem.scala 54:24]
    sram.io_pong_wr_en <= _sram_io_pong_wr_en_T_1 @[src/main/scala/wbcontrollersystem.scala 45:24]
    sram.io_pong_wr_addr <= controller.io_wr_addr @[src/main/scala/wbcontrollersystem.scala 47:24]
    sram.io_pong_wr_data <= io_dma_data @[src/main/scala/wbcontrollersystem.scala 49:24]
    sram.io_pong_rd_en <= _sram_io_pong_rd_en_T_1 @[src/main/scala/wbcontrollersystem.scala 53:24]
    sram.io_pong_rd_addr <= controller.io_rd_addr @[src/main/scala/wbcontrollersystem.scala 55:24]
    readPingD1 <= mux(reset, UInt<1>("h1"), _GEN_0) @[src/main/scala/wbcontrollersystem.scala 58:{29,29}]
    io_rd_data_valid_REG <= mux(reset, UInt<1>("h0"), controller.io_rd_en) @[src/main/scala/wbcontrollersystem.scala 71:{31,31,31}]
