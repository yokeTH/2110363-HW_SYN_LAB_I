module TextDisplayWithBuffer (
    input  wire       clk,           // System clock
    input  wire       reset,         // Reset
    // Text buffer write interface
    input  wire       write_enable,
    input  wire [6:0] write_x,
    input  wire [4:0] write_y,
    input  wire [6:0] write_data,
    output wire       busy,          // Add busy signal output
    // VGA outputs
    output wire       Hsync,
    output wire       Vsync,
    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue
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
        .COLS(80),
        .ROWS(30)
    ) text_buffer (
        .clk         (clk),
        .reset       (reset),
        // Write interface
        .write_enable(write_enable),
        .write_x     (write_x),
        .write_y     (write_y),
        .write_data  (write_data),
        .busy        (busy),          // Connect busy signal
        // Read interface
        .read_x      (read_x),
        .read_y      (read_y),
        .char_out    (char_at_pos)
    );

    // Text display controller
    TextDisplayController #(
        .COLS(80),
        .ROWS(30)
    ) display_ctrl (
        .clk        (clk),
        .reset      (btnU),
        .pixel_x    (pixel_x),
        .pixel_y    (pixel_y),
        .video_on   (video_on),
        .char_at_pos(char_at_pos),
        .text_bit_on(text_bit_on),
        .read_x     (read_x),
        .read_y     (read_y)
    );

    // Color definitions
    wire [11:0] bg_color = 12'h001;  // Dark blue background
    wire [11:0] text_color = 12'hFFF;  // White text

    // RGB output logic
    always @(posedge clk) begin
        if (pixel_tick) begin
            if (!video_on) rgb_reg <= 12'h000;  // Black during blanking
            else if (text_bit_on) rgb_reg <= text_color;  // Text color
            else rgb_reg <= bg_color;  // Background color
        end
    end

    // Output assignments
    assign vgaRed   = rgb_reg[11:8];
    assign vgaGreen = rgb_reg[7:4];
    assign vgaBlue  = rgb_reg[3:0];

endmodule
