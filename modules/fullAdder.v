`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/05/2024 09:42:04 AM
// Design Name:
// Module Name: fullAdder
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


module fullAdder (
    output reg  cout,
    output reg  s,
    input  wire a,
    input  wire b,
    input  wire c
);
    always @(*) begin
        assign {cout, s} = a + b + c;
    end
endmodule
