module MEM_WB(
	input clk, 
	input rst,
	input wb_en_MEM,
	input fwb_en_MEM,
	input [2:0] is_load_MEM,
	input [5:0] rd_addr_MEM,
	input [31:0] alu_out_MEM,
	input [31:0] DM_OUT,
	output logic wb_en_WB,
	output logic fwb_en_WB,
	output logic [5:0] rd_addr_WB,
	output logic [31:0] alu_out_WB
	);

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		rd_addr_WB <= 6'd0;
	end
	else begin
		rd_addr_WB <= rd_addr_MEM;
	end
end

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		wb_en_WB <= 1'b0;
		fwb_en_WB <= 1'b0;
	end
	else begin
		wb_en_WB <= wb_en_MEM;
		fwb_en_WB <= fwb_en_MEM;
	end
end

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		alu_out_WB <= 32'd0;
	end
	else begin
		case(is_load_MEM)
			3'b000: alu_out_WB <= alu_out_MEM;
			3'b001: alu_out_WB <= {{24{DM_OUT[7]}}, DM_OUT[7:0]};   //LB
			3'b010: alu_out_WB <= {{16{DM_OUT[15]}}, DM_OUT[15:0]}; //LH
			3'b011: alu_out_WB <= DM_OUT;                           //LW
			3'b100: alu_out_WB <= {24'd0, DM_OUT[7:0]};             //LBU
			3'b101: alu_out_WB <= {16'd0, DM_OUT[15:0]};            //LHU
			default: alu_out_WB <= 32'd0;
		endcase
	end
end


endmodule