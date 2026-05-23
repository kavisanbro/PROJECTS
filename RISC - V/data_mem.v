`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/23/2026 01:29:15 PM
// Design Name: 
// Module Name: data_mem
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


module data_mem (
    input  wire        clk,
    input  wire        reset,
    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [2:0]  funct3,
    input  wire [31:0] addr,
    input  wire [31:0] write_data,
    output reg  [31:0] read_data
);

    localparam DEPTH = 1024; // 4 KiB
    reg [7:0] mem [0:DEPTH-1];

    integer i;
    wire [9:0] word_index = addr[11:2];

    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < DEPTH; i = i + 1)
                mem[i] <= 8'd0;
        end else if (mem_write) begin
            case (funct3)
                3'b000: mem[addr[11:0]] <= write_data[7:0];                    // SB
                3'b001: begin                                                  // SH
                    mem[addr[11:0]]     <= write_data[7:0];
                    mem[addr[11:0] + 1] <= write_data[15:8];
                end
                3'b010: begin                                                  // SW
                    mem[addr[11:0]]     <= write_data[7:0];
                    mem[addr[11:0] + 1] <= write_data[15:8];
                    mem[addr[11:0] + 2] <= write_data[23:16];
                    mem[addr[11:0] + 3] <= write_data[31:24];
                end
                default: ;
            endcase
        end
    end

    wire [7:0]  byte_val  = mem[addr[11:0]];
    wire [15:0] half_val  = {mem[addr[11:0] + 1], mem[addr[11:0]]};
    wire [31:0] word_val  = {mem[addr[11:0] + 3], mem[addr[11:0] + 2],
                             mem[addr[11:0] + 1], mem[addr[11:0]]};

    always @(*) begin
        if (!mem_read) begin
            read_data = 32'd0;
        end else begin
            case (funct3)
                3'b000: read_data = {{24{byte_val[7]}}, byte_val};             // LB
                3'b001: read_data = {{16{half_val[15]}}, half_val};            // LH
                3'b010: read_data = word_val;                                    // LW
                3'b100: read_data = {24'd0, byte_val};                         // LBU
                3'b101: read_data = {16'd0, half_val};                           // LHU
                default: read_data = word_val;
            endcase
        end
    end

endmodule

