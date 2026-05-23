`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/23/2026 01:24:36 PM
// Design Name: 
// Module Name: imm_gen
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

module imm_gen (
    input  wire [31:0] instr,
    input  wire [2:0]  imm_type,
    output reg  [31:0] imm
);

    localparam IMM_I = 3'd0;
    localparam IMM_S = 3'd1;
    localparam IMM_B = 3'd2;
    localparam IMM_U = 3'd3;
    localparam IMM_J = 3'd4;

    wire [31:0] i_imm = {{20{instr[31]}}, instr[31:20]};
    wire [31:0] s_imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    wire [31:0] b_imm = {{19{instr[31]}}, instr[31],
                         instr[7], instr[30:25], instr[11:8], 1'b0};
    wire [31:0] u_imm = {instr[31:12], 12'b0};
    wire [31:0] j_imm = {{11{instr[31]}}, instr[31],
                         instr[19:12], instr[20], instr[30:21], 1'b0};

    always @(*) begin
        case (imm_type)
            IMM_I: imm = i_imm;
            IMM_S: imm = s_imm;
            IMM_B: imm = b_imm;
            IMM_U: imm = u_imm;
            IMM_J: imm = j_imm;
            default: imm = 32'd0;
        endcase
    end

endmodule

