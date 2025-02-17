module AXI_Slave(
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
    input                                BREADY_S,

    // SRAM
    output logic CEB_S,
    output logic WEB_S,
    output logic [`AXI_ADDR_BITS-1:0] A_S,    // Read/Write address to SRAM
    output logic [`AXI_DATA_BITS-1:0] DI_S,   // Write data to SRAM
    output logic [`AXI_STRB_BITS-1:0] BWEB_S, // Write select
    input  [`AXI_DATA_BITS-1:0] DO_S          // Read data from SRAM

	);

localparam MaxBurst = 4;  // Determine by user
logic [2:0] BurstCnt;

// All handshake(HS) signals
logic ARHS, RHS, AWHS, WHS, BHS; 
assign ARHS = ARVALID_S && ARREADY_S;
assign RHS  = RVALID_S  && RREADY_S;
assign AWHS = AWVALID_S && AWREADY_S;
assign WHS  = WVALID_S  && WREADY_S;
assign BHS  = BVALID_S  && BREADY_S;

// State
typedef enum logic [2:0]{
	RST        = 3'd0,
    STANDBY    = 3'd1,
    READ_BUSY  = 3'd2,
    WRITE_BUSY = 3'd3,
    RESPONSE   = 3'd4
    } state_t;

state_t state, ntState;
always_ff@(posedge ACLK, negedge ARESETn) begin
	if(!ARESETn) begin
		state <= RST;
	end
	else begin
		state <= ntState;
	end
end

always_comb begin
	RID_S = ARID_S;
	RDATA_S = (state==READ_BUSY && RHS)? DO_S : 32'd0;
	RRESP_S = (state==READ_BUSY && BurstCnt>MaxBurst)? `AXI_RESP_SLVERR : `AXI_RESP_OKAY;  // In this design, slave can just support Burst=4, it out of boundary it need to send error.
	RLAST_S = (state==READ_BUSY && BurstCnt==(ARLEN_S+1) );
	BID_S = AWID_S;
	BRESP_S = (state==RESPONSE && (BurstCnt>MaxBurst))? `AXI_RESP_SLVERR : `AXI_RESP_OKAY;
end

// To SRAM
always_comb begin
	case(state)
		RST: begin
			CEB_S = 1'b1;
			WEB_S = 1'b1;
			A_S   = ARADDR_S;
			BWEB_S = 4'b1111;
			DI_S  = 32'd0;
		end
		STANDBY: begin   // In standby state, both Ready is assert.
			CEB_S = 1'b1;
			WEB_S = 1'b1;
			A_S   = ARADDR_S;
			BWEB_S = 4'b1111;
			DI_S  = 32'd0;
		end
		READ_BUSY: begin
			CEB_S = 1'b0;
			WEB_S = 1'b1;
			A_S   = ARADDR_S;
			BWEB_S = 4'b1111;
			DI_S  = 32'd0;
		end
		WRITE_BUSY: begin
			CEB_S = 1'b0;
			WEB_S = 1'b0;  // Write
			A_S   = AWADDR_S;
			BWEB_S = (WHS)? WSTRB_S : 4'b1111;
			DI_S  = (WHS)? WDATA_S : 32'd0;
		end
		RESPONSE: begin
			CEB_S = 1'b1;
			WEB_S = 1'b1;
			A_S   = ARADDR_S;
			BWEB_S = 4'b1111;
			DI_S  = 32'd0;
		end
		default: begin
			CEB_S = 1'b1;
			WEB_S = 1'b1;
			A_S   = ARADDR_S;
			BWEB_S = 4'b1111;
			DI_S  = 32'd0;
		end
	endcase
end

always_ff @(posedge ACLK, negedge ARESETn) begin
	if(!ARESETn) begin
		BurstCnt <= 3'd1;
	end 
	else begin
		if(state==READ_BUSY || state==WRITE_BUSY) begin
			BurstCnt <= (BurstCnt==(ARLEN_S+1))? BurstCnt : BurstCnt+1;
		end
		else BurstCnt <= 3'd1;
	end
end


always_comb begin
	case(state)
		RST: begin
			ARREADY_S = 1'b0;
			RVALID_S  = 1'b0;
			AWREADY_S = 1'b0;
			WREADY_S  = 1'b0;
			BVALID_S  = 1'b0;
		end
		STANDBY: begin   // In standby state, both Ready is assert.
			ARREADY_S = 1'b1;
			RVALID_S  = 1'b0;
			AWREADY_S = 1'b1;
			WREADY_S  = 1'b0;
			BVALID_S  = 1'b0;
		end
		READ_BUSY: begin
			ARREADY_S = 1'b0;
			RVALID_S  = 1'b1;
			AWREADY_S = 1'b0;
			WREADY_S  = 1'b0;
			BVALID_S  = 1'b0;
		end
		WRITE_BUSY: begin
			ARREADY_S = 1'b0;
			RVALID_S  = 1'b0;
			AWREADY_S = 1'b0;
			WREADY_S  = 1'b1;
			BVALID_S  = 1'b0;
		end
		RESPONSE: begin
			ARREADY_S = 1'b0;
			RVALID_S  = 1'b0;
			AWREADY_S = 1'b0;
			WREADY_S  = 1'b0;
			BVALID_S  = 1'b1;
		end
		default: begin
			ARREADY_S = 1'b0;
			RVALID_S  = 1'b0;
			AWREADY_S = 1'b0;
			WREADY_S  = 1'b0;
			BVALID_S  = 1'b0;
		end
	endcase
end


always_comb begin
	case(state)
		RST: ntState = (!ARESETn)? RST : STANDBY;
		STANDBY: begin
			if(ARHS) ntState = READ_BUSY;
			else if(AWHS) ntState = WRITE_BUSY;
			else ntState = STANDBY;
		end
		READ_BUSY: begin
			ntState = (RLAST_S)? STANDBY : READ_BUSY;
		end
		WRITE_BUSY: begin
			ntState = (WLAST_S)? RESPONSE : WRITE_BUSY;
		end
		RESPONSE: begin
			ntState = (BHS)? STANDBY : RESPONSE;
		end
		default: ntState = RST;
	endcase
end


endmodule