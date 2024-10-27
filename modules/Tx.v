`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/22/2024 04:28:04 AM
// Design Name:
// Module Name: Tx
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


module Tx #(
    parameter integer SAMPLING_RATE = 16
) (
    input  wire       clk,
    input  wire [7:0] data_transmit,
    input  wire       ena,
    output reg        sent,
    output reg        sending = 0,
    output reg        bit_out
);

    reg       last_ena;
    reg [7:0] count;
    reg [7:0] temp;

    localparam integer IntervalSignalCount = SAMPLING_RATE / 2;

    always @(posedge clk) begin
        if (~sending & ~last_ena & ena) begin
            temp    <= data_transmit;
            sending <= 1;
            sent    <= 0;
            count   <= 0;
        end

        // send one time
        last_ena <= ena;

        if (sending) count <= count + 1;
        else begin
            count   <= 0;
            bit_out <= 1;  // Idle state is high
        end

        // sampling at middle of the signal
        // 2 * i + 1 is the middle of the signal
        case (count)
            IntervalSignalCount * 1:  bit_out <= 0;        // Start bit
            IntervalSignalCount * 3:  bit_out <= temp[0];  // Data bit 0
            IntervalSignalCount * 5:  bit_out <= temp[1];  // Data bit 1
            IntervalSignalCount * 7:  bit_out <= temp[2];  // Data bit 2
            IntervalSignalCount * 9:  bit_out <= temp[3];  // Data bit 3
            IntervalSignalCount * 11: bit_out <= temp[4];  // Data bit 4
            IntervalSignalCount * 13: bit_out <= temp[5];  // Data bit 5
            IntervalSignalCount * 15: bit_out <= temp[6];  // Data bit 6
            IntervalSignalCount * 17: bit_out <= temp[7];  // Data bit 7
            IntervalSignalCount * 19: begin
                bit_out <= 1;  // Stop bit
                sent    <= 1;
                sending <= 0;
            end
            default:                  ;
        endcase
    end


endmodule
