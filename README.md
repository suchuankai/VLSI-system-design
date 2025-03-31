# RISC-V Five Stage Pipeline CPU
This project implements a RISC-V 5-stage pipelined CPU using SystemVerilog, based on the NCKU VLSI course.  
The system includes several additional modules, such as an AXI bus, a simple DRAM simulator, a DMA controller, a watchdog timer (WDT), and two SRAM modules serving as the instruction memory (IM) and data memory (DM) for the CPU.    
  
**Note: This repository does not include a testbench.**

## Architecture
![Architecture](https://github.com/user-attachments/assets/acb2b2f5-f335-419f-b0d8-14d910ac0b71)
## Supported Instructions  
This design supports **53 instructions** in total.  
- **R-Type**  
`ADD`, `SUB`, `SLL`, `SLT`, `SLTU`, `XOR`, `SRL`, `SRA`, `OR`, `AND`, `MUL`, `MULH`, `MULHSU`, `MULHU`  
- **I-Type**  
`LW`, `ADDI`, `SLTI`, `SLTIU`, `XORI`, `ORI`, `ANDI`, `LB`, `SLLI`, `SRLI`, `SRAI`, `JALR`, `LH`, `LHU`, `LBU`  
- **S-Type**  
`SW`, `SB`, `SH`  
- **B-Type**  
`BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`  
- **U-Type**  
`AUIPC`, `LUI`  
- **J-Type**  
`JAL`  
- **F-Type (Floating-Point Instructions)**  
`FLW`, `FSW`, `FADD.S`, `FSUB.S`  
- **CSR Instructions**  
`RDINSTRETH`, `RDINSTRET`, `RDCYCLEH`, `RDCYCLE`, `CSRRW`, `CSRRS`, `CSRRC`, `CSRRWI`, `CSRRSI`, `CSRRCI`, `WFI`, `MRET`
## Address Map  
| Component       | Access Type   | Address Range                     |
|-----------------|---------------|-----------------------------------|
| **Master 0 (IM)**  | Read       | -                                 |
| **Master 1 (DM)**  | Read/Write | -                                 |
| **Master 2 (DMA)** | Read/Write | -                                 |
| **Slave 0 (ROM)**  | Read       | `0x0000_0000` ~ `0x0000_1FFF`     |
| **Slave 1 (IM)**   | Read/Write | `0x0001_0000` ~ `0x0001_FFFF`     |
| **Slave 2 (DM)**   | Read/Write | `0x0002_0000` ~ `0x0002_FFFF`     |
| **Slave 3 (DMA)**  | Write      | `0x1002_0000` ~ `0x1002_0400`     |
| **Slave 4 (WDT)**  | Write      | `0x1001_0000` ~ `0x1001_03FF`     |
| **Slave 5 (DRAM)** | Read/Write | `0x2000_0000` ~ `0x201F_FFFF`     |

## Design detail
### AXI bus

### DMA

### DRAM



