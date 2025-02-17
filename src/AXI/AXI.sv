//////////////////////////////////////////////////////////////////////
//          ██╗       ██████╗   ██╗  ██╗    ██████╗            		//
//          ██║       ██╔══█║   ██║  ██║    ██╔══█║            		//
//          ██║       ██████║   ███████║    ██████║            		//
//          ██║       ██╔═══╝   ██╔══██║    ██╔═══╝            		//
//          ███████╗  ██║  	    ██║  ██║    ██║  	           		//
//          ╚══════╝  ╚═╝  	    ╚═╝  ╚═╝    ╚═╝  	           		//
//                                                             		//
// 	2024 Advanced VLSI System Design, advisor: Lih-Yih, Chiou		//
//                                                             		//
//////////////////////////////////////////////////////////////////////
//                                                             		//
// 	Autor: 			TZUNG-JIN, TSAI (Leo)				  	   		//
//	Filename:		 AXI.sv			                            	//
//	Description:	Top module of AXI	 							//
// 	Version:		1.0	    								   		//
//////////////////////////////////////////////////////////////////////

module AXI(

	input ACLK,
	input ARESETn,

	//SLAVE INTERFACE FOR MASTERS
	
	//WRITE ADDRESS
	input [`AXI_ID_BITS-1:0] AWID_M1,
	input [`AXI_ADDR_BITS-1:0] AWADDR_M1,
	input [`AXI_LEN_BITS-1:0] AWLEN_M1,
	input [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
	input [1:0] AWBURST_M1,
	input AWVALID_M1,
	output logic AWREADY_M1,
	
	//WRITE DATA
	input [`AXI_DATA_BITS-1:0] WDATA_M1,
	input [`AXI_STRB_BITS-1:0] WSTRB_M1,
	input WLAST_M1,
	input WVALID_M1,
	output logic WREADY_M1,
	
	//WRITE RESPONSE
	output logic [`AXI_ID_BITS-1:0] BID_M1,
	output logic [1:0] BRESP_M1,
	output logic BVALID_M1,
	input BREADY_M1,

	//READ ADDRESS0
	input [`AXI_ID_BITS-1:0] ARID_M0,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M0,
	input [`AXI_LEN_BITS-1:0] ARLEN_M0,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
	input [1:0] ARBURST_M0,
	input ARVALID_M0,
	output logic ARREADY_M0,
	
	//READ DATA0
	output logic [`AXI_ID_BITS-1:0] RID_M0,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M0,
	output logic [1:0] RRESP_M0,
	output logic RLAST_M0,
	output logic RVALID_M0,
	input RREADY_M0,
	
	//READ ADDRESS1
	input [`AXI_ID_BITS-1:0] ARID_M1,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M1,
	input [`AXI_LEN_BITS-1:0] ARLEN_M1,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
	input [1:0] ARBURST_M1,
	input ARVALID_M1,
	output logic ARREADY_M1,
	
	//READ DATA1
	output logic [`AXI_ID_BITS-1:0] RID_M1,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M1,
	output logic [1:0] RRESP_M1,
	output logic RLAST_M1,
	output logic RVALID_M1,
	input RREADY_M1,

	//MASTER INTERFACE FOR SLAVES
	//WRITE ADDRESS0
	output logic [`AXI_IDS_BITS-1:0] AWID_S0,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S0,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S0,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S0,
	output logic [1:0] AWBURST_S0,
	output logic AWVALID_S0,
	input AWREADY_S0,
	
	//WRITE DATA0
	output logic [`AXI_DATA_BITS-1:0] WDATA_S0,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S0,
	output logic WLAST_S0,
	output logic WVALID_S0,
	input WREADY_S0,
	
	//WRITE RESPONSE0
	input [`AXI_IDS_BITS-1:0] BID_S0,
	input [1:0] BRESP_S0,
	input BVALID_S0,
	output logic BREADY_S0,
	
	//WRITE ADDRESS1
	output logic [`AXI_IDS_BITS-1:0] AWID_S1,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S1,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S1,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S1,
	output logic [1:0] AWBURST_S1,
	output logic AWVALID_S1,
	input AWREADY_S1,
	
	//WRITE DATA1
	output logic [`AXI_DATA_BITS-1:0] WDATA_S1,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S1,
	output logic WLAST_S1,
	output logic WVALID_S1,
	input WREADY_S1,
	
	//WRITE RESPONSE1
	input [`AXI_IDS_BITS-1:0] BID_S1,
	input [1:0] BRESP_S1,
	input BVALID_S1,
	output logic BREADY_S1,
	
	//READ ADDRESS0
	output logic [`AXI_IDS_BITS-1:0] ARID_S0,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S0,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S0,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S0,
	output logic [1:0] ARBURST_S0,
	output logic ARVALID_S0,
	input ARREADY_S0,
	
	//READ DATA0
	input [`AXI_IDS_BITS-1:0] RID_S0,
	input [`AXI_DATA_BITS-1:0] RDATA_S0,
	input [1:0] RRESP_S0,
	input RLAST_S0,
	input RVALID_S0,
	output logic RREADY_S0,
	
	//READ ADDRESS1
	output logic [`AXI_IDS_BITS-1:0] ARID_S1,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S1,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S1,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S1,
	output logic [1:0] ARBURST_S1,
	output logic ARVALID_S1,
	input ARREADY_S1,
	
	//READ DATA1
	input [`AXI_IDS_BITS-1:0] RID_S1,
	input [`AXI_DATA_BITS-1:0] RDATA_S1,
	input [1:0] RRESP_S1,
	input RLAST_S1,
	input RVALID_S1,
	output logic RREADY_S1
	
);
    //---------- you should put your design here ----------//

