`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/23/2026 01:32:31 PM
// Design Name: 
// Module Name: rv32i_cpu
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

// RV32I Single-Cycle Processor - top-level core
module rv32i_cpu (
    input  wire        clk,
    input  wire        reset,
    output wire [31:0] pc_out,
    output wire [31:0] instr_out,
    output wire [31:0] alu_result_out,
    output wire        reg_write_out
);

    reg [31:0] pc;

    wire [31:0] instr;
    wire [6:0]  opcode  = instr[6:0];
    wire [4:0]  rd      = instr[11:7];
    wire [2:0]  funct3  = instr[14:12];
    wire [4:0]  rs1     = instr[19:15];
    wire [4:0]  rs2     = instr[24:20];
    wire [6:0]  funct7  = instr[31:25];

    wire        reg_write, mem_read, mem_write, branch, jump, jalr;
    wire        alu_src, mem_to_reg, auipc, lui;
    wire [2:0]  imm_type, branch_type;
    wire [3:0]  alu_ctrl;

    wire [31:0] imm;
    wire [31:0] rs1_data, rs2_data;
    wire [31:0] alu_a, alu_b, alu_result;
    wire        branch_taken;
    wire [31:0] mem_rdata;
    wire [31:0] rd_wdata;
    wire [31:0] pc_plus4;
    wire [31:0] pc_next;

    assign pc_out          = pc;
    assign instr_out       = instr;
    assign alu_result_out  = alu_result;
    assign reg_write_out   = reg_write;

    assign pc_plus4 = pc + 32'd4;

    instr_mem u_imem (
        .addr (pc),
        .instr(instr)
    );

    control u_ctrl (
        .opcode      (opcode),
        .funct3      (funct3),
        .funct7      (funct7),
        .reg_write   (reg_write),
        .mem_read    (mem_read),
        .mem_write   (mem_write),
        .branch      (branch),
        .jump        (jump),
        .jalr        (jalr),
        .alu_src     (alu_src),
        .mem_to_reg  (mem_to_reg),
        .auipc       (auipc),
        .lui         (lui),
        .imm_type    (imm_type),
        .alu_ctrl    (alu_ctrl),
        .branch_type (branch_type)
    );

    imm_gen u_imm (
        .instr   (instr),
        .imm_type(imm_type),
        .imm     (imm)
    );

    regfile u_reg (
        .clk      (clk),
        .reset    (reset),
        .reg_write(reg_write),
        .rd_addr  (rd),
        .rd_data  (rd_wdata),
        .rs1_addr (rs1),
        .rs2_addr (rs2),
        .rs1_data (rs1_data),
        .rs2_data (rs2_data)
    );

    assign alu_a = auipc ? pc : rs1_data;
    assign alu_b = alu_src ? imm : rs2_data;

    alu u_alu (
        .a        (alu_a),
        .b        (alu_b),
        .alu_ctrl (alu_ctrl),
        .result   (alu_result)
    );

    branch_unit u_br (
        .rs1         (rs1_data),
        .rs2         (rs2_data),
        .branch_type (branch_type),
        .taken       (branch_taken)
    );

    data_mem u_dmem (
        .clk       (clk),
        .reset     (reset),
        .mem_read  (mem_read),
        .mem_write (mem_write),
        .funct3    (funct3),
        .addr      (alu_result),
        .write_data(rs2_data),
        .read_data (mem_rdata)
    );

    assign rd_wdata = jump ? pc_plus4 :
                      mem_to_reg ? mem_rdata : alu_result;

    wire [31:0] branch_target = pc + imm;
    wire [31:0] jalr_target = (rs1_data + imm) & ~32'd1;
    wire [31:0] jump_target = jalr ? jalr_target : (pc + imm);

    assign pc_next = jump ? jump_target :
                     (branch && branch_taken) ? branch_target :
                     pc_plus4;

    always @(posedge clk) begin
        if (reset)
            pc <= 32'd0;
        else
            pc <= pc_next;
    end

endmodule
