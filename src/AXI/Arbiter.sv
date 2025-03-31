module Arbiter(
	input ACLK,
	input ARESETn,
	input ARVALID_M0,
	input ARVALID_M1,
	input ARVALID_M2,
	input AWVALID_M0,  // Always 0
	input AWVALID_M1,
	input AWVALID_M2,
	input [3:0] MRead0_target,
	input [3:0] MRead1_target,
	input [3:0] MRead2_target,
	input [3:0] MWrite0_target,
	input [3:0] MWrite1_target,
	input [3:0] MWrite2_target,

	input ARREADY_S0,
	input ARREADY_S1,
	input ARREADY_S2,
	input ARREADY_S3,
	input ARREADY_S4,
	input ARREADY_S5,

	input AWREADY_S0,
	input AWREADY_S1,
	input AWREADY_S2,
	input AWREADY_S3,
	input AWREADY_S4,
	input AWREADY_S5,

	input RLAST_S0,
	input RLAST_S1,
	input RLAST_S2,
	input RLAST_S3,
	input RLAST_S4,
	input RLAST_S5,

	input BVALID_S0,
	input BVALID_S1,
	input BVALID_S2,
	input BVALID_S3,
	input BVALID_S4,
	input BVALID_S5,

	output logic [2:0] T0_M,
	output logic [2:0] T0_S
	);

logic [2:0] master_valid;
logic [5:0] slave_ready;
logic [3:0] master_target [0:2];
logic [5:0] check;

assign slave_ready = {ARREADY_S5|AWREADY_S5, ARREADY_S4|AWREADY_S4, ARREADY_S3|AWREADY_S3, ARREADY_S2|AWREADY_S2, ARREADY_S1|AWREADY_S1, ARREADY_S0|AWREADY_S0};
assign check = {RLAST_S5|BVALID_S5, RLAST_S4|BVALID_S4, RLAST_S3|BVALID_S3, RLAST_S2|BVALID_S2, RLAST_S1|BVALID_S1, RLAST_S0|BVALID_S0};

logic [2:0] T0_M_reg;
logic [2:0] T0_S_reg;

logic state, ntState;
localparam IDLE = 1'b0,
           BUSY = 1'b1;

logic [1:0] masterTable [0:2]; 
logic [1:0] last_master;

// Priority Decision
always_comb begin
	if(last_master==0) begin
		master_valid = {ARVALID_M0||AWVALID_M0, ARVALID_M2||AWVALID_M2, ARVALID_M1||AWVALID_M1};  // priority M1 > M2 > M0
		masterTable[0] = 2'b01;
		masterTable[1] = 2'b10;
		masterTable[2] = 2'b00;
		master_target[0] = {MRead1_target|MWrite1_target};
		master_target[1] = {MRead2_target|MWrite2_target};
		master_target[2] = {MRead0_target|MWrite0_target};
	end
	else if(last_master==1) begin
		master_valid = {ARVALID_M1||AWVALID_M1, ARVALID_M0||AWVALID_M0, ARVALID_M2||AWVALID_M2};  // priority M2 > M0 > M1
		masterTable[0] = 2'b10;
		masterTable[1] = 2'b00;
		masterTable[2] = 2'b01;
		master_target[0] = {MRead2_target|MWrite2_target};
		master_target[1] = {MRead0_target|MWrite0_target};
		master_target[2] = {MRead1_target|MWrite1_target};
	end
	else begin
		master_valid = {ARVALID_M2||AWVALID_M2, ARVALID_M1||AWVALID_M1, ARVALID_M0||AWVALID_M0};  // priority M0 > M1 > M2
		masterTable[0] = 2'b00;
		masterTable[1] = 2'b01;
		masterTable[2] = 2'b10;
		master_target[0] = {MRead0_target|MWrite0_target};
		master_target[1] = {MRead1_target|MWrite1_target};
		master_target[2] = {MRead2_target|MWrite2_target};
	end
end


logic find;
int i;
always_comb begin
	case(state)
		IDLE: begin
			find = 0;
			T0_M = 3'b111;
			T0_S = 3'b111;
			for(i=0 ; i<3 && (find == 0); i=i+1) begin
				if(master_valid[i] && slave_ready[ master_target[i] ]) begin
					T0_M = masterTable[i];
					T0_S = master_target[i];
					find = 1;
				end
			end
		end
		BUSY: begin
			find = 0;
			T0_M = T0_M_reg;
			T0_S = T0_S_reg;
		end
	endcase
end

always_ff@(posedge ACLK, negedge ARESETn) begin
	if(!ARESETn) begin
		state <= IDLE;
	end
	else begin
		state <= ntState;
	end
end

always_ff@(posedge ACLK, negedge ARESETn) begin
	if(!ARESETn) begin
		T0_M_reg <= 3'b001;
		T0_S_reg <= 3'b001;
		last_master <= 2'b10;  // Let master 0 has the highest priority at first.
	end
	else begin
		case(state)
			IDLE: begin
				T0_M_reg <= T0_M;
				T0_S_reg <= T0_S;
				if(find) last_master <= T0_M;
			end
			BUSY: begin
				if(check[T0_S_reg]) begin
					T0_M_reg = 3'b111;
					T0_S_reg = 3'b111;
				end
			end
		endcase
	end
end

always_comb begin
	case(state)
		IDLE: ntState = (find)? BUSY : IDLE;
		BUSY: ntState = (check[T0_S_reg])? IDLE : BUSY;
	endcase
end

endmodule