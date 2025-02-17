/* ---------- Define opcode ---------- */
// ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND, MUL, MULH, MULHSU, MULHU (14)
`define Rtype 7'b0110011
// ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI (9)
`define Itype 7'b0010011
// LW, LB, LH, LBU, LHU (5)
`define Load 7'b0000011
// SW, SB, SH (3)
`define Store 7'b0100011
// BEQ, BNE, BLT, BGE, BLTU, BGEU (6)
`define Branch 7'b1100011
// JALR
`define JALR 7'b1100111
// JAL
`define JAL 7'b1101111
// AUIPC
`define AUIPC 7'b0010111
// LUI
`define LUI 7'b0110111
// FLW
`define FLW 7'b0000111
// FSW
`define FSW 7'b0100111
// FALU
`define FALU 7'b1010011
// CSR
`define CSR 7'b1110011