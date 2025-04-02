module Controller(
	input clk, 
	input rst,
	input [1:0] busStall,
	input interrupt,
	input [6:0] opcode,
	input [2:0] funct3,
	input [6:0] funct7,
	input [5:0] rs1_addr,
	input [5:0] rs2_addr,
	input [5:0] rd_addr_EX,
	input [5:0] rd_addr_MEM,
	input wb_en_MEM,
	input [5:0] rd_addr_WB,
	input wb_en_WB,
	input fwb_en_MEM,
	input fwb_en_WB,
	input taken,                   // Signal to check branch instruction
	output logic reg1_sel,         // Select the data into reg1
	output logic reg2_sel,         // Select the data into reg2
	output logic [1:0] mux1_sel,   // Select the src1 1st stage data before ALU 
	output logic [1:0] mux2_sel,   // Select the src2 1st stage data before ALU 
	output logic mux3_sel,         // Select the src1 2nd stage data before ALU 
	output logic mux4_sel,         // Select the src2 2nd stage data before ALU 
	output logic [3:0] alu_ctrl,
	output logic [1:0] mul_ctrl,
	output logic [1:0] alu_mul_sel,
	output logic [2:0] is_load_EX,
	output logic [1:0] is_store_EX, 
	output logic [2:0] is_branch_EX,
	output load_use,
	output logic [1:0] pc_sel,     // Select PC+4, PC, jump/branch address
	output logic [1:0] instr_sel, 
	output logic DM_CEB,
	output logic DM_WEB_EX,
	output logic wb_en_EX,
	output logic fwb_en_EX,
	output logic floatAddSub
	);

