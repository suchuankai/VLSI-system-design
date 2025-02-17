module Addr_decoder(
    input        [`AXI_ADDR_BITS-1:0] address,
    output logic [3:0] slaveID
);

always_comb begin
    case(address[31:16])
        16'h0001: slaveID = 4'd1; // slave 2 (DM)
        16'h0000: slaveID = 4'd0; // slave 1 (IM)
        default : slaveID = 4'd2; // slave T (Default slave)
    endcase
end

endmodule
