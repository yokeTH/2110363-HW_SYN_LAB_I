`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/07/2024 05:33:22 AM
// Design Name:
// Module Name: ClkDivider
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


module ClkDivider(output reg out,
                  input wire in);
    
    initial begin
        out <= 0;
    end
    
    always @(posedge in) begin
        out <= ~out;
    end
endmodule
