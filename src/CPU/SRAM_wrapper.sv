module SRAM_wrapper (
  input ACLK,
  input ARESETn,
  
  // 1. AR channel
  input        [`AXI_IDS_BITS-1:0]     ARID_S, 
  input        [`AXI_ADDR_BITS-1:0]    ARADDR_S, 
  input        [`AXI_LEN_BITS-1:0]     ARLEN_S,
  input        [`AXI_SIZE_BITS-1:0]    ARSIZE_S, 
  input        [`USER_BURST_BITS-1:0]  ARBURST_S, 
  input                                ARVALID_S, 
  output logic                         ARREADY_S,
  
  // 2. R channel
  output logic [`AXI_IDS_BITS-1:0]     RID_S, 
  output logic [`AXI_DATA_BITS-1:0]    RDATA_S, 
  output logic [`USER_RRESP_BITS-1:0]  RRESP_S, 
  output logic                         RLAST_S, 
  output logic                         RVALID_S, 
  input                                RREADY_S,

  // 3. AW channel
  input        [`AXI_IDS_BITS-1:0]     AWID_S,      
  input        [`AXI_ADDR_BITS-1:0]    AWADDR_S,    
  input        [`AXI_LEN_BITS-1:0]     AWLEN_S,   
  input        [`AXI_SIZE_BITS-1:0]    AWSIZE_S,    
  input        [`USER_BURST_BITS-1:0]  AWBURST_S,  
  input                                AWVALID_S, 
  output logic                         AWREADY_S,

  // 4. W channel
  input        [`AXI_DATA_BITS-1:0]    WDATA_S,
  input        [`AXI_STRB_BITS-1:0]    WSTRB_S,
  input                                WLAST_S,
  input                                WVALID_S,
  output logic                         WREADY_S,

  // 5. R channel
  output logic [`AXI_IDS_BITS-1:0]     BID_S,
  output logic [`USER_BRESP_BITS-1:0]  BRESP_S,
  output logic                         BVALID_S,
  input                                BREADY_S
  );

  // SRAM ports
  logic CEB;
  logic WEB;
  logic [3:0] BWEB;
  logic [31:0] A;
  logic [31:0] DI;
  logic [31:0] DO;

  // AXI
  AXI_Slave u_AXI_Slave(
    .ACLK(ACLK),
    .ARESETn(ARESETn),

    .ARID_S(ARID_S), 
    .ARADDR_S(ARADDR_S), 
    .ARLEN_S(ARLEN_S),
    .ARSIZE_S(ARSIZE_S), 
    .ARBURST_S(ARBURST_S), 
    .ARVALID_S(ARVALID_S), 
    .ARREADY_S(ARREADY_S),  
    
    .RID_S(RID_S), 
    .RDATA_S(RDATA_S), 
    .RRESP_S(RRESP_S), 
    .RLAST_S(RLAST_S), 
    .RVALID_S(RVALID_S), 
    .RREADY_S(RREADY_S),

    .AWID_S(AWID_S),      
    .AWADDR_S(AWADDR_S),    
    .AWLEN_S(AWLEN_S),   
    .AWSIZE_S(AWSIZE_S),    
    .AWBURST_S(AWBURST_S),  
    .AWVALID_S(AWVALID_S), 
    .AWREADY_S(AWREADY_S),

    .WDATA_S(WDATA_S),
    .WSTRB_S(WSTRB_S),
    .WLAST_S(WLAST_S),
    .WVALID_S(WVALID_S),
    .WREADY_S(WREADY_S),

    .BID_S(BID_S),
    .BRESP_S(BRESP_S),
    .BVALID_S(BVALID_S),
    .BREADY_S(BREADY_S),

    .read_en(1'b1),  // SRAM is always ready.
    .write_en(1'b1),
    .CEB_S(CEB),
    .WEB_S(WEB),
    .A_S(A),
    .DI_S(DI),
    .BWEB_S(BWEB),
    .DO_S(DO)
  );

  logic [31:0] BWEB_expand;
  assign BWEB_expand = { {8{BWEB[3]}}, {8{BWEB[2]}}, {8{BWEB[1]}}, {8{BWEB[0]}} };

  logic [13:0] sram_A;
  assign sram_A = A[15:2];

  // SRAM
  TS1N16ADFPCLLLVTA512X45M4SWSHOD i_SRAM (
    .SLP(1'b0),
    .DSLP(1'b0),
    .SD(1'b0),
    .PUDELAY(),
    .CLK(ACLK),
	  .CEB(CEB),
	  .WEB(WEB),
    .A(sram_A),
	  .D(DI),
    .BWEB(BWEB_expand),
    .RTSEL(2'b01),
    .WTSEL(2'b01),
    .Q(DO)
);


endmodule
