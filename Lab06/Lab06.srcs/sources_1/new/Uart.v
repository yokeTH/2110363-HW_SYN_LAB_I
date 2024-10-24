`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/22/2024 04:28:04 AM
// Design Name:
// Module Name: Uart
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


module Uart #(
    parameter integer CLOCK_FREQ = 100_000_000,
    parameter integer BAUD_RATE = 9600,
    parameter integer SAMPLING_RATE = 16
) (
    input clk,
    input RsRx,
    output RsTx,
    output wire [7:0] data_out,
    output receiving,
    output received
);
    reg en, last_rec;
    reg [7:0] data_in;
    wire sent, received, baud;

    BaudrateGenerator #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .SAMPLING_RATE(SAMPLING_RATE)
    ) baudrate_gen (
        .clk (clk),
        .baud(baud)
    );

    Rx #(
        .SAMPLING_RATE(SAMPLING_RATE)
    ) receiver (
        .clk(baud),
        .bit_in(RsRx),
        .received(received),
        .data_out(data_out),
        .receiving(receiving)
    );

    Tx #(
        .SAMPLING_RATE(SAMPLING_RATE)
    ) transmitter (
        .clk(baud),
        .data_transmit(data_in),
        .ena(en),
        .sent(sent),
        .bit_out(RsTx)
    );

    always @(posedge baud) begin
        if (en) en = 0;
        if (~last_rec & received) begin
            data_in = data_out;
            en = 1;
        end
        // send one time
        last_rec = received;
    end

endmodule
