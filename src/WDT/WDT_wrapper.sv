module WDT_wrapper(
	input clk1,
	input clk2,
	input rst,
	input rst2,

	// Slave (Write only)
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

	output logic WDT_interrupt
	);


AXI_Slave WDT_slave(
	.ACLK(),
    .ARESETn(),
    
    .ARID_S(), 
    .ARADDR_S(), 
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

    .read_en(),
    .write_en(),

    .CEB_S(),
    .WEB_S(),
    .A_S(),
    .DI_S(),
    .BWEB_S(),
    .DO_S()
    );




endmodule