`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2024 01:23:54 AM
// Design Name: 
// Module Name: TxMultiByte
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


module TxMultiByte #(
    parameter integer SAMPLING_RATE = 16
) (
    input  wire        clk,
    input  wire [23:0] data_transmit,
    input  wire [ 2:0] bytes_to_send,
    input  wire        ena,
    output reg         sent,
    output reg         sending = 0,
    output reg         bit_out
);
    reg        last_ena;
    reg [ 7:0] count;
    reg [23:0] temp;
    reg [ 2:0] current_byte;
    reg [ 7:0] current_data;

    localparam integer IntervalSignalCount = SAMPLING_RATE / 2;

    always @(posedge clk) begin
        if (~sending & ~last_ena & ena) begin
            temp         <= data_transmit;
            sending      <= 1;
            sent         <= 0;
            count        <= 0;
            current_byte <= 0;
        end

        last_ena <= ena;

        if (sending) begin
            count <= count + 1;

            case (current_byte)
                0:       current_data <= temp[23:16];
                1:       current_data <= temp[15:8];
                2:       current_data <= temp[7:0];
                default: current_data <= temp[7:0];
            endcase
        end else begin
            count   <= 0;
            bit_out <= 1;  // Idle state is high
        end

        case (count)
            IntervalSignalCount * 1:  bit_out <= 0;  // Start bit
            IntervalSignalCount * 3:  bit_out <= current_data[0];  // Data bit 0
            IntervalSignalCount * 5:  bit_out <= current_data[1];  // Data bit 1
            IntervalSignalCount * 7:  bit_out <= current_data[2];  // Data bit 2
            IntervalSignalCount * 9:  bit_out <= current_data[3];  // Data bit 3
            IntervalSignalCount * 11: bit_out <= current_data[4];  // Data bit 4
            IntervalSignalCount * 13: bit_out <= current_data[5];  // Data bit 5
            IntervalSignalCount * 15: bit_out <= current_data[6];  // Data bit 6
            IntervalSignalCount * 17: bit_out <= current_data[7];  // Data bit 7
            IntervalSignalCount * 19: begin
                bit_out <= 1;  // Stop bit
                if (current_byte == bytes_to_send - 1) begin
                    sent         <= 1;
                    sending      <= 0;
                    current_byte <= 0;
                end else begin
                    current_byte <= current_byte + 1;
                    count        <= 0;
                end
            end
            default:                  ;
        endcase
    end
endmodule

