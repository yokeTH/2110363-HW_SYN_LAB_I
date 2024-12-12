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


module TextDisplayWithBufferWithUartWithFifo_2 (
    input  wire        clk,
    input  wire        btnU,      // Reset
    // Uart
    input  wire        RsRx,      // UART receive
    output wire        RsTx,      // UART transmit
    // Vga
    output wire        Hsync,     // VGA horizontal sync
    output wire        Vsync,     // VGA vertical sync
    output wire [ 3:0] vgaRed,    // VGA red channel
    output wire [ 3:0] vgaGreen,  // VGA green channel
    output wire [ 3:0] vgaBlue,   // VGA blue channel
    // PS/2 Keyboard
    input  wire        PS2Clk,
    input  wire        PS2Data,
    // Quad 7 Segments display for Debug KBD
    output wire [ 6:0] seg,       // 7-segment display output
    output wire        dp,        // Decimal point output
    output wire [ 3:0] an,        // Anode control for 7-segment display
    // Switch
    input  wire [12:0] sw,
    input  wire        btnD,
    // 2 device communication
    output wire        JB,        // TX to other device
    input  wire        JC,        // RX from other device
    // Set Text Color
    input  wire        btnL,      // SET RED
    input  wire        btnR,      // SET GREEN
    input  wire        btnC       // SET BLUE
);

    // ==============================
    // Signal
    // ==============================

    wire       lang = sw[8];  // 0 Eng | 1 Thai

    reg  [3:0] text_red = 4'hF;
    reg  [3:0] text_green = 4'hF;
    reg  [3:0] text_blue = 4'hF;

    // ==============================
    // UART signals and instances
    // ==============================
    wire [7:0] uart_data_out;
    wire       uart_receiving;
    wire       uart_received;
    wire       uart_sent;
    wire       uart_sending;

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

    wire baud;
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
        .baud     (baud)             // Unused
    );

    // ==============================
    // Text buffer signals
    // ==============================
    reg         write_enable;
    wire [ 6:0] write_data;
    wire [ 6:0] write_x;
    wire [ 4:0] write_y;
    wire        buffer_busy;

    reg  [ 6:0] current_x;
    reg  [ 4:0] current_y;

    // ==============================
    // FIFO For Display (Input Queue)
    // ==============================
    wire        fifo_display_full;
    wire        fifo_display_empty;
    wire [31:0] fifo_display_din;
    wire [31:0] fifo_display_dout;
    wire [ 3:0] write_text_read;
    wire [ 3:0] write_text_green;
    wire [ 3:0] write_text_blue;
    wire        write_lang;
    reg         fifo_display_wr_en;
    reg         fifo_display_rd_en;

    // Pack data and coordinates into display FIFO data
    reg  [ 6:0] fifo_pos_data;
    assign fifo_display_din = {
        text_red, text_green, text_blue, lang, fifo_pos_data[6:0], current_x, current_y
    };

    // Extract data from display FIFO output
    assign write_text_read = fifo_display_dout[31:28];
    assign write_text_green = fifo_display_dout[27:24];
    assign write_text_blue = fifo_display_dout[23:20];
    assign write_lang = fifo_display_dout[19];
    assign write_data = fifo_display_dout[18:12];
    assign write_x = fifo_display_dout[11:5];
    assign write_y = fifo_display_dout[4:0];

    // FIFO instance for display
    fifo_generator_0 fifo_display (
        .clk  (clk),
        .rst  (btnU),
        .din  (fifo_display_din),
        .wr_en(fifo_display_wr_en),
        .rd_en(fifo_display_rd_en),
        .dout (fifo_display_dout),
        .full (fifo_display_full),
        .empty(fifo_display_empty)
    );

    // ==============================
    // FIFO For Output Queue
    // ==============================
    wire        fifo_output_full;
    wire        fifo_output_empty;
    wire [31:0] fifo_output_din;  // {red4, green4, blue4, lang1, data7, x7, y5}
    wire [31:0] fifo_output_dout;
    reg         fifo_output_wr_en;
    reg         fifo_output_rd_en;

    // Pack tx_data into the 19-bit FIFO data format
    // We'll use only the upper 8 bits and pad the rest with zeros
    assign fifo_output_din = {
        13'b0, tx_data[6:0], 12'b0
    };  // Pack 8-bit data into MSB, pad with zeros

    // Extract only the upper 8 bits from FIFO output for transmission
    wire [7:0] fifo_output_data = {0, fifo_output_dout[18:12]};  // Extract character data from MSB

    // FIFO instance for output queue
    fifo_generator_0 fifo_output (
        .clk  (clk),
        .rst  (btnU),
        .din  (fifo_output_din),
        .wr_en(fifo_output_wr_en),
        .rd_en(fifo_output_rd_en),
        .dout (fifo_output_dout),
        .full (fifo_output_full),
        .empty(fifo_output_empty)
    );

    // ==============================
    // PS/2 Keyboard Instance
    // ==============================
    wire [7:0] ascii_code;
    wire       key_valid;
    wire       is_pressed;

    // Synchronization registers for is_pressed signal
    reg key_valid_1, key_valid_2;
    wire key_valid_pulse;

    // Double-register is_pressed signal for synchronization
    always @(posedge clk) begin
        key_valid_1 <= key_valid;
        key_valid_2 <= key_valid_1;
    end

    // Generate is_pressed pulse
    assign key_valid_pulse = key_valid_1 & ~key_valid_2;

    ps2_keyboard keyboard_inst (
        .clk        (clk),
        .ps2_clk    (PS2Clk),
        .ps2_data   (PS2Data),
        .ascii_code (ascii_code),
        .ascii_valid(key_valid)
    );

    // ==============================
    // Button D synchronization
    // ==============================
    reg btnD_1, btnD_2;
    wire btnD_pulse;

    always @(posedge clk) begin
        btnD_1 <= btnD;
        btnD_2 <= btnD_1;
    end

    assign btnD_pulse = btnD_1 & ~btnD_2;

    // ==============================
    // Cross-device Communication
    // ==============================
    reg        tx_ena;
    reg  [7:0] tx_data;
    wire       tx_sent;
    wire       tx_sending;

    // Transmitter instance
    TxWrapper #(
        .SAMPLING_RATE(16)
    ) tx_pmod (
        .baud         (baud),
        .clk          (clk),
        .data_transmit(fifo_output_data),
        .ena          (tx_ena),
        .sent         (tx_sent),
        .sending      (tx_sending),
        .bit_out      (JB)
    );

    // Receiver instance
    wire       pmod_received;
    wire [7:0] pmod_data_out;
    wire       pmod_receiving;
    wire       pmod_received_pulse;

    // Synchronization registers for UART received signal
    reg        pmod_received_1 = 0;
    reg        pmod_received_2 = 0;

    // Double-register UART received signal for synchronization
    always @(posedge clk) begin
        pmod_received_1 <= pmod_received;
        pmod_received_2 <= pmod_received_1;
    end

    // Generate received pulse
    assign pmod_received_pulse = pmod_received_1 & ~pmod_received_2;

    Rx #(
        .SAMPLING_RATE(16)
    ) rx_pmod (
        .clk      (baud),
        .bit_in   (JC),
        .received (pmod_received),
        .data_out (pmod_data_out),
        .receiving(pmod_receiving)
    );

    // ==============================
    // Text Display Instance
    // ==============================
    TextDisplayWithBuffer display (
        .clk             (clk),
        .reset           (btnU),
        .write_enable    (write_enable),
        .write_x         (write_x),
        .write_y         (write_y),
        .write_data      (write_data),
        .write_text_color({write_text_read, write_text_green, write_text_blue}),
        .write_lang      (write_lang),
        .busy            (buffer_busy),
        .Hsync           (Hsync),
        .Vsync           (Vsync),
        .vgaRed          (vgaRed),
        .vgaGreen        (vgaGreen),
        .vgaBlue         (vgaBlue)
    );

    // ==============================
    // Text Options State
    // ==============================

    // Button L synchronization
    reg btnL_1, btnL_2;
    wire btnL_pulse;

    always @(posedge clk) begin
        btnL_1 <= btnL;
        btnL_2 <= btnL_1;
    end

    assign btnL_pulse = btnL_1 & ~btnL_2;

    // Button C synchronization
    reg btnC_1, btnC_2;
    wire btnC_pulse;

    always @(posedge clk) begin
        btnC_1 <= btnC;
        btnC_2 <= btnC_1;
    end

    assign btnC_pulse = btnC_1 & ~btnC_2;

    // Button R synchronization
    reg btnR_1, btnR_2;
    wire btnR_pulse;

    always @(posedge clk) begin
        btnR_1 <= btnR;
        btnR_2 <= btnR_1;
    end

    assign btnR_pulse = btnR_1 & ~btnR_2;


    always @(posedge clk) begin
        if (btnU) begin
            text_red   <= 4'hF;
            text_green <= 4'hF;
            text_blue  <= 4'hF;
        end else begin
            if (btnL_pulse) begin
                text_red <= sw[12:9];
            end else if (btnC_pulse) begin
                text_green <= sw[12:9];
            end else if (btnR_pulse) begin
                text_blue <= sw[12:9];
            end
        end
    end

    // ==============================
    // State Machines
    // ==============================

    // Output state machine
    reg [2:0] output_state;
    localparam OUTPUT_IDLE = 3'b000;
    localparam OUTPUT_PREPARE = 3'b001;
    localparam OUTPUT_SENDING = 3'b010;
    localparam OUTPUT_WAIT = 3'b011;

    always @(posedge clk) begin
        if (btnU) begin
            output_state      <= OUTPUT_IDLE;
            tx_ena            <= 0;
            tx_data           <= 0;
            fifo_output_wr_en <= 0;
            fifo_output_rd_en <= 0;
        end else begin
            case (output_state)
                OUTPUT_IDLE: begin
                    tx_ena            <= 0;
                    fifo_output_wr_en <= 0;
                    fifo_output_rd_en <= 0;

                    if (key_valid_pulse && key_valid && !fifo_output_full) begin
                        tx_data           <= ascii_code;
                        fifo_output_wr_en <= 1;
                        output_state      <= OUTPUT_PREPARE;
                    end else if (btnD_pulse && !fifo_output_full) begin
                        tx_data           <= sw[7:0];
                        fifo_output_wr_en <= 1;
                        output_state      <= OUTPUT_PREPARE;
                    end else if (uart_received_pulse && !fifo_output_full) begin
                        tx_data           <= uart_data_out;
                        fifo_output_wr_en <= 1;
                        output_state      <= OUTPUT_PREPARE;
                    end
                end

                OUTPUT_PREPARE: begin
                    fifo_output_wr_en <= 0;
                    if (!fifo_output_empty && !tx_sending) begin
                        fifo_output_rd_en <= 1;
                        output_state      <= OUTPUT_SENDING;
                    end
                end

                OUTPUT_SENDING: begin
                    fifo_output_rd_en <= 0;
                    if (baud) begin
                        tx_ena       <= 1;
                        output_state <= OUTPUT_WAIT;
                    end
                end

                OUTPUT_WAIT: begin
                    tx_ena <= 0;
                    if (tx_sent) begin
                        output_state <= OUTPUT_IDLE;
                    end
                end

                default: output_state <= OUTPUT_IDLE;
            endcase
        end
    end

    // Input state machine
    reg [2:0] input_state;
    localparam INPUT_IDLE = 3'b000;
    localparam INPUT_CHECK_DATA = 3'b001;
    localparam INPUT_WRITE_BUFFER = 3'b010;
    localparam INPUT_UPDATE = 3'b011;

    always @(posedge clk) begin
        if (btnU) begin
            input_state        <= INPUT_IDLE;
            fifo_display_wr_en <= 0;
            fifo_pos_data      <= 0;
            current_x          <= 0;
            current_y          <= 0;
        end else begin
            case (input_state)
                INPUT_IDLE: begin
                    fifo_display_wr_en <= 0;
                    if (pmod_received_pulse) begin
                        fifo_pos_data <= pmod_data_out[6:0];
                        input_state   <= INPUT_CHECK_DATA;
                    end
                end

                INPUT_CHECK_DATA: begin
                    case (pmod_data_out)
                        8'h0D: begin  // Carriage return
                            current_x <= 0;
                            if (current_y < 19) current_y <= current_y + 1;
                            input_state <= INPUT_IDLE;
                        end
                        8'h0A: begin  // Line feed
                            if (current_y < 19) current_y <= current_y + 1;
                            else current_y <= 0;
                            input_state <= INPUT_IDLE;
                        end
                        default: begin  // Normal character
                            if (!fifo_display_full) begin
                                fifo_display_wr_en <= 1;
                                input_state        <= INPUT_WRITE_BUFFER;
                            end
                        end
                    endcase
                end

                INPUT_WRITE_BUFFER: begin
                    fifo_display_wr_en <= 0;
                    input_state        <= INPUT_UPDATE;
                end

                INPUT_UPDATE: begin
                    if (current_x < 59) current_x <= current_x + 1;
                    else begin
                        current_x <= 0;
                        if (current_y < 59) current_y <= current_y + 1;
                        else current_y <= 0;
                    end
                    input_state <= INPUT_IDLE;
                end

                default: input_state <= INPUT_IDLE;
            endcase
        end
    end

    // Display state machine
    reg [2:0] display_state;
    localparam DISPLAY_IDLE = 3'b000;
    localparam DISPLAY_WRITING = 3'b001;
    localparam DISPLAY_UPDATE = 3'b010;

    always @(posedge clk) begin
        if (btnU) begin
            display_state      <= DISPLAY_IDLE;
            write_enable       <= 0;
            fifo_display_rd_en <= 0;
        end else begin
            case (display_state)
                DISPLAY_IDLE: begin
                    write_enable       <= 0;
                    fifo_display_rd_en <= 0;
                    if (!fifo_display_empty && !buffer_busy) begin
                        fifo_display_rd_en <= 1;
                        display_state      <= DISPLAY_WRITING;
                    end
                end

                DISPLAY_WRITING: begin
                    fifo_display_rd_en <= 0;
                    write_enable       <= 1;
                    display_state      <= DISPLAY_UPDATE;
                end

                DISPLAY_UPDATE: begin
                    write_enable  <= 0;
                    display_state <= DISPLAY_IDLE;
                end

                default: display_state <= DISPLAY_IDLE;
            endcase
        end
    end

    // ==============================
    // Seven Segment Debug Display
    // ==============================
    localparam integer SevenSegmentDigitInputWidth = 4;

    reg [SevenSegmentDigitInputWidth - 1:0] num3, num2, num1, num0;
    initial begin
        num3 = 0;
        num2 = 0;
        num1 = 0;
        num0 = 0;
    end

    always @(posedge clk) begin
        num3 <= {3'b000, tx_sending};  // Upper 4 bits of received data
        num2 <= {0, display_state};  // Lower 4 bits of received data
        num1 <= {0, input_state};  // Upper 4 bits of sent data
        num0 <= {0, output_state};  // Lower 4 bits of sent data
        // num0 <= tx_data[3:0];  // Lower 4 bits of sent data
        // num1 <= tx_data[7:4];  // Upper 4 bits of sent data
        // num2 <= fifo_pos_data[3:0];  // Lower 4 bits of received data
        // num3 <= {0, fifo_pos_data[6:4]};  // Upper 4 bits of received data
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

    // ==============================
    // Clock Divider for Debug Display
    // ==============================
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
