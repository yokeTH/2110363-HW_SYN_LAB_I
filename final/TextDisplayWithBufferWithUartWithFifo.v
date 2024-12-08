`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/05/2024 03:54:27 PM
// Design Name: 
// Module Name: TextDisplayWithBufferWithUartWithFifo
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


module TextDisplayWithBufferWithUartWithFifo (
    input  wire       clk,       // System clock
    input  wire       btnU,      // Reset
    // Uart
    input  wire       RsRx,      // UART receive
    output wire       RsTx,      // UART transmit
    // Vga
    output wire       Hsync,     // VGA horizontal sync
    output wire       Vsync,     // VGA vertical sync
    output wire [3:0] vgaRed,    // VGA red channel
    output wire [3:0] vgaGreen,  // VGA green channel
    output wire [3:0] vgaBlue,   // VGA blue channel
    // PS/2 Keyboard
    input  wire       PS2Clk,
    input  wire       PS2Data,
    // Quad 7 Segments display for Debug KBD
    output wire [6:0] seg,       // 7-segment display output
    output wire       dp,        // Decimal point output
    output wire [3:0] an,        // Anode control for 7-segment display
    // Switch
    input  wire [7:0] sw,
    input  wire       btnC,
    // 2 device
    output wire       JB,
    input  wire       JC
);
    // UART signals
    wire [ 7:0] uart_data_out;
    wire        uart_receiving;
    wire        uart_received;
    wire        uart_sent;
    wire        uart_sending;

    // FIFO signals
    wire        fifo_full;
    wire        fifo_empty;
    wire [18:0] fifo_din;
    wire [18:0] fifo_dout;
    reg         fifo_wr_en;
    reg         fifo_rd_en;

    // Pack UART data and coordinates into FIFO data
    reg  [ 6:0] fifo_pos_data;
    assign fifo_din = {fifo_pos_data[6:0], current_x, current_y};

    // Text buffer control signals
    reg        write_enable;
    wire [6:0] write_data;
    wire [6:0] write_x;
    wire [4:0] write_y;
    wire       buffer_busy;

    // Extract data from FIFO output
    assign write_data = fifo_dout[18:12];
    assign write_x    = fifo_dout[11:5];
    assign write_y    = fifo_dout[4:0];

    // Text position management
    reg [6:0] current_x;
    reg [4:0] current_y;

    // State machine for write control
    reg [2:0] write_state;
    localparam IDLE = 3'b000;
    localparam WAIT_FIFO = 3'b001;
    localparam WRITING = 3'b010;
    localparam UPDATE_CURSOR = 3'b011;

    // Synchronization registers for UART received signal
    reg uart_received_1, uart_received_2;
    wire uart_received_pulse;

    // Double-register UART received signal for synchronization
    always @(posedge clk) begin
        uart_received_1 <= uart_received;
        uart_received_2 <= uart_received_1;
    end

    // Generate received pulse
    assign uart_received_pulse = uart_received_1 & ~uart_received_2;

    // UART instance
    Uart #(
        .CLOCK_FREQ   (100_000_000),  // 100MHz system clock
        .BAUD_RATE    (115200),       // Standard baud rate
        .SAMPLING_RATE(16)            // Standard sampling rate
    ) uart (
        .clk      (clk),
        .RsRx     (RsRx),
        .RsTx     (RsTx),
        .data_out (uart_data_out),
        .receiving(uart_receiving),
        .received (uart_received),
        .sent     (uart_sent),
        .sending  (uart_sending),
        .baud     ()                 // Unused
    );

    // FIFO instance
    fifo_generator_0 fifo (
        .clk  (clk),
        .rst  (btnU),
        .din  (fifo_din),
        .wr_en(fifo_wr_en),
        .rd_en(fifo_rd_en),
        .dout (fifo_dout),
        .full (fifo_full),
        .empty(fifo_empty)
    );


    // Text Display instance
    TextDisplayWithBuffer display (
        .clk         (clk),
        .reset       (btnU),
        .write_enable(write_enable),
        .write_x     (write_x),
        .write_y     (write_y),
        .write_data  (write_data),
        .busy        (buffer_busy),
        .Hsync       (Hsync),
        .Vsync       (Vsync),
        .vgaRed      (vgaRed),
        .vgaGreen    (vgaGreen),
        .vgaBlue     (vgaBlue)
    );

    wire [7:0] ascii_code;
    wire       key_valid;
    wire       is_pressed;

    // Synchronization registers for is_pressed signal
    reg is_pressed_1, is_pressed_2;
    wire is_pressed_pulse;

    // Double-register is_pressed signal for synchronization
    always @(posedge clk) begin
        is_pressed_1 <= is_pressed;
        is_pressed_2 <= is_pressed_1;
    end

    // Generate is_pressed pulse
    assign is_pressed_pulse = is_pressed_1 & ~is_pressed_2;

    ps2_keyboard keyboard_inst (
        .clk        (clk),
        .ps2_clk    (PS2Clk),
        .ps2_data   (PS2Data),
        .ascii_code (ascii_code),
        .ascii_valid(key_valid),
        .scancode   (),
        .is_pressed (is_pressed)
    );


    // Synchronization registers for btnC signal
    reg btnC_1, btnC_2;
    wire btnC_pulse;

    // Double-register btnC signal for synchronization
    always @(posedge clk) begin
        btnC_1 <= btnC;
        btnC_2 <= btnC_1;
    end

    // Generate btnC pulse
    assign btnC_pulse = btnC_1 & ~btnC_2;

    always @(posedge clk) begin
        if (btnU) begin
            // Reset cursor position and state
            current_x     <= 0;
            current_y     <= 0;
            write_enable  <= 0;
            write_state   <= IDLE;
            fifo_wr_en    <= 0;
            fifo_rd_en    <= 0;
            fifo_pos_data <= 0;
        end else begin
            // Default state
            write_enable <= 0;
            fifo_wr_en   <= 0;
            fifo_rd_en   <= 0;

            case (write_state)
                IDLE: begin
                    if (uart_received_pulse && !fifo_full) begin
                        case (uart_data_out)
                            8'h0D: begin  // Carriage return
                                current_x <= 0;
                                if (current_y < 29) current_y <= current_y + 1;
                            end
                            8'h0A: begin  // Line feed
                                if (current_y < 29) current_y <= current_y + 1;
                                else current_y <= 0;
                            end
                            default: begin  // Normal character
                                fifo_wr_en    <= 1;
                                fifo_pos_data <= uart_data_out[6:0];
                                write_state   <= WAIT_FIFO;
                            end
                        endcase
                    end else if (is_pressed_pulse && !fifo_full) begin
                        case (ascii_code)
                            8'h0D: begin  // Carriage return
                                current_x <= 0;
                                if (current_y < 29) current_y <= current_y + 1;
                            end
                            8'h0A: begin  // Line feed
                                if (current_y < 29) current_y <= current_y + 1;
                                else current_y <= 0;
                            end
                            default: begin  // Normal character
                                fifo_wr_en    <= 1;
                                fifo_pos_data <= ascii_code[6:0];
                                write_state   <= WAIT_FIFO;
                            end
                        endcase
                    end else if (btnC_pulse && !fifo_full) begin
                        case (sw[7:0])
                            8'h0D: begin  // Carriage return
                                current_x <= 0;
                                if (current_y < 29) current_y <= current_y + 1;
                            end
                            8'h0A: begin  // Line feed
                                if (current_y < 29) current_y <= current_y + 1;
                                else current_y <= 0;
                            end
                            default: begin  // Normal character
                                fifo_wr_en    <= 1;
                                fifo_pos_data <= sw[6:0];
                                write_state   <= WAIT_FIFO;
                            end
                        endcase
                    end else if (!fifo_empty && !buffer_busy) begin
                        fifo_rd_en  <= 1;
                        write_state <= WRITING;
                    end
                end

                WAIT_FIFO: begin
                    if (!buffer_busy) begin
                        if (current_x < 79) current_x <= current_x + 1;
                        else begin
                            current_x <= 0;
                            if (current_y < 29) current_y <= current_y + 1;
                            else current_y <= 0;
                        end
                        write_state <= IDLE;
                    end
                end

                WRITING: begin
                    write_enable <= 1;
                    write_state  <= UPDATE_CURSOR;
                end

                UPDATE_CURSOR: begin
                    write_state <= IDLE;
                end

                default: write_state <= IDLE;
            endcase
        end
    end


    //
    // Debug KBD input
    //
    localparam integer SevenSegmentDigitInputWidth = 4;

    // init Digit to invalid ascii value to make 7segment off
    reg [SevenSegmentDigitInputWidth - 1 : 0] num3, num2, num1, num0;
    initial begin
        num3 = 0;
        num2 = 0;
        num1 = 0;
        num0 = 0;
    end

    // Debug display:
    // num1,num0: Recently added data to output FIFO (data to be sent)
    // num3,num2: Recently added data to display FIFO (received data)
    always @(posedge clk) begin
        num0 <= 0;
        num1 <= 0;
        num2 <= 0;
        num3 <= 0;
    end

    // Decode Data
    wire [SevenSegmentDigitInputWidth-1:0] decoder_in;
    wire [                            6:0] decoder_out;

    NumTo7Seg decoder (
        .out(decoder_out),
        .in (decoder_in)
    );

    // quad 7segments display controller

    Quad7SegDisplay #(
        .INPUT_WIDTH(SevenSegmentDigitInputWidth)
    ) q7seg (
        .seg        (seg),
        .dp         (dp),
        .an         (an),
        .decoder_in (decoder_in),
        .decoder_out(decoder_out),
        .digit3     (num3),
        .digit2     (num2),
        .digit1     (num1),
        .digit0     (num0),
        .clk        (tClk[18])
    );

    // divide clock 100MHz (10^8) to ~200Hz
    wire [18:0] tClk;
    assign tClk[0] = clk;
    genvar i;
    generate
        for (i = 0; i < 18; i = i + 1) begin : gen_clock
            ClkDivider clockDiv (
                .out(tClk[i+1]),
                .in (tClk[i])
            );
        end
    endgenerate

endmodule
