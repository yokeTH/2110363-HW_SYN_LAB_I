`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/05/2024 07:41:40 AM
// Design Name:
// Module Name: TextDisplay_Top
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


module StaticTextDisplay_Top (
    input  wire       clk,       // System clock
    input  wire       btnU,      // Reset
    input  wire       RsRx,      // UART RX
    output wire       RsTx,      // UART TX
    output wire       Hsync,     // VGA horizontal sync
    output wire       Vsync,     // VGA vertical sync
    output wire [3:0] vgaRed,    // VGA red channel
    output wire [3:0] vgaGreen,  // VGA green channel
    output wire [3:0] vgaBlue    // VGA blue channel
);
    // Internal signals
    wire [9:0] pixel_x, pixel_y;
    wire video_on, pixel_tick;
    reg [11:0] rgb_reg;

    // Text display signals for each character
    wire text_bit_A, text_bit_B, text_bit_C;
    wire any_text_bit;

    // VGA sync generation
    VGA_sync sync_unit (
        .clk     (clk),
        .reset   (btnU),
        .hsync   (Hsync),
        .vsync   (Vsync),
        .video_on(video_on),
        .p_tick  (pixel_tick),
        .x       (pixel_x),
        .y       (pixel_y)
    );

    // Text display instances for "ABC"
    SingleCharDisplay text_A (
        .clk        (clk),
        .reset      (btnU),
        .pixel_x    (pixel_x),
        .pixel_y    (pixel_y),
        .char_code  (7'h41),      // 'A'
        .text_x     (100),        // X position
        .text_y     (100),        // Y position
        .text_bit_on(text_bit_A)
    );

    SingleCharDisplay text_B (
        .clk        (clk),
        .reset      (btnU),
        .pixel_x    (pixel_x),
        .pixel_y    (pixel_y),
        .char_code  (7'h42),      // 'B'
        .text_x     (108),        // X position (8 pixels after A)
        .text_y     (100),        // Y position
        .text_bit_on(text_bit_B)
    );

    SingleCharDisplay text_C (
        .clk        (clk),
        .reset      (btnU),
        .pixel_x    (pixel_x),
        .pixel_y    (pixel_y),
        .char_code  (7'h43),      // 'C'
        .text_x     (116),        // X position (8 pixels after B)
        .text_y     (100),        // Y position
        .text_bit_on(text_bit_C)
    );

    // Combine all text bits
    assign any_text_bit = text_bit_A | text_bit_B | text_bit_C;

    // Background color generator
    wire [11:0] bg_color;
    assign bg_color = 12'h001;  // Dark blue background

    // Text color
    wire [11:0] text_color;
    assign text_color = 12'hFFF;  // White text

    // RGB output logic
    always @(posedge clk) begin
        if (pixel_tick) begin
            if (!video_on) rgb_reg <= 12'h000;  // Black during blanking
            else if (any_text_bit) rgb_reg <= text_color;  // Text color
            else rgb_reg <= bg_color;  // Background color
        end
    end

    // Output assignments
    assign vgaRed   = rgb_reg[11:8];
    assign vgaGreen = rgb_reg[7:4];
    assign vgaBlue  = rgb_reg[3:0];

    // UART loopback for now
    assign RsTx     = RsRx;
endmodule
