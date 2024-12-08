`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/05/2024 07:36:49 AM
// Design Name:
// Module Name: Rectangle_Top
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


module Rectangle_Top (
    input  wire       clk,       // System clock
    input  wire       btnU,      // Reset
    input  wire       RsRx,      // UART RX
    output wire       RsTx,      // UART TX (loopback)
    output wire       Hsync,     // VGA horizontal sync
    output wire       Vsync,     // VGA vertical sync
    output wire [3:0] vgaRed,    // VGA red channel
    output wire [3:0] vgaGreen,  // VGA green channel
    output wire [3:0] vgaBlue    // VGA blue channel
);
    // Internal signals
    wire [9:0] pixel_x, pixel_y;
    wire video_on, pixel_tick;
    wire [11:0] vram_out;
    wire [18:0] read_addr;
    wire        rect_we;
    wire [18:0] rect_addr;
    wire [11:0] rect_data;
    wire [11:0] rgb;

    // UART loopback
    assign RsTx = RsRx;

    // VGA sync generation
    VGA_sync sync_unit (
        .clk     (clk),
        .reset   (btnU),
        .hsync   (Hsync),
        .vsync   (Vsync),
        .video_on(video_on),
        .p_tick  (pixel_tick),
        .x       (pixel_x),
        .y       (pixel_y)
    );

    // Video RAM
    VideoRam #(
        .ADDR_WIDTH(19),  // 640*480 = 307,200 locations
        .DATA_WIDTH(12)   // 12-bit color
    ) video_ram (
        .clk       (clk),
        .we        (rect_we),
        .write_addr(rect_addr),
        .write_data(rect_data),
        .read_addr ((pixel_y * 640) + pixel_x),
        .read_data (vram_out)
    );

    // Rectangle drawing signals
    reg [9:0] rect_x, rect_y, rect_width, rect_height;
    reg  [11:0] rect_color;
    reg         draw_start;
    wire        drawing_done;
    reg  [ 2:0] rect_count;

    // Rectangle generator
    RectangleGenerator rect_unit (
        .clk         (clk),
        .reset       (btnU),
        .rect_x      (rect_x),
        .rect_y      (rect_y),
        .rect_width  (rect_width),
        .rect_height (rect_height),
        .rect_color  (rect_color),
        .draw_start  (draw_start),
        .write_enable(rect_we),
        .write_addr  (rect_addr),
        .write_data  (rect_data),
        .drawing_done(drawing_done)
    );

    // Test pattern generator
    always @(posedge clk or posedge btnU) begin
        if (btnU) begin
            rect_count <= 0;
            draw_start <= 0;
        end else begin
            if (!draw_start && !drawing_done) begin
                case (rect_count)
                    0: begin  // Red rectangle
                        rect_x      <= 100;
                        rect_y      <= 100;
                        rect_width  <= 120;
                        rect_height <= 80;
                        rect_color  <= 12'hF00;
                        draw_start  <= 1;
                    end

                    1: begin  // Green rectangle
                        rect_x      <= 300;
                        rect_y      <= 200;
                        rect_width  <= 80;
                        rect_height <= 120;
                        rect_color  <= 12'h0F0;
                        draw_start  <= 1;
                    end

                    2: begin  // Blue rectangle
                        rect_x      <= 200;
                        rect_y      <= 300;
                        rect_width  <= 100;
                        rect_height <= 100;
                        rect_color  <= 12'h00F;
                        draw_start  <= 1;
                    end

                    default: begin
                        draw_start <= 0;
                    end
                endcase
            end else if (drawing_done) begin
                draw_start <= 0;
                if (rect_count < 3) rect_count <= rect_count + 1;
            end
        end
    end

    // Final RGB output
    assign rgb      = video_on ? vram_out : 12'h000;

    // Split 12-bit RGB into separate channels
    assign vgaRed   = rgb[11:8];
    assign vgaGreen = rgb[7:4];
    assign vgaBlue  = rgb[3:0];
endmodule
