`timescale 1ns / 1ps

module TextDisplayWithBufferWithUartWithFifo_tb_2;
    // Inputs
    reg         clk;
    reg         btnU;
    reg         btnD;
    reg         btnL;
    reg         btnC;
    reg         btnR;
    reg         RsRx;
    reg  [12:0] sw;

    // Outputs
    wire        RsTx;
    wire        Hsync;
    wire        Vsync;
    wire [ 3:0] vgaRed;
    wire [ 3:0] vgaGreen;
    wire [ 3:0] vgaBlue;

    // Test parameters
    parameter CLOCK_PERIOD = 10;  // 10ns (100MHz)
    parameter UART_PERIOD = 8680;  // ~8.68us for 115200 baud
    parameter CHAR_DELAY = 0;  // 500us between characters
    parameter TEST_DURATION = 100_000_000;  // 100ms simulation

    // File handle for VGA output log
    integer vga_log;

    wire    JB;

    // UUT instantiation
    TextDisplayWithBufferWithUartWithFifo_2 uut (
        .clk     (clk),
        .btnU    (btnU),
        .RsRx    (RsRx),      // UART RX line
        .RsTx    (RsTx),      // Unused
        .Hsync   (Hsync),
        .Vsync   (Vsync),
        .vgaRed  (vgaRed),
        .vgaGreen(vgaGreen),
        .vgaBlue (vgaBlue),
        .PS2Clk  (1'b1),      // Idle high
        .PS2Data (1'b1),      // Idle high
        .seg     (),          // Unused
        .dp      (),          // Unused
        .an      (),          // Unused
        .sw      (sw),
        .btnD    (btnD),
        .JB      (JB),
        .JC      (JB),        // Loop back JB to JC
        .btnL    (btnL),
        .btnC    (btnC),
        .btnR    (btnR)
    );

    // Clock generation
    always begin
        clk = 0;
        #(CLOCK_PERIOD / 2);
        clk = 1;
        #(CLOCK_PERIOD / 2);
    end

    // Task to press a button
    task press_button;
        input [2:0] button;
        begin
            case (button)
                3'b001: btnL = 1;
                3'b010: btnC = 1;
                3'b100: btnR = 1;
            endcase
            #20;
            case (button)
                3'b001: btnL = 0;
                3'b010: btnC = 0;
                3'b100: btnR = 0;
            endcase
            #10000;
        end
    endtask

    task press_send_btn;
        begin
            btnD = 1;
            #10 btnD = 0;
            #10000;
        end
    endtask

    task reset_color;
        begin
            // Reset color by setting 4 MLB to 0000 and pressing all color buttons
            sw <= 13'b0000101000001;  // Base configuration with color reset

            // Press all color buttons to reset
            #10;
            press_button(3'b001);  // Red (Left button)
            #10;
            press_button(3'b010);  // Green (Center button)
            #10;  // Blue (Right button)
            press_button(3'b100);
            // Send the reset configuration
            press_send_btn();
            #10000;
        end
    endtask

    // Task to send ASCII character via switch
    task send_ascii_via_sw;
        input [7:0] ascii;
        begin
            sw[7:0] = ascii;  // Set ASCII character
            press_send_btn();  // Send the configuration
            #(CHAR_DELAY);  // Apply character delay
        end
    endtask

    // Color and ASCII test sequence
    initial begin
        // Initialize signals
        btnR <= 0;
        btnC <= 0;
        btnL <= 0;
        btnU = 1;
        RsRx = 1;  // UART idle state is high
        btnD <= 0;
        sw   <= 13'b0000101000001;  // Base switch configuration


        // Reset
        #1000 btnU = 0;
        #10000;
        press_button(3'b001);
        press_button(3'b010);
        press_button(3'b100);
        // Test all displayable ASCII characters
        for (integer ascii = 32; ascii < 127; ascii = ascii + 1) begin
            // Set base configuration
            sw[12:9] = 4'b0000;  // Default color
            sw[8]    = 1;  // Default language

            // Send ASCII character via switch
            send_ascii_via_sw(ascii);

            // Send the configuration
            #1000000;
        end

        // Final reset
        reset_color();

        // Wait for display to stabilize
        #TEST_DURATION;

        $finish;
    end

    // VGA log file initialization
    initial begin
        vga_log = $fopen("vga_output.txt", "w");
        if (vga_log == 0) begin
            $display("Error: Could not open vga_output.txt");
            $finish;
        end
    end

    // VGA signal logging
    always @(posedge clk) begin
        if (uut.display.sync_unit.p_tick) begin  // Only log when pixel clock is active
            $fwrite(vga_log, "%0d ns: %b %b %04b %04b %04b\n", $time,  // Current simulation time
                    Hsync,  // H-sync
                    Vsync,  // V-sync
                    vgaRed,  // Red (4 bits)
                    vgaGreen,  // Green (4 bits)
                    vgaBlue  // Blue (4 bits)
            );
        end
    end

endmodule