/* -------------------- ALU Dataflow Control Signal -------------------- */ 
always_comb begin
 	reg1_sel = ( (rs1_addr==rd_addr_WB) && (rd_addr_WB!=5'd0) && (wb_en_WB || fwb_en_WB) );
 	reg2_sel = ( (rs2_addr==rd_addr_WB) && (rd_addr_WB!=5'd0) && (wb_en_WB || fwb_en_WB) );
end

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		mux1_sel <= 2'b00;
	end
	else begin
		if(busStall[1]) mux1_sel <= mux1_sel;
		else if(rs1_addr==rd_addr_EX && rd_addr_EX!=5'd0 && (wb_en_EX || fwb_en_EX) ) mux1_sel <= 2'b01;
		else if(rs1_addr==rd_addr_MEM && rd_addr_MEM!=5'd0 && (wb_en_MEM || fwb_en_MEM)) mux1_sel <= 2'b10;
		else mux1_sel <= 2'b00;
	end
end

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		mux2_sel <= 2'b00;
	end
	else begin
		if(busStall[1]) mux2_sel <= mux2_sel;
		else if(rs2_addr==rd_addr_EX && rd_addr_EX!=5'd0 && (wb_en_EX || fwb_en_EX) ) mux2_sel <= 2'b01;
		else if(rs2_addr==rd_addr_MEM && rd_addr_MEM!=5'd0 && (wb_en_MEM || fwb_en_MEM) ) mux2_sel <= 2'b10;
		else mux2_sel <= 2'b00;
	end
end

always_ff@(posedge clk, posedge rst) begin  // PC or rs1
	if(rst) begin
		mux3_sel <= 1'b0;
	end
	else begin
		if(busStall[1]) mux3_sel <= mux3_sel;
		else mux3_sel <= (opcode==`Branch || opcode==`AUIPC || opcode==`JAL)? 1'b1:1'b0; // PC relate instruction
	end
end

always_ff@(posedge clk, posedge rst) begin // imm or rs2
	if(rst) begin
		mux4_sel <= 1'b0;
	end
	else begin
		if(busStall[1]) mux4_sel <= mux4_sel;
		else mux4_sel <= (opcode==`Rtype || opcode==`FALU)? 1'b0:1'b1;
	end
end

// Store control
always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		is_store_EX <= 2'b00;
	end
	else begin
		if(busStall[1]) is_store_EX <= is_store_EX;
		else if(opcode==`Store || opcode==`FSW) begin
			case(funct3)
				3'b010: is_store_EX <= 2'b01;  // SW
				3'b001: is_store_EX <= 2'b10;  // SH
				3'b000: is_store_EX <= 2'b11;  // SB
			endcase
		end
		else is_store_EX <= 2'b00;
	end
end

// Load control
always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		is_load_EX <= 3'b000;
	end
	else begin
		if(busStall[1]) is_load_EX <= is_load_EX; 
		else if(opcode==`Load || opcode==`FLW) begin
			case(funct3)
				3'b000: is_load_EX <= 3'b001;  // LB
				3'b001: is_load_EX <= 3'b010;  // LH
				3'b010: is_load_EX <= 3'b011;  // LW, FLW
				3'b100: is_load_EX <= 3'b100;  // LHU
				3'b101: is_load_EX <= 3'b101;  // LBU
				default: is_load_EX <= 3'b000;
			endcase
		end
		else is_load_EX <= 3'b000;
	end
end

// Branch control
always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		is_branch_EX <= 3'b000;
	end
	else begin
		if(busStall[1]) is_branch_EX <= is_branch_EX;
		else if(opcode == `Branch) begin
			case(funct3[2:1])
				2'b00: begin   // BEQ, BNE
					is_branch_EX <= {funct3[0], 2'b01};
				end
				2'b10: begin   // BLT, BGE
					is_branch_EX <= {funct3[0], 2'b10};
				end  
				2'b11: begin   // BLTU、 BGEU
					is_branch_EX <= {funct3[0], 2'b11};
				end
				default: begin
					is_branch_EX <= {funct3[0], 2'b00};
				end
			endcase
		end
		else is_branch_EX <= 3'b000;
	end
end


/* -------------------- ALU Control Signal -------------------- */ 
always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		alu_ctrl <= 4'b0000;
	end
	else begin
		if(busStall[1]) alu_ctrl <= alu_ctrl;
		else begin
			case(opcode)
				`Rtype: alu_ctrl <= {funct7[5], funct3};
				`Itype: alu_ctrl <= (funct3==3'b001 || funct3==3'b101)? {funct7[5], funct3} : {1'b0, funct3};
				`JAL, 
				`JALR,
				`Load,
				`Store,
				`Branch,
				`AUIPC:  alu_ctrl <= 4'b0000;
				`LUI:    alu_ctrl <= 4'b1001;
				default: alu_ctrl <= 4'b0000;
			endcase
		end
	end
end

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		mul_ctrl <= 2'b00;
	end
	else begin
		if(busStall[1]) mul_ctrl <= mul_ctrl;
		else if(opcode==`Rtype) begin
			case({funct7[0], funct3[1:0]})
				3'b100: mul_ctrl <= 2'b00;
				3'b101: mul_ctrl <= 2'b01;
				3'b110: mul_ctrl <= 2'b10;
				3'b111: mul_ctrl <= 2'b11;
			endcase
		end
	end
end

// Use to control the alu_out_mem register select(ALU out/Mul out/PC + 4)
always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		alu_mul_sel <= 2'b00;
	end
	else begin
		if(busStall[1]) alu_mul_sel <= alu_mul_sel;
		else if(opcode==`Rtype && funct7[0]) alu_mul_sel <= 2'b01;
		else if(opcode==`JALR || opcode==`JAL) alu_mul_sel <= 2'b10;
		else alu_mul_sel <= 2'b00;
	end
end


/* -------------------- Hazard relate Signal -------------------- */ 
logic [6:0] opcode_reg;
always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		opcode_reg <= 7'd0;
	end
	else begin
		if(interrupt) opcode_reg <= 7'd0;
		else if(busStall[1]) opcode_reg <= opcode_reg;
		else opcode_reg <= (load_use)? 7'd0: opcode;
	end
end

logic load_use_reg;
assign load_use = ( (opcode_reg==`Load || opcode_reg==`FLW) && ((rd_addr_EX==rs1_addr) || (rd_addr_EX==rs2_addr)) );

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		load_use_reg <= 1'b0;
	end
	else begin
		if(busStall[1]) load_use_reg <= load_use_reg;
		else load_use_reg <= load_use;
	end
end

always_comb begin
	if(pc_sel==2'b01) instr_sel = 2'b10;
	else if(load_use_reg) instr_sel = 2'b01; // When load use occur, still use previous instr.
	else instr_sel = 2'b00;
end

always_comb begin
	case(opcode_reg)
		`JAL: pc_sel = 2'b01; // ALU out  
		`JALR: pc_sel = 2'b01; // ALU out  
		`Branch: pc_sel = (taken==1'b1)? 2'b01 : 2'b00; // ALU out
		`Load,
		`FLW: pc_sel = (load_use)? 2'b10 : 2'b00;  // Stall 1 cycle
		default: pc_sel = 2'b00;
	endcase
end

/* -------------------- DM relate Signal -------------------- */ 
logic delay;  // This delay is for DM, when the first cycle IM output instr is 'z' will cause DM error.

always_ff@(posedge clk, posedge rst) begin
	if(rst) delay <= 1'b0;
	else delay <= 1'b1;
end

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		DM_CEB <= 1'b1;
	end
	else begin
		//if(busStall[1]) DM_CEB <= DM_CEB;
		if(delay) DM_CEB <= (opcode==`Load || opcode==`FLW || opcode==`Store || opcode==`FSW)? 1'b0 : 1'b1;
	end
end

// DM Load/Store enable 
always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		DM_WEB_EX <= 1'b1;  // read
	end
	else begin
		if(busStall[1]) DM_WEB_EX <= DM_WEB_EX;
		else if(delay) DM_WEB_EX <= ((opcode==`Store || opcode==`FSW) && !load_use)? 1'b0 : 1'b1;
	end
end


/* -------------------- Write back control -------------------- */ 
always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		wb_en_EX <= 1'b0;
	end
	else begin  // pc_sel = 2'b01 means jump or branch taken.
		if(busStall[1]) wb_en_EX <= wb_en_EX;
		else wb_en_EX <= (opcode==`Branch || opcode==`Store || opcode==`FSW || opcode==`FLW || opcode==`FALU || pc_sel==2'b01 || load_use)? 1'b0 : 1'b1;
	end
end


/* -------------------- Floating Register control -------------------- */  
always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		fwb_en_EX <= 1'b0;
	end
	else begin
		if(busStall[1]) fwb_en_EX <= fwb_en_EX;
		else if(load_use)  fwb_en_EX <= 1'b0;
		else fwb_en_EX <= (opcode==`FLW || opcode==`FALU)? 1'b1 : 1'b0;
	end
end

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		floatAddSub <= 1'b0;
	end
	else begin
		if(busStall[1]) floatAddSub <= floatAddSub;
		else floatAddSub <= (funct7[2])? 1'b1:1'b0;  // funct5[0]
	end
end

endmodule
