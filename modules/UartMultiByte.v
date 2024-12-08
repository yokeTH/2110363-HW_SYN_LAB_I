`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2024 01:23:54 AM
// Design Name: 
// Module Name: UartMultiByte
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


module UartMultiByte #(
    parameter integer CLOCK_FREQ    = 100_000_000,
    parameter integer BAUD_RATE     = 9600,
    parameter integer SAMPLING_RATE = 16
) (
    input  wire        clk,
    input  wire        RsRx,
    output wire        RsTx,
    input  wire [23:0] data_to_send,
    input  wire [ 2:0] bytes_to_send,
    input  wire        en,
    output wire [ 7:0] ascii_out,
    output wire [23:0] utf8_out,
    output wire        receiving,
    output wire        received,
    output wire        is_utf8,
    output wire        sent,
    output wire        sending
);
    wire [ 7:0] rx_data;
    reg  [23:0] utf8_buffer;
    reg  [ 1:0] byte_count;
    reg         utf8_mode;
    wire        rx_received;  // Changed from reg to wire
    wire        baud;

    BaudrateGenerator #(
        .CLOCK_FREQ   (CLOCK_FREQ),
        .BAUD_RATE    (BAUD_RATE),
        .SAMPLING_RATE(SAMPLING_RATE)
    ) baudrate_gen (
        .clk (clk),
        .baud(baud)
    );

    Rx #(
        .SAMPLING_RATE(SAMPLING_RATE)
    ) receiver (
        .clk      (baud),
        .bit_in   (RsRx),
        .received (rx_received),  // Now correctly connected as a wire
        .data_out (rx_data),
        .receiving(receiving)
    );

    TxMultiByte #(
        .SAMPLING_RATE(SAMPLING_RATE)
    ) transmitter (
        .clk          (baud),
        .data_transmit(data_to_send),
        .bytes_to_send(bytes_to_send),
        .ena          (en),
        .sent         (sent),
        .bit_out      (RsTx),
        .sending      (sending)
    );

    // UTF-8 detection and processing
    always @(posedge baud) begin
        if (rx_received) begin
            if (byte_count == 0) begin
                if (rx_data[7:5] == 3'b111) begin  // 3-byte UTF-8
                    utf8_mode          <= 1;
                    utf8_buffer[23:16] <= rx_data;
                    byte_count         <= 1;
                end else begin  // ASCII
                    utf8_mode        <= 0;
                    utf8_buffer[7:0] <= rx_data;
                end
            end else if (utf8_mode) begin
                case (byte_count)
                    1: begin
                        utf8_buffer[15:8] <= rx_data;
                        byte_count        <= 2;
                    end
                    2: begin
                        utf8_buffer[7:0] <= rx_data;
                        byte_count       <= 0;
                    end
                endcase
            end
        end
    end

    assign ascii_out = utf8_mode ? 8'h00 : rx_data;
    assign utf8_out  = utf8_buffer;
    assign is_utf8   = utf8_mode;
    assign received  = (utf8_mode && byte_count == 0) || (!utf8_mode && rx_received);

endmodule
