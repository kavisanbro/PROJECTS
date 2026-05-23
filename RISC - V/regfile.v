`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/23/2026 01:33:54 PM
// Design Name: 
// Module Name: regfile
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


module regfile (
    input  wire        clk,
    input  wire        reset,
    input  wire        reg_write,
    input  wire [4:0]  rd_addr,
    input  wire [31:0] rd_data,
    input  wire [4:0]  rs1_addr,
    input  wire [4:0]  rs2_addr,
    output wire [31:0] rs1_data,
    output wire [31:0] rs2_data
);

    reg [31:0] regs [1:31]; // x1-x31; x0 is always 0

    integer i;

    assign rs1_data = (rs1_addr == 5'd0) ? 32'd0 : regs[rs1_addr];
    assign rs2_data = (rs2_addr == 5'd0) ? 32'd0 : regs[rs2_addr];

    always @(posedge clk) begin
        if (reset) begin
            for (i = 1; i < 32; i = i + 1)
                regs[i] <= 32'd0;
        end else if (reg_write && (rd_addr != 5'd0)) begin
            regs[rd_addr] <= rd_data;
        end
    end

endmodule
