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

`timescale 1ns / 1ps

module Final (
    input  wire       clk,       // System clock
    input  wire       btnU,         // Reset
    input  wire       RsRx,      // UART RX
    output wire       RsTx,      // UART TX (loopback)
    output wire       Hsync,     // VGA horizontal sync
    output wire       Vsync,     // VGA vertical sync
    output wire [3:0] vgaRed,    // VGA red channel
    output wire [3:0] vgaGreen,  // VGA green channel
    output wire [3:0] vgaBlue    // VGA blue channel
);

    // Text display parameters
    localparam TEXT_COLS = 106;  // 1280/12 rounded down
    localparam TEXT_ROWS = 30;  // 720/24 rounded down

    // Internal signals
    wire       clk_74_25MHz;
    wire       mmcm_locked;

    // UART signals
    wire [7:0] rx_data;
    wire receiving, received;
    wire sending, sent;

    // Text position tracking
    reg  [ 6:0] cursor_x = 0;
    reg  [ 4:0] cursor_y = 0;

    // Text to VRAM signals
    reg         write_char;
    reg  [ 6:0] ascii_char;
    reg  [11:0] char_color;
    wire        char_busy;
    wire        char_done;

    // VRAM interface signals
    wire [16:0] vram_read_addr;
    wire        write_enable;
    wire [16:0] write_addr;
    wire [11:0] write_data;
    wire [3:0] vram_r, vram_g, vram_b;

    // Character ROM interface
    wire [6:0] char_code;
    wire [4:0] char_row;
    wire [3:0] char_col;
    wire       char_pixel;

    // Clock generator
    ClockGenerator clk_gen (
        .clk_100MHz  (clk),
        .rst         (rst),
        .clk_74_25MHz(clk_74_25MHz),
        .locked      (mmcm_locked)
    );

    // UART module (your existing module)
    Uart #(
        .CLOCK_FREQ(100_000_000),
        .BAUD_RATE (9600)
    ) uart (
        .clk      (clk),
        .RsRx     (RsRx),
        .RsTx     (RsTx),
        .data_out (rx_data),
        .receiving(receiving),
        .received (received),
        .sending  (sending),
        .sent     (sent)
    );

    // VGA Controller
    VGAController vga_ctrl (
        .clk_100MHz  (clk),
        .rst         (rst),
        .clk_74_25MHz(clk_74_25MHz),
        .vga_hsync   (vga_hsync),
        .vga_vsync   (vga_vsync),
        .vga_red     (vga_red),
        .vga_green   (vga_green),
        .vga_blue    (vga_blue),
        .vram_addr   (vram_read_addr),
        .vram_red    (vram_r),
        .vram_green  (vram_g),
        .vram_blue   (vram_b)
    );

    // Character ROM
    CharacterROM char_rom (
        .char_code(char_code),
        .row      (char_row),
        .col      (char_col),
        .pixel    (char_pixel)
    );

    // Video RAM
    VideoRAM vram (
        .clk_write   (clk),
        .clk_read    (clk_74_25MHz),
        .write_enable(write_enable),
        .write_addr  (write_addr),
        .write_data  (write_data),
        .read_addr   (vram_read_addr),
        .red_out     (vram_r),
        .green_out   (vram_g),
        .blue_out    (vram_b)
    );

    // Text to VRAM controller
    TextToVRAMController text_ctrl (
        .clk         (clk),
        .rst         (rst),
        .ascii_in    (ascii_char),
        .color       (char_color),
        .text_x      (cursor_x),
        .text_y      (cursor_y),
        .write_char  (write_char),
        .char_code   (char_code),
        .char_row    (char_row),
        .char_col    (char_col),
        .char_pixel  (char_pixel),
        .write_enable(write_enable),
        .write_addr  (write_addr),
        .write_data  (write_data),
        .busy        (char_busy),
        .done        (char_done)
    );

    // UART character processing
    reg last_received;

    always @(posedge clk) begin
        if (rst) begin
            cursor_x      <= 0;
            cursor_y      <= 0;
            write_char    <= 0;
            char_color    <= 12'hFFF;  // White text
            last_received <= 0;
        end else begin
            // Detect new character received
            if (received && !last_received) begin
                // Process the received character
                case (rx_data)
                    8'h0D: begin  // Carriage return
                        cursor_x   <= 0;
                        write_char <= 0;
                    end

                    8'h0A: begin  // Line feed
                        if (cursor_y < TEXT_ROWS - 1) cursor_y <= cursor_y + 1;
                        else cursor_y <= 0;  // Wrap to top
                        write_char <= 0;
                    end

                    default: begin  // Normal character
                        ascii_char <= rx_data[6:0];  // ASCII 7-bit
                        write_char <= 1;
                    end
                endcase
            end else begin
                write_char <= 0;

                // Move cursor after character is written
                if (char_done && (rx_data != 8'h0D) && (rx_data != 8'h0A)) begin
                    if (cursor_x < TEXT_COLS - 1) cursor_x <= cursor_x + 1;
                    else begin
                        cursor_x <= 0;
                        if (cursor_y < TEXT_ROWS - 1) cursor_y <= cursor_y + 1;
                        else cursor_y <= 0;  // Wrap to top
                    end
                end
            end

            last_received <= received;
        end
    end

endmodule
