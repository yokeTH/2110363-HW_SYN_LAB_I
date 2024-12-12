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


module CharRom #(
    parameter MEM_FILE = "reduced_char_rom.mem"
) (
    input  wire [6:0] char_code,  // ASCII code 0-127
    input  wire [3:0] row,        // Row 0-15
    output reg  [7:0] char_line   // Output line
);

    // Single port ROM
    (* ram_style = "block" *)
    reg [7:0] rom[0:1519];  // Reduced ROM: 95 characters * 16 rows = 1520 entries

    // Load the memory file
    initial begin
        $readmemh(MEM_FILE, rom);
    end

    // Synchronous read with bounds checking
    always @* begin
        if (char_code >= 32 && char_code <= 126) begin
            char_line = rom[(char_code-32)*16+row];
        end else begin
            char_line = 8'b0;  // Default value for out-of-range characters
        end
    end
endmodule
