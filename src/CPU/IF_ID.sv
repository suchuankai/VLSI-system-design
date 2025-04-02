module IF_ID(
	input clk, 
	input rst,
	input [1:0] busStall,
	input [31:0] pc, 
	input [31:0] instr,
	input [1:0] instr_sel,
	input loadUse,
	input isWFI,
	input interrupt,
	output logic [31:0] pc_ID,
	output logic [31:0] instr_ID
);

logic [31:0] instr_reg;
always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		instr_reg <= 32'd0;
	end
	else begin
		if(busStall != 2'b00) instr_reg <= instr_reg;
		else instr_reg <= instr;
	end
end

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		pc_ID <= 32'd0;
	end
	else begin
		if(busStall != 2'b00) pc_ID <= pc_ID;
		else if(!loadUse) pc_ID <= pc;
	end
end

logic flush;  // Each time branch taken or jump instrution will cause two instructions flush.
always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		flush <= 1'b0;
	end
	else begin
		if(interrupt) flush <= 1'b1;
		else if(busStall != 2'b00) flush <= flush;
		else flush <= instr_sel[1];
	end
end 

always_comb begin
	if(flush || isWFI) instr_ID = 32'h0000_0013;  // If WFI, perform NOP operation in the following stage.
	else begin
		case(instr_sel)
			2'b00: instr_ID = instr;
			2'b01: instr_ID = instr_reg;      // Load-use needs to stall one cycle.
			2'b10: instr_ID = 32'h0000_0013;  // Use x0 = x0 + x0 to implement flush.
			default: instr_ID = instr;
		endcase
	end
end

endmodule