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
    parameter CHAR_HEIGHT = 16,
    parameter OFFSET_TOP  = 0,
    parameter OFFSET_LEFT = 0
) (
    input  wire       clk,
    input  wire       reset,
    input  wire [9:0] pixel_x,
    input  wire [9:0] pixel_y,
    input  wire       video_on,
    input  wire       lang,
    input  wire [6:0] char_at_pos,  // Character from TextBuffer
    output wire       text_bit_on,  // Pixel should be lit
    output wire [6:0] read_x,       // X position to read from buffer
    output wire [4:0] read_y        // Y position to read from buffer
);

    // Calculate which character position we're in, considering offsets
    wire [9:0] adj_pixel_x = pixel_x - OFFSET_LEFT;
    wire [9:0] adj_pixel_y = pixel_y - OFFSET_TOP;
    wire [6:0] char_x = adj_pixel_x[9:3];  // Divide by 8
    wire [4:0] char_y = adj_pixel_y[9:4];  // Divide by 16

    // Calculate position within character
    wire [2:0] char_col = adj_pixel_x[2:0];
    wire [3:0] char_row = adj_pixel_y[3:0];

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

    // Character ROM instance with parameter for Thai characters
    wire [7:0] char_thai_line;
    CharRom #(
        .MEM_FILE("reduced_char_rom_thai.mem")
    ) char_rom_thai (
        .char_code(char_at_pos),
        .row      (char_row),
        .char_line(char_thai_line)
    );

    // Generate pixel
    wire [7:0] selected_char_line = lang ? char_thai_line : char_line;
    assign text_bit_on = video_on && (char_x < COLS) && (char_y < ROWS) && selected_char_line[7-char_col];
endmodule

