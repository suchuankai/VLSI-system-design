# RISC-V 5-Stage Pipelined CPU System Design
This project implements a RISC-V 5-stage pipelined CPU using SystemVerilog, based on the NCKU VLSI course.  
The system includes several additional modules, such as an AXI bus, a simple DRAM simulator, a DMA controller, a watchdog timer (WDT), and two SRAM modules serving as the instruction memory (IM) and data memory (DM) for the CPU.    
  
**Note: This repository does not include a testbench.**

## Architecture  
### System Design
![Architecture](https://github.com/user-attachments/assets/8f249c27-9313-4a99-813e-05a097af5a76)
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


## Design detail
### Address Map && AXI bus FSM 
![AXI](https://github.com/user-attachments/assets/d18516ae-ffdb-4266-a2cb-b626f4845b11)  

#### **Master:**  
The AXI master module has seven states. After a reset, the state enters `STANDBY`, where it waits for a request and read/write signals.  

- **Read Operation:**  
  The address channel handshake occurs first, followed by the data channel handshake. These operations take place in the `RADDR_VALID` and `READ_BUSY` states. Once the data transfer reaches the burst length, the state transitions back to `STANDBY`.  

- **Write Operation:**  
  The write operation follows a similar process as the read operation, but with an additional response state to handle the B-channel handshake.

#### **Slave:**  
The AXI slave module has five states. Its design logic is similar to the master, with one key difference: in the `STANDBY` state, `ARREADY_S` and `AWREADY_S` are set, eliminating the need for an "ADDR_VALID" state.  
### DMA Module  
<img src="https://github.com/user-attachments/assets/56433358-a37e-4551-acd1-2a9d5af341c7" width="720" height="240" alt="DMA"/>  

The DMA module has both a master port and a slave port. The slave port is used to configure four registers: `DMAEN`, `DMASRC`, `DMADST`, and `DMALEN`.  
Once `DMAEN` is set, the DMA starts transferring data. In the `READ` state, the master port reads from the source address and stores the data in a buffer.  
After the read data reaches the burst length, the state transitions to `WRITE`, where data is written to the destination address. 
When the processed data length equals `DMALEN`, the module enters the `FINISH` state and sent interrupt to CPU.  
**Note: If an address crosses a DRAM row boundary or is the last data transfer, the burst length is adjusted; otherwise, it remains fixed at 4.**

### WDT Module  

The WDT (Watchdog Timer) module is controlled by the CPU. Once `WDEN` is set, the WDT starts counting up to `WTOCNT`.  
If the counter reaches `WTOCNT`, the WDT module sets `WTO` that the CPU's program counter jump to a specific address.  

#### **WDT Registers**  

| Register | Bits | Function                      |  
|----------|------|------------------------------|  
| `WDEN`   | 1    | Enable WDT                   |  
| `WDLIVE` | 1    | Restart the WDT counter      |  
| `WTOCNT` | 32   | Timeout threshold for WDT    |  
| `WTO`    | 1    | Timeout signal (interrupt)   |  

## Reference
NCKU VLSI course
