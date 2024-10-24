`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/22/2024 04:28:04 AM
// Design Name:
// Module Name: BaudrateGenerator
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


module BaudrateGenerator #(
    parameter integer CLOCK_FREQ = 100_000_000,
    parameter integer BAUD_RATE  = 9600,
    parameter integer SAMPLING_RATE = 16
) (
    input wire clk,
    output reg baud
);
    // divide the clock frequency by the baud rate and the sampling rate
    // and divide by 2 to get low and high in 1 sampling rate
    localparam integer CounterMax = CLOCK_FREQ / BAUD_RATE / SAMPLING_RATE / 2;
    integer counter;
    always @(posedge clk) begin
        counter = counter + 1;
        if (counter == CounterMax) begin
            counter = 0;
            baud = ~baud;
        end
    end

endmodule
