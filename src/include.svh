// Decode & AXI define
`include "../include/AXI_define.svh"
`include "../include/CPU_define.svh"
// AXI files
`include "../src/AXI/Arbiter.sv"
`include "../src/AXI/AXI.sv"
`include "../src/AXI/AXI_Master.sv"
`include "../src/AXI/AXI_Slave.sv"
`include "../src/AXI/Addr_decoder.sv"
// CPU files
`include "../src/CPU/ALU.sv"
`include "../src/CPU/CLZ.sv"
`include "../src/CPU/Controller.sv"
`include "../src/CPU/CPU.sv"
`include "../src/CPU/CPU_wrapper.sv"
`include "../src/CPU/CSR.sv"
`include "../src/CPU/Decoder.sv"
`include "../src/CPU/EX_MEM.sv"
`include "../src/CPU/FloatRegister.sv"
`include "../src/CPU/FPU.sv"
`include "../src/CPU/ID_EXE.sv"
`include "../src/CPU/IF_ID.sv"
`include "../src/CPU/MEM_WB.sv"
`include "../src/CPU/PC.sv"
`include "../src/CPU/Register.sv"
`include "../src/CPU/SRAM_wrapper.sv"
// DMA files
`include "../src/DMA/DMA_controller.sv"
`include "../src/DMA/DMA_wrapper.sv"
// DRAM files
`include "../src/DRAM/DRAM_wrapper.sv"
// ROM files
`include "../src/ROM/ROM_wrapper.sv"
// WDT files
// CDC files