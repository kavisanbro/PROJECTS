`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/18/2026 04:56:43 PM
// Design Name: 
// Module Name: axi4_lite_spi_bridge
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module axi4_lite_spi_bridge (
    // Clock / reset
    input  wire        ACLK,
    input  wire        ARESETn,

    // AXI4-Lite slave
    input  wire [31:0] AWADDR,
    input  wire        AWVALID,
    output wire        AWREADY,
    input  wire [31:0] WDATA,
    input  wire [3:0]  WSTRB,
    input  wire        WVALID,
    output wire        WREADY,
    output wire [1:0]  BRESP,
    output wire        BVALID,
    input  wire        BREADY,
    input  wire [31:0] ARADDR,
    input  wire        ARVALID,
    output wire        ARREADY,
    output wire [31:0] RDATA,
    output wire [1:0]  RRESP,
    output wire        RVALID,
    input  wire        RREADY,

    // SPI master
    output wire        SCLK,
    output wire        MOSI,
    input  wire        MISO,
    output wire        CS_N
);

    wire       reg_enable;
    wire       reg_start;
    wire       reg_cpol;
    wire       reg_cpha;
    wire [7:0] reg_txdata;
    wire [7:0] reg_clkdiv;
    wire       spi_busy;
    wire       spi_done;
    wire [7:0] spi_rxdata;

    axi4_lite_slave u_axi (
        .ACLK       (ACLK),
        .ARESETn    (ARESETn),
        .AWADDR     (AWADDR),
        .AWVALID    (AWVALID),
        .AWREADY    (AWREADY),
        .WDATA      (WDATA),
        .WSTRB      (WSTRB),
        .WVALID     (WVALID),
        .WREADY     (WREADY),
        .BRESP      (BRESP),
        .BVALID     (BVALID),
        .BREADY     (BREADY),
        .ARADDR     (ARADDR),
        .ARVALID    (ARVALID),
        .ARREADY    (ARREADY),
        .RDATA      (RDATA),
        .RRESP      (RRESP),
        .RVALID     (RVALID),
        .RREADY     (RREADY),
        .reg_enable (reg_enable),
        .reg_start  (reg_start),
        .reg_cpol   (reg_cpol),
        .reg_cpha   (reg_cpha),
        .reg_txdata (reg_txdata),
        .reg_clkdiv (reg_clkdiv),
        .spi_busy   (spi_busy),
        .spi_done   (spi_done),
        .spi_rxdata (spi_rxdata)
    );

    spi_master u_spi (
        .aclk     (ACLK),
        .aresetn  (ARESETn),
        .enable   (reg_enable),
        .start    (reg_start),
        .cpol     (reg_cpol),
        .cpha     (reg_cpha),
        .clk_div  (reg_clkdiv),
        .tx_data  (reg_txdata),
        .busy     (spi_busy),
        .done     (spi_done),
        .rx_data  (spi_rxdata),
        .sclk     (SCLK),
        .mosi     (MOSI),
        .miso     (MISO),
        .cs_n     (CS_N)
    );

endmodule