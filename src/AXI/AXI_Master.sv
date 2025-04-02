module AXI_Master(

    input clk, 
    input rst,
    input CEB, // Memory access request
    input WEB, // Read->active high | Write->active low 
    input [31:0] addr,
    input [3:0] bweb,
    input [31:0] writeData,
    input [`AXI_LEN_BITS-1:0] burst_len,
    output logic [31:0] readData,
    output logic busBusy,   	// When bus busy is 1, stall the cpu

    // 1. AR channel (Read)
    output logic  [`AXI_ID_BITS-1:0]     ARID_M, 
    output logic  [`AXI_ADDR_BITS-1:0]   ARADDR_M, 
    output logic  [`AXI_LEN_BITS-1:0]    ARLEN_M,  // Nead to modify
    output logic  [`AXI_SIZE_BITS-1:0]   ARSIZE_M, 
    output logic  [`USER_BURST_BITS-1:0] ARBURST_M, 
    output logic                         ARVALID_M, 
    input                                ARREADY_M, 
     
    // 2. R channel (Read)
    input         [`AXI_ID_BITS-1:0]     RID_M, 
    input         [`AXI_DATA_BITS-1:0]   RDATA_M, 
    input         [`USER_RRESP_BITS-1:0] RRESP_M, 
    input                                RLAST_M, 
    input                                RVALID_M, 
    output logic                         RREADY_M,
    
    // 3. AW channel (Write) 
    output logic [`AXI_ID_BITS-1:0]     AWID_M, 
    output logic [`AXI_ADDR_BITS-1:0]   AWADDR_M, 
    output logic [`AXI_LEN_BITS-1:0]    AWLEN_M, 
    output logic [`AXI_SIZE_BITS-1:0]   AWSIZE_M, 
    output logic [`USER_BURST_BITS-1:0] AWBURST_M, 
    output logic                        AWVALID_M, 
    input                               AWREADY_M, 

    // 4. W channel (Write)
    output logic [`AXI_DATA_BITS-1:0]   WDATA_M, 
    output logic [`AXI_STRB_BITS-1:0]   WSTRB_M, 
    output logic                        WLAST_M, 
    output logic                        WVALID_M, 
    input                               WREADY_M, 

    // 5. B channel (Write)
    input  [`AXI_ID_BITS-1:0]     BID_M, 
    input  [`USER_BRESP_BITS-1:0] BRESP_M, 
    input                         BVALID_M, 
    output logic                  BREADY_M 
    );


// State
typedef enum logic [2:0] { 
    RST           = 3'd0,
    STANDBY       = 3'd1,
    RADDR_VALID   = 3'd2, 
    READ_BUSY     = 3'd3,
    WADDR_VALID   = 3'd4,
    WRITE_BUSY    = 3'd5,
    WAIT_RESPONSE = 3'd6
} state_t;

state_t state, ntState;

always_ff@(posedge clk, negedge rst) begin
    if(!rst) begin
        state <= RST;
    end
    else begin
	state <= ntState;
    end
end

logic ARHS, RHS, AWHS, WHS, BHS;

assign ARHS = ARVALID_M && ARREADY_M;
assign RHS  = RVALID_M  && RREADY_M;
assign AWHS = AWVALID_M && AWREADY_M;
assign WHS  = WVALID_M  && WREADY_M;
assign BHS  = BVALID_M  && BREADY_M;

logic [`AXI_ADDR_BITS-1:0] ARADDR_M_reg;
logic [`AXI_ADDR_BITS-1:0] AWADDR_M_reg;
logic [3:0] bweb_reg;
logic [31:0] writeData_reg;
logic [2:0] burst_cnt;

// Data
always_comb begin
    // AR channel
    ARID_M = `AXI_ID_BITS'd0;  // Master 4 bit
    ARADDR_M = ARADDR_M_reg;
    ARLEN_M  = burst_len; // Read burst length
    ARSIZE_M = `AXI_SIZE_BITS'd2; // 4Bytes
    ARBURST_M = `AXI_BURST_INC;
    // R channel
    readData = (state==READ_BUSY && RHS)? RDATA_M : 32'd0;
    // AW channel
    AWID_M = `AXI_ID_BITS'd0;  // Master 4 bit
    AWADDR_M = AWADDR_M_reg;
    AWLEN_M = burst_len;  // Write burst length
    AWSIZE_M = `AXI_SIZE_BITS'd2; // 4Bytes
    AWBURST_M = `AXI_BURST_INC;
    WDATA_M = (state==WRITE_BUSY && WHS)? writeData_reg : writeData_reg;
    WSTRB_M = (state==WRITE_BUSY && WHS)? bweb_reg : 4'b1111;
    WLAST_M = (state==WRITE_BUSY && (burst_cnt==AWLEN_M+1)); // Master burst = 1
end

