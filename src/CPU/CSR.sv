module CSR(
	input clk, 
	input rst,
	input [1:0] busStall,
	input [1:0] pc_sel, 
	input [31:0] instr,
	input [31:0] rs1_data,
	input isWFI,
	input interrupt_re,
	input interrupt_dma,
	input interrupt_timer,
	input [31:0] pcInterrupt,
	output logic isCSR,
	output logic [31:0] CSR_out,
	output logic [31:0] mtvec,   // In this design, fix to 32'h0001_0000.
	output logic [31:0] mepc,
	output logic interrupt
	);

logic [6:0] opcode;
logic [10:0] imm12;
logic [3:0] csr_sel, csr_sel_reg;
logic [63:0] cycleCnt, instretCnt;

assign opcode = instr[6:0];
assign imm12 = instr[31:20]; 

logic [31:0] mstatus, mie, mip;

// Interrupt conditions
logic global_en, timer_trigger, external_trigger;
assign global_en = mstatus[3];
assign timer_trigger = mip[7] & mie[7];
assign external_trigger = mip[11] & mie[11];

always_comb begin
	interrupt = (global_en||isWFI) && (timer_trigger | external_trigger);
end


always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		isCSR <= 1'b0;
	end
	else begin
		isCSR <= (opcode==`CSR)? 1'b1 : 1'b0;
	end
end

always_comb begin
	if(imm12 == 12'h300) csr_sel = 4'b0100;      // mstatus
	else if(imm12 == 12'h304) csr_sel = 4'b0101; // mie
	else if(imm12 == 12'h305) csr_sel = 4'b0110; // mtvec
	else if(imm12 == 12'h341) csr_sel = 4'b0111; // mepc
	else if(imm12 == 12'h344) csr_sel = 4'b1000; // mip
	else csr_sel = {2'b00, imm12[7], imm12[1]};
end

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		csr_sel_reg <= 4'b0000;
	end
	else begin
		csr_sel_reg <= csr_sel;
	end
end

// For CSR instructions
logic [2:0] csr_type;
logic [31:0] uimm;
logic [4:0] rs1;

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		csr_type <= 3'b000;
		uimm <= 5'd0;
	end 
	else begin
		csr_type <= instr[14:12];  // funct3
		uimm <= {26'd0, instr[19:15]};  
		rs1 <= instr[19:15];
	end
end

logic [31:0] csr_in;
assign csr_in = (csr_type[2])? uimm : rs1_data;

// mstatus
always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		mstatus <= 32'd0;
	end
	else begin
		if(interrupt) begin
			mstatus[7] <= mstatus[3];
			mstatus[3] <= 1'b0;
			mstatus[12:11] = 2'b11;
		end
		else if(interrupt_re) begin
			mstatus[7] <= 1'b1;
			mstatus[3] <= mstatus[7];
			mstatus[12:11] = 2'b11;
		end
		else if(isCSR && csr_sel_reg==4'b0100) begin
			case(csr_type[1:0])
				2'b00: mstatus <= mstatus;
				2'b01: begin 
					mstatus[3] <= csr_in[3];
					mstatus[7] <= csr_in[7];
					mstatus[12:11] <= csr_in[12:11];
				end
				2'b10: begin
					mstatus[3] <= mstatus[3] | csr_in[3];
					mstatus[7] <= mstatus[7] | csr_in[7];
					mstatus[12:11] <= mstatus[12:11] | csr_in[12:11];
				end
				2'b11: begin
					mstatus[3] <= mstatus[3] & (~csr_in[3]);
					mstatus[7] <= mstatus[7] & (~csr_in[7]);
					mstatus[12:11] <= mstatus[12:11] & (~csr_in[12:11]);
				end
			endcase
		end
	end
end

// mie
always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		mie <= 32'd0;
	end
	else begin
		if(isCSR && csr_sel_reg==4'b0101) begin
			case(csr_type[1:0])
				2'b00: mie <= mie;
				2'b01: begin
					mie[7] <= csr_in[7];
					mie[11] <= csr_in[11];
				end
				2'b10: begin
					mie[7] <= mie[7] | csr_in[7];
					mie[11] <= mie[11] | csr_in[11];
				end
				2'b11: begin
					mie[7] <= mie[7] & (~csr_in[7]);
					mie[11] <= mie[11] & (~csr_in[11]);
				end
			endcase
		end
	end
end

// mtvec
always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		mtvec <= 32'h0001_0000;
	end
	else begin
		mtvec <= 32'h0001_0000;
	end
end

// mepc
always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		mepc <= 32'd0;
	end
	else begin
		if(interrupt) begin
			if(isWFI) mepc <= pcInterrupt; // PC + 4
			else mepc <= pcInterrupt - 4;  // PC
		end
		else if(isCSR && csr_sel_reg==4'b0111) begin
			case(csr_type[1:0])
				2'b00: mepc <= mepc;
				2'b01: mepc <= csr_in;
				2'b10: mepc <= mepc | csr_in;
				2'b11: mepc <= mepc & (~csr_in);
			endcase
		end
	end
end

// mip
always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		mip <= 32'd0;
	end
	else begin
		if(isCSR && csr_sel_reg==4'b1000) begin
			case(csr_type[1:0])
				2'b00: mip <= mip;
				2'b01: begin
					mip[7] <= csr_in[7];
					mip[11] <= csr_in[11];
				end
				2'b10: begin
					mip[7] <= mip[7] | csr_in[7];
					mip[11] <= mip[11] | csr_in[11];
				end
				2'b11: begin
					mip[7] <= mip[7] & (~csr_in[7]);
					mip[11] <= mip[11] & (~csr_in[11]);
				end
			endcase
		end
		else begin
			mip[7] <= interrupt_timer;
			mip[11] <= interrupt_dma;
		end
	end
end

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		cycleCnt <= 64'd0;
	end
	else begin
		cycleCnt <= cycleCnt + 64'd1;
	end
end 

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		instretCnt <= 64'd0;
	end
	else begin
		if(cycleCnt!=64'd0 && busStall == 2'b00) begin
			case(pc_sel)
				2'b00: begin
					instretCnt <= instretCnt + 64'd1;  // Normal case
				end
				2'b01: begin
					instretCnt <= instretCnt;  // Flush 2 instructions 
				end
				2'b10: begin
					instretCnt <= instretCnt;  // Stall(Load use)
				end
			endcase
		end
	end
end 

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		CSR_out <= 32'd0;
	end
	else begin 
		if(opcode==`CSR) begin
			case(csr_sel)
				4'b0000: CSR_out <= cycleCnt[31:0];    // RDCYCLE
				4'b0001: CSR_out <= instretCnt[31:0];  // RDINSTRET
				4'b0010: CSR_out <= cycleCnt[63:32];   // RDCYCLEH
				4'b0011: CSR_out <= instretCnt[63:32]; // RDINSTRETH
				4'b0100: CSR_out <= mstatus;
				4'b0101: CSR_out <= mie;
				4'b0110: CSR_out <= mtvec;
				4'b0111: CSR_out <= mepc;
				4'b1000: CSR_out <= mip;
				default: CSR_out <= 32'd0;
			endcase
		end
		else CSR_out <= 32'd0;
	end
end

endmodule