module PC(
	input clk, 
	input rst,
	input [1:0] busStall,
	input isWFI,
	input interrupt,
	input interrupt_re,
	input [31:0] mtvec,
	input [31:0] mepc,
	input [1:0] pc_sel,
	input [31:0] alu_out,
	output logic IM_CEB,
	output logic IM_WEB,
	output [31:0] pc, 
	output logic [31:0] pc_reg
	);

logic [31:0] pc_add4;
assign pc_add4 = pc_reg + 32'd4;
assign pc = pc_reg;

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		pc_reg <= 32'd0;
	end
	else begin
		if(interrupt) pc_reg <= mtvec;
		else if(interrupt_re) pc_reg <= mepc;
		else if(busStall != 2'b00 || isWFI) pc_reg <= pc_reg; // If WFI, keep the pc data
		else begin // Master 0 is not busy.
			case(pc_sel)
				2'b00: pc_reg <= pc_add4;
				2'b01: pc_reg <= alu_out;
				2'b10: pc_reg <= pc_reg;
			endcase
		end
	end
end

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		IM_CEB <= 1'b1;
		IM_WEB <= 1'b1;
	end
	else begin
		if(interrupt) IM_CEB <= 1'b0;
		else if(isWFI) IM_CEB <= 1'b1;
		else IM_CEB <= 1'b0;  // If now it is wait for interrupt, don't ask data from IM.
		IM_WEB <= 1'b1;
	end
end

endmodule