module MEM_WB(
	input clk, 
	input rst,
	input wb_en_mem,
	input float_wb_en_mem,
	input floatOpMem,
	input [2:0] is_load_mem,
	input [5:0] rd_addr_mem,
	input [31:0] alu_out_mem,
	input [31:0] DM_OUT,
	output logic wb_en_wb,
	output logic float_wb_en_wb,
	output logic floatOpWb,
	output logic [5:0] rd_addr_wb,
	output logic [31:0] alu_out_wb
	);

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		rd_addr_wb <= 5'd0;
	end
	else begin
		rd_addr_wb <= rd_addr_mem;
	end
end

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		wb_en_wb <= 1'b0;
		float_wb_en_wb <= 1'b0;
		floatOpWb <= 1'b0;
	end
	else begin
		wb_en_wb <= wb_en_mem;
		float_wb_en_wb <= float_wb_en_mem;
		floatOpWb <= floatOpMem;
	end
end

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		alu_out_wb <= 32'd0;
	end
	else begin
		case(is_load_mem)
			3'b000: alu_out_wb <= alu_out_mem;
			3'b001: alu_out_wb <= {{24{DM_OUT[7]}}, DM_OUT[7:0]};   //LB
			3'b010: alu_out_wb <= {{16{DM_OUT[15]}}, DM_OUT[15:0]}; //LH
			3'b011: alu_out_wb <= DM_OUT;    // LW
			3'b100: alu_out_wb <= {24'd0, DM_OUT[7:0]};   //LBU
			3'b101: alu_out_wb <= {16'd0, DM_OUT[15:0]};   //LHU
			default: alu_out_wb <= 32'd0;
		endcase
	end
end


endmodule