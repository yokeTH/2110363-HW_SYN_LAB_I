`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/07/2024 09:07:24 AM
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
    output wire [6:0] seg,
    output wire       dp,
    output wire [3:0] an,
    input  wire       btnC,
    input  wire       btnU,
    input  wire [7:0] sw,
    input  wire       clk
);

    localparam integer SevenSegmentDigitInputWidth = 4;  // hex bit counts

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
    // end divide clock


    // Decode Data
    wire [SevenSegmentDigitInputWidth-1:0] decoder_in;
    wire [                            6:0] decoder_out;

    NumTo7Seg decoder (
        .out(decoder_out),
        .in (decoder_in)
    );


    // Display Controller
    wire [3:0] num3, num2, num1, num0;
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

    // BCD counter
    // Counter 3 (left)
    wire [3:0] outputs_3;
    wire cout_3, bout_3, up_3, down_3, set9_3, set0_3;
    BCDCounter counter_3 (
        .outputs(outputs_3),
        .cout   (cout_3),
        .bout   (bout_3),
        .up     (up_3),
        .down   (down_3),
        .set9   (set9_3),
        .set0   (set0_3),
        .clk    (tClk[18])
    );


    // Counter 2
    wire [3:0] outputs_2;
    wire cout_2, bout_2, up_2, down_2, set9_2, set0_2;
    BCDCounter counter_2 (
        .outputs(outputs_2),
        .cout   (cout_2),
        .bout   (bout_2),
        .up     (up_2),
        .down   (down_2),
        .set9   (set9_2),
        .set0   (set0_2),
        .clk    (tClk[18])
    );

    // Counter 1
    wire [3:0] outputs_1;
    wire cout_1, bout_1, up_1, down_1, set9_1, set0_1;
    BCDCounter counter_1 (
        .outputs(outputs_1),
        .cout   (cout_1),
        .bout   (bout_1),
        .up     (up_1),
        .down   (down_1),
        .set9   (set9_1),
        .set0   (set0_1),
        .clk    (tClk[18])
    );

    // Counter 0 (right)
    wire [3:0] outputs_0;
    wire cout_0, bout_0, up_0, down_0, set9_0, set0_0;
    BCDCounter counter_0 (
        .outputs(outputs_0),
        .cout   (cout_0),
        .bout   (bout_0),
        .up     (up_0),
        .down   (down_0),
        .set9   (set9_0),
        .set0   (set0_0),
        .clk    (tClk[18])
    );

    wire [7:0] sp_sw;
    wire [7:0] q0;
    wire [7:0] q1;
    genvar s;
    generate
        for (s = 0; s < 8; s = s + 1) begin : gen_single_pulse_for_eash_swith
            DFlipFlop dFF0 (
                .q     (q0[s]),
                .clk   (tClk[18]),
                .nreset(1),
                .d     (sw[s])
            );

            DFlipFlop dFF1 (
                .q     (q1[s]),
                .clk   (tClk[18]),
                .nreset(1),
                .d     (q0[s])
            );

            SinglePulser sp (
                .out(sp_sw[s]),
                .in (q1[s]),
                .clk(tClk[18])
            );
        end
    endgenerate


    assign set0_0 = btnC || bout_3;
    assign set0_1 = btnC || bout_3;
    assign set0_2 = btnC || bout_3;
    assign set0_3 = btnC || bout_3;

    assign set9_0 = btnU || cout_3;
    assign set9_1 = btnU || cout_3;
    assign set9_2 = btnU || cout_3;
    assign set9_3 = btnU || cout_3;

    assign down_0 = sp_sw[0];
    assign down_1 = sp_sw[2] || bout_0;
    assign down_2 = sp_sw[4] || bout_1;
    assign down_3 = sp_sw[6] || bout_2;

    assign up_0   = sp_sw[1];
    assign up_1   = sp_sw[3] || cout_0;
    assign up_2   = sp_sw[5] || cout_1;
    assign up_3   = sp_sw[7] || cout_2;

    assign num3   = outputs_3;
    assign num2   = outputs_2;
    assign num1   = outputs_1;
    assign num0   = outputs_0;

endmodule
