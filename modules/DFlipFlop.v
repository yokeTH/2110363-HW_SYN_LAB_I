`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/05/2024 10:22:46 AM
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


module DFlipFlop (
    output reg  q,
    input  wire clk,
    input  wire nreset,
    input  wire d
);

    always @(posedge clk or nreset) begin
        if (nreset == 1) begin
            q = d;
        end else begin
            q = 0;
        end
    end
endmodule
