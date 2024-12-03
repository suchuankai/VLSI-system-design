module IF_ID(
	input  clk, 
	input  rst,
	output [13:0] pc 
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
		pc_reg <= pc_add4;
	end
end




endmodule