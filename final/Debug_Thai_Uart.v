`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2024 12:26:40 AM
// Design Name: 
// Module Name: Debug_Thai_Uart
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


module Thai_Uart (
    output wire RsTx,
    input  wire RsRx,
    input  wire clk
);
    // Local Params
    localparam integer SystemClockFreqency = 100_000_000;
    localparam integer BaudRate = 115200;
    localparam integer SamplingRate = 16;

    // Internal signals
    wire [7:0] rx_data;
    wire received, sending, sent, receiving;
    reg  [ 2:0] state;
    reg  [ 1:0] byte_count;
    reg  [23:0] utf8_buffer;
    reg  [ 3:0] hex_position;
    wire        baud;
    reg         last_rec;

    // State definitions
    localparam IDLE = 0;
    localparam COLLECT_UTF8 = 1;
    localparam SEND_HEX = 2;
    localparam WAIT_SEND = 3;

    // Baud generator
    BaudrateGenerator #(
        .CLOCK_FREQ   (SystemClockFreqency),
        .BAUD_RATE    (BaudRate),
        .SAMPLING_RATE(SamplingRate)
    ) baudrate_gen (
        .clk (clk),
        .baud(baud)
    );

    // Receiver
    Rx #(
        .SAMPLING_RATE(SamplingRate)
    ) receiver (
        .clk      (baud),
        .bit_in   (RsRx),
        .received (received),
        .data_out (rx_data),
        .receiving(receiving)
    );

    // Transmitter control signals
    reg [7:0] tx_data;
    reg       tx_en;

    // Transmitter
    Tx #(
        .SAMPLING_RATE(SamplingRate)
    ) transmitter (
        .clk          (baud),
        .data_transmit(tx_data),
        .ena          (tx_en),
        .sent         (sent),
        .bit_out      (RsTx),
        .sending      (sending)
    );

    // Main state machine
    always @(posedge baud) begin
        // Clear enable after sending starts
        if (tx_en) tx_en <= 0;

        case (state)
            IDLE: begin
                if (received && !sending && !tx_en) begin
                    if (rx_data[7:6] == 2'b11) begin  // UTF-8 multi-byte start
                        utf8_buffer[23:16] <= rx_data;
                        byte_count         <= 2'b01;
                        state              <= COLLECT_UTF8;
                    end else begin
                        // Normal ASCII
                        tx_data <= rx_data;
                        tx_en   <= 1;
                    end
                end
            end

            COLLECT_UTF8: begin
                if (received && !sending && !tx_en) begin
                    case (byte_count)
                        2'b01: begin
                            utf8_buffer[15:8] <= rx_data;
                            byte_count        <= 2'b10;
                        end
                        2'b10: begin
                            utf8_buffer[7:0] <= rx_data;
                            hex_position     <= 0;
                            state            <= WAIT_SEND;
                        end
                    endcase
                end
            end

            WAIT_SEND: begin
                if (!sending && !tx_en) begin
                    state <= SEND_HEX;
                end
            end

            SEND_HEX: begin
                if (!sending && !tx_en) begin
                    case (hex_position)
                        4'h0: tx_data <= "E";
                        4'h1: tx_data <= "0";
                        4'h2: tx_data <= "B";
                        4'h3: tx_data <= "8";
                        4'h4: tx_data <= "8";
                        4'h5: tx_data <= "1";
                        4'h6: tx_data <= 8'h0D;  // CR
                        4'h7: tx_data <= 8'h0A;  // LF
                        4'h8: begin
                            state      <= IDLE;
                            byte_count <= 0;
                        end
                    endcase

                    if (hex_position < 4'h8) begin
                        tx_en        <= 1;
                        hex_position <= hex_position + 1;
                    end
                end
            end
        endcase
    end

endmodule
