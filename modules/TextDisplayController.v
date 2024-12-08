`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/05/2024 08:34:20 AM
// Design Name: 
// Module Name: TextDisplayController
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


module TextDisplayController #(
    parameter COLS        = 80,
    parameter ROWS        = 30,
    parameter CHAR_WIDTH  = 8,
    parameter CHAR_HEIGHT = 16
) (
    input  wire       clk,
    input  wire       reset,
    input  wire [9:0] pixel_x,
    input  wire [9:0] pixel_y,
    input  wire       video_on,
    input  wire [6:0] char_at_pos,  // Character from TextBuffer
    output wire       text_bit_on,  // Pixel should be lit
    output wire [6:0] read_x,       // X position to read from buffer
    output wire [4:0] read_y        // Y position to read from buffer
);

    // Calculate which character position we're in
    wire [6:0] char_x = pixel_x[9:3];  // Divide by 8
    wire [4:0] char_y = pixel_y[9:4];  // Divide by 16

    // Calculate position within character
    wire [2:0] char_col = pixel_x[2:0];
    wire [3:0] char_row = pixel_y[3:0];

    // Connect to text buffer read position
    assign read_x = char_x;
    assign read_y = char_y;

    // Character ROM instance
    wire [7:0] char_line;
    CharRom char_rom (
        .char_code(char_at_pos),
        .row      (char_row),
        .char_line(char_line)
    );

    // Generate pixel
    assign text_bit_on = video_on && (char_x < COLS) && (char_y < ROWS) && char_line[7-char_col];
endmodule

