module DMA_controller(
	input clk,
	input rst,
	input [31:0] s_addr,   // DMA slave write address
	input [31:0] s_data,   // DMA slave write data
	input s_en,     // DMA slave write enable

	input r_valid,  // Master Read  handshakes
	input w_valid,  // Master Write handshakes
	input [31:0] readData,

	output logic [31:0] addr,  
	output logic [3:0] bweb,
	output logic [31:0] write_data,
	output logic [3:0] burst_len,
	output logic CEB,
	output logic WEB,
	output logic interrupt_dma
	);


integer i;
// localparam BURST = 8;

logic [31:0] buffer [0:4];
logic [31:0] read_addr, write_addr;

typedef enum logic [1:0]{
	ACCEPT = 2'd0,
    READ   = 2'd1,
    WRITE  = 2'd2,
    FINISH = 2'd3
    } state_t;

state_t state, ntState;

logic DMAEN_reg; 
logic [31:0] DMASRC_reg, DMADST_reg, DMALEN_reg;

logic [2:0] cnt;
logic [31:0] len_cnt;  // Caculate how much data already processed.
logic last;
assign last = ((DMALEN_reg-len_cnt) <= 16); // Relate to burst length .

// DMA control registers
always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		DMAEN_reg  <= 1'b0;
		DMASRC_reg <= 32'd0;
		DMADST_reg <= 32'd0;
		DMALEN_reg <= 32'd0; 
	end
	else begin
		if( (state == ACCEPT || state == FINISH) && s_en) begin
			case(s_addr)
				32'h10020100: DMAEN_reg  <= s_data[0];
				32'h10020200: DMASRC_reg <= s_data;
				32'h10020300: DMADST_reg <= s_data;
				32'h10020400: DMALEN_reg <= s_data << 2; // Word to byte address representation
			endcase
		end
	end
end

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		state <= ACCEPT;
	end
	else begin
		state <= ntState;
	end
end

// Addr / bweb
always_comb begin
	case(state)
		ACCEPT: begin
			addr = read_addr; 
			bweb = 4'hf;
		end
		READ: begin  
			addr = read_addr; 
			bweb = 4'hf;
		end
		WRITE: begin 
			addr = write_addr; 
			bweb = 4'h0;
		end
		FINISH: begin
			addr = write_addr; 
			bweb = 4'hf;
		end
	endcase
end

// FSM
always_comb begin
	case(state)
		ACCEPT: ntState = (DMAEN_reg)? READ : ACCEPT;
		READ: ntState = (cnt==burst_len && r_valid)? WRITE : READ;
		WRITE: begin
			if(cnt==burst_len && w_valid) begin
				if(last) ntState = FINISH;
				else ntState = READ;
			end
			else ntState = WRITE;
		end
		FINISH: ntState = (DMAEN_reg)? FINISH : ACCEPT;
	endcase
end


always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		len_cnt <= 32'd0;
	end
	else begin
		if(state == WRITE && cnt == 3'd3 && w_valid) begin
			len_cnt <= len_cnt + ((burst_len + 1) << 2);
		end
		else if(state == FINISH) len_cnt <= 32'd0;
	end
end


always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		burst_len <= 4'd0;
	end
	else begin
		if(last) burst_len <= ((DMALEN_reg-len_cnt) >> 2) - 1;
		else if(read_addr[11:2]==10'b1111_1111_11 || write_addr[11:2]==10'b1111_1111_11) burst_len <= 0;  // Avoid DRAM read between two row
		else if(read_addr[11:2]==10'b1111_1111_10 || write_addr[11:2]==10'b1111_1111_10) burst_len <= 1;
		else if(read_addr[11:2]==10'b1111_1111_01 || write_addr[11:2]==10'b1111_1111_01) burst_len <= 2;
		else burst_len <= 3;
	end
end


always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		for(i=0; i<5; i=i+1) begin
			buffer[i] <= 32'd0;
		end
		cnt <= 3'd0;
		write_addr <= 32'd0;
	end
	else begin
		case(state)
			ACCEPT: begin
				if(DMAEN_reg) begin  // Master2 start read operation
					read_addr <= DMASRC_reg;
					write_addr <= DMADST_reg;
				end
			end
			READ: begin
				if(r_valid) begin
					cnt <= (cnt==burst_len)? 3'd0 : cnt + 1;
				end
				buffer[cnt] <= readData;
			end
			WRITE: begin
				if(w_valid) begin
					cnt <= (cnt==burst_len)? 3'd0 : cnt + 1;
					if(cnt==burst_len) begin  // Start back to Read
						write_addr <= write_addr + ((burst_len + 1) << 2);
						read_addr <= read_addr + ((burst_len + 1) << 2);
					end
				end
			end
		endcase
	end
end


always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		CEB <= 1'b1;  // enable
		WEB <= 1'b1;  // Read
		interrupt_dma <= 1'b0;
	end
	else begin
		case(state)
			ACCEPT: begin
				if(DMAEN_reg) begin  // Master2 start read operation
					CEB <= 1'b0;     // enable
					WEB <= 1'b1;     // Read
				end
				interrupt_dma <= 1'b0;
			end
			READ: begin
				if(cnt==burst_len) begin  // Start to write
					CEB <= 1'b0;     // enable
					WEB <= 1'b0;     // Write
				end
			end
			WRITE: begin
				if(cnt==burst_len) begin  // Start back to Read
					CEB <= 1'b0;     // enable
					WEB <= 1'b1;     // Read
				end
			end
			FINISH: begin
				CEB <= 1'b1;         // disble
				WEB <= 1'b1;         // Read
				interrupt_dma <= 1'b1;
			end
		endcase
	end
end


always_comb begin
	case(state)
		READ: begin
			write_data = buffer[0];
		end
		WRITE: begin
			if(w_valid) write_data = buffer[cnt+1];
			else write_data = buffer[cnt];
		end
		default: begin
			write_data = 32'd0;
		end
	endcase
end

endmodule