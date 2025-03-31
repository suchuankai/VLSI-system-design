`include "include.svh"

module top (
	input clk, 
	input rst,
	input clk2,
	input rst2,
    
    input  [31:0] ROM_out,    
    output 		  ROM_read,
    output 		  ROM_enable,
    output [11:0] ROM_address,

    input [31:0]  DRAM_Q,
    input 		  DRAM_valid,
    output 		  DRAM_CSn,
    output [3:0]  DRAM_WEn,
    output 		  DRAM_RASn,
    output 		  DRAM_CASn,
    output [10:0] DRAM_A,
    output [31:0] DRAM_D
    );

logic ACLK;
logic ARESETn;

assign ACLK = clk;
assign ARESETn = ~rst;

/*  
    ##########################################################
    ###                   Address Define                   ###
    ##########################################################
     Master/Slave      Operation             Address
    ---------------------------------------------------------
     Master 0(IM)      Read           
     Master 1(DM)      Read/Write     
     Master 2(DMA)     Read/Write     
     Slave  0(ROM)     Read         0x0000_0000 ~ 0x0000_1FFF
     Slave  1(IM)      Read/Write   0x0001_0000 ~ 0x0001_FFFF
	 Slave  2(DM)      Read/Write   0x0002_0000 ~ 0x0002_FFFF
	 Slave  3(DMA)     Write        0x1002_0000 ~ 0x1002_0400
	 Slave  4(WDT)     Write        0x1001_0000 ~ 0x1001_03FF
	 Slave  5(DRAM)    Read/Write   0x2000_0000 ~ 0x201F_FFFF
*/

/* -------------------- Master -------------------- */
// Master 0 (Read Only)
logic [`AXI_ID_BITS-1:0]   ARID_M0    ;
logic [`AXI_ADDR_BITS-1:0] ARADDR_M0  ;
logic [`AXI_LEN_BITS-1:0]  ARLEN_M0   ;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_M0  ;
logic [1:0]                ARBURST_M0 ;
logic                      ARVALID_M0 ;
logic                      ARREADY_M0 ;
logic [`AXI_ID_BITS-1:0]   RID_M0     ;
logic [`AXI_DATA_BITS-1:0] RDATA_M0   ;
logic [1:0]                RRESP_M0   ;
logic                      RLAST_M0   ;
logic                      RVALID_M0  ;
logic                      RREADY_M0  ;

// Master 1
logic [`AXI_ID_BITS-1:0]   ARID_M1    ;
logic [`AXI_ADDR_BITS-1:0] ARADDR_M1  ;
logic [`AXI_LEN_BITS-1:0]  ARLEN_M1   ;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_M1  ;
logic [1:0]                ARBURST_M1 ;
logic                      ARVALID_M1 ;
logic                      ARREADY_M1 ;
logic [`AXI_ID_BITS-1:0]   RID_M1     ;
logic [`AXI_DATA_BITS-1:0] RDATA_M1   ;
logic [1:0]                RRESP_M1   ;
logic                      RLAST_M1   ;
logic                      RVALID_M1  ;
logic                      RREADY_M1  ;

logic [`AXI_ID_BITS-1:0]   AWID_M1    ;
logic [`AXI_ADDR_BITS-1:0] AWADDR_M1  ;
logic [`AXI_LEN_BITS-1:0]  AWLEN_M1   ;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_M1  ;
logic [1:0]                AWBURST_M1 ;
logic                      AWVALID_M1 ;
logic                      AWREADY_M1 ;
logic [`AXI_DATA_BITS-1:0] WDATA_M1   ;
logic [`AXI_STRB_BITS-1:0] WSTRB_M1   ;
logic                      WLAST_M1   ;
logic                      WVALID_M1  ;
logic                      WREADY_M1  ;
logic [`AXI_ID_BITS-1:0]   BID_M1     ;
logic [1:0]                BRESP_M1   ;
logic                      BVALID_M1  ;
logic                      BREADY_M1  ;

// Master 2
logic [`AXI_ID_BITS-1:0]   ARID_M2    ;
logic [`AXI_ADDR_BITS-1:0] ARADDR_M2  ;
logic [`AXI_LEN_BITS-1:0]  ARLEN_M2   ;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_M2  ;
logic [1:0]                ARBURST_M2 ;
logic                      ARVALID_M2 ;
logic                      ARREADY_M2 ;
logic [`AXI_ID_BITS-1:0]   RID_M2     ;
logic [`AXI_DATA_BITS-1:0] RDATA_M2   ;
logic [1:0]                RRESP_M2   ;
logic                      RLAST_M2   ;
logic                      RVALID_M2  ;
logic                      RREADY_M2  ;

logic [`AXI_ID_BITS-1:0]   AWID_M2    ;
logic [`AXI_ADDR_BITS-1:0] AWADDR_M2  ;
logic [`AXI_LEN_BITS-1:0]  AWLEN_M2   ;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_M2  ;
logic [1:0]                AWBURST_M2 ;
logic                      AWVALID_M2 ;
logic                      AWREADY_M2 ;
logic [`AXI_DATA_BITS-1:0] WDATA_M2   ;
logic [`AXI_STRB_BITS-1:0] WSTRB_M2   ;
logic                      WLAST_M2   ;
logic                      WVALID_M2  ;
logic                      WREADY_M2  ;
logic [`AXI_ID_BITS-1:0]   BID_M2     ;
logic [1:0]                BRESP_M2   ;
logic                      BVALID_M2  ;
logic                      BREADY_M2  ;

/* -------------------- Slave -------------------- */
// Slave 0
logic [`AXI_IDS_BITS-1:0]  ARID_S0    ;
logic [`AXI_ADDR_BITS-1:0] ARADDR_S0  ;
logic [`AXI_LEN_BITS-1:0]  ARLEN_S0   ;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_S0  ;
logic [1:0]                ARBURST_S0 ;
logic                      ARVALID_S0 ;
logic                      ARREADY_S0 ;
logic [`AXI_IDS_BITS-1:0]  RID_S0     ;
logic [`AXI_DATA_BITS-1:0] RDATA_S0   ;
logic [1:0]                RRESP_S0   ;
logic                      RLAST_S0   ;
logic                      RVALID_S0  ;
logic                      RREADY_S0  ;

/*  logic [`AXI_IDS_BITS-1:0]  AWID_S0    ;
	logic [`AXI_ADDR_BITS-1:0] AWADDR_S0  ;
	logic [`AXI_LEN_BITS-1:0]  AWLEN_S0   ;
	logic [`AXI_SIZE_BITS-1:0] AWSIZE_S0  ;
	logic [1:0]                AWBURST_S0 ;
	logic                      AWVALID_S0 ;
	logic                      AWREADY_S0 ;
	logic [`AXI_DATA_BITS-1:0] WDATA_S0   ;
	logic [`AXI_STRB_BITS-1:0] WSTRB_S0   ;
	logic                      WLAST_S0   ;
	logic                      WVALID_S0  ;
	logic                      WREADY_S0  ;
	logic [`AXI_IDS_BITS-1:0]  BID_S0     ;
	logic [1:0]                BRESP_S0   ;
	logic                      BVALID_S0  ;
	logic                      BREADY_S0  ;  */

// Slave 1
logic [`AXI_IDS_BITS-1:0]  ARID_S1    ;
logic [`AXI_ADDR_BITS-1:0] ARADDR_S1  ;
logic [`AXI_LEN_BITS-1:0]  ARLEN_S1   ;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_S1  ;
logic [1:0]                ARBURST_S1 ;
logic                      ARVALID_S1 ;
logic                      ARREADY_S1 ;
logic [`AXI_IDS_BITS-1:0]  RID_S1     ;
logic [`AXI_DATA_BITS-1:0] RDATA_S1   ;
logic [1:0]                RRESP_S1   ;
logic                      RLAST_S1   ;
logic                      RVALID_S1  ;
logic                      RREADY_S1  ;

logic [`AXI_IDS_BITS-1:0]  AWID_S1    ;
logic [`AXI_ADDR_BITS-1:0] AWADDR_S1  ;
logic [`AXI_LEN_BITS-1:0]  AWLEN_S1   ;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_S1  ;
logic [1:0]                AWBURST_S1 ;
logic                      AWVALID_S1 ;
logic                      AWREADY_S1 ;
logic [`AXI_DATA_BITS-1:0] WDATA_S1   ;
logic [`AXI_STRB_BITS-1:0] WSTRB_S1   ;
logic                      WLAST_S1   ;
logic                      WVALID_S1  ;
logic                      WREADY_S1  ;
logic [`AXI_IDS_BITS-1:0]  BID_S1     ;
logic [1:0]                BRESP_S1   ;
logic                      BVALID_S1  ;
logic                      BREADY_S1  ;

// Slave 2
logic [`AXI_IDS_BITS-1:0]  ARID_S2    ;
logic [`AXI_ADDR_BITS-1:0] ARADDR_S2  ;
logic [`AXI_LEN_BITS-1:0]  ARLEN_S2   ;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_S2  ;
logic [1:0]                ARBURST_S2 ;
logic                      ARVALID_S2 ;
logic                      ARREADY_S2 ;
logic [`AXI_IDS_BITS-1:0]  RID_S2     ;
logic [`AXI_DATA_BITS-1:0] RDATA_S2   ;
logic [1:0]                RRESP_S2   ;
logic                      RLAST_S2   ;
logic                      RVALID_S2  ;
logic                      RREADY_S2  ;

logic [`AXI_IDS_BITS-1:0]  AWID_S2    ;
logic [`AXI_ADDR_BITS-1:0] AWADDR_S2  ;
logic [`AXI_LEN_BITS-1:0]  AWLEN_S2   ;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_S2  ;
logic [1:0]                AWBURST_S2 ;
logic                      AWVALID_S2 ;
logic                      AWREADY_S2 ;
logic [`AXI_DATA_BITS-1:0] WDATA_S2   ;
logic [`AXI_STRB_BITS-1:0] WSTRB_S2   ;
logic                      WLAST_S2   ;
logic                      WVALID_S2  ;
logic                      WREADY_S2  ;
logic [`AXI_IDS_BITS-1:0]  BID_S2     ;
logic [1:0]                BRESP_S2   ;
logic                      BVALID_S2  ;
logic                      BREADY_S2  ;

// Slave 3
/*  logic [`AXI_IDS_BITS-1:0]  ARID_S3    ;
	logic [`AXI_ADDR_BITS-1:0] ARADDR_S3  ;
	logic [`AXI_LEN_BITS-1:0]  ARLEN_S3   ;
	logic [`AXI_SIZE_BITS-1:0] ARSIZE_S3  ;
	logic [1:0]                ARBURST_S3 ;
	logic                      ARVALID_S3 ;
	logic                      ARREADY_S3 ;
	logic [`AXI_IDS_BITS-1:0]  RID_S3     ;
	logic [`AXI_DATA_BITS-1:0] RDATA_S3   ;
	logic [1:0]                RRESP_S3   ;
	logic                      RLAST_S3   ;
	logic                      RVALID_S3  ;
	logic                      RREADY_S3  ;  */

logic [`AXI_IDS_BITS-1:0]  AWID_S3    ;
logic [`AXI_ADDR_BITS-1:0] AWADDR_S3  ;
logic [`AXI_LEN_BITS-1:0]  AWLEN_S3   ;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_S3  ;
logic [1:0]                AWBURST_S3 ;
logic                      AWVALID_S3 ;
logic                      AWREADY_S3 ;
logic [`AXI_DATA_BITS-1:0] WDATA_S3   ;
logic [`AXI_STRB_BITS-1:0] WSTRB_S3   ;
logic                      WLAST_S3   ;
logic                      WVALID_S3  ;
logic                      WREADY_S3  ;
logic [`AXI_IDS_BITS-1:0]  BID_S3     ;
logic [1:0]                BRESP_S3   ;
logic                      BVALID_S3  ;
logic                      BREADY_S3  ;

// Slave 4
/*	logic [`AXI_IDS_BITS-1:0]  ARID_S4    ;
	logic [`AXI_ADDR_BITS-1:0] ARADDR_S4  ;
	logic [`AXI_LEN_BITS-1:0]  ARLEN_S4   ;
	logic [`AXI_SIZE_BITS-1:0] ARSIZE_S4  ;
	logic [1:0]                ARBURST_S4 ;
	logic                      ARVALID_S4 ;
	logic                      ARREADY_S4 ;
	logic [`AXI_IDS_BITS-1:0]  RID_S4     ;
	logic [`AXI_DATA_BITS-1:0] RDATA_S4   ;
	logic [1:0]                RRESP_S4   ;
	logic                      RLAST_S4   ;
	logic                      RVALID_S4  ;
	logic                      RREADY_S4  ;  */

logic [`AXI_IDS_BITS-1:0]  AWID_S4    ;
logic [`AXI_ADDR_BITS-1:0] AWADDR_S4  ;
logic [`AXI_LEN_BITS-1:0]  AWLEN_S4   ;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_S4  ;
logic [1:0]                AWBURST_S4 ;
logic                      AWVALID_S4 ;
logic                      AWREADY_S4 ;
logic [`AXI_DATA_BITS-1:0] WDATA_S4   ;
logic [`AXI_STRB_BITS-1:0] WSTRB_S4   ;
logic                      WLAST_S4   ;
logic                      WVALID_S4  ;
logic                      WREADY_S4  ;
logic [`AXI_IDS_BITS-1:0]  BID_S4     ;
logic [1:0]                BRESP_S4   ;
logic                      BVALID_S4  ;
logic                      BREADY_S4  ;

