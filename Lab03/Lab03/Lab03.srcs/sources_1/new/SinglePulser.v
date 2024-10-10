`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/07/2024 09:06:26 AM
// Design Name:
// Module Name: SinglePulser
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


module SinglePulser(output reg out,
                    input in,
                    input clk);
    
    reg state;
    
    always @(posedge clk) begin
        out = 0;
        case ({state, in})
            2'b01: begin
                out   = 1;
                state = 1;
            end
            2'b10: begin
                state = 0;
            end
        endcase
    end
endmodule
