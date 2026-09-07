FIRRTL version 1.2.0
circuit VbControllerWithSram :
  module VbController : @[src/main/scala/OCM.scala 304:7]
    input clock : Clock @[src/main/scala/OCM.scala 304:7]
    input reset : UInt<1> @[src/main/scala/OCM.scala 304:7]
    input io_ctrl_soft_reset : UInt<1> @[src/main/scala/OCM.scala 305:14]
    input io_ctrl_enable : UInt<1> @[src/main/scala/OCM.scala 305:14]
    output io_ctrl_working : UInt<1> @[src/main/scala/OCM.scala 305:14]
    input io_fusion_req_in : UInt<1> @[src/main/scala/OCM.scala 305:14]
    output io_rd_addr : UInt<8> @[src/main/scala/OCM.scala 305:14]
    output io_rd_en : UInt<1> @[src/main/scala/OCM.scala 305:14]
    output io_wr_en : UInt<1> @[src/main/scala/OCM.scala 305:14]
    output io_wr_addr : UInt<8> @[src/main/scala/OCM.scala 305:14]
    input io_wr_valid : UInt<1> @[src/main/scala/OCM.scala 305:14]
    input io_last_write : UInt<1> @[src/main/scala/OCM.scala 305:14]

    reg state : UInt<3>, clock with :
      reset => (UInt<1>("h0"), state) @[src/main/scala/OCM.scala 318:22]
    reg readPtr : UInt<8>, clock with :
      reset => (UInt<1>("h0"), readPtr) @[src/main/scala/OCM.scala 319:24]
    reg writePtr : UInt<8>, clock with :
      reset => (UInt<1>("h0"), writePtr) @[src/main/scala/OCM.scala 320:25]
    reg lastWritePtr : UInt<8>, clock with :
      reset => (UInt<1>("h0"), lastWritePtr) @[src/main/scala/OCM.scala 321:29]
    node isWorking = eq(state, UInt<3>("h3")) @[src/main/scala/OCM.scala 323:25]
    node _T = eq(UInt<3>("h0"), state) @[src/main/scala/OCM.scala 325:17]
    node _T_1 = eq(io_ctrl_soft_reset, UInt<1>("h0")) @[src/main/scala/OCM.scala 327:30]
    node _T_2 = and(io_ctrl_enable, _T_1) @[src/main/scala/OCM.scala 327:27]
    node _GEN_0 = mux(_T_2, UInt<3>("h3"), state) @[src/main/scala/OCM.scala 327:51 328:15 318:22]
    node _T_3 = eq(UInt<3>("h3"), state) @[src/main/scala/OCM.scala 325:17]
    node _writePtr_T = add(writePtr, UInt<1>("h1")) @[src/main/scala/OCM.scala 334:30]
    node _writePtr_T_1 = tail(_writePtr_T, 1) @[src/main/scala/OCM.scala 334:30]
    node _GEN_1 = mux(io_last_write, UInt<1>("h0"), _writePtr_T_1) @[src/main/scala/OCM.scala 334:18 335:29 336:20]
    node _GEN_2 = mux(io_wr_valid, writePtr, lastWritePtr) @[src/main/scala/OCM.scala 332:25 333:22 321:29]
    node _GEN_3 = mux(io_wr_valid, _GEN_1, writePtr) @[src/main/scala/OCM.scala 320:25 332:25]
    node _readPtr_T = add(readPtr, UInt<1>("h1")) @[src/main/scala/OCM.scala 340:28]
    node _readPtr_T_1 = tail(_readPtr_T, 1) @[src/main/scala/OCM.scala 340:28]
    node _T_4 = eq(readPtr, lastWritePtr) @[src/main/scala/OCM.scala 341:22]
    node _GEN_4 = mux(_T_4, UInt<1>("h0"), _readPtr_T_1) @[src/main/scala/OCM.scala 340:17 341:40 342:19]
    node _GEN_5 = mux(io_fusion_req_in, _GEN_4, readPtr) @[src/main/scala/OCM.scala 319:24 339:30]
    node _GEN_6 = mux(_T_3, _GEN_2, lastWritePtr) @[src/main/scala/OCM.scala 325:17 321:29]
    node _GEN_7 = mux(_T_3, _GEN_3, writePtr) @[src/main/scala/OCM.scala 325:17 320:25]
    node _GEN_8 = mux(_T_3, _GEN_5, readPtr) @[src/main/scala/OCM.scala 325:17 319:24]
    node _GEN_9 = mux(_T, _GEN_0, state) @[src/main/scala/OCM.scala 325:17 318:22]
    node _GEN_10 = mux(_T, lastWritePtr, _GEN_6) @[src/main/scala/OCM.scala 325:17 321:29]
    node _GEN_11 = mux(_T, writePtr, _GEN_7) @[src/main/scala/OCM.scala 325:17 320:25]
    node _GEN_12 = mux(_T, readPtr, _GEN_8) @[src/main/scala/OCM.scala 325:17 319:24]
    node _T_5 = eq(io_ctrl_enable, UInt<1>("h0")) @[src/main/scala/OCM.scala 348:30]
    node _T_6 = or(io_ctrl_soft_reset, _T_5) @[src/main/scala/OCM.scala 348:27]
    node _GEN_13 = mux(_T_6, UInt<3>("h0"), _GEN_9) @[src/main/scala/OCM.scala 348:47 349:11]
    node _GEN_14 = mux(_T_6, UInt<1>("h0"), _GEN_12) @[src/main/scala/OCM.scala 348:47 350:13]
    node _GEN_15 = mux(_T_6, UInt<1>("h0"), _GEN_11) @[src/main/scala/OCM.scala 348:47 351:14]
    node _GEN_16 = mux(_T_6, UInt<1>("h0"), _GEN_10) @[src/main/scala/OCM.scala 348:47 352:18]
    node _io_rd_en_T = and(isWorking, io_fusion_req_in) @[src/main/scala/OCM.scala 357:25]
    node _io_wr_en_T = eq(state, UInt<3>("h3")) @[src/main/scala/OCM.scala 358:36]
    node _io_wr_en_T_1 = and(io_wr_valid, _io_wr_en_T) @[src/main/scala/OCM.scala 358:27]
    io_ctrl_working <= isWorking @[src/main/scala/OCM.scala 355:19]
    io_rd_addr <= readPtr @[src/main/scala/OCM.scala 356:14]
    io_rd_en <= _io_rd_en_T @[src/main/scala/OCM.scala 357:12]
    io_wr_en <= _io_wr_en_T_1 @[src/main/scala/OCM.scala 358:12]
    io_wr_addr <= writePtr @[src/main/scala/OCM.scala 359:14]
    state <= mux(reset, UInt<3>("h0"), _GEN_13) @[src/main/scala/OCM.scala 318:{22,22}]
    readPtr <= mux(reset, UInt<8>("h0"), _GEN_14) @[src/main/scala/OCM.scala 319:{24,24}]
    writePtr <= mux(reset, UInt<8>("h0"), _GEN_15) @[src/main/scala/OCM.scala 320:{25,25}]
    lastWritePtr <= mux(reset, UInt<8>("h0"), _GEN_16) @[src/main/scala/OCM.scala 321:{29,29}]

  module VbSram : @[src/main/scala/OCM.scala 110:7]
    input clock : Clock @[src/main/scala/OCM.scala 110:7]
    input reset : UInt<1> @[src/main/scala/OCM.scala 110:7]
    input io_wr_en : UInt<1> @[src/main/scala/OCM.scala 111:14]
    input io_wr_addr : UInt<8> @[src/main/scala/OCM.scala 111:14]
    input io_wr_data : UInt<128> @[src/main/scala/OCM.scala 111:14]
    input io_rd_en : UInt<1> @[src/main/scala/OCM.scala 111:14]
    input io_rd_addr : UInt<8> @[src/main/scala/OCM.scala 111:14]
    output io_rd_data : UInt<128> @[src/main/scala/OCM.scala 111:14]
    output io_rd_valid : UInt<1> @[src/main/scala/OCM.scala 111:14]

    mem vb_lane0 : @[src/main/scala/OCM.scala 123:16]
      data-type => UInt<64>
      depth => 256
      read-latency => 1
      write-latency => 1
      reader => lane0Read
      writer => MPORT
      read-under-write => undefined
    mem vb_lane1 : @[src/main/scala/OCM.scala 123:16]
      data-type => UInt<64>
      depth => 256
      read-latency => 1
      write-latency => 1
      reader => lane1Read
      writer => MPORT_1
      read-under-write => undefined
    node _T = bits(io_wr_data, 63, 0) @[src/main/scala/OCM.scala 127:42]
    node _T_1 = bits(io_wr_data, 127, 64) @[src/main/scala/OCM.scala 128:42]
    node _GEN_0 = validif(io_wr_en, io_wr_addr) @[src/main/scala/OCM.scala 126:18 127:19]
    node _GEN_1 = validif(io_wr_en, clock) @[src/main/scala/OCM.scala 126:18 127:19]
    node _GEN_2 = mux(io_wr_en, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/OCM.scala 123:16 126:18 127:19]
    node _GEN_3 = validif(io_wr_en, UInt<1>("h1")) @[src/main/scala/OCM.scala 126:18 127:19]
    node _GEN_4 = validif(io_wr_en, _T) @[src/main/scala/OCM.scala 126:18 127:19]
    node _GEN_5 = validif(io_wr_en, _T_1) @[src/main/scala/OCM.scala 126:18 128:19]
    node _GEN_6 = validif(io_rd_en, io_rd_addr) @[src/main/scala/OCM.scala 131:{32,32}]
    node _GEN_7 = mux(io_rd_en, UInt<1>("h1"), UInt<1>("h0")) @[src/main/scala/OCM.scala 123:16 131:{32,32}]
    node _lane0Read_WIRE = _GEN_6 @[src/main/scala/OCM.scala 131:32]
    node _GEN_8 = validif(io_rd_en, _lane0Read_WIRE) @[src/main/scala/OCM.scala 131:{32,32}]
    node _GEN_9 = validif(io_rd_en, clock) @[src/main/scala/OCM.scala 131:{32,32}]
    node _lane1Read_WIRE = _GEN_6 @[src/main/scala/OCM.scala 132:32]
    node _GEN_10 = validif(io_rd_en, _lane1Read_WIRE) @[src/main/scala/OCM.scala 132:{32,32}]
    node _io_rd_data_T = cat(vb_lane1.lane1Read.data, vb_lane0.lane0Read.data) @[src/main/scala/OCM.scala 134:21]
    reg io_rd_valid_REG : UInt<1>, clock with :
      reset => (UInt<1>("h0"), io_rd_valid_REG) @[src/main/scala/OCM.scala 135:25]
    io_rd_data <= _io_rd_data_T @[src/main/scala/OCM.scala 134:15]
    io_rd_valid <= io_rd_valid_REG @[src/main/scala/OCM.scala 135:15]
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
    io_rd_valid_REG <= mux(reset, UInt<1>("h0"), io_rd_en) @[src/main/scala/OCM.scala 135:{25,25,25}]

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