logic [3:0] MRead0_target, MRead1_target;
logic [3:0] MWrite0_target, MWrite1_target;

logic [1:0] T0_M, T0_S;

// Master Ports
logic [50:0] M2S_Read [0:1];
//                           4 bit     32 bit     4 bit     3 bit      2 bit       1 bit       1 bit
assign M2S_Read[0] = {{4'd0, ARID_M0}, ARADDR_M0, ARLEN_M0, ARSIZE_M0, ARBURST_M0, ARVALID_M0, RREADY_M0};
assign M2S_Read[1] = {{4'd1, ARID_M1}, ARADDR_M1, ARLEN_M1, ARSIZE_M1, ARBURST_M1, ARVALID_M1, RREADY_M1};

Addr_decoder MRead0(.address(ARADDR_M0), .slaveID(MRead0_target));
Addr_decoder MRead1(.address(ARADDR_M1), .slaveID(MRead1_target));

logic [88:0] M2S_Write [0:1];
//                            4 bit     32 bit     4 bit     3 bit      2 bit       1 bit       32 bit    4 bit     1 bit     1 bit      1 bit
assign M2S_Write[0] = 85'd0;
assign M2S_Write[1] = {{4'd1, AWID_M1}, AWADDR_M1, AWLEN_M1, AWSIZE_M1, AWBURST_M1, AWVALID_M1, WDATA_M1, WSTRB_M1, WLAST_M1, WVALID_M1, BREADY_M1};

Addr_decoder MWrite0(.address(32'd0), .slaveID(MWrite0_target));
Addr_decoder MWrite1(.address(AWADDR_M1), .slaveID(MWrite1_target));


logic [44:0] S2M_Read [0:1];
//                    1 bit       8 bit   32 bit    2 bit     1 bit     1 bit
assign S2M_Read[0] = {ARREADY_S0, RID_S0, RDATA_S0, RRESP_S0, RLAST_S0, RVALID_S0};
assign S2M_Read[1] = {ARREADY_S1, RID_S1, RDATA_S1, RRESP_S1, RLAST_S1, RVALID_S1};

logic [19:0] S2M_Write [0:1];
//                     1 bit       8 bit      8 bit   2 bit     1 bit
assign S2M_Write[0] = {AWREADY_S0, WREADY_S0, BID_S0, BRESP_S0, BVALID_S0};
assign S2M_Write[1] = {AWREADY_S1, WREADY_S1, BID_S1, BRESP_S1, BVALID_S1};


Arbiter u_Arbiter(
	.ACLK(ACLK),
	.ARESETn(ARESETn),
	.ARVALID_M0(ARVALID_M0),
	.ARVALID_M1(ARVALID_M1),
	.AWVALID_M0(1'b0),   // Master 0 not perform write
	.AWVALID_M1(AWVALID_M1),
	.MRead0_target(MRead0_target),
	.MRead1_target(MRead1_target),
	.MWrite0_target(MWrite0_target),
	.MWrite1_target(MWrite1_target),

	.ARREADY_S0(ARREADY_S0),
	.ARREADY_S1(ARREADY_S1),
	.AWREADY_S0(AWREADY_S0),
	.AWREADY_S1(AWREADY_S1),

	.RLAST_S0(RLAST_S0),
	.RLAST_S1(RLAST_S1),
	.BVALID_S0(BVALID_S0),
	.BVALID_S1(BVALID_S1),

	.T0_M(T0_M),
	.T0_S(T0_S)
	);


logic [40:0] MRead_out [0:1];
//      1 bit       4 bit   32 bit    2 bit     1 bit     1 bit
assign {ARREADY_M0, RID_M0, RDATA_M0, RRESP_M0, RLAST_M0, RVALID_M0} = MRead_out[0];
assign {ARREADY_M1, RID_M1, RDATA_M1, RRESP_M1, RLAST_M1, RVALID_M1} = MRead_out[1];

logic [15:0] MWrite_out [0:1];
//      1 bit       8 bit      4 bit   2 bit     1 bit
//assign {AWREADY_M0, WREADY_M0, BID_M0, BRESP_M0, BVALID_M0} = MWrite_out[0];
assign {AWREADY_M1, WREADY_M1, BID_M1, BRESP_M1, BVALID_M1}  = MWrite_out[1];



logic [50:0] SRead_out [0:1];
//      8 bit    32 bit     4 bit     3 bit      2 bit       1 bit       1 bit
assign {ARID_S0, ARADDR_S0, ARLEN_S0, ARSIZE_S0, ARBURST_S0, ARVALID_S0, RREADY_S0} = SRead_out[0];
assign {ARID_S1, ARADDR_S1, ARLEN_S1, ARSIZE_S1, ARBURST_S1, ARVALID_S1, RREADY_S1} = SRead_out[1];

logic [88:0] SWrite_out [0:1];
//     8 bit     32 bit     4 bit     3 bit      2 bit       1 bit       32 bit    4 bit     1 bit     1 bit      1 bit
assign {AWID_S0, AWADDR_S0, AWLEN_S0, AWSIZE_S0, AWBURST_S0, AWVALID_S0, WDATA_S0, WSTRB_S0, WLAST_S0, WVALID_S0, BREADY_S0} = SWrite_out[0];
assign {AWID_S1, AWADDR_S1, AWLEN_S1, AWSIZE_S1, AWBURST_S1, AWVALID_S1, WDATA_S1, WSTRB_S1, WLAST_S1, WVALID_S1, BREADY_S1} = SWrite_out[1];


integer i;
// Transaction 1
always_comb begin
	for(i=0; i<2; i=i+1) begin
		MRead_out[i]  = 41'd0;
		MWrite_out[i] = 20'd0;
		SRead_out[i]  = 51'd0;
		SWrite_out[i] = 85'd0;
	end
	if(T0_M != 2'b11 && T0_S != 2'b11) begin  // 2'b11 means no master and slave need to connect.
		MRead_out[T0_M]  = {S2M_Read[T0_S][44], S2M_Read[T0_S][39:0]}; // 40~43 is master target
		MWrite_out[T0_M] = {S2M_Write[T0_S][19:11], S2M_Write[T0_S][6:0]};
		SRead_out[T0_S]  = M2S_Read[T0_M];
		SWrite_out[T0_S] = M2S_Write[T0_M];
	end
end

endmodule
