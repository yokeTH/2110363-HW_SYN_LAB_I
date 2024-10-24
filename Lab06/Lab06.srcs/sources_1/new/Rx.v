`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/22/2024 04:28:04 AM
// Design Name:
// Module Name: Rx
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


module Rx #(
    parameter integer SAMPLING_RATE = 16
) (
    input clk,
    input bit_in,
    output reg received,
    output reg [7:0] data_out,
    output reg receiving = 0
);

    reg last_bit;
    reg [7:0] count;

    localparam integer IntervalSignalCount = SAMPLING_RATE / 2;

    always @(posedge clk) begin
        if (~receiving & last_bit & ~bit_in) begin
            receiving <= 1;
            received  <= 0;
            count     <= 0;
        end

        last_bit <= bit_in;
        count    <= (receiving) ? count + 1 : 0;

        // sampling at middle of the signal
        // 2 * i + 1 is the middle of the signal
        // ignored i = 0 because it is the start bit
        case (count)
            IntervalSignalCount * 3: data_out[0] <= bit_in;  // Data bit 0
            IntervalSignalCount * 5: data_out[1] <= bit_in;  // Data bit 1
            IntervalSignalCount * 7: data_out[2] <= bit_in;  // Data bit 2
            IntervalSignalCount * 9: data_out[3] <= bit_in;  // Data bit 3
            IntervalSignalCount * 11: data_out[4] <= bit_in;  // Data bit 4
            IntervalSignalCount * 13: data_out[5] <= bit_in;  // Data bit 5
            IntervalSignalCount * 15: data_out[6] <= bit_in;  // Data bit 6
            IntervalSignalCount * 17: data_out[7] <= bit_in;  // Data bit 7
            IntervalSignalCount * 19: begin
                received  <= 1;
                receiving <= 0;
            end
            default: ;
        endcase
    end

endmodule
