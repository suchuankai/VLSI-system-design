module AXI(

	input ACLK,
	input ARESETn,

	/* ----- M0 Master ----- */
	input [`AXI_ID_BITS-1:0] ARID_M0,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M0,
	input [`AXI_LEN_BITS-1:0] ARLEN_M0,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
	input [1:0] ARBURST_M0,
	input ARVALID_M0,
	output logic ARREADY_M0,
	
	output logic [`AXI_ID_BITS-1:0] RID_M0,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M0,
	output logic [1:0] RRESP_M0,
	output logic RLAST_M0,
	output logic RVALID_M0,
	input RREADY_M0,
	
	/* ----- M1 Master ----- */
	input [`AXI_ID_BITS-1:0] ARID_M1,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M1,
	input [`AXI_LEN_BITS-1:0] ARLEN_M1,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
	input [1:0] ARBURST_M1,
	input ARVALID_M1,
	output logic ARREADY_M1,
	
	output logic [`AXI_ID_BITS-1:0] RID_M1,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M1,
	output logic [1:0] RRESP_M1,
	output logic RLAST_M1,
	output logic RVALID_M1,
	input RREADY_M1,

	input [`AXI_ID_BITS-1:0] AWID_M1,
	input [`AXI_ADDR_BITS-1:0] AWADDR_M1,
	input [`AXI_LEN_BITS-1:0] AWLEN_M1,
	input [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
	input [1:0] AWBURST_M1,
	input AWVALID_M1,
	output logic AWREADY_M1,
	
	input [`AXI_DATA_BITS-1:0] WDATA_M1,
	input [`AXI_STRB_BITS-1:0] WSTRB_M1,
	input WLAST_M1,
	input WVALID_M1,
	output logic WREADY_M1,
	
	output logic [`AXI_ID_BITS-1:0] BID_M1,
	output logic [1:0] BRESP_M1,
	output logic BVALID_M1,
	input BREADY_M1,

	/* ----- M2 Master ----- */
	input [`AXI_ID_BITS-1:0] ARID_M2,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M2,
	input [`AXI_LEN_BITS-1:0] ARLEN_M2,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M2,
	input [1:0] ARBURST_M2,
	input ARVALID_M2,
	output logic ARREADY_M2,
	
	output logic [`AXI_ID_BITS-1:0] RID_M2,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M2,
	output logic [1:0] RRESP_M2,
	output logic RLAST_M2,
	output logic RVALID_M2,
	input RREADY_M2,

	input [`AXI_ID_BITS-1:0] AWID_M2,
	input [`AXI_ADDR_BITS-1:0] AWADDR_M2,
	input [`AXI_LEN_BITS-1:0] AWLEN_M2,
	input [`AXI_SIZE_BITS-1:0] AWSIZE_M2,
	input [1:0] AWBURST_M2,
	input AWVALID_M2,
	output logic AWREADY_M2,
	
	input [`AXI_DATA_BITS-1:0] WDATA_M2,
	input [`AXI_STRB_BITS-1:0] WSTRB_M2,
	input WLAST_M2,
	input WVALID_M2,
	output logic WREADY_M2,
	
	output logic [`AXI_ID_BITS-1:0] BID_M2,
	output logic [1:0] BRESP_M2,
	output logic BVALID_M2,
	input BREADY_M2,

	/* ----- S0 Slave(ROM) ----- */
	output logic [`AXI_IDS_BITS-1:0] ARID_S0,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S0,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S0,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S0,
	output logic [1:0] ARBURST_S0,
	output logic ARVALID_S0,
	input ARREADY_S0,
	
	input [`AXI_IDS_BITS-1:0] RID_S0,
	input [`AXI_DATA_BITS-1:0] RDATA_S0,
	input [1:0] RRESP_S0,
	input RLAST_S0,
	input RVALID_S0,
	output logic RREADY_S0,

	/* ----- S1 Slave(IM) ----- */
	output logic [`AXI_IDS_BITS-1:0] ARID_S1,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S1,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S1,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S1,
	output logic [1:0] ARBURST_S1,
	output logic ARVALID_S1,
	input ARREADY_S1,
	
	input [`AXI_IDS_BITS-1:0] RID_S1,
	input [`AXI_DATA_BITS-1:0] RDATA_S1,
	input [1:0] RRESP_S1,
	input RLAST_S1,
	input RVALID_S1,
	output logic RREADY_S1,

	output logic [`AXI_IDS_BITS-1:0] AWID_S1,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S1,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S1,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S1,
	output logic [1:0] AWBURST_S1,
	output logic AWVALID_S1,
	input AWREADY_S1,
	
	output logic [`AXI_DATA_BITS-1:0] WDATA_S1,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S1,
	output logic WLAST_S1,
	output logic WVALID_S1,
	input WREADY_S1,
	
	input [`AXI_IDS_BITS-1:0] BID_S1,
	input [1:0] BRESP_S1,
	input BVALID_S1,
	output logic BREADY_S1,

	/* ----- S2 Slave(DM) ----- */
	output logic [`AXI_IDS_BITS-1:0] ARID_S2,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S2,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S2,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S2,
	output logic [1:0] ARBURST_S2,
	output logic ARVALID_S2,
	input ARREADY_S2,
	
	input [`AXI_IDS_BITS-1:0] RID_S2,
	input [`AXI_DATA_BITS-1:0] RDATA_S2,
	input [1:0] RRESP_S2,
	input RLAST_S2,
	input RVALID_S2,
	output logic RREADY_S2,

	output logic [`AXI_IDS_BITS-1:0] AWID_S2,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S2,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S2,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S2,
	output logic [1:0] AWBURST_S2,
	output logic AWVALID_S2,
	input AWREADY_S2,
	
	output logic [`AXI_DATA_BITS-1:0] WDATA_S2,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S2,
	output logic WLAST_S2,
	output logic WVALID_S2,
	input WREADY_S2,
	
	input [`AXI_IDS_BITS-1:0] BID_S2,
	input [1:0] BRESP_S2,
	input BVALID_S2,
	output logic BREADY_S2,

	/* ----- S3 Slave(DMA) ----- */
	output logic [`AXI_IDS_BITS-1:0] AWID_S3,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S3,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S3,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S3,
	output logic [1:0] AWBURST_S3,
	output logic AWVALID_S3,
	input AWREADY_S3,
	
	output logic [`AXI_DATA_BITS-1:0] WDATA_S3,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S3,
	output logic WLAST_S3,
	output logic WVALID_S3,
	input WREADY_S3,
	
	input [`AXI_IDS_BITS-1:0] BID_S3,
	input [1:0] BRESP_S3,
	input BVALID_S3,
	output logic BREADY_S3,

	/* ----- S4 Slave(WDT) ----- */
	output logic [`AXI_IDS_BITS-1:0] AWID_S4,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S4,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S4,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S4,
	output logic [1:0] AWBURST_S4,
	output logic AWVALID_S4,
	input AWREADY_S4,
	
	output logic [`AXI_DATA_BITS-1:0] WDATA_S4,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S4,
	output logic WLAST_S4,
	output logic WVALID_S4,
	input WREADY_S4,
	
	input [`AXI_IDS_BITS-1:0] BID_S4,
	input [1:0] BRESP_S4,
	input BVALID_S4,
	output logic BREADY_S4,

	/* ----- S5 Slave(DRAM) ----- */
	output logic [`AXI_IDS_BITS-1:0] ARID_S5,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S5,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S5,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S5,
	output logic [1:0] ARBURST_S5,
	output logic ARVALID_S5,
	input ARREADY_S5,
	
	input [`AXI_IDS_BITS-1:0] RID_S5,
	input [`AXI_DATA_BITS-1:0] RDATA_S5,
	input [1:0] RRESP_S5,
	input RLAST_S5,
	input RVALID_S5,
	output logic RREADY_S5,

	output logic [`AXI_IDS_BITS-1:0] AWID_S5,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S5,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S5,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S5,
	output logic [1:0] AWBURST_S5,
	output logic AWVALID_S5,
	input AWREADY_S5,
	
	output logic [`AXI_DATA_BITS-1:0] WDATA_S5,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S5,
	output logic WLAST_S5,
	output logic WVALID_S5,
	input WREADY_S5,
	
	input [`AXI_IDS_BITS-1:0] BID_S5,
	input [1:0] BRESP_S5,
	input BVALID_S5,
	output logic BREADY_S5
);

logic [3:0] MRead0_target, MRead1_target, MRead2_target;
logic [3:0] MWrite0_target, MWrite1_target, MWrite2_target;

logic [2:0] T0_M, T0_S;

/*  ################################################
    ###              Master Ports                ###
    ################################################  */

logic [50:0] M2S_Read [0:2];
//                           4 bit     32 bit     4 bit     3 bit      2 bit       1 bit       1 bit
assign M2S_Read[0] = {{4'd0, ARID_M0}, ARADDR_M0, ARLEN_M0, ARSIZE_M0, ARBURST_M0, ARVALID_M0, RREADY_M0};
assign M2S_Read[1] = {{4'd1, ARID_M1}, ARADDR_M1, ARLEN_M1, ARSIZE_M1, ARBURST_M1, ARVALID_M1, RREADY_M1};
assign M2S_Read[2] = {{4'd2, ARID_M2}, ARADDR_M2, ARLEN_M2, ARSIZE_M2, ARBURST_M2, ARVALID_M2, RREADY_M2};

Addr_decoder MRead0(.address(ARADDR_M0), .slaveID(MRead0_target));
Addr_decoder MRead1(.address(ARADDR_M1), .slaveID(MRead1_target));
Addr_decoder MRead2(.address(ARADDR_M2), .slaveID(MRead2_target));

logic [88:0] M2S_Write [0:2];
//                            4 bit     32 bit     4 bit     3 bit      2 bit       1 bit       32 bit    4 bit     1 bit     1 bit      1 bit
assign M2S_Write[0] = 85'd0;
assign M2S_Write[1] = {{4'd1, AWID_M1}, AWADDR_M1, AWLEN_M1, AWSIZE_M1, AWBURST_M1, AWVALID_M1, WDATA_M1, WSTRB_M1, WLAST_M1, WVALID_M1, BREADY_M1};
assign M2S_Write[2] = {{4'd1, AWID_M2}, AWADDR_M2, AWLEN_M2, AWSIZE_M2, AWBURST_M2, AWVALID_M2, WDATA_M2, WSTRB_M2, WLAST_M2, WVALID_M2, BREADY_M2};


Addr_decoder MWrite0(.address(32'd0), .slaveID(MWrite0_target));
Addr_decoder MWrite1(.address(AWADDR_M1), .slaveID(MWrite1_target));
Addr_decoder MWrite2(.address(AWADDR_M2), .slaveID(MWrite2_target));


/*  ################################################
    ###              Slave  Ports                ###
    ################################################  */

logic [44:0] S2M_Read [0:5];
//                    1 bit       8 bit   32 bit    2 bit     1 bit     1 bit
assign S2M_Read[0] = {ARREADY_S0, RID_S0, RDATA_S0, RRESP_S0, RLAST_S0, RVALID_S0};
assign S2M_Read[1] = {ARREADY_S1, RID_S1, RDATA_S1, RRESP_S1, RLAST_S1, RVALID_S1};
assign S2M_Read[2] = {ARREADY_S2, RID_S2, RDATA_S2, RRESP_S2, RLAST_S2, RVALID_S2};
assign S2M_Read[3] = 45'd0;
assign S2M_Read[4] = 45'd0;
assign S2M_Read[5] = {ARREADY_S5, RID_S5, RDATA_S5, RRESP_S5, RLAST_S5, RVALID_S5};

logic [19:0] S2M_Write [0:5];
//                     1 bit       8 bit      8 bit   2 bit     1 bit
assign S2M_Write[0] = 20'd0;
assign S2M_Write[1] = {AWREADY_S1, WREADY_S1, BID_S1, BRESP_S1, BVALID_S1};
assign S2M_Write[2] = {AWREADY_S2, WREADY_S2, BID_S2, BRESP_S2, BVALID_S2};
assign S2M_Write[3] = {AWREADY_S3, WREADY_S3, BID_S3, BRESP_S3, BVALID_S3};
assign S2M_Write[4] = {AWREADY_S4, WREADY_S4, BID_S4, BRESP_S4, BVALID_S4};
assign S2M_Write[5] = {AWREADY_S5, WREADY_S5, BID_S5, BRESP_S5, BVALID_S5};


Arbiter u_Arbiter(
	.ACLK(ACLK),
	.ARESETn(ARESETn),
	.ARVALID_M0(ARVALID_M0),
	.ARVALID_M1(ARVALID_M1),
	.ARVALID_M2(ARVALID_M2),
	.AWVALID_M0(1'b0),   // Master 0 not perform write
	.AWVALID_M1(AWVALID_M1),
	.AWVALID_M2(AWVALID_M2),
	.MRead0_target(MRead0_target),
	.MRead1_target(MRead1_target),
	.MRead2_target(MRead2_target),
	.MWrite0_target(MWrite0_target),
	.MWrite1_target(MWrite1_target),
	.MWrite2_target(MWrite2_target),

	.ARREADY_S0(ARREADY_S0),
	.ARREADY_S1(ARREADY_S1),
	.ARREADY_S2(ARREADY_S2),
	.ARREADY_S3(1'b0),
	.ARREADY_S4(1'b0),
	.ARREADY_S5(ARREADY_S5),

	.AWREADY_S0(1'b0),
	.AWREADY_S1(AWREADY_S1),
	.AWREADY_S2(AWREADY_S2),
	.AWREADY_S3(AWREADY_S3),
	.AWREADY_S4(AWREADY_S4),
	.AWREADY_S5(AWREADY_S5),

	.RLAST_S0(RLAST_S0),
	.RLAST_S1(RLAST_S1),
	.RLAST_S2(RLAST_S2),
	.RLAST_S3(1'b0),
	.RLAST_S4(1'b0),
	.RLAST_S5(RLAST_S5),
	.BVALID_S0(1'b0),
	.BVALID_S1(BVALID_S1),
	.BVALID_S2(BVALID_S2),
	.BVALID_S3(BVALID_S3),
	.BVALID_S4(BVALID_S4),
	.BVALID_S5(BVALID_S5),

	.T0_M(T0_M),
	.T0_S(T0_S)
	);


logic [40:0] MRead_out [0:2];
//      1 bit       4 bit   32 bit    2 bit     1 bit     1 bit
assign {ARREADY_M0, RID_M0, RDATA_M0, RRESP_M0, RLAST_M0, RVALID_M0} = MRead_out[0];
assign {ARREADY_M1, RID_M1, RDATA_M1, RRESP_M1, RLAST_M1, RVALID_M1} = MRead_out[1];
assign {ARREADY_M2, RID_M2, RDATA_M2, RRESP_M2, RLAST_M2, RVALID_M2} = MRead_out[2];

logic [15:0] MWrite_out [0:2];
//      1 bit       8 bit      4 bit   2 bit     1 bit
//assign {AWREADY_M0, WREADY_M0, BID_M0, BRESP_M0, BVALID_M0} = MWrite_out[0];
assign {AWREADY_M1, WREADY_M1, BID_M1, BRESP_M1, BVALID_M1}  = MWrite_out[1];
assign {AWREADY_M2, WREADY_M2, BID_M2, BRESP_M2, BVALID_M2}  = MWrite_out[2];


logic [50:0] SRead_out [0:5];
//      8 bit    32 bit     4 bit     3 bit      2 bit       1 bit       1 bit
assign {ARID_S0, ARADDR_S0, ARLEN_S0, ARSIZE_S0, ARBURST_S0, ARVALID_S0, RREADY_S0} = SRead_out[0];
assign {ARID_S1, ARADDR_S1, ARLEN_S1, ARSIZE_S1, ARBURST_S1, ARVALID_S1, RREADY_S1} = SRead_out[1];
assign {ARID_S2, ARADDR_S2, ARLEN_S2, ARSIZE_S2, ARBURST_S2, ARVALID_S2, RREADY_S2} = SRead_out[2];
assign {ARID_S3, ARADDR_S3, ARLEN_S3, ARSIZE_S3, ARBURST_S3, ARVALID_S3, RREADY_S3} = SRead_out[3];
assign {ARID_S4, ARADDR_S4, ARLEN_S4, ARSIZE_S4, ARBURST_S4, ARVALID_S4, RREADY_S4} = SRead_out[4];
assign {ARID_S5, ARADDR_S5, ARLEN_S5, ARSIZE_S5, ARBURST_S5, ARVALID_S5, RREADY_S5} = SRead_out[5];

logic [88:0] SWrite_out [0:5];
//     8 bit     32 bit     4 bit     3 bit      2 bit       1 bit       32 bit    4 bit     1 bit     1 bit      1 bit
assign {AWID_S0, AWADDR_S0, AWLEN_S0, AWSIZE_S0, AWBURST_S0, AWVALID_S0, WDATA_S0, WSTRB_S0, WLAST_S0, WVALID_S0, BREADY_S0} = SWrite_out[0];
assign {AWID_S1, AWADDR_S1, AWLEN_S1, AWSIZE_S1, AWBURST_S1, AWVALID_S1, WDATA_S1, WSTRB_S1, WLAST_S1, WVALID_S1, BREADY_S1} = SWrite_out[1];
assign {AWID_S2, AWADDR_S2, AWLEN_S2, AWSIZE_S2, AWBURST_S2, AWVALID_S2, WDATA_S2, WSTRB_S2, WLAST_S2, WVALID_S2, BREADY_S2} = SWrite_out[2];
assign {AWID_S3, AWADDR_S3, AWLEN_S3, AWSIZE_S3, AWBURST_S3, AWVALID_S3, WDATA_S3, WSTRB_S3, WLAST_S3, WVALID_S3, BREADY_S3} = SWrite_out[3];
assign {AWID_S4, AWADDR_S4, AWLEN_S4, AWSIZE_S4, AWBURST_S4, AWVALID_S4, WDATA_S4, WSTRB_S4, WLAST_S4, WVALID_S4, BREADY_S4} = SWrite_out[4];
assign {AWID_S5, AWADDR_S5, AWLEN_S5, AWSIZE_S5, AWBURST_S5, AWVALID_S5, WDATA_S5, WSTRB_S5, WLAST_S5, WVALID_S5, BREADY_S5} = SWrite_out[5];

integer i;
always_comb begin
	for(i=0; i<6; i=i+1) begin
		if(i<3) begin
			MRead_out[i]  = 41'd0;
			MWrite_out[i] = 20'd0;
		end
		SRead_out[i]  = 51'd0;
		SWrite_out[i] = 85'd0;
	end
	if(T0_M != 3'b111 && T0_S != 3'b111) begin  // 3'b111 means no master and slave need to connect.
		MRead_out[T0_M]  = {S2M_Read[T0_S][44], S2M_Read[T0_S][39:0]}; // 40~43 is master target
		MWrite_out[T0_M] = {S2M_Write[T0_S][19:11], S2M_Write[T0_S][6:0]};
		SRead_out[T0_S]  = M2S_Read[T0_M];
		SWrite_out[T0_S] = M2S_Write[T0_M];
	end
end

endmodule
