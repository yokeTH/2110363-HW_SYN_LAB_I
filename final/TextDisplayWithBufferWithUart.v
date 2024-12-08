module TextDisplayWithBufferWithUart (
    input  wire       clk,       // System clock
    input  wire       btnU,      // Reset
    input  wire       RsRx,      // UART receive
    output wire       RsTx,      // UART transmit
    output wire       Hsync,     // VGA horizontal sync
    output wire       Vsync,     // VGA vertical sync
    output wire [3:0] vgaRed,    // VGA red channel
    output wire [3:0] vgaGreen,  // VGA green channel
    output wire [3:0] vgaBlue    // VGA blue channel
);

    // UART signals
    wire [7:0] uart_data_out;
    wire       uart_receiving;
    wire       uart_received;
    wire       uart_sent;
    wire       uart_sending;

    // Text buffer control signals
    reg        write_enable;
    reg  [6:0] write_x;
    reg  [4:0] write_y;
    wire       buffer_busy;

    // Text position management
    reg  [6:0] current_x;
    reg  [4:0] current_y;

    // State machine for write control
    reg  [2:0] write_state;
    localparam IDLE = 3'b000;
    localparam WAIT_RECEIVE = 3'b001;
    localparam WAIT_BUSY = 3'b010;
    localparam WRITING = 3'b011;
    localparam UPDATE_CURSOR = 3'b100;

    // Synchronization registers for UART received signal
    reg uart_received_1, uart_received_2;
    reg  [7:0] uart_data_reg;
    wire       uart_received_pulse;

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
        .RsRx     (Rs),
        .RsTx     (RsTx),
        .data_out (uart_data_out),
        .receiving(uart_receiving),
        .received (uart_received),
        .sent     (uart_sent),
        .sending  (uart_sending),
        .baud     ()                 // Unused
    );

    // Text Display instance
    TextDisplayWithBuffer display (
        .clk         (clk),
        .reset       (btnU),
        .write_enable(write_enable),
        .write_x     (write_x),
        .write_y     (write_y),
        .write_data  (uart_data_reg[6:0]),  // Use registered data
        .busy        (buffer_busy),
        .Hsync       (Hsync),
        .Vsync       (Vsync),
        .vgaRed      (vgaRed),
        .vgaGreen    (vgaGreen),
        .vgaBlue     (vgaBlue)
    );

    // Text cursor management and special character handling
    always @(posedge clk) begin
        if (btnU) begin
            // Reset cursor position and state
            current_x     <= 0;
            current_y     <= 0;
            write_enable  <= 0;
            write_state   <= IDLE;
            uart_data_reg <= 0;
        end else begin
            // Default state
            write_enable <= 0;

            case (write_state)
                IDLE: begin
                    if (uart_received_pulse) begin
                        uart_data_reg <= uart_data_out;
                        write_state   <= WAIT_BUSY;
                    end
                end

                WAIT_BUSY: begin
                    if (!buffer_busy) begin
                        case (uart_data_reg)
                            8'h0D: begin  // Carriage return
                                current_x   <= 0;
                                write_state <= IDLE;
                            end
                            8'h0A: begin  // Line feed
                                if (current_y < 29) current_y <= current_y + 1;
                                else current_y <= 0;
                                write_state <= IDLE;
                            end
                            default: begin  // Normal character
                                write_enable <= 1;
                                write_x      <= current_x;
                                write_y      <= current_y;
                                write_state  <= WRITING;
                            end
                        endcase
                    end
                end

                WRITING: begin
                    write_enable <= 0;
                    write_state  <= UPDATE_CURSOR;
                end

                UPDATE_CURSOR: begin
                    if (current_x < 79) begin
                        current_x <= current_x + 1;
                    end else begin
                        current_x <= 0;
                        if (current_y < 29) current_y <= current_y + 1;
                        else current_y <= 0;
                    end
                    write_state <= IDLE;
                end

                default: write_state <= IDLE;
            endcase
        end
    end

endmodule
