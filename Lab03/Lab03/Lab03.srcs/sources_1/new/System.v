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


module System(output [6:0] seg,
              output dp,
              output [3:0] an,
              input btnC,
              input btnU,
              input [7:0] sw,
              input clk);
    
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
    
    // end divide clock
    
    // Display Controller
    wire [3:0] num3, num2, num1, num0;
    wire an3, an2, an1, an0;
    
    assign an = {an3, an2, an1, an0};
    Quad7SegDisplay q7seg(seg, dp, an3, an2, an1, an0, num3, num2, num1, num0, targetClk);
    
    // end Display Controller
    // BCD counter
    // Counter 3 (left)
    wire [3:0] outputs_3;
    wire cout_3, bout_3, up_3, down_3, set9_3, set0_3;
    BCDCounter counter_3(outputs_3, cout_3, bout_3, up_3, down_3, set9_3, set0_3, targetClk);
    
    
    // Counter 2
    wire [3:0] outputs_2;
    wire cout_2, bout_2, up_2, down_2, set9_2, set0_2;
    BCDCounter counter_2(outputs_2, cout_2, bout_2, up_2, down_2, set9_2, set0_2, targetClk);
    
    // Counter 1
    wire [3:0] outputs_1;
    wire cout_1, bout_1, up_1, down_1, set9_1, set0_1;
    BCDCounter counter_1(outputs_1, cout_1, bout_1, up_1, down_1, set9_1, set0_1, targetClk);
    
    // Counter 0 (right)
    wire [3:0] outputs_0;
    wire cout_0, bout_0, up_0, down_0, set9_0, set0_0;
    BCDCounter counter_0(outputs_0, cout_0, bout_0, up_0, down_0, set9_0, set0_0, targetClk);
    
    
    assign set0_0 = btnC || bout_0;
    assign set0_1 = btnC || bout_0;
    assign set0_2 = btnC || bout_0;
    assign set0_3 = btnC || bout_0;
    
    assign set9_0 = btnU || cout_3;
    assign set9_1 = btnU || cout_3;
    assign set9_2 = btnU || cout_3;
    assign set9_3 = btnU || cout_3;
    
    assign down_0 = sw[0];
    assign down_1 = sw[2] || bout_0;
    assign down_2 = sw[4] || bout_1;
    assign down_3 = sw[6] || bout_2;
    
    assign up_0 = sw[1];
    assign up_1 = sw[3] || cout_0;
    assign up_2 = sw[5] || cout_1;
    assign up_3 = sw[7] || cout_2;
    
    assign num3 = outputs_3;
    assign num2 = outputs_2;
    assign num1 = outputs_1;
    assign num0 = outputs_0;
    
endmodule
