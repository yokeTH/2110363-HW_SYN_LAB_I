`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/05/2024 07:11:56 AM
// Design Name:
// Module Name: SingleCharDisplay
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


module SingleCharDisplay (
    input  wire       clk,
    input  wire       reset,
    input  wire [9:0] pixel_x,
    input  wire [9:0] pixel_y,
    input  wire [6:0] char_code,   // 7-bit ASCII
    input  wire [9:0] text_x,
    input  wire [9:0] text_y,
    output wire       text_bit_on
);

    wire [3:0] char_row;  // Row number within character (0-15)
    wire [2:0] char_col;  // Column number within character (0-7)
    wire [7:0] char_line;  // One row of character data

    // Calculate if current pixel is within text area
    wire in_text_area = (pixel_x >= text_x) && (pixel_x < text_x + 8) &&
                       (pixel_y >= text_y) && (pixel_y < text_y + 16);

    // Calculate character row and column
    assign char_row = pixel_y - text_y;
    assign char_col = pixel_x - text_x;

    // Instantiate character ROM
    CharRom char_rom_unit (
        .char_code(char_code),
        .row      (char_row),
        .char_line(char_line)
    );

    // Get pixel value from character line
    assign text_bit_on = in_text_area ? char_line[7-char_col] : 1'b0;
endmodule
