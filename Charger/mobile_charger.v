`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/31/2026 11:11:10 PM
// Design Name: 
// Module Name: mobile_charger
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

module charger_ic(
    input battery_full,
    input overheating,
    output charging_enable
);

assign charging_enable = ~(battery_full | overheating);

endmodule