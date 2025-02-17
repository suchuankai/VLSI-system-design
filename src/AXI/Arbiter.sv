module Arbiter(
	input ACLK,
	input ARESETn,
	input ARVALID_M0,
	input ARVALID_M1,
	input AWVALID_M0,  // Always 0
	input AWVALID_M1,
	input [3:0] MRead0_target,
	input [3:0] MRead1_target,
	input [3:0] MWrite0_target,
	input [3:0] MWrite1_target,

	input ARREADY_S0,
	input ARREADY_S1,
	input AWREADY_S0,
	input AWREADY_S1,

	input RLAST_S0,
	input RLAST_S1,
	input BVALID_S0,
	input BVALID_S1,

	output logic [1:0] T0_M,
	output logic [1:0] T0_S
	);

logic [1:0] master_valid;
logic [1:0] slave_ready;
logic [3:0] master_target [0:1];
logic [1:0] check;

assign slave_ready = {ARREADY_S1|AWREADY_S1, ARREADY_S0|AWREADY_S0};
assign check = {RLAST_S1|BVALID_S1, RLAST_S0|BVALID_S0};


logic [1:0] T0_M_reg;
logic [1:0] T0_S_reg;

logic state, ntState;
localparam IDLE = 1'b0,
           BUSY = 1'b1;

logic [1:0] masterTable [0:1]; 
logic [1:0] last_master;

// Priority Decision
always_comb begin
	if(last_master==0) begin
		master_valid = {ARVALID_M0||AWVALID_M0, ARVALID_M1||AWVALID_M1};  // priority M1 > M0
		masterTable[0] = 2'b01;
		masterTable[1] = 2'b00;
		master_target[0] = {MRead1_target|MWrite1_target};
		master_target[1] = {MRead0_target|MWrite0_target};
	end
	else begin
		master_valid = {ARVALID_M1||AWVALID_M1, ARVALID_M0||AWVALID_M0};  // priority M0 > M1
		masterTable[0] = 2'b00;
		masterTable[1] = 2'b01;
		master_target[0] = {MRead0_target|MWrite0_target};
		master_target[1] = {MRead1_target|MWrite1_target};
	end
end


logic find;
int i;
always_comb begin
	case(state)
		IDLE: begin
			find = 0;
			T0_M = 2'b11;
			T0_S = 2'b11;
			for(i=0 ; i<2 && (find == 0); i=i+1) begin
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
		T0_M_reg <= 1'b1;
		T0_S_reg <= 1'b1;
		last_master <= 2'b00;
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
					T0_M_reg = 2'b11;
					T0_S_reg = 2'b11;
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