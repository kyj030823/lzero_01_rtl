FIRRTL version 1.2.0
circuit VbSram :
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
