`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/05/2024 07:11:56 AM
// Design Name:
// Module Name: VGA_sync
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


module VGA_sync (
    input  wire       clk,       // Input clock (100MHz expected)
    input  wire       reset,     // System reset
    output wire       hsync,     // Horizontal sync
    output wire       vsync,     // Vertical sync
    output wire       video_on,  // Display area active
    output wire       p_tick,    // Pixel clock tick (25MHz)
    output wire [9:0] x,         // Current pixel X coordinate
    output wire [9:0] y          // Current pixel Y coordinate
);

    // VGA 640x480@60Hz timing parameters
    localparam integer HDisplay = 640;   // Horizontal display area
    localparam integer HFront = 16;      // Horizontal front porch
    localparam integer HSync = 96;       // Horizontal sync pulse
    localparam integer HBack = 48;       // Horizontal back porch
    localparam integer HTotal = HDisplay + HFront + HSync + HBack; // Total horizontal time

    localparam integer VDisplay = 480;   // Vertical display area
    localparam integer VFront = 10;      // Vertical front porch
    localparam integer VSync = 2;        // Vertical sync pulse
    localparam integer VBack = 33;       // Vertical back porch
    localparam integer VTotal = VDisplay + VFront + VSync + VBack; // Total vertical time

    // Counter signals
    reg [1:0] pixel_count = 0;           // Pixel clock divider counter
    reg [9:0] h_count = 0;               // Horizontal pixel counter
    reg [9:0] v_count = 0;               // Vertical line counter

    // Generate 25MHz pixel tick from 100MHz input clock
    assign p_tick = (pixel_count == 0);

    // Counters for horizontal and vertical sync
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all counters
            pixel_count <= 0;
            h_count     <= 0;
            v_count     <= 0;
        end else begin
            // Increment pixel clock divider counter
            pixel_count <= pixel_count + 1;
            if (p_tick) begin
                // Increment horizontal counter
                if (h_count == HTotal - 1) begin
                    h_count <= 0;
                    // Increment vertical counter
                    if (v_count == VTotal - 1) v_count <= 0;
                    else v_count <= v_count + 1;
                end else h_count <= h_count + 1;
            end
        end
    end

    // Generate horizontal sync pulse
    assign hsync = (h_count >= (HDisplay + HFront) &&
                   h_count < (HDisplay + HFront + HSync)) ? 0 : 1;

    // Generate vertical sync pulse
    assign vsync = (v_count >= (VDisplay + VFront) &&
                   v_count < (VDisplay + VFront + VSync)) ? 0 : 1;

    // Indicate when the display area is active
    assign video_on = (h_count < HDisplay && v_count < VDisplay);

    // Output current pixel coordinates
    assign x = h_count;
    assign y = v_count;
endmodule
