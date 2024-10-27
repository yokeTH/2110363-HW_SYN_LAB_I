`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/05/2024 10:26:10 AM
// Design Name:
// Module Name: testDFlipFlop
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


module testDFlipFlop ();
    reg  clk;
    reg  nreset;
    reg  d;
    wire q;

    DFlipFlop D1 (
        .q     (q),
        .clk   (clk),
        .nreset(nreset),
        .d     (d)
    );


    always @(*) begin
        #10 clk <= ~clk;
    end

    initial begin
        #0 d <= 0;
        clk    <= 0;
        nreset <= 0;

        #50 nreset <= 1;

        #100 nreset <= 0;

        #200;
        nreset <= 1;

        #1000 $finish;
    end

    always @(*) begin
        #8 d <= ~d;
    end
endmodule
