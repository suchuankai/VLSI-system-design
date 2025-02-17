module CPU_wrapper(
	input clk,
	input rst,

	/*------------------ Master0(IM) Ports ------------------*/
	// 1. AR channel (Read) 
	output logic  [`AXI_ID_BITS-1:0]     ARID_M0, 
  	output logic  [`AXI_ADDR_BITS-1:0]   ARADDR_M0, 
  	output logic  [`AXI_LEN_BITS-1:0]    ARLEN_M0, 
  	output logic  [`AXI_SIZE_BITS-1:0]   ARSIZE_M0, 
  	output logic  [`USER_BURST_BITS-1:0] ARBURST_M0, 
  	output logic                         ARVALID_M0, 
  	input                                ARREADY_M0,
     
    // 2. R channel (Read)
  	input         [`AXI_ID_BITS-1:0]     RID_M0, 
  	input         [`AXI_DATA_BITS-1:0]   RDATA_M0, 
  	input         [`USER_RRESP_BITS-1:0] RRESP_M0, 
  	input                                RLAST_M0, 
  	input                                RVALID_M0, 
  	output logic                         RREADY_M0,
    
    /* In this design, Master 1 just need to perform read operation.
    // 3. AW channel (Write) 
    output [`AXI_ID_BITS-1:0]     AWID_M0, 
 	output [`AXI_ADDR_BITS-1:0]   AWADDR_M0, 
  	output [`AXI_LEN_BITS-1:0]    AWLEN_M0, 
  	output [`AXI_SIZE_BITS-1:0]   AWSIZE_M0, 
  	output [`USER_BURST_BITS-1:0] AWBURST_M0, 
  	output                        AWVALID_M0, 
  	input                         AWREADY_M0, 

  	// 4. W channel (Write)
  	output [`AXI_DATA_BITS-1:0]   WDATA_M0, 
  	output [`AXI_STRB_BITS-1:0]   WSTRB_M0, 
  	output                        WLAST_M0, 
  	output                        WVALID_M0, 
  	input                         WREADY_M0, 

  	// 5. B channel (Write)
  	input  [`AXI_ID_BITS-1:0]     BID_M0, 
  	input  [`USER_BRESP_BITS-1:0] BRESP_M0, 
  	input                         BVALID_M0, 
  	output                        BREADY_M0,
	*/

  	/*------------------ Master1(DM) Ports ------------------*/
	// 1. AR channel (Read) 
	output logic  [`AXI_ID_BITS-1:0]     ARID_M1, 
  	output logic  [`AXI_ADDR_BITS-1:0]   ARADDR_M1, 
  	output logic  [`AXI_LEN_BITS-1:0]    ARLEN_M1, 
  	output logic  [`AXI_SIZE_BITS-1:0]   ARSIZE_M1, 
  	output logic  [`USER_BURST_BITS-1:0] ARBURST_M1, 
  	output logic                         ARVALID_M1, 
  	input                                ARREADY_M1, 
     
    // 2. R channel (Read)
  	input         [`AXI_ID_BITS-1:0]     RID_M1, 
  	input         [`AXI_DATA_BITS-1:0]   RDATA_M1, 
  	input         [`USER_RRESP_BITS-1:0] RRESP_M1, 
  	input                                RLAST_M1, 
  	input                                RVALID_M1, 
  	output logic                         RREADY_M1,
    
    // 3. AW channel (Write) 
    output [`AXI_ID_BITS-1:0]     AWID_M1, 
 	output [`AXI_ADDR_BITS-1:0]   AWADDR_M1, 
  	output [`AXI_LEN_BITS-1:0]    AWLEN_M1, 
  	output [`AXI_SIZE_BITS-1:0]   AWSIZE_M1, 
  	output [`USER_BURST_BITS-1:0] AWBURST_M1, 
  	output                        AWVALID_M1, 
  	input                         AWREADY_M1, 

  	// 4. W channel (Write)
  	output [`AXI_DATA_BITS-1:0]   WDATA_M1, 
  	output [`AXI_STRB_BITS-1:0]   WSTRB_M1, 
  	output                        WLAST_M1, 
  	output                        WVALID_M1, 
  	input                         WREADY_M1, 

  	// 5. B channel (Write)
  	input  [`AXI_ID_BITS-1:0]     BID_M1, 
  	input  [`USER_BRESP_BITS-1:0] BRESP_M1, 
  	input                         BVALID_M1, 
  	output                        BREADY_M1     
	);
	
	logic [31:0] IM_A;
	logic IM_WEB, IM_CEB;
	logic [31:0] readData_M0;

	logic [31:0] DM_A;
	logic DM_WEB, DM_CEB;
	logic [31:0] readData_M1;
	logic [3:0] DM_BWEB;
	logic [31:0] DM_IN;

	logic [1:0] busStall;
	logic DM_busy, IM_busy;

	assign busStall = {DM_busy, IM_busy};

	CPU u_CPU(
		.clk(clk), 
		.rst(rst),
		.busStall(busStall),
		.instr(readData_M0),  // IM_OUT(Data read from IM)
		.IM_WEB(IM_WEB),
		.pc(IM_A),     
		.IM_CEB(IM_CEB),

		.DM_OUT(readData_M1), // Data read from DM
		.DM_WEB(DM_WEB),
		.DM_BWEB(DM_BWEB),
		.DM_A(DM_A),
		.DM_IN(DM_IN), // Data needs to write into DM
		.DM_CEB(DM_CEB)
	);

	AXI_Master IM_Master(
		.clk(clk), 
		.rst(~rst),
		.CEB(IM_CEB), // Memory access request
		.WEB(IM_WEB), // Read->active high | Write->active low 
		.addr(IM_A),
		.bweb(4'b0000),   // IM don't need write operation
		.writeData(32'd0),
		.readData(readData_M0),
		.busBusy(IM_busy),

		// 1. AR channel (Read)
		.ARID_M(ARID_M0), 
	  	.ARADDR_M(ARADDR_M0), 
	  	.ARLEN_M(ARLEN_M0), 
	  	.ARSIZE_M(ARSIZE_M0), 
	  	.ARBURST_M(ARBURST_M0), 
	  	.ARVALID_M(ARVALID_M0), 
	  	.ARREADY_M(ARREADY_M0), 
	     
	    // 2. R channel (Read)
	  	.RID_M(RID_M0), 
	  	.RDATA_M(RDATA_M0), 
	  	.RRESP_M(RRESP_M0), 
	  	.RLAST_M(RLAST_M0), 
	  	.RVALID_M(RVALID_M0), 
	  	.RREADY_M(RREADY_M0),
	    
	    // 3. AW channel (Write) 
	    .AWID_M(), 
	 	.AWADDR_M(), 
	  	.AWLEN_M(), 
	  	.AWSIZE_M(), 
	  	.AWBURST_M(), 
	  	.AWVALID_M(), 
	  	.AWREADY_M(), 

	  	// 4. W channel (Write)
	  	.WDATA_M(), 
	  	.WSTRB_M(), 
	  	.WLAST_M(), 
	  	.WVALID_M(), 
	  	.WREADY_M(), 

	  	// 5. B channel (Write)
	  	.BID_M(), 
	  	.BRESP_M(), 
	  	.BVALID_M(), 
	  	.BREADY_M()
	);

	AXI_Master DM_Master(
		.clk(clk), 
		.rst(~rst),
		.CEB(DM_CEB), // Memory access request
		.WEB(DM_WEB), // Read->active high | Write->active low 
		.addr(DM_A),
		.bweb(DM_BWEB),
		.writeData(DM_IN),
		.readData(readData_M1),
		.busBusy(DM_busy),

		// 1. AR channel (Read)
		.ARID_M(ARID_M1), 
	  	.ARADDR_M(ARADDR_M1), 
	  	.ARLEN_M(ARLEN_M1), 
	  	.ARSIZE_M(ARSIZE_M1), 
	  	.ARBURST_M(ARBURST_M1), 
	  	.ARVALID_M(ARVALID_M1), 
	  	.ARREADY_M(ARREADY_M1), 
	     
	    // 2. R channel (Read)
	  	.RID_M(RID_M1), 
	  	.RDATA_M(RDATA_M1), 
	  	.RRESP_M(RRESP_M1), 
	  	.RLAST_M(RLAST_M1), 
	  	.RVALID_M(RVALID_M1), 
	  	.RREADY_M(RREADY_M1),
	    
	    // 3. AW channel (Write) 
	    .AWID_M(AWID_M1), 
	 	.AWADDR_M(AWADDR_M1), 
	  	.AWLEN_M(AWLEN_M1), 
	  	.AWSIZE_M(AWSIZE_M1), 
	  	.AWBURST_M(AWBURST_M1), 
	  	.AWVALID_M(AWVALID_M1), 
	  	.AWREADY_M(AWREADY_M1), 

	  	// 4. W channel (Write)
	  	.WDATA_M(WDATA_M1), 
	  	.WSTRB_M(WSTRB_M1), 
	  	.WLAST_M(WLAST_M1), 
	  	.WVALID_M(WVALID_M1), 
	  	.WREADY_M(WREADY_M1), 

	  	// 5. B channel (Write)
	  	.BID_M(BID_M1), 
	  	.BRESP_M(BRESP_M1), 
	  	.BVALID_M(BVALID_M1), 
	  	.BREADY_M(BREADY_M1)
	);

endmodule