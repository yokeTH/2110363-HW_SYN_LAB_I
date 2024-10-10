`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/07/2024 05:33:22 AM
// Design Name:
// Module Name: Quad7SegDisplay
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


module Quad7SegDisplay(output reg [6:0] seg,
                       output reg dp,
                       output reg an3,
                       output reg an2,
                       output reg an1,
                       output reg an0,
                       input [3:0] num3,
                       input [3:0] num2,
                       input [3:0] num1,
                       input [3:0] num0,
                       input wire overflow,
                       input clk);
    
    reg [1:0] present_state, next_state;
    reg [3:0] present_num, display_enable;
    wire [6:0] decode_out;
    
    NumTo7Seg decode(decode_out, present_num,overflow);
    
    always @(posedge clk) begin
        present_state <= next_state;
        next_state    <= next_state + 1;
        
        case (present_state)
            2'b00: begin
                present_num    <= num0;
                display_enable <= 4'b0001;
            end
            2'b01: begin
                present_num    <= num1;
                display_enable <= 4'b0010;
            end
            2'b10: begin
                present_num    <= num2;
                display_enable <= 4'b0100;
            end
            2'b11: begin
                present_num    <= num3;
                display_enable <= 4'b1000;
            end
        endcase
    end
    
    always @(*) begin
        {an3, an2, an1, an0} <= ~display_enable;
        dp                   <= 0;
        seg                  <= decode_out;
    end
        
endmodule
