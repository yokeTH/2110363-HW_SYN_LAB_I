`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2024 09:56:52 PM
// Design Name: 
// Module Name: TxWrapper
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


module TxWrapper #(
    parameter integer SAMPLING_RATE = 16
) (
    input  wire       baud,
    input  wire       clk,
    input  wire [7:0] data_transmit,
    input  wire       ena,
    output wire       sent,
    output wire       sending,
    output wire       bit_out
);

    // Synchronization registers for UART received signal
    reg sent_1 = 0;
    reg sent_2 = 0;

    // Double-register UART received signal for synchronization
    always @(posedge clk) begin
        sent_1 <= sent_tx;
        sent_2 <= sent_1;
    end

    // Generate received pulse
    assign sent = sent_1 & ~sent_2;


    reg posedge_baud_cnt = 0;
    reg longer_ena = 0;
    reg now_baud_is_down = 0;

    always @(posedge clk) begin
        if (baud && ~posedge_baud_cnt && ena) begin
            posedge_baud_cnt <= 1;
            longer_ena       <= 1;
        end
        if (~baud && posedge_baud_cnt) begin
            posedge_baud_cnt <= 0;
            now_baud_is_down <= 1;
        end
        if (baud && now_baud_is_down) begin
            now_baud_is_down <= 0;
            longer_ena       <= 0;
        end
    end

    wire sent_tx;

    Tx #(
        .SAMPLING_RATE(SAMPLING_RATE)
    ) tx_pmod (
        .clk          (baud),
        .data_transmit(data_transmit),
        .ena          (longer_ena),
        .sent         (sent_tx),
        .sending      (sending),
        .bit_out      (bit_out)
    );

endmodule
