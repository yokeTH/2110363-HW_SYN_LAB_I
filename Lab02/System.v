`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/07/2024 05:33:22 AM
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
    output [6:0] seg,
    output       dp,
    output [3:0] an,
    input        clk
);

    localparam integer SevenSegmentDigitInputWidth = 4;  // ascii bit counts

    reg [SevenSegmentDigitInputWidth - 1 : 0] num3, num2, num1, num0;

    initial begin
        num3 = 1;
        num2 = 2;
        num1 = 3;
        num0 = 4;
    end

    // Decode Data
    wire [SevenSegmentDigitInputWidth-1:0] decoder_in;
    wire [                            6:0] decoder_out;

    NumTo7Seg decoder (
        .out(decoder_out),
        .in (decoder_in)
    );

    // quad 7segments display controller

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

    // divide clock 100MHz (10^8) to ~200Hz
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

endmodule
