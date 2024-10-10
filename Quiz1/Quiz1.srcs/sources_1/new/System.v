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


module System(output [6:0] seg, // seven segments data
              output dp,        // dot data
              output [3:0] an,  // display no.
              input [13:0] sw,  // switch
              input clk);       // clock
    
    // divide clock 100MHz (10^9) to ~200Hz
    wire targetClk;
    wire [17:0] tClk;
    assign tClk[0] = clk;
    genvar i;
    generate
    for(i = 0; i < 17; i = i+1) begin
        ClkDivider clockDiv(tClk[i+1], tClk[i]);
    end
    endgenerate
    
    ClkDivider clockDivTarget(targetClk, tClk[17]);
    
    
    // control quad 7seg
    wire [3:0] num3, num2, num1, num0;
    wire an3, an2, an1, an0, overflow;
    
    assign an = {an3, an2, an1, an0};
    Quad7SegDisplay q7seg(seg, dp, an3, an2, an1, an0, num3, num2, num1, num0, overflow, targetClk);
    
    // Using ram map method

    // reg [15:0] rom[2**14-1:0];
    initial $readmemb("bin2dec.data", rom);
    assign {num3, num2, num1, num0} = rom[sw[13:0]];

    // Using ALU
    // assign num3                        = (sw[13:0] / 1000) % 10;
    // assign num2                        = (sw[13:0] / 100) % 10;
    // assign num1                        = (sw[13:0] / 10) % 10;
    // assign num0                        = sw[13:0] % 10;

    assign overflow                    = sw[13:0] > 14'b10011100001111;
    
endmodule
