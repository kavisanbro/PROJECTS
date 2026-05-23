`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/23/2026 01:36:15 PM
// Design Name: 
// Module Name: instr_mem
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

module instr_mem #(
    parameter DEPTH    = 256,
    parameter HEX_FILE = "programs/program.hex"
)(
    input  wire [31:0] addr,
    output wire [31:0] instr
);

    localparam ADDR_W = $clog2(DEPTH);

    reg [31:0] rom [0:DEPTH-1];

    integer i;

    initial begin
        for (i = 0; i < DEPTH; i = i + 1)
            rom[i] = 32'h00000013;

        $readmemh(HEX_FILE, rom);

`ifdef FALLBACK_PROG_VH
`include "program_init.vh"
`endif
    end

    wire [ADDR_W-1:0] word_addr = addr[ADDR_W+1:2];

    assign instr = rom[word_addr];

endmodule
