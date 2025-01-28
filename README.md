# RISC-V Five Stage Pipeline CPU
## Description
This project has implemented a **5-stage pipelined CPU** using SystemVerilog. The data width is 32-bit, and the instruction set is based on the RISC-V instruction set architecture.
There are total of 49 instructions. After being synthesized using TSMC 16nm process technology, the operational frequency can reach up to MHz.
## Architecture
![Architecture](https://github.com/user-attachments/assets/acb2b2f5-f335-419f-b0d8-14d910ac0b71)
## All Instruction
- **R type**  
ADD、SUB、SLL、SLT、SLTU、XOR、SRL、SRA、OR、AND、MUL、MULH、MULHSU、MULHU
- **I type**  
LW、ADDI、SLTI、SLTIU、XORI、ORI、ANDI、LB、SLLI、SRLI、SRAI、JALR、LH、LHU、LBU
- **S type**  
SW、SB、SH
- **B type**  
BEQ、BNE、BLT、BGE、BLTU、BGEU
- **U type**   
AUIPC、LUI
- **J type**  
JAL
- **F type**  
FLW、FSW、FADD.S、FSUB.S
- **CSR Instruction**  
RDINSTRETH、RDINSTRET、RDCYCLEH、RDCYCLE
## Tips
## PPA
- Power :  mW
- Performance :  MHz
- Area :  um^2



