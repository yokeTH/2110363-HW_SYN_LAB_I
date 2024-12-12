module TextDisplayWithBuffer (
    input  wire        clk,               // System clock
    input  wire        reset,             // Reset
    // Text buffer write interface
    input  wire        write_enable,
    input  wire [ 6:0] write_x,
    input  wire [ 4:0] write_y,
    input  wire [ 6:0] write_data,
    input  wire [11:0] write_text_color,
    input  wire        write_lang,
    output wire        busy,              // Add busy signal output
    // VGA outputs
    output wire        Hsync,
    output wire        Vsync,
    output wire [ 3:0] vgaRed,
    output wire [ 3:0] vgaGreen,
    output wire [ 3:0] vgaBlue
);

    // Internal signals
    wire [9:0] pixel_x, pixel_y;
    wire video_on, pixel_tick;
    reg  [11:0] rgb_reg;

    // Text buffer signals
    wire [ 6:0] char_at_pos;
    wire [ 6:0] read_x;
    wire [ 4:0] read_y;
    wire        text_bit_on;
    wire [11:0] read_color;
    wire        read_lang;

    // VGA sync generation
    VGA_sync sync_unit (
        .clk     (clk),
        .reset   (reset),
        .hsync   (Hsync),
        .vsync   (Vsync),
        .video_on(video_on),
        .p_tick  (pixel_tick),
        .x       (pixel_x),
        .y       (pixel_y)
    );

    // Text buffer instance with write capability
    TextBuffer #(
        .COLS(60),
        .ROWS(20)
    ) text_buffer (
        .clk         (clk),
        .reset       (reset),
        // Write interface
        .write_enable(write_enable),
        .write_x     (write_x),
        .write_y     (write_y),
        .write_data  (write_data),
        .write_color (write_text_color),
        .write_lang  (write_lang),
        .busy        (busy),              // Connect busy signal
        // Read interface
        .read_x      (read_x),
        .read_y      (read_y),
        .char_out    (char_at_pos),
        .read_color  (read_color),
        .read_lang   (read_lang)
    );

    // Text display controller
    TextDisplayController #(
        .COLS       (60),
        .ROWS       (20),
        .OFFSET_TOP ((480 - (20 * 16)) / 2),  // Center vertically
        .OFFSET_LEFT((640 - (60 * 8)) / 2)    // Center horizontally
    ) display_ctrl (
        .clk        (clk),
        .reset      (btnU),
        .pixel_x    (pixel_x),
        .pixel_y    (pixel_y),
        .video_on   (video_on),
        .lang       (read_lang),
        .char_at_pos(char_at_pos),
        .text_bit_on(text_bit_on),
        .read_x     (read_x),
        .read_y     (read_y)
    );

    // Color definitions
    wire [11:0] bg_color = 12'hCCC;  // Dark blue background

    // RGB output logic
    always @(posedge clk) begin
        if (pixel_tick) begin
            if (!video_on) begin
                rgb_reg <= 12'h000;  // Black during blanking
            end else if (text_bit_on) begin
                rgb_reg <= read_color;  // Text color
            end else if ((pixel_x - 85)**2 + (pixel_y - 55)**2 < 25) begin
                rgb_reg <= 12'hF00;
            end else if ((pixel_x - 102)**2 + (pixel_y - 55)**2 < 25) begin
                rgb_reg <= 12'hFD0;
            end else if ((pixel_x - 117)**2 + (pixel_y - 55)**2 < 25) begin
                rgb_reg <= 12'h2D1;
            end else if ((pixel_x > 70 && pixel_x < 570 && pixel_y > 70 && pixel_y < 410)) begin
                rgb_reg <= 12'hFFF;
            end else if ((pixel_x > 68 && pixel_x < 572 && pixel_y > 40 && pixel_y < 412)) begin
                rgb_reg <= 12'h000;
            end else if ((pixel_x > 75 && pixel_x < 579 && pixel_y > 47 && pixel_y < 419)) begin
                rgb_reg <= 12'h666;
            end else begin
                rgb_reg <= bg_color;  // Background color
            end

        end
    end

    // Output assignments
    assign vgaRed   = rgb_reg[11:8];
    assign vgaGreen = rgb_reg[7:4];
    assign vgaBlue  = rgb_reg[3:0];

endmodule