always_ff@(posedge clk, negedge rst) begin
    if(!rst) begin
	burst_cnt <= 3'd1;
    end
    else begin
	if(state == WRITE_BUSY) begin
	    if(WHS) burst_cnt <= (burst_cnt==AWLEN_M+1)? burst_cnt : burst_cnt + 1;
	end
	else burst_cnt <= 3'd1;
    end
end

logic [31:0] writeData_reg_test;
logic test1, test2;
assign test1 = state==STANDBY && !WEB;
assign test2 = state==WRITE_BUSY && WHS;
always_ff@(posedge clk, negedge rst) begin
    if(!rst) begin
	ARADDR_M_reg <= 32'd0;
	AWADDR_M_reg <= 32'd0;
	bweb_reg <= 4'b1111;
	writeData_reg <= 32'd0;
    end
    else begin
	ARADDR_M_reg <= (state==STANDBY)? addr : ARADDR_M_reg;
	AWADDR_M_reg <= (state==STANDBY)? addr : AWADDR_M_reg;
	bweb_reg <= (state==STANDBY)? bweb : bweb_reg;
	writeData_reg <= ((state==STANDBY && !WEB) || (state==WRITE_BUSY && WHS) )? writeData : writeData_reg;
	writeData_reg_test <= ((state==STANDBY) || (state==WRITE_BUSY && WHS) )? writeData : writeData_reg_test;
    end
end


// Signal to Stall cpu
always_comb begin
    if(state==RST || state==STANDBY) busBusy = 0; // Only when finish the read/write operation set 0. 
    else busBusy = 1;
end

// Handshake signals
always_comb begin
    case(state)
	RST: begin
	    ARVALID_M = 1'b0;
	    RREADY_M  = 1'b0;
	    AWVALID_M = 1'b0;
	    WVALID_M  = 1'b0;
	    BREADY_M  = 1'b0;
	end
	STANDBY: begin
	    ARVALID_M = 1'b0;
	    RREADY_M  = 1'b0;
	    AWVALID_M = 1'b0;
	    WVALID_M  = 1'b0;
	    BREADY_M  = 1'b0;
	end
	RADDR_VALID: begin
	    ARVALID_M = 1'b1;
	    RREADY_M  = 1'b0;
	    AWVALID_M = 1'b0;
	    WVALID_M  = 1'b0;
	    BREADY_M  = 1'b0;
	end
	READ_BUSY: begin
	    ARVALID_M = 1'b0;
	    RREADY_M  = 1'b1;
	    AWVALID_M = 1'b0;
	    WVALID_M  = 1'b0;
	    BREADY_M  = 1'b0;
	end
	WADDR_VALID: begin
	    ARVALID_M = 1'b0;
	    RREADY_M  = 1'b0;
	    AWVALID_M = 1'b1;
	    WVALID_M  = 1'b0;
	    BREADY_M  = 1'b0;
	end
	WRITE_BUSY: begin
	    ARVALID_M = 1'b0;
	    RREADY_M  = 1'b0;
	    AWVALID_M = 1'b0;
	    WVALID_M  = 1'b1;
	    BREADY_M  = 1'b0;
	end
	WAIT_RESPONSE: begin
	    ARVALID_M = 1'b0;
	    RREADY_M  = 1'b0;
	    AWVALID_M = 1'b0;
	    WVALID_M  = 1'b0;
	    BREADY_M  = 1'b1;
	end
	default: begin
	    ARVALID_M = 1'b0;
	    RREADY_M  = 1'b0;
	    AWVALID_M = 1'b0;
	    WVALID_M  = 1'b0;
	    BREADY_M  = 1'b0;
	end
    endcase
end


// FSM control
always_comb begin
    case(state)
	RST: ntState = (rst)? STANDBY : RST;
	STANDBY: begin
	    if(CEB) ntState = STANDBY;           // No memory access request
	    else if(WEB) ntState = RADDR_VALID;  // Read
	    else ntState = WADDR_VALID;          // Write
	end
	RADDR_VALID: begin
	    ntState = (ARHS)? READ_BUSY : RADDR_VALID;
	end
	READ_BUSY: begin // If handshake compeleted, start read data until RLAST signal.
	    if(RRESP_M!=`AXI_RESP_OKAY && RLAST_M) ntState = RADDR_VALID;  // Request again
	    else ntState = (RHS && RLAST_M)? STANDBY : READ_BUSY;
	end
	WADDR_VALID: begin
	    ntState = (AWHS)? WRITE_BUSY : WADDR_VALID;
        end
	WRITE_BUSY: begin // If handshake compeleted, start write data until WLAST signal.
	    ntState = (WHS && WLAST_M)? WAIT_RESPONSE : WRITE_BUSY;
	end
	WAIT_RESPONSE: begin
	    if(BRESP_M!=`AXI_RESP_OKAY && BHS) ntState = WADDR_VALID; // Request again
	    else ntState = (BHS)? STANDBY : WAIT_RESPONSE;
	end
    endcase
end

endmodule