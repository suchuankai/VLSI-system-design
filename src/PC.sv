module PC(
	input clk, 
	input rst,
	input [1:0] pc_sel,
	input [31:0] alu_out,
	output [13:0] pc, 
	output logic [31:0] pc_reg
	);

/* ---------- PC register ---------- */
logic [31:0] pc_reg;
logic [31:0] pc_add4;
assign pc_add4 = pc_reg + 32'd4;
assign pc = pc_reg[15:2];

always@(posedge clk, posedge rst) begin
	if(rst) begin
		pc_reg <= 32'd0;
	end
	else begin
		case(pc_sel)
			2'b00: pc_reg <= (pc_reg==800)? 800 : pc_add4;
			2'b01: pc_reg <= alu_out;
		endcase
	end
end

endmodule