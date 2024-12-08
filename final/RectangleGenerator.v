`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/05/2024 07:35:43 AM
// Design Name:
// Module Name: RectangleGenerator
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


module RectangleGenerator (
    input  wire        clk,
    input  wire        reset,
    input  wire [ 9:0] rect_x,        // Rectangle top-left X (0-639)
    input  wire [ 9:0] rect_y,        // Rectangle top-left Y (0-479)
    input  wire [ 9:0] rect_width,    // Rectangle width
    input  wire [ 9:0] rect_height,   // Rectangle height
    input  wire [11:0] rect_color,    // Rectangle color (RGB444)
    input  wire        draw_start,    // Start drawing signal
    output reg         write_enable,
    output reg  [18:0] write_addr,
    output reg  [11:0] write_data,
    output reg         drawing_done
);
    // Drawing state machine
    localparam integer IDLE = 0;
    localparam integer DRAWING = 1;
    localparam integer DONE = 2;

    reg [1:0] state;
    reg [9:0] current_x;
    reg [9:0] current_y;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state        <= IDLE;
            write_enable <= 0;
            write_addr   <= 0;
            write_data   <= 0;
            current_x    <= 0;
            current_y    <= 0;
            drawing_done <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (draw_start) begin
                        state        <= DRAWING;
                        current_x    <= rect_x;
                        current_y    <= rect_y;
                        drawing_done <= 0;
                    end
                end

                DRAWING: begin
                    if (current_x < 640 && current_y < 480) begin
                        write_enable <= 1;
                        write_data   <= rect_color;
                        write_addr   <= (current_y * 640) + current_x;

                        if (current_x < rect_x + rect_width - 1) begin
                            current_x <= current_x + 1;
                        end else begin
                            current_x <= rect_x;
                            if (current_y < rect_y + rect_height - 1) begin
                                current_y <= current_y + 1;
                            end else begin
                                state <= DONE;
                            end
                        end
                    end else begin
                        state <= DONE;
                    end
                end

                DONE: begin
                    write_enable <= 0;
                    drawing_done <= 1;
                    state        <= IDLE;
                end

                default: begin
                    state        <= IDLE;
                    write_enable <= 0;
                    write_addr   <= 0;
                    write_data   <= 0;
                    current_x    <= 0;
                    current_y    <= 0;
                    drawing_done <= 0;
                end
            endcase
        end
    end
endmodule