// Slave 5
logic [`AXI_IDS_BITS-1:0]  ARID_S5    ;
logic [`AXI_ADDR_BITS-1:0] ARADDR_S5  ;
logic [`AXI_LEN_BITS-1:0]  ARLEN_S5   ;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_S5  ;
logic [1:0]                ARBURST_S5 ;
logic                      ARVALID_S5 ;
logic                      ARREADY_S5 ;
logic [`AXI_IDS_BITS-1:0]  RID_S5     ;
logic [`AXI_DATA_BITS-1:0] RDATA_S5   ;
logic [1:0]                RRESP_S5   ;
logic                      RLAST_S5   ;
logic                      RVALID_S5  ;
logic                      RREADY_S5  ;

logic [`AXI_IDS_BITS-1:0]  AWID_S5    ;
logic [`AXI_ADDR_BITS-1:0] AWADDR_S5  ;
logic [`AXI_LEN_BITS-1:0]  AWLEN_S5   ;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_S5  ;
logic [1:0]                AWBURST_S5 ;
logic                      AWVALID_S5 ;
logic                      AWREADY_S5 ;
logic [`AXI_DATA_BITS-1:0] WDATA_S5   ;
logic [`AXI_STRB_BITS-1:0] WSTRB_S5   ;
logic                      WLAST_S5   ;
logic                      WVALID_S5  ;
logic                      WREADY_S5  ;
logic [`AXI_IDS_BITS-1:0]  BID_S5     ;
logic [1:0]                BRESP_S5   ;
logic                      BVALID_S5  ;
logic                      BREADY_S5  ;

logic dma_interrupt;

CPU_wrapper u_CPU(
	.clk(clk),
	.rst(rst),
	.interrupt_dma(interrupt_dma),
	.ARID_M0(ARID_M0), 
  	.ARADDR_M0(ARADDR_M0), 
  	.ARLEN_M0(ARLEN_M0), 
  	.ARSIZE_M0(ARSIZE_M0), 
  	.ARBURST_M0(ARBURST_M0), 
  	.ARVALID_M0(ARVALID_M0), 
  	.ARREADY_M0(ARREADY_M0),
  	.RID_M0(RID_M0), 
  	.RDATA_M0(RDATA_M0), 
  	.RRESP_M0(RRESP_M0), 
  	.RLAST_M0(RLAST_M0), 
  	.RVALID_M0(RVALID_M0), 
  	.RREADY_M0(RREADY_M0),
    /* In this design, Master 1 just need to perform read operation.
    .AWID_M0(), 
 	.AWADDR_M0(), 
  	.AWLEN_M0(), 
  	.AWSIZE_M0(), 
  	.AWBURST_M0(), 
  	.AWVALID_M0(), 
  	.AWREADY_M0(), 
  	.WDATA_M0(), 
  	.WSTRB_M0(), 
  	.WLAST_M0(), 
  	.WVALID_M0(), 
  	.WREADY_M0(), 
  	.BID_M0(), 
  	.BRESP_M0(), 
  	.BVALID_M0(), 
  	.BREADY_M0(),
	*/
	.ARID_M1(ARID_M1), 
  	.ARADDR_M1(ARADDR_M1), 
  	.ARLEN_M1(ARLEN_M1), 
  	.ARSIZE_M1(ARSIZE_M1), 
  	.ARBURST_M1(ARBURST_M1), 
  	.ARVALID_M1(ARVALID_M1), 
  	.ARREADY_M1(ARREADY_M1), 
  	.RID_M1(RID_M1), 
  	.RDATA_M1(RDATA_M1), 
  	.RRESP_M1(RRESP_M1), 
  	.RLAST_M1(RLAST_M1), 
  	.RVALID_M1(RVALID_M1), 
  	.RREADY_M1(RREADY_M1),
    .AWID_M1(AWID_M1), 
 	.AWADDR_M1(AWADDR_M1), 
  	.AWLEN_M1(AWLEN_M1), 
  	.AWSIZE_M1(AWSIZE_M1), 
  	.AWBURST_M1(AWBURST_M1), 
  	.AWVALID_M1(AWVALID_M1), 
  	.AWREADY_M1(AWREADY_M1),
  	.WDATA_M1(WDATA_M1), 
  	.WSTRB_M1(WSTRB_M1), 
  	.WLAST_M1(WLAST_M1), 
  	.WVALID_M1(WVALID_M1), 
  	.WREADY_M1(WREADY_M1),
  	.BID_M1(BID_M1), 
  	.BRESP_M1(BRESP_M1), 
  	.BVALID_M1(BVALID_M1), 
  	.BREADY_M1(BREADY_M1) 
  	);

ROM_wrapper u_ROM(
	.ACLK(clk),
	.ARESETn(ARESETn),
    .ARID_S(ARID_S0), 
	.ARADDR_S(ARADDR_S0), 
	.ARLEN_S(ARLEN_S0),
	.ARSIZE_S(ARSIZE_S0), 
	.ARBURST_S(ARBURST_S0), 
	.ARVALID_S(ARVALID_S0), 
	.ARREADY_S(ARREADY_S0),
	.RID_S(RID_S0), 
	.RDATA_S(RDATA_S0), 
	.RRESP_S(RRESP_S0), 
	.RLAST_S(RLAST_S0), 
	.RVALID_S(RVALID_S0), 
	.RREADY_S(RREADY_S0),
	// To ROM
	.OE(ROM_read),
	.CS(ROM_enable),
	.A(ROM_address),
	.DO(ROM_out)
	);


SRAM_wrapper IM1(
	.ACLK(ACLK),
  	.ARESETn(ARESETn),
	.ARID_S(ARID_S1), 
	.ARADDR_S(ARADDR_S1), 
	.ARLEN_S(ARLEN_S1),
	.ARSIZE_S(ARSIZE_S1), 
	.ARBURST_S(ARBURST_S1), 
	.ARVALID_S(ARVALID_S1), 
	.ARREADY_S(ARREADY_S1),  
	.RID_S(RID_S1), 
	.RDATA_S(RDATA_S1), 
	.RRESP_S(RRESP_S1), 
	.RLAST_S(RLAST_S1), 
	.RVALID_S(RVALID_S1), 
	.RREADY_S(RREADY_S1),
	.AWID_S(AWID_S1),      
	.AWADDR_S(AWADDR_S1),    
	.AWLEN_S(AWLEN_S1),   
	.AWSIZE_S(AWSIZE_S1),    
	.AWBURST_S(AWBURST_S1),  
	.AWVALID_S(AWVALID_S1), 
	.AWREADY_S(AWREADY_S1),
	.WDATA_S(WDATA_S1),
	.WSTRB_S(WSTRB_S1),
	.WLAST_S(WLAST_S1),
	.WVALID_S(WVALID_S1),
	.WREADY_S(WREADY_S1),
	.BID_S(BID_S1),
	.BRESP_S(BRESP_S1),
	.BVALID_S(BVALID_S1),
	.BREADY_S(BREADY_S1)
	);


SRAM_wrapper DM1(
	.ACLK(ACLK),
  	.ARESETn(ARESETn),
	.ARID_S(ARID_S2), 
	.ARADDR_S(ARADDR_S2), 
	.ARLEN_S(ARLEN_S2),
	.ARSIZE_S(ARSIZE_S2), 
	.ARBURST_S(ARBURST_S2), 
	.ARVALID_S(ARVALID_S2), 
	.ARREADY_S(ARREADY_S2),  
	.RID_S(RID_S2), 
	.RDATA_S(RDATA_S2), 
	.RRESP_S(RRESP_S2), 
	.RLAST_S(RLAST_S2), 
	.RVALID_S(RVALID_S2), 
	.RREADY_S(RREADY_S2),
	.AWID_S(AWID_S2),      
	.AWADDR_S(AWADDR_S2),    
	.AWLEN_S(AWLEN_S2),   
	.AWSIZE_S(AWSIZE_S2),    
	.AWBURST_S(AWBURST_S2),  
	.AWVALID_S(AWVALID_S2), 
	.AWREADY_S(AWREADY_S2),
	.WDATA_S(WDATA_S2),
	.WSTRB_S(WSTRB_S2),
	.WLAST_S(WLAST_S2),
	.WVALID_S(WVALID_S2),
	.WREADY_S(WREADY_S2),
	.BID_S(BID_S2),
	.BRESP_S(BRESP_S2),
	.BVALID_S(BVALID_S2),
	.BREADY_S(BREADY_S2)
	);


AXI u_AXI(
	.ACLK(ACLK),
	.ARESETn(ARESETn),

	/* Master 0 (IM) */
	.ARID_M0(ARID_M0),
	.ARADDR_M0(ARADDR_M0),
	.ARLEN_M0(ARLEN_M0),
	.ARSIZE_M0(ARSIZE_M0),
	.ARBURST_M0(ARBURST_M0),
	.ARVALID_M0(ARVALID_M0),
	.ARREADY_M0(ARREADY_M0),
	.RID_M0(RID_M0),
	.RDATA_M0(RDATA_M0),
	.RRESP_M0(RRESP_M0),
	.RLAST_M0(RLAST_M0),
	.RVALID_M0(RVALID_M0),
	.RREADY_M0(RREADY_M0),

	/* Master 1 (DM) */
	.ARID_M1(ARID_M1),
	.ARADDR_M1(ARADDR_M1),
	.ARLEN_M1(ARLEN_M1),
	.ARSIZE_M1(ARSIZE_M1),
	.ARBURST_M1(ARBURST_M1),
	.ARVALID_M1(ARVALID_M1),
	.ARREADY_M1(ARREADY_M1),
	.RID_M1(RID_M1),
	.RDATA_M1(RDATA_M1),
	.RRESP_M1(RRESP_M1),
	.RLAST_M1(RLAST_M1),
	.RVALID_M1(RVALID_M1),
	.RREADY_M1(RREADY_M1),
	.AWID_M1(AWID_M1),
	.AWADDR_M1(AWADDR_M1),
	.AWLEN_M1(AWLEN_M1),
	.AWSIZE_M1(AWSIZE_M1),
	.AWBURST_M1(AWBURST_M1),
	.AWVALID_M1(AWVALID_M1),
	.AWREADY_M1(AWREADY_M1),
	.WDATA_M1(WDATA_M1),
	.WSTRB_M1(WSTRB_M1),
	.WLAST_M1(WLAST_M1),
	.WVALID_M1(WVALID_M1),
	.WREADY_M1(WREADY_M1),
	.BID_M1(BID_M1),
	.BRESP_M1(BRESP_M1),
	.BVALID_M1(BVALID_M1),
	.BREADY_M1(BREADY_M1),

	/* Master 2 (DMA) */
	.ARID_M2(ARID_M2),
	.ARADDR_M2(ARADDR_M2),
	.ARLEN_M2(ARLEN_M2),
	.ARSIZE_M2(ARSIZE_M2),
	.ARBURST_M2(ARBURST_M2),
	.ARVALID_M2(ARVALID_M2),
	.ARREADY_M2(ARREADY_M2),
	.RID_M2(RID_M2),
	.RDATA_M2(RDATA_M2),
	.RRESP_M2(RRESP_M2),
	.RLAST_M2(RLAST_M2),
	.RVALID_M2(RVALID_M2),
	.RREADY_M2(RREADY_M2),
	.AWID_M2(AWID_M2),
	.AWADDR_M2(AWADDR_M2),
	.AWLEN_M2(AWLEN_M2),
	.AWSIZE_M2(AWSIZE_M2),
	.AWBURST_M2(AWBURST_M2),
	.AWVALID_M2(AWVALID_M2),
	.AWREADY_M2(AWREADY_M2),
	.WDATA_M2(WDATA_M2),
	.WSTRB_M2(WSTRB_M2),
	.WLAST_M2(WLAST_M2),
	.WVALID_M2(WVALID_M2),
	.WREADY_M2(WREADY_M2),
	.BID_M2(BID_M2),
	.BRESP_M2(BRESP_M2),
	.BVALID_M2(BVALID_M2),
	.BREADY_M2(BREADY_M2),

	/* Slave 0 (ROM) */
	.ARID_S0(ARID_S0),
	.ARADDR_S0(ARADDR_S0),
	.ARLEN_S0(ARLEN_S0),
	.ARSIZE_S0(ARSIZE_S0),
	.ARBURST_S0(ARBURST_S0),
	.ARVALID_S0(ARVALID_S0),
	.ARREADY_S0(ARREADY_S0),
	.RID_S0(RID_S0),
	.RDATA_S0(RDATA_S0),
	.RRESP_S0(RRESP_S0),
	.RLAST_S0(RLAST_S0),
	.RVALID_S0(RVALID_S0),
	.RREADY_S0(RREADY_S0),
	/*  .AWID_S0(AWID_S0),
		.AWADDR_S0(AWADDR_S0),
		.AWLEN_S0(AWLEN_S0),
		.AWSIZE_S0(AWSIZE_S0),
		.AWBURST_S0(AWBURST_S0),
		.AWVALID_S0(AWVALID_S0),
		.AWREADY_S0(AWREADY_S0),
		.WDATA_S0(WDATA_S0),
		.WSTRB_S0(WSTRB_S0),
		.WLAST_S0(WLAST_S0),
		.WVALID_S0(WVALID_S0),
		.WREADY_S0(WREADY_S0),
		.BID_S0(BID_S0),
		.BRESP_S0(BRESP_S0),
		.BVALID_S0(BVALID_S0),
		.BREADY_S0(BREADY_S0), */

	/* Slave 1 (IM) */
	.ARID_S1(ARID_S1),
	.ARADDR_S1(ARADDR_S1),
	.ARLEN_S1(ARLEN_S1),
	.ARSIZE_S1(ARSIZE_S1),
	.ARBURST_S1(ARBURST_S1),
	.ARVALID_S1(ARVALID_S1),
	.ARREADY_S1(ARREADY_S1),
	.RID_S1(RID_S1),
	.RDATA_S1(RDATA_S1),
	.RRESP_S1(RRESP_S1),
	.RLAST_S1(RLAST_S1),
	.RVALID_S1(RVALID_S1),
	.RREADY_S1(RREADY_S1),
	.AWID_S1(AWID_S1),
	.AWADDR_S1(AWADDR_S1),
	.AWLEN_S1(AWLEN_S1),
	.AWSIZE_S1(AWSIZE_S1),
	.AWBURST_S1(AWBURST_S1),
	.AWVALID_S1(AWVALID_S1),
	.AWREADY_S1(AWREADY_S1),
	.WDATA_S1(WDATA_S1),
	.WSTRB_S1(WSTRB_S1),
	.WLAST_S1(WLAST_S1),
	.WVALID_S1(WVALID_S1),
	.WREADY_S1(WREADY_S1),
	.BID_S1(BID_S1),
	.BRESP_S1(BRESP_S1),
	.BVALID_S1(BVALID_S1),
	.BREADY_S1(BREADY_S1),

	/* Slave 2 (DM) */
	.ARID_S2(ARID_S2),
	.ARADDR_S2(ARADDR_S2),
	.ARLEN_S2(ARLEN_S2),
	.ARSIZE_S2(ARSIZE_S2),
	.ARBURST_S2(ARBURST_S2),
	.ARVALID_S2(ARVALID_S2),
	.ARREADY_S2(ARREADY_S2),
	.RID_S2(RID_S2),
	.RDATA_S2(RDATA_S2),
	.RRESP_S2(RRESP_S2),
	.RLAST_S2(RLAST_S2),
	.RVALID_S2(RVALID_S2),
	.RREADY_S2(RREADY_S2),
	.AWID_S2(AWID_S2),
	.AWADDR_S2(AWADDR_S2),
	.AWLEN_S2(AWLEN_S2),
	.AWSIZE_S2(AWSIZE_S2),
	.AWBURST_S2(AWBURST_S2),
	.AWVALID_S2(AWVALID_S2),
	.AWREADY_S2(AWREADY_S2),
	.WDATA_S2(WDATA_S2),
	.WSTRB_S2(WSTRB_S2),
	.WLAST_S2(WLAST_S2),
	.WVALID_S2(WVALID_S2),
	.WREADY_S2(WREADY_S2),
	.BID_S2(BID_S2),
	.BRESP_S2(BRESP_S2),
	.BVALID_S2(BVALID_S2),
	.BREADY_S2(BREADY_S2),

	/* Slave 3 (DMA) */
	/*	.ARID_S3(ARID_S3),
		.ARADDR_S3(ARADDR_S3),
		.ARLEN_S3(ARLEN_S3),
		.ARSIZE_S3(ARSIZE_S3),
		.ARBURST_S3(ARBURST_S3),
		.ARVALID_S3(ARVALID_S3),
		.ARREADY_S3(ARREADY_S3),
		.RID_S3(RID_S3),
		.RDATA_S3(RDATA_S3),
		.RRESP_S3(RRESP_S3),
		.RLAST_S3(RLAST_S3),
		.RVALID_S3(RVALID_S3),
		.RREADY_S3(RREADY_S3),*/
	.AWID_S3(AWID_S3),
	.AWADDR_S3(AWADDR_S3),
	.AWLEN_S3(AWLEN_S3),
	.AWSIZE_S3(AWSIZE_S3),
	.AWBURST_S3(AWBURST_S3),
	.AWVALID_S3(AWVALID_S3),
	.AWREADY_S3(AWREADY_S3),
	.WDATA_S3(WDATA_S3),
	.WSTRB_S3(WSTRB_S3),
	.WLAST_S3(WLAST_S3),
	.WVALID_S3(WVALID_S3),
	.WREADY_S3(WREADY_S3),
	.BID_S3(BID_S3),
	.BRESP_S3(BRESP_S3),
	.BVALID_S3(BVALID_S3),
	.BREADY_S3(BREADY_S3),

	/* Slave 4 (WDT) */
	/*	.ARID_S4(ARID_S4),
		.ARADDR_S4(ARADDR_S4),
		.ARLEN_S4(ARLEN_S4),
		.ARSIZE_S4(ARSIZE_S4),
		.ARBURST_S4(ARBURST_S4),
		.ARVALID_S4(ARVALID_S4),
		.ARREADY_S4(ARREADY_S4),
		.RID_S4(RID_S4),
		.RDATA_S4(RDATA_S4),
		.RRESP_S4(RRESP_S4),
		.RLAST_S4(RLAST_S4),
		.RVALID_S4(RVALID_S4),
		.RREADY_S4(RREADY_S4),*/
	.AWID_S4(AWID_S4),
	.AWADDR_S4(AWADDR_S4),
	.AWLEN_S4(AWLEN_S4),
	.AWSIZE_S4(AWSIZE_S4),
	.AWBURST_S4(AWBURST_S4),
	.AWVALID_S4(AWVALID_S4),
	.AWREADY_S4(AWREADY_S4),
	.WDATA_S4(WDATA_S4),
	.WSTRB_S4(WSTRB_S4),
	.WLAST_S4(WLAST_S4),
	.WVALID_S4(WVALID_S4),
	.WREADY_S4(WREADY_S4),
	.BID_S4(BID_S4),
	.BRESP_S4(BRESP_S4),
	.BVALID_S4(BVALID_S4),
	.BREADY_S4(BREADY_S4),

	/* Slave 5 (DRAM) */
	.ARID_S5(ARID_S5),
	.ARADDR_S5(ARADDR_S5),
	.ARLEN_S5(ARLEN_S5),
	.ARSIZE_S5(ARSIZE_S5),
	.ARBURST_S5(ARBURST_S5),
	.ARVALID_S5(ARVALID_S5),
	.ARREADY_S5(ARREADY_S5),
	.RID_S5(RID_S5),
	.RDATA_S5(RDATA_S5),
	.RRESP_S5(RRESP_S5),
	.RLAST_S5(RLAST_S5),
	.RVALID_S5(RVALID_S5),
	.RREADY_S5(RREADY_S5),
	.AWID_S5(AWID_S5),
	.AWADDR_S5(AWADDR_S5),
	.AWLEN_S5(AWLEN_S5),
	.AWSIZE_S5(AWSIZE_S5),
	.AWBURST_S5(AWBURST_S5),
	.AWVALID_S5(AWVALID_S5),
	.AWREADY_S5(AWREADY_S5),
	.WDATA_S5(WDATA_S5),
	.WSTRB_S5(WSTRB_S5),
	.WLAST_S5(WLAST_S5),
	.WVALID_S5(WVALID_S5),
	.WREADY_S5(WREADY_S5),
	.BID_S5(BID_S5),
	.BRESP_S5(BRESP_S5),
	.BVALID_S5(BVALID_S5),
	.BREADY_S5(BREADY_S5)
	);


DMA_wrapper u_DMA_wrapper(
	.clk(clk),
	.ARESETn(ARESETn),
	// Master
	.ARID_M(ARID_M2), 
  	.ARADDR_M(ARADDR_M2), 
  	.ARLEN_M(ARLEN_M2), 
  	.ARSIZE_M(ARSIZE_M2), 
  	.ARBURST_M(ARBURST_M2), 
  	.ARVALID_M(ARVALID_M2), 
  	.ARREADY_M(ARREADY_M2), 
  	.RID_M(RID_M2), 
  	.RDATA_M(RDATA_M2), 
  	.RRESP_M(RRESP_M2), 
  	.RLAST_M(RLAST_M2), 
  	.RVALID_M(RVALID_M2), 
  	.RREADY_M(RREADY_M2),
    .AWID_M(AWID_M2), 
 	.AWADDR_M(AWADDR_M2), 
  	.AWLEN_M(AWLEN_M2), 
  	.AWSIZE_M(AWSIZE_M2), 
  	.AWBURST_M(AWBURST_M2), 
  	.AWVALID_M(AWVALID_M2), 
  	.AWREADY_M(AWREADY_M2), 
  	.WDATA_M(WDATA_M2), 
  	.WSTRB_M(WSTRB_M2), 
  	.WLAST_M(WLAST_M2), 
  	.WVALID_M(WVALID_M2), 
  	.WREADY_M(WREADY_M2), 
  	.BID_M(BID_M2), 
  	.BRESP_M(BRESP_M2), 
  	.BVALID_M(BVALID_M2), 
  	.BREADY_M(BREADY_M2),   
	// Slave(Write only)
	/*.ARID_S(), 
	.ARADDR_S(), 
	.ARLEN_S(),
	.ARSIZE_S(), 
	.ARBURST_S(), 
	.ARVALID_S(), 
	.ARREADY_S(),
	.RID_S(), 
	.RDATA_S(), 
	.RRESP_S(), 
	.RLAST_S(), 
	.RVALID_S(), 
	.RREADY_S(),*/
	.AWID_S(AWID_S3),      
	.AWADDR_S(AWADDR_S3),    
	.AWLEN_S(AWLEN_S3),   
	.AWSIZE_S(AWSIZE_S3),    
	.AWBURST_S(AWBURST_S3),  
	.AWVALID_S(AWVALID_S3), 
	.AWREADY_S(AWREADY_S3),
	.WDATA_S(WDATA_S3),
	.WSTRB_S(WSTRB_S3),
	.WLAST_S(WLAST_S3),
	.WVALID_S(WVALID_S3),
	.WREADY_S(WREADY_S3),
	.BID_S(BID_S3),
	.BRESP_S(BRESP_S3),
	.BVALID_S(BVALID_S3),
	.BREADY_S(BREADY_S3),
	.interrupt_dma(interrupt_dma)
	);


DRAM_wrapper u_DRAM_wrapper(
	.ACLK(clk),
	.ARESETn(ARESETn),
	.ARID_S(ARID_S5), 
	.ARADDR_S(ARADDR_S5), 
	.ARLEN_S(ARLEN_S5),
	.ARSIZE_S(ARSIZE_S5), 
	.ARBURST_S(ARBURST_S5), 
	.ARVALID_S(ARVALID_S5), 
	.ARREADY_S(ARREADY_S5),
	.RID_S(RID_S5), 
	.RDATA_S(RDATA_S5), 
	.RRESP_S(RRESP_S5), 
	.RLAST_S(RLAST_S5), 
	.RVALID_S(RVALID_S5), 
	.RREADY_S(RREADY_S5),
	.AWID_S(AWID_S5),      
	.AWADDR_S(AWADDR_S5),    
	.AWLEN_S(AWLEN_S5),   
	.AWSIZE_S(AWSIZE_S5),    
	.AWBURST_S(AWBURST_S5),  
	.AWVALID_S(AWVALID_S5), 
	.AWREADY_S(AWREADY_S5),
	.WDATA_S(WDATA_S5),
	.WSTRB_S(WSTRB_S5),
	.WLAST_S(WLAST_S5),
	.WVALID_S(WVALID_S5),
	.WREADY_S(WREADY_S5),
	.BID_S(BID_S5),
	.BRESP_S(BRESP_S5),
	.BVALID_S(BVALID_S5),
	.BREADY_S(BREADY_S5),
	// To DRAM signals
	.VALID(DRAM_valid),
	.Q(DRAM_Q),
	.CSn(DRAM_CSn),
	.WEn(DRAM_WEn),
	.RASn(DRAM_RASn),
	.CASn(DRAM_CASn),
	.A(DRAM_A),
	.D(DRAM_D)
	);
 
// WDT_wrapper()



endmodule