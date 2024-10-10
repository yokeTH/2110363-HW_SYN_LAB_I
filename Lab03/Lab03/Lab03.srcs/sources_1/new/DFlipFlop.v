`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/07/2024 10:36:51 AM
// Design Name:
// Module Name: DFlipFlop
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


module DFlipFlop(output reg q,
                 input d,
                 input reset,
                 input clk);
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            q <= 1'b0;
            end else begin
            q <= d;
        end
    end
endmodule
