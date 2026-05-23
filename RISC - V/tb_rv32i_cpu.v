`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/23/2026 01:37:44 PM
// Design Name: 
// Module Name: tb_rv32i_cpu
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



module tb_rv32i_cpu;

    reg         clk;
    reg         reset;
    wire [31:0] pc;
    wire [31:0] instr;
    wire [31:0] alu_result;
    wire        reg_write;

    rv32i_cpu uut (
        .clk            (clk),
        .reset          (reset),
        .pc_out         (pc),
        .instr_out      (instr),
        .alu_result_out (alu_result),
        .reg_write_out  (reg_write)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk; // 100 MHz
    end

    initial begin
        $dumpfile("sim/rv32i_cpu.vcd");
        $dumpvars(0, tb_rv32i_cpu);
    end

    // Peek register file via hierarchical access
    wire [31:0] x1 = uut.u_reg.regs[1];
    wire [31:0] x2 = uut.u_reg.regs[2];
    wire [31:0] x3 = uut.u_reg.regs[3];
    wire [31:0] x4 = uut.u_reg.regs[4];
    wire [31:0] x5 = uut.u_reg.regs[5];
    wire [31:0] x6 = uut.u_reg.regs[6];
    wire [31:0] x7 = uut.u_reg.regs[7];

    integer errors;

    initial begin
        errors = 0;
        reset = 1'b1;
        #25;
        reset = 1'b0;

        // Wait for program to reach halt (10 instructions + pipeline settle)
        repeat (20) @(posedge clk);

        $display("=== RV32I CPU Simulation Results ===");
        $display(" PC        = 0x%08h", pc);
        $display(" x1 (5)    = %0d (expected 5)",  x1);
        $display(" x2 (3)    = %0d (expected 3)",  x2);
        $display(" x3 (8)    = %0d (expected 8)",  x3);
        $display(" x4 (8)    = %0d (expected 8)",  x4);
        $display(" x5 (skip) = %0d (expected 0)", x5);
        $display(" x6 (flag) = %0d (expected 1)",  x6);
        $display(" x7 (42)   = %0d (expected 42)", x7);

        if (x1 !== 32'd5)  begin $display("FAIL: x1"); errors = errors + 1; end
        if (x2 !== 32'd3)  begin $display("FAIL: x2"); errors = errors + 1; end
        if (x3 !== 32'd8)  begin $display("FAIL: x3"); errors = errors + 1; end
        if (x4 !== 32'd8)  begin $display("FAIL: x4"); errors = errors + 1; end
        if (x5 !== 32'd0)  begin $display("FAIL: x5 (branch did not skip)"); errors = errors + 1; end
        if (x6 !== 32'd1)  begin $display("FAIL: x6"); errors = errors + 1; end
        if (x7 !== 32'd42) begin $display("FAIL: x7"); errors = errors + 1; end

        if (errors == 0)
            $display("*** ALL TESTS PASSED ***");
        else
            $display("*** %0d TEST(S) FAILED ***", errors);

        $finish;
    end

endmodule
