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


module System(output [6:0] seg,
              output dp,
              output [3:0] an,
              input clk);
    
    reg [3:0] num3, num2, num1, num0;
    wire an3, an2, an1, an0;
    
    initial begin
        num3 = 9;
        num2 = 8;
        num1 = 7;
        num0 = 6;
    end
    
    assign an = {an3, an2, an1, an0};
    
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
    
    
    Quad7SegDisplay q7seg(seg,dp,an3,an2,an1,an0,num3,num2,num1,num0,targetClk);
endmodule
