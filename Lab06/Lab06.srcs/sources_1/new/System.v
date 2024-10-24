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
    output [6:0] seg,   // 7-segment display output
    output       dp,    // Decimal point output
    output [3:0] an,    // Anode control for 7-segment display
    output       RsTx,  // UART transmit output
    input        RsRx,  // UART receive input
    input        clk    // Main clock input
);
    wire [7:0] data_out;
    wire receiving, received;

    Uart uart (
        clk,
        RsRx,
        RsTx,
        data_out,
        receiving,
        received
    );

    reg [7:0] num3, num2, num1, num0;
    wire an3, an2, an1, an0;

    initial begin
        num3 = 0;
        num2 = 0;
        num1 = 0;
        num0 = 0;
    end

    always @(posedge received) begin
        num0 <= data_out;
        num1 <= num0;
        num2 <= num1;
        num3 <= num2;
    end

    assign an = {an3, an2, an1, an0};

    // divide clock 100MHz (10^9) to ~200Hz
    wire targetClk;
    wire [17:0] tClk;
    assign tClk[0] = clk;
    genvar i;
    generate
        for (i = 0; i < 17; i = i + 1) begin : gen_clock
            ClkDivider clockDiv (
                tClk[i+1],
                tClk[i]
            );
        end
    endgenerate

    ClkDivider clockDivTarget (
        targetClk,
        tClk[17]
    );

    Quad7SegDisplay q7seg (
        seg,
        dp,
        an3,
        an2,
        an1,
        an0,
        num3,
        num2,
        num1,
        num0,
        targetClk
    );

endmodule
