FIRRTL version 1.2.0
circuit VbControllerWithSram :
  module VbController : @[src/main/scala/OCM.scala 300:7]
    input clock : Clock @[src/main/scala/OCM.scala 300:7]
    input reset : UInt<1> @[src/main/scala/OCM.scala 300:7]
    input io_ctrl_soft_reset : UInt<1> @[src/main/scala/OCM.scala 301:14]
    input io_ctrl_enable : UInt<1> @[src/main/scala/OCM.scala 301:14]
    output io_ctrl_working : UInt<1> @[src/main/scala/OCM.scala 301:14]
    input io_fusion_req_in : UInt<1> @[src/main/scala/OCM.scala 301:14]
    output io_rd_addr : UInt<8> @[src/main/scala/OCM.scala 301:14]
    output io_rd_en : UInt<1> @[src/main/scala/OCM.scala 301:14]
    output io_wr_en : UInt<1> @[src/main/scala/OCM.scala 301:14]
    output io_wr_addr : UInt<8> @[src/main/scala/OCM.scala 301:14]
    input io_wr_valid : UInt<1> @[src/main/scala/OCM.scala 301:14]
    input io_last_write : UInt<1> @[src/main/scala/OCM.scala 301:14]

    reg state : UInt<3>, clock with :
      reset => (UInt<1>("h0"), state) @[src/main/scala/OCM.scala 314:28]
    reg read_ptr : UInt<8>, clock with :
      reset => (UInt<1>("h0"), read_ptr) @[src/main/scala/OCM.scala 315:28]
    reg write_ptr : UInt<8>, clock with :
      reset => (UInt<1>("h0"), write_ptr) @[src/main/scala/OCM.scala 316:27]
    reg last_write_ptr : UInt<8>, clock with :
      reset => (UInt<1>("h0"), last_write_ptr) @[src/main/scala/OCM.scala 317:31]
    node is_working = eq(state, UInt<3>("h3")) @[src/main/scala/OCM.scala 319:27]
    node _T = eq(UInt<3>("h0"), state) @[src/main/scala/OCM.scala 321:17]
    node _T_1 = eq(io_ctrl_soft_reset, UInt<1>("h0")) @[src/main/scala/OCM.scala 322:53]
    node _T_2 = and(io_ctrl_enable, _T_1) @[src/main/scala/OCM.scala 322:50]
    node _GEN_0 = mux(_T_2, UInt<3>("h3"), state) @[src/main/scala/OCM.scala 314:28 322:{74,82}]
    node _T_3 = eq(UInt<3>("h3"), state) @[src/main/scala/OCM.scala 321:17]
    node _write_ptr_T = add(write_ptr, UInt<1>("h1")) @[src/main/scala/OCM.scala 327:32]
    node _write_ptr_T_1 = tail(_write_ptr_T, 1) @[src/main/scala/OCM.scala 327:32]
    node _GEN_1 = mux(io_last_write, UInt<1>("h0"), _write_ptr_T_1) @[src/main/scala/OCM.scala 327:19 328:29 329:21]
    node _GEN_2 = mux(io_wr_valid, write_ptr, last_write_ptr) @[src/main/scala/OCM.scala 324:25 326:24 317:31]
    node _GEN_3 = mux(io_wr_valid, _GEN_1, write_ptr) @[src/main/scala/OCM.scala 324:25 316:27]
    node _read_ptr_T = add(read_ptr, UInt<1>("h1")) @[src/main/scala/OCM.scala 333:30]
    node _read_ptr_T_1 = tail(_read_ptr_T, 1) @[src/main/scala/OCM.scala 333:30]
    node _T_4 = eq(read_ptr, last_write_ptr) @[src/main/scala/OCM.scala 334:23]
    node _GEN_4 = mux(_T_4, UInt<1>("h0"), _read_ptr_T_1) @[src/main/scala/OCM.scala 333:18 334:43 335:20]
    node _GEN_5 = mux(io_fusion_req_in, _GEN_4, read_ptr) @[src/main/scala/OCM.scala 315:28 332:30]
    node _GEN_6 = mux(_T_3, _GEN_2, last_write_ptr) @[src/main/scala/OCM.scala 321:17 317:31]
    node _GEN_7 = mux(_T_3, _GEN_3, write_ptr) @[src/main/scala/OCM.scala 321:17 316:27]
    node _GEN_8 = mux(_T_3, _GEN_5, read_ptr) @[src/main/scala/OCM.scala 321:17 315:28]
    node _GEN_9 = mux(_T, _GEN_0, state) @[src/main/scala/OCM.scala 321:17 314:28]
    node _GEN_10 = mux(_T, last_write_ptr, _GEN_6) @[src/main/scala/OCM.scala 321:17 317:31]
    node _GEN_11 = mux(_T, write_ptr, _GEN_7) @[src/main/scala/OCM.scala 321:17 316:27]
    node _GEN_12 = mux(_T, read_ptr, _GEN_8) @[src/main/scala/OCM.scala 321:17 315:28]
    node _T_5 = eq(io_ctrl_enable, UInt<1>("h0")) @[src/main/scala/OCM.scala 340:30]
    node _T_6 = or(io_ctrl_soft_reset, _T_5) @[src/main/scala/OCM.scala 340:27]
    node _GEN_13 = mux(_T_6, UInt<3>("h0"), _GEN_9) @[src/main/scala/OCM.scala 340:{47,55}]
    node _GEN_14 = mux(_T_6, UInt<1>("h0"), _GEN_12) @[src/main/scala/OCM.scala 340:{47,84}]
    node _GEN_15 = mux(_T_6, UInt<1>("h0"), _GEN_11) @[src/main/scala/OCM.scala 340:{102,47}]
    node _GEN_16 = mux(_T_6, UInt<1>("h0"), _GEN_10) @[src/main/scala/OCM.scala 340:{125,47}]
    node _io_rd_en_T = and(is_working, io_fusion_req_in) @[src/main/scala/OCM.scala 346:32]
    node _io_wr_en_T = eq(state, UInt<3>("h3")) @[src/main/scala/OCM.scala 348:42]
    node _io_wr_en_T_1 = and(io_wr_valid, _io_wr_en_T) @[src/main/scala/OCM.scala 348:33]
    io_ctrl_working <= is_working @[src/main/scala/OCM.scala 342:21]
    io_rd_addr <= read_ptr @[src/main/scala/OCM.scala 344:18]
    io_rd_en <= _io_rd_en_T @[src/main/scala/OCM.scala 346:18]
    io_wr_en <= _io_wr_en_T_1 @[src/main/scala/OCM.scala 348:18]
    io_wr_addr <= write_ptr @[src/main/scala/OCM.scala 349:18]
    state <= mux(reset, UInt<3>("h0"), _GEN_13) @[src/main/scala/OCM.scala 314:{28,28}]
    read_ptr <= mux(reset, UInt<8>("h0"), _GEN_14) @[src/main/scala/OCM.scala 315:{28,28}]
    write_ptr <= mux(reset, UInt<8>("h0"), _GEN_15) @[src/main/scala/OCM.scala 316:{27,27}]
    last_write_ptr <= mux(reset, UInt<8>("h0"), _GEN_16) @[src/main/scala/OCM.scala 317:{31,31}]

  module VbSram : @[src/main/scala/OCM.scala 127:7]
    input clock : Clock @[src/main/scala/OCM.scala 127:7]
    input reset : UInt<1> @[src/main/scala/OCM.scala 127:7]
    input io_wr_en : UInt<1> @[src/main/scala/OCM.scala 128:14]
    input io_wr_addr : UInt<8> @[src/main/scala/OCM.scala 128:14]
    input io_wr_data : UInt<128> @[src/main/scala/OCM.scala 128:14]
    input io_rd_en : UInt<1> @[src/main/scala/OCM.scala 128:14]
    input io_rd_addr : UInt<8> @[src/main/scala/OCM.scala 128:14]
    output io_rd_data : UInt<128> @[src/main/scala/OCM.scala 128:14]
    output io_rd_valid : UInt<1> @[src/main/scala/OCM.scala 128:14]

    mem vb_lane0 : @[src/main/scala/OCM.scala 141:16]
      data-type => UInt<64>
      depth => 256
      read-latency => 1
      write-latency => 1
      reader => lane0Read
      writer => MPORT
      read-under-write => undefined
    mem vb_lane1 : @[src/main/scala/OCM.scala 141:16]
      data-type => UInt<64>
      depth => 256
      read-latency => 1
      write-latency => 1
      reader => lane1Read
      writer => MPORT_1
      read-under-write => undefined
    node _T = bits(io_wr_data, 63, 0) @[src/main/scala/OCM.scala 145:42]
    node _T_1 = bits(io_wr_data, 127, 64) @[src/main/scala/OCM.scala 146:42]
    node _GEN_0 = validif(io_wr_en, io_wr_addr) @[src/main/scala/OCM.scala 144:18 145:19]
    node _GEN_1 = validif(io_wr_en, clock) @[src/main/scala/OCM.scala 144:18 145:19]
    node _GEN_2 = mux(io_wr_en, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/OCM.scala 141:16 144:18 145:19]
    node _GEN_3 = validif(io_wr_en, UInt<1>("h1")) @[src/main/scala/OCM.scala 144:18 145:19]
    node _GEN_4 = validif(io_wr_en, _T) @[src/main/scala/OCM.scala 144:18 145:19]
    node _GEN_5 = validif(io_wr_en, _T_1) @[src/main/scala/OCM.scala 144:18 146:19]
    node _GEN_6 = validif(io_rd_en, io_rd_addr) @[src/main/scala/OCM.scala 149:{32,32}]
    node _GEN_7 = mux(io_rd_en, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/OCM.scala 141:16 149:{32,32}]
    node _lane0Read_WIRE = _GEN_6 @[src/main/scala/OCM.scala 149:32]
    node _GEN_8 = validif(io_rd_en, _lane0Read_WIRE) @[src/main/scala/OCM.scala 149:{32,32}]
    node _GEN_9 = validif(io_rd_en, clock) @[src/main/scala/OCM.scala 149:{32,32}]
    node _lane1Read_WIRE = _GEN_6 @[src/main/scala/OCM.scala 150:32]
    node _GEN_10 = validif(io_rd_en, _lane1Read_WIRE) @[src/main/scala/OCM.scala 150:{32,32}]
    node _io_rd_data_T = cat(vb_lane1.lane1Read.data, vb_lane0.lane0Read.data) @[src/main/scala/OCM.scala 152:21]
    reg io_rd_valid_REG : UInt<1>, clock with :
      reset => (UInt<1>("h0"), io_rd_valid_REG) @[src/main/scala/OCM.scala 153:25]
    io_rd_data <= _io_rd_data_T @[src/main/scala/OCM.scala 152:15]
    io_rd_valid <= io_rd_valid_REG @[src/main/scala/OCM.scala 153:15]
    vb_lane0.lane0Read.addr <= _GEN_8
    vb_lane0.lane0Read.en <= _GEN_7
    vb_lane0.lane0Read.clk <= _GEN_9
    vb_lane0.MPORT.addr <= _GEN_0
    vb_lane0.MPORT.en <= _GEN_2
    vb_lane0.MPORT.clk <= _GEN_1
    vb_lane0.MPORT.data <= _GEN_4
    vb_lane0.MPORT.mask <= _GEN_3
    vb_lane1.lane1Read.addr <= _GEN_10
    vb_lane1.lane1Read.en <= _GEN_7
    vb_lane1.lane1Read.clk <= _GEN_9
    vb_lane1.MPORT_1.addr <= _GEN_0
    vb_lane1.MPORT_1.en <= _GEN_2
    vb_lane1.MPORT_1.clk <= _GEN_1
    vb_lane1.MPORT_1.data <= _GEN_5
    vb_lane1.MPORT_1.mask <= _GEN_3
    io_rd_valid_REG <= mux(reset, UInt<1>("h0"), io_rd_en) @[src/main/scala/OCM.scala 153:{25,25,25}]

  module VbControllerWithSram : @[src/main/scala/vb.scala 7:7]
    input clock : Clock @[src/main/scala/vb.scala 7:7]
    input reset : UInt<1> @[src/main/scala/vb.scala 7:7]
    input io_ctrl_soft_reset : UInt<1> @[src/main/scala/vb.scala 8:14]
    input io_ctrl_enable : UInt<1> @[src/main/scala/vb.scala 8:14]
    output io_ctrl_working : UInt<1> @[src/main/scala/vb.scala 8:14]
    input io_fusion_req_in : UInt<1> @[src/main/scala/vb.scala 8:14]
    input io_wr_valid : UInt<1> @[src/main/scala/vb.scala 8:14]
    input io_last_write : UInt<1> @[src/main/scala/vb.scala 8:14]
    input io_wr_data : UInt<128> @[src/main/scala/vb.scala 8:14]
    output io_rd_data : UInt<128> @[src/main/scala/vb.scala 8:14]
    output io_rd_valid : UInt<1> @[src/main/scala/vb.scala 8:14]

    inst controller of VbController @[src/main/scala/vb.scala 20:26]
    inst sram of VbSram @[src/main/scala/vb.scala 21:20]
    io_ctrl_working <= controller.io_ctrl_working @[src/main/scala/vb.scala 35:21]
    io_rd_data <= sram.io_rd_data @[src/main/scala/vb.scala 36:21]
    io_rd_valid <= sram.io_rd_valid @[src/main/scala/vb.scala 37:21]
    controller.clock <= clock
    controller.reset <= reset
    controller.io_ctrl_soft_reset <= io_ctrl_soft_reset @[src/main/scala/vb.scala 23:38]
    controller.io_ctrl_enable <= io_ctrl_enable @[src/main/scala/vb.scala 24:38]
    controller.io_fusion_req_in <= io_fusion_req_in @[src/main/scala/vb.scala 25:38]
    controller.io_wr_valid <= io_wr_valid @[src/main/scala/vb.scala 26:38]
    controller.io_last_write <= io_last_write @[src/main/scala/vb.scala 27:38]
    sram.clock <= clock
    sram.reset <= reset
    sram.io_wr_en <= controller.io_wr_en @[src/main/scala/vb.scala 29:19]
    sram.io_wr_addr <= controller.io_wr_addr @[src/main/scala/vb.scala 30:19]
    sram.io_wr_data <= io_wr_data @[src/main/scala/vb.scala 31:19]
    sram.io_rd_en <= controller.io_rd_en @[src/main/scala/vb.scala 32:19]
    sram.io_rd_addr <= controller.io_rd_addr @[src/main/scala/vb.scala 33:19]
