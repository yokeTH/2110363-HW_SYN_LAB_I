`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/07/2024 12:02:38 PM
// Design Name:
// Module Name: TestBCDCounterAndSinglePulser
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


module TestBCDCounterAndSinglePulser ();
    wire [3:0] outputs;
    wire d, cout, bout;
    reg clk, pushed, set9, set0, up, down;

    SinglePulser sp (
        .out(d),
        .in (pushed),
        .clk(clk)
    );
    BCDCounter bcd (
        .outputs(outputs),
        .cout   (cout),
        .bout   (bout),
        .up     (up),
        .down   (down),
        .set9   (set9),
        .set0   (set0),
        .clk    (clk)
    );

    always @(*) begin
        #5 clk <= ~clk;
    end

    initial begin
        clk <= 0;
    end

    initial begin
        pushed <= 0;

        #5 pushed <= 1;

        #20 pushed <= 0;

        #10 pushed <= 1;

        #1000 $finish;
    end

    initial begin
        up   <= 0;
        down <= 0;
        set9 <= 0;
        set0 <= 1;

        #20 set0 <= 0;
        up <= 1;

        #300 up <= 0;

        #10 set9 <= 1;

        #20 set9 <= 0;

        #10 down <= 1;

        #300 down <= 0;

        #10 set0 <= 1;

        #20 set0 <= 0;
    end
endmodule
