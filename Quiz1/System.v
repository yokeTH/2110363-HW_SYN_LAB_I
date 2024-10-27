`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/08/2024 06:02:41 AM
// Design Name:
// Module Name: System
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


module System (
    output [ 6:0] seg,  // Seven segments data
    output        dp,   // Dot data
    output [ 3:0] an,   // Display no.
    input  [13:0] sw,   // Switch input
    input         clk   // Clock input
);

    localparam integer SevenSegmentDigitInputWidth = 4;  // Hex bit count

    // Divide clock 100MHz (10^8) to ~200Hz
    wire [18:0] tClk;
    assign tClk[0] = clk;
    genvar i;
    generate
        for (i = 0; i < 18; i = i + 1) begin : gen_clock
            ClkDivider clockDiv (
                .out(tClk[i+1]),
                .in (tClk[i])
            );
        end
    endgenerate
    // End clock division

    wire [SevenSegmentDigitInputWidth-1:0] num3;
    wire [SevenSegmentDigitInputWidth-1:0] num2;
    wire [SevenSegmentDigitInputWidth-1:0] num1;
    wire [SevenSegmentDigitInputWidth-1:0] num0;
    // Decode Data
    wire [SevenSegmentDigitInputWidth-1:0] decoder_in;
    wire [                            6:0] decoder_out;

    NumTo7SegOverflow decoder (
        .out     (decoder_out),
        .in      (decoder_in),
        .overflow(overflow)
    );

    // Quad 7-segment display controller
    Quad7SegDisplay #(
        .INPUT_WIDTH(SevenSegmentDigitInputWidth)
    ) q7seg (
        .seg        (seg),
        .dp         (dp),
        .an         (an),
        .decoder_in (decoder_in),
        .decoder_out(decoder_out),
        .digit3     (num3),
        .digit2     (num2),
        .digit1     (num1),
        .digit0     (num0),
        .clk        (tClk[18])
    );

    // ROM mapping
    reg [15:0] rom[2**14-1:0];
    initial $readmemb("bin2dec.data", rom);
    assign {num3, num2, num1, num0} = rom[sw[13:0]];

    // ALU-based method
    // assign num3 = (sw[13:0] / 1000) % 10;
    // assign num2 = (sw[13:0] / 100) % 10;
    // assign num1 = (sw[13:0] / 10) % 10;
    // assign num0 = sw[13:0] % 10;

    assign overflow                 = sw[13:0] > 14'b10011100001111;

endmodule
