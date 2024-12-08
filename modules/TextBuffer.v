`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/05/2024 07:11:56 AM
// Design Name:
// Module Name: TextBuffer
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

module TextBuffer #(
    parameter COLS = 80,  // 80 columns
    parameter ROWS = 30   // 30 rows
) (
    input  wire       clk,
    input  wire       reset,
    // Write interface
    input  wire       write_enable,
    input  wire [6:0] write_x,
    input  wire [4:0] write_y,
    input  wire [6:0] write_data,
    output reg        busy,          // Indicates buffer is busy with write operation
    // Read interface
    input  wire [6:0] read_x,
    input  wire [4:0] read_y,
    output reg  [6:0] char_out
);
    // Text buffer memory
    reg [6:0] buffer      [ROWS-1:0][COLS-1:0];

    // Write operation state
    reg [1:0] write_state;
    localparam IDLE = 2'b00;
    localparam WRITING = 2'b01;
    localparam WRITE_COMPLETE = 2'b10;

    integer i, j;
    // Initialize buffer with spaces
    initial begin
        for (i = 0; i < ROWS; i = i + 1)
        for (j = 0; j < COLS; j = j + 1) buffer[i][j] = 7'h20;  // Fill with spaces
        busy        = 1'b0;
        write_state = IDLE;
    end

    // Write state machine and busy signal
    always @(posedge clk) begin
        if (reset) begin
            busy        <= 1'b0;
            write_state <= IDLE;
            for (i = 0; i < ROWS; i = i + 1) for (j = 0; j < COLS; j = j + 1) buffer[i][j] <= 7'h20;
        end else begin
            case (write_state)
                IDLE: begin
                    if (write_enable && write_x < COLS && write_y < ROWS) begin
                        busy        <= 1'b1;
                        write_state <= WRITING;
                    end
                end

                WRITING: begin
                    buffer[write_y][write_x] <= write_data;
                    write_state              <= WRITE_COMPLETE;
                end

                WRITE_COMPLETE: begin
                    busy        <= 1'b0;
                    write_state <= IDLE;
                end

                default: write_state <= IDLE;
            endcase
        end
    end

    // Read operation (independent from write operation)
    always @(posedge clk) begin
        if (read_x < COLS && read_y < ROWS) char_out <= buffer[read_y][read_x];
        else char_out <= 7'h20;  // Space for out of bounds
    end
endmodule
