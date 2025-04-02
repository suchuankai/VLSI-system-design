module DRAM_wrapper(
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

    // To DRAM signals
    input VALID,
    input [31:0] Q,
    output logic CSn,
    output logic [3:0] WEn,
    output logic RASn,
    output logic CASn,
    output logic [10:0] A,
    output logic [31:0] D
    );


  // SRAM ports
  logic CEB;
  logic WEB;
  logic [3:0] BWEB;
  logic [31:0] DI;
  logic [31:0] DO;
  logic [31:0] DI_S;
  logic [31:0] A_S;
  logic read_en, write_en;

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

    .read_en(read_en),
    .write_en(write_en),
    .CEB_S(CEB),
    .WEB_S(WEB),
    .A_S(A_S),
    .DI_S(DI_S),
    .BWEB_S(BWEB),
    .DO_S(Q)
  );

logic rst;
assign rst = ~ARESETn;

typedef enum logic [1:0]{
    WAITHS    = 2'd0,
    PRECHARGE = 2'd1,
    ROWSEL    = 2'd2,
    COLSEL    = 2'd3
} state_t;

state_t state, ntstate;

logic [2:0] pre_cnt, row_cnt, col_cnt, len_cnt;
logic [3:0] ARLEN_S_reg, AWLEN_S_reg;
logic ARHS, AWHS, ARWHS;
logic read_write;
assign ARHS = (ARVALID_S && ARREADY_S);
assign AWHS = (AWVALID_S && AWREADY_S);
assign ARWHS = ARHS || AWHS;

logic burst_done;
assign burst_done = (state == COLSEL) && ( (len_cnt == ARLEN_S_reg && !read_write) || (len_cnt == AWLEN_S_reg && read_write) );

assign read_en = VALID;
assign write_en = (col_cnt == 3'd5 && read_write);

logic [11:0] rowAddrBuf;
logic [31:0] addr;

always_ff@(posedge ACLK, posedge rst) begin
    if(rst) begin
        state <= PRECHARGE;
    end
    else begin
        state <= ntstate;
    end
end

// Next state logic
always_comb begin
    case(state)
        WAITHS: ntstate = (ARWHS)? PRECHARGE : WAITHS;
        PRECHARGE: begin
            if(pre_cnt == 3'd4)
                if(rowAddrBuf == A_S[22:12]) ntstate = COLSEL; // Hit
                else ntstate = ROWSEL;
            else ntstate = PRECHARGE;
        end
        ROWSEL: ntstate = (row_cnt == 3'd4)? COLSEL : ROWSEL;
        COLSEL: ntstate = (col_cnt == 3'd5 && burst_done)? WAITHS : COLSEL;
    endcase
end

// Store burst length and determine read / write
always_ff@(posedge ACLK, posedge rst) begin
    if(rst) begin
        ARLEN_S_reg <= 4'd0;
        AWLEN_S_reg <= 4'd0;
        read_write <= 1'b0;  // Low -> Read / High -> Write 
    end
    else begin
        if(ARHS) begin
            ARLEN_S_reg <= ARLEN_S;
            read_write <= 1'b0;
        end
        else if(AWHS) begin
            AWLEN_S_reg <= AWLEN_S;
            read_write <= 1'b1;
        end
    end
end

// Store last row address
always_ff@(posedge ACLK, posedge rst) begin
    if(rst) begin
        rowAddrBuf <= 11'd0;
    end
    else begin
        rowAddrBuf <= (state==ROWSEL && row_cnt==3'd4)? A_S[22:12] : rowAddrBuf;
    end
end

always_ff@(posedge ACLK, posedge rst) begin
    if(rst) begin
        D <= 32'd0;
    end
    else begin
        if(state == COLSEL && !CASn) D <= DI_S;
    end
end

// Counters 
always_ff@(posedge ACLK, posedge rst) begin
    if(rst) begin
        pre_cnt <= 3'd0;
        row_cnt <= 3'd0;
        col_cnt <= 3'd0;
        len_cnt <= 3'd0;
    end
    else begin
        case(state)
            WAITHS: begin
                pre_cnt <= 3'd0;
                col_cnt <= 3'd0;
            end
            PRECHARGE: begin
                pre_cnt <= (pre_cnt == 3'd4)? 3'd0 : pre_cnt + 1;
            end
            ROWSEL: begin
                row_cnt <= (row_cnt == 3'd4)? 3'd0 : row_cnt + 1;
                col_cnt <= 3'd0;
            end
            COLSEL: begin
                if(col_cnt == 3'd5) begin
                    len_cnt <= (burst_done)? 3'd0 : len_cnt + 1;
                end
                col_cnt <= (col_cnt == 3'd5)? 3'd0 : col_cnt + 1;
            end
        endcase
    end
end

// DRAM Control signals
always_comb begin
    case(state)
        WAITHS: begin
            CSn  = 1'b0;
            RASn = 1'b1;
            CASn = 1'b1;
            WEn = 4'hf;
            A = 11'd0;
        end
        PRECHARGE: begin
            CSn  = 1'b0;  // Chip select always enable.
            RASn = (pre_cnt == 3'd4)? 1'b0 : 1'b1;
            CASn = 1'b1;
            WEn = 4'h0;
            A = rowAddrBuf;
        end
        ROWSEL: begin
            CSn  = 1'b0;
            RASn = (row_cnt == 3'd4)? 1'b0 : 1'b1;
            CASn = 1'b1;
            WEn = 4'hf;
            A = A_S[22:12];
        end
        COLSEL: begin
            CSn  = 1'b0;
            RASn = 1'b1;
            CASn = (col_cnt == 3'd5)? 1'b0 : 1'b1;
            WEn = (col_cnt == 3'd5 && read_write)? BWEB : 4'hf;
            A = {1'b0, A_S[11:2]};
        end
    endcase
end


endmodule