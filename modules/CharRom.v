`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: -
// Engineer: Thanapon Johdee
//
// Create Date: 12/05/2024 07:11:56 AM
// Design Name:
// Module Name: CharRom
// Project Name:
// Target Devices: Atrix 3
// Tool Versions:
// Description:
//
// Dependencies:
// 1. char_rom.mem (coloun 8 x row16 each charactor)
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module CharRom (
    input  wire [6:0] char_code,  // ASCII code 0-127
    input  wire [3:0] row,        // Row 0-15
    output reg  [7:0] char_line   // Output line
);

    // Single port ROM
    reg [7:0] rom[0:2047];  // 128 chars * 16 rows = 2048 bytes

    // Load the memory file
    initial begin
        $readmemh("char_rom.mem", rom);
    end

    // Synchronous read
    always @* begin
        char_line = rom[char_code*16+row];
    end
endmodule
