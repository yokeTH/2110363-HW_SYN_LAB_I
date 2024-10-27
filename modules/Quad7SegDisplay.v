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


module Quad7SegDisplay #(
    parameter integer INPUT_WIDTH = 8
) (
    output wire [            6:0] seg,
    output wire                   dp,
    output wire [            3:0] an,
    output reg  [INPUT_WIDTH-1:0] present_digit,
    input  wire [            6:0] segment_data,
    input  wire [INPUT_WIDTH-1:0] digit3,         // most left
    input  wire [INPUT_WIDTH-1:0] digit2,
    input  wire [INPUT_WIDTH-1:0] digit1,
    input  wire [INPUT_WIDTH-1:0] digit0,         // most right
    input  wire                   clk
);

    reg  [1:0] state;
    reg  [3:0] display_enable;
    wire [6:0] decode_out;


    always @(posedge clk) begin : state_change
        state <= state + 1;

        case (state)
            2'b00: begin
                present_digit  <= digit0;
                display_enable <= 4'b0001;
            end
            2'b01: begin
                present_digit  <= digit1;
                display_enable <= 4'b0010;
            end
            2'b10: begin
                present_digit  <= digit2;
                display_enable <= 4'b0100;
            end
            2'b11: begin
                present_digit  <= digit3;
                display_enable <= 4'b1000;
            end
            default: ;
        endcase
    end

    assign seg = segment_data;
    assign an  = ~display_enable;
    assign dp  = 1;


endmodule
