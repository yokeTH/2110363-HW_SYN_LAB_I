`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/22/2024 04:26:18 AM
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
    output wire [6:0] seg,   // 7-segment display output
    output wire       dp,    // Decimal point output
    output wire [3:0] an,    // Anode control for 7-segment display
    output wire       RsTx,  // UART transmit output
    input  wire       RsRx,  // UART receive input
    input  wire       clk    // Main clock input
);

    // Local Params
    localparam integer SystemClockFreqency = 100_000_000;  // system clock 10 ns
    localparam integer BaudRate = 115200;  // adjust to you baud rate
    localparam integer SamplingRate = 16;  // even value expect 2++
    localparam integer SevenSegmentDigitInputWidth = 8;  // ascii bit counts


    // Uart module to receive, transmit data and status
    wire [7:0] data_out;  // ascii
    wire       receiving;
    wire       received;
    wire       sent;
    wire       sending;

    Uart #(
        .CLOCK_FREQ   (SystemClockFreqency),
        .BAUD_RATE    (BaudRate),
        .SAMPLING_RATE(SamplingRate)
    ) uart (
        .clk      (clk),
        .RsRx     (RsRx),
        .RsTx     (RsTx),
        .data_out (data_out),
        .receiving(receiving),
        .received (received),
        .sent     (sent),
        .sending  (sending)
    );

    // init Digit to invalid ascii value to make 7segment off
    reg [SevenSegmentDigitInputWidth - 1 : 0] num3, num2, num1, num0;
    initial begin
        num3 = 0;
        num2 = 0;
        num1 = 0;
        num0 = 0;
    end

    // when received shift number Right -> Left
    always @(posedge received) begin
        num0 <= data_out;
        num1 <= num0;
        num2 <= num1;
        num3 <= num2;
    end

    // Decode Data
    wire [SevenSegmentDigitInputWidth-1:0] decode_in;
    wire [                            6:0] decode_out;

    AsciiToSiekoo decoder (
        .out(decode_out),
        .in (decode_in)
    );

    // quad 7segments display controller

    Quad7SegDisplay #(
        .INPUT_WIDTH(SevenSegmentDigitInputWidth)
    ) q7seg (
        .seg          (seg),
        .dp           (dp),
        .an           (an),
        .present_digit(decode_in),
        .segment_data (decode_out),
        .digit3       (num3),
        .digit2       (num2),
        .digit1       (num1),
        .digit0       (num0),
        .clk          (tClk[18])
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
