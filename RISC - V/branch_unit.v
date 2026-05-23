`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/23/2026 01:27:40 PM
// Design Name: 
// Module Name: branch_unit
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

module branch_unit (
    input  wire [31:0] rs1,
    input  wire [31:0] rs2,
    input  wire [2:0]  branch_type,
    output wire        taken
);

    localparam BR_EQ  = 3'd0;
    localparam BR_NE  = 3'd1;
    localparam BR_LT  = 3'd2;
    localparam BR_GE  = 3'd3;
    localparam BR_LTU = 3'd4;
    localparam BR_GEU = 3'd5;

    reg branch_taken;

    always @(*) begin
        case (branch_type)
            BR_EQ:  branch_taken = (rs1 == rs2);
            BR_NE:  branch_taken = (rs1 != rs2);
            BR_LT:  branch_taken = ($signed(rs1) < $signed(rs2));
            BR_GE:  branch_taken = ($signed(rs1) >= $signed(rs2));
            BR_LTU: branch_taken = (rs1 < rs2);
            BR_GEU: branch_taken = (rs1 >= rs2);
            default: branch_taken = 1'b0;
        endcase
    end

    assign taken = branch_taken;

endmodule

