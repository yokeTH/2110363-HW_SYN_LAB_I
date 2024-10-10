`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/05/2024 11:23:37 AM
// Design Name:
// Module Name: shiftA
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


module shiftA(output reg [1:0] q,
              input clk,
              input d);
    
    always @(posedge clk) begin
        q[0] = d;
        q[1] = q[0];
    end
endmodule
