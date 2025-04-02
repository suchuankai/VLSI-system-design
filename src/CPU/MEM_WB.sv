module MEM_WB(
	input clk, 
	input rst,
	input [1:0] busStall,
	input wb_en_MEM,
	input fwb_en_MEM,
	input [2:0] is_load_MEM,
	input [5:0] rd_addr_MEM,
	input [31:0] alu_out_MEM,
	input DM_CEB,
	input [31:0] DM_OUT,
	input [1:0] DM_shift,
	output logic wb_en_WB,
	output logic fwb_en_WB,
	output logic [5:0] rd_addr_WB,
	output logic [31:0] alu_out_WB
	);

logic [1:0] DM_shift_reg;

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		rd_addr_WB <= 6'd0;
	end
	else begin
		if(busStall[1]) rd_addr_WB <= rd_addr_WB;
		else rd_addr_WB <= rd_addr_MEM;
	end
end

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		DM_shift_reg <= 2'b00;
	end
	else begin
		if(!DM_CEB) DM_shift_reg <= DM_shift;
	end
end

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		wb_en_WB <= 1'b0;
		fwb_en_WB <= 1'b0;
	end
	else begin
		if(busStall[1]) wb_en_WB <= wb_en_WB;
		else wb_en_WB <= wb_en_MEM;
		if(busStall[1]) fwb_en_WB <= fwb_en_WB;
		else fwb_en_WB <= fwb_en_MEM;
	end
end

logic [31:0] readBuffer;
always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		readBuffer <= 32'd0;
	end
	else begin
		case(DM_shift_reg)
			2'b00: readBuffer <= DM_OUT;
			2'b01: readBuffer <= DM_OUT >> 8;
			2'b10: readBuffer <= DM_OUT >> 16;
			2'b11: readBuffer <= DM_OUT >> 24;
		endcase
	end
end

always_ff@(posedge clk, posedge rst) begin
	if(rst) begin
		alu_out_WB <= 32'd0;
	end
	else begin
		if(busStall[1]) alu_out_WB <= alu_out_WB;
		else begin
			case(is_load_MEM)
				3'b000: alu_out_WB  <= alu_out_MEM;
				3'b001: alu_out_WB  <= {{24{readBuffer[7]}}, readBuffer[7:0]};   //LB
				3'b010: alu_out_WB  <= {{16{readBuffer[15]}}, readBuffer[15:0]}; //LH
				3'b011: alu_out_WB  <= readBuffer;                               //LW
				3'b100: alu_out_WB  <= {24'd0, readBuffer[7:0]};                 //LBU
				3'b101: alu_out_WB  <= {16'd0, readBuffer[15:0]};                //LHU
				default: alu_out_WB <= 32'd0;
			endcase
		end
	end
end

endmodule