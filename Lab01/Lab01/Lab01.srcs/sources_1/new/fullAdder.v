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


module fullAdder(output cout,
                 output s,
                 input a,
                 input b,
                 input c);
    always @(*) begin
        {cout, s} = a + b + c;
    end
endmodule
