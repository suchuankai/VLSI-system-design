module DMA_wrapper(
	input clk,
	input ARESETn,

	// Master
	output logic  [`AXI_ID_BITS-1:0]     ARID_M, 
  	output logic  [`AXI_ADDR_BITS-1:0]   ARADDR_M, 
  	output logic  [`AXI_LEN_BITS-1:0]    ARLEN_M, 
  	output logic  [`AXI_SIZE_BITS-1:0]   ARSIZE_M, 
  	output logic  [`USER_BURST_BITS-1:0] ARBURST_M, 
  	output logic                         ARVALID_M, 
  	input                                ARREADY_M, 
     
  	input         [`AXI_ID_BITS-1:0]     RID_M, 
  	input         [`AXI_DATA_BITS-1:0]   RDATA_M, 
  	input         [`USER_RRESP_BITS-1:0] RRESP_M, 
  	input                                RLAST_M, 
  	input                                RVALID_M, 
  	output logic                         RREADY_M,
     
    output [`AXI_ID_BITS-1:0]     AWID_M, 
 	output [`AXI_ADDR_BITS-1:0]   AWADDR_M, 
  	output [`AXI_LEN_BITS-1:0]    AWLEN_M, 
  	output [`AXI_SIZE_BITS-1:0]   AWSIZE_M, 
  	output [`USER_BURST_BITS-1:0] AWBURST_M, 
  	output                        AWVALID_M, 
  	input                         AWREADY_M, 

  	output [`AXI_DATA_BITS-1:0]   WDATA_M, 
  	output [`AXI_STRB_BITS-1:0]   WSTRB_M, 
  	output                        WLAST_M, 
  	output                        WVALID_M, 
  	input                         WREADY_M, 

  	input  [`AXI_ID_BITS-1:0]     BID_M, 
  	input  [`USER_BRESP_BITS-1:0] BRESP_M, 
  	input                         BVALID_M, 
  	output                        BREADY_M,   


	// Slave(Write only)
	/*  input        [`AXI_IDS_BITS-1:0]     ARID_S, 
		input        [`AXI_ADDR_BITS-1:0]    ARADDR_S, 
		input        [`AXI_LEN_BITS-1:0]     ARLEN_S,
		input        [`AXI_SIZE_BITS-1:0]    ARSIZE_S, 
		input        [`USER_BURST_BITS-1:0]  ARBURST_S, 
		input                                ARVALID_S, 
		output logic                         ARREADY_S,

		output logic [`AXI_IDS_BITS-1:0]     RID_S, 
		output logic [`AXI_DATA_BITS-1:0]    RDATA_S, 
		output logic [`USER_RRESP_BITS-1:0]  RRESP_S, 
		output logic                         RLAST_S, 
		output logic                         RVALID_S, 
		input                                RREADY_S,*/

	input        [`AXI_IDS_BITS-1:0]     AWID_S,      
	input        [`AXI_ADDR_BITS-1:0]    AWADDR_S,    
	input        [`AXI_LEN_BITS-1:0]     AWLEN_S,   
	input        [`AXI_SIZE_BITS-1:0]    AWSIZE_S,    
	input        [`USER_BURST_BITS-1:0]  AWBURST_S,  
	input                                AWVALID_S, 
	output logic                         AWREADY_S,

	input        [`AXI_DATA_BITS-1:0]    WDATA_S,
	input        [`AXI_STRB_BITS-1:0]    WSTRB_S,
	input                                WLAST_S,
	input                                WVALID_S,
	output logic                         WREADY_S,

	output logic [`AXI_IDS_BITS-1:0]     BID_S,
	output logic [`USER_BRESP_BITS-1:0]  BRESP_S,
	output logic                         BVALID_S,
	input                                BREADY_S,

	output interrupt_dma
);
logic rst;
assign rst = ~ARESETn;

logic mr_valid, mw_valid;
logic [3:0] burst_len;
assign mr_valid = RVALID_M && RREADY_M;
assign mw_valid = WVALID_M && WREADY_M;
assign ms_valid = WVALID_S && WREADY_S;

logic CEB, WEB;
logic [3:0] bweb;
logic [31:0] addr;
logic [31:0] writeData, readData;

logic [31:0] A_S, DI_S;

AXI_Master DMA_Master(
	.clk(clk), 
	.rst(ARESETn),
	.CEB(CEB),
	.WEB(WEB), 
	.addr(addr),
	.bweb(bweb),
	.writeData(writeData),
	.burst_len(burst_len),
	.readData(readData), // output
	.busBusy(),

	.ARID_M(ARID_M), 
  	.ARADDR_M(ARADDR_M), 
  	.ARLEN_M(ARLEN_M), 
  	.ARSIZE_M(ARSIZE_M), 
  	.ARBURST_M(ARBURST_M), 
  	.ARVALID_M(ARVALID_M), 
  	.ARREADY_M(ARREADY_M), 
     
  	.RID_M(RID_M), 
  	.RDATA_M(RDATA_M), 
  	.RRESP_M(RRESP_M), 
  	.RLAST_M(RLAST_M), 
  	.RVALID_M(RVALID_M), 
  	.RREADY_M(RREADY_M),
    
    .AWID_M(AWID_M), 
 	.AWADDR_M(AWADDR_M), 
  	.AWLEN_M(AWLEN_M), 
  	.AWSIZE_M(AWSIZE_M), 
  	.AWBURST_M(AWBURST_M), 
  	.AWVALID_M(AWVALID_M), 
  	.AWREADY_M(AWREADY_M), 

  	.WDATA_M(WDATA_M), 
  	.WSTRB_M(WSTRB_M), 
  	.WLAST_M(WLAST_M), 
  	.WVALID_M(WVALID_M), 
  	.WREADY_M(WREADY_M), 

  	.BID_M(BID_M), 
  	.BRESP_M(BRESP_M), 
  	.BVALID_M(BVALID_M), 
  	.BREADY_M(BREADY_M)
);


AXI_Slave DMA_Slave(
    .ACLK(clk),
    .ARESETn(ARESETn),
    
    .ARID_S(), 
    .ARADDR_S(32'd0), 
    .ARLEN_S(),
    .ARSIZE_S(), 
    .ARBURST_S(), 
    .ARVALID_S(), 
    .ARREADY_S(),  
    
    .RID_S(), 
    .RDATA_S(), 
    .RRESP_S(), 
    .RLAST_S(), 
    .RVALID_S(), 
    .RREADY_S(),
	
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

    .read_en(1'b1),
    .write_en(1'b1),

    .CEB_S(),
    .WEB_S(),
    .A_S(A_S),
    .DI_S(DI_S),
    .BWEB_S(),
    .DO_S()
  );


DMA_controller u_DMA_controller(
	.clk(clk),
	.rst(rst),
	.s_addr(A_S),      // DMA slave write address
  	.s_data(DI_S),     // DMA slave write data
	.s_en(ms_valid),   // DMA slave write enable

	.r_valid(mr_valid),  // Master Read  handshakes
	.w_valid(mw_valid),  // Master Write handshakes
	.readData(readData),

	.addr(addr),
	.bweb(bweb),
	.write_data(writeData),
	.burst_len(burst_len),
	.CEB(CEB),
	.WEB(WEB),
	.interrupt_dma(interrupt_dma)
	);


endmodule