module IF_ID(
	input clk, 
	input rst,
	input [31:0] pc, 
	input [31:0] instr,
	input [1:0] instr_sel,
	output logic [31:0] pc_ID,
	output logic [31:0] instr_ID
);

always@(posedge clk, posedge rst) begin
	if(rst) begin
		pc_ID <= 32'd0;
	end
	else begin
		pc_ID <= pc;
	end
end

logic [31:0] instr_reg;
always@(posedge clk, posedge rst) begin
	if(rst) begin
		instr_reg <= 32'd0;
	end
	else begin
		instr_reg <= instr;
	end
end

logic flush;  // Each time branch taken or jump instrution will cause two bubbles.
always@(posedge clk, posedge rst) begin
	if(rst) begin
		flush <= 1'b0;
	end
	else begin
		flush <= instr_sel[1];
	end
end

always_comb begin
	if(flush) instr_ID = 32'h0000_0013;
	else begin
		case(instr_sel)
			2'b00: instr_ID = instr;
			2'b01: instr_ID = instr_reg;    // Load use stall one cycle
			2'b10: instr_ID = 32'h0000_0013;
			default: instr_ID = instr;
		endcase
	end
end


endmodule