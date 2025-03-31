module ROM_wrapper(
	input ACLK,
	input ARESETn,

	// AXI slave
    input        [`AXI_IDS_BITS-1:0]     ARID_S, 
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
	input                                RREADY_S,

	/*  input        [`AXI_IDS_BITS-1:0]     AWID_S,      
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
		input                                BREADY_S */

	// To ROM
	output OE,
	output CS,
	output [11:0] A,
	input [31:0] DO

	);


logic [31:0] A_S;
logic CEB_S, WEB_S;
assign A = A_S[13:2];
assign OE = !CEB_S;
assign CS = WEB_S;


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

    .AWID_S(),      
    .AWADDR_S(),    
    .AWLEN_S(),   
    .AWSIZE_S(),    
    .AWBURST_S(),  
    .AWVALID_S(), 
    .AWREADY_S(),

    .WDATA_S(),
    .WSTRB_S(),
    .WLAST_S(),
    .WVALID_S(),
    .WREADY_S(),

    .BID_S(),
    .BRESP_S(),
    .BVALID_S(),
    .BREADY_S(),

    .read_en(1'b1),
    .write_en(1'b1),

    .CEB_S(CEB_S),
    .WEB_S(WEB_S),
    .A_S(A_S),
    .DI_S(),
    .BWEB_S(),
    .DO_S(DO)
  );





endmodule