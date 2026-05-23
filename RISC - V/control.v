`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/23/2026 01:26:22 PM
// Design Name: 
// Module Name: control
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

module control (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output reg        reg_write,
    output reg        mem_read,
    output reg        mem_write,
    output reg        branch,
    output reg        jump,
    output reg        jalr,
    output reg        alu_src,
    output reg        mem_to_reg,
    output reg        auipc,
    output reg        lui,
    output reg [2:0]  imm_type,
    output reg [3:0]  alu_ctrl,
    output reg [2:0]  branch_type
);

    localparam OPCODE_LOAD    = 7'b0000011;
    localparam OPCODE_OP_IMM  = 7'b0010011;
    localparam OPCODE_AUIPC   = 7'b0010111;
    localparam OPCODE_STORE   = 7'b0100011;
    localparam OPCODE_OP      = 7'b0110011;
    localparam OPCODE_LUI     = 7'b0110111;
    localparam OPCODE_BRANCH  = 7'b1100011;
    localparam OPCODE_JALR    = 7'b1100111;
    localparam OPCODE_JAL     = 7'b1101111;

    localparam IMM_I = 3'd0;
    localparam IMM_S = 3'd1;
    localparam IMM_B = 3'd2;
    localparam IMM_U = 3'd3;
    localparam IMM_J = 3'd4;

    localparam ALU_ADD  = 4'd0;
    localparam ALU_SUB  = 4'd1;
    localparam ALU_SLL  = 4'd2;
    localparam ALU_SLT  = 4'd3;
    localparam ALU_SLTU = 4'd4;
    localparam ALU_XOR  = 4'd5;
    localparam ALU_SRL  = 4'd6;
    localparam ALU_SRA  = 4'd7;
    localparam ALU_OR   = 4'd8;
    localparam ALU_AND  = 4'd9;
    localparam ALU_PASS = 4'd10;

    localparam BR_EQ  = 3'd0;
    localparam BR_NE  = 3'd1;
    localparam BR_LT  = 3'd2;
    localparam BR_GE  = 3'd3;
    localparam BR_LTU = 3'd4;
    localparam BR_GEU = 3'd5;

    always @(*) begin
        reg_write   = 1'b0;
        mem_read    = 1'b0;
        mem_write   = 1'b0;
        branch      = 1'b0;
        jump        = 1'b0;
        jalr        = 1'b0;
        alu_src     = 1'b0;
        mem_to_reg  = 1'b0;
        auipc       = 1'b0;
        lui         = 1'b0;
        imm_type    = IMM_I;
        alu_ctrl    = ALU_ADD;
        branch_type = BR_EQ;

        case (opcode)
            OPCODE_LUI: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                lui       = 1'b1;
                imm_type  = IMM_U;
                alu_ctrl  = ALU_PASS;
            end

            OPCODE_AUIPC: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                auipc     = 1'b1;
                imm_type  = IMM_U;
                alu_ctrl  = ALU_ADD;
            end

            OPCODE_JAL: begin
                reg_write = 1'b1;
                jump      = 1'b1;
                imm_type  = IMM_J;
            end

            OPCODE_JALR: begin
                reg_write = 1'b1;
                jump      = 1'b1;
                jalr      = 1'b1;
                alu_src   = 1'b1;
                imm_type  = IMM_I;
                alu_ctrl  = ALU_ADD;
            end

            OPCODE_BRANCH: begin
                branch      = 1'b1;
                imm_type    = IMM_B;
                branch_type = funct3;
            end

            OPCODE_LOAD: begin
                reg_write  = 1'b1;
                mem_read   = 1'b1;
                alu_src    = 1'b1;
                mem_to_reg = 1'b1;
                imm_type   = IMM_I;
                alu_ctrl   = ALU_ADD;
            end

            OPCODE_STORE: begin
                mem_write = 1'b1;
                alu_src   = 1'b1;
                imm_type  = IMM_S;
                alu_ctrl  = ALU_ADD;
            end

            OPCODE_OP_IMM: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                imm_type  = IMM_I;
                case (funct3)
                    3'b000: alu_ctrl = ALU_ADD;
                    3'b010: alu_ctrl = ALU_SLT;
                    3'b011: alu_ctrl = ALU_SLTU;
                    3'b100: alu_ctrl = ALU_XOR;
                    3'b110: alu_ctrl = ALU_OR;
                    3'b111: alu_ctrl = ALU_AND;
                    3'b001: alu_ctrl = ALU_SLL;
                    3'b101: alu_ctrl = (funct7[5]) ? ALU_SRA : ALU_SRL;
                    default: alu_ctrl = ALU_ADD;
                endcase
            end

            OPCODE_OP: begin
                reg_write = 1'b1;
                case (funct3)
                    3'b000: alu_ctrl = (funct7[5]) ? ALU_SUB : ALU_ADD;
                    3'b001: alu_ctrl = ALU_SLL;
                    3'b010: alu_ctrl = ALU_SLT;
                    3'b011: alu_ctrl = ALU_SLTU;
                    3'b100: alu_ctrl = ALU_XOR;
                    3'b101: alu_ctrl = (funct7[5]) ? ALU_SRA : ALU_SRL;
                    3'b110: alu_ctrl = ALU_OR;
                    3'b111: alu_ctrl = ALU_AND;
                    default: alu_ctrl = ALU_ADD;
                endcase
            end

            default: ;
        endcase
    end

endmodule
