`timescale 1ns / 1ps

module TextDisplayWithBufferWithUartWithFifo_tb_2;
    // Inputs
    reg        clk;
    reg        btnU;
    reg        RsRx;
    reg  [7:0] sw;
    reg        btnC;

    // Outputs
    wire       RsTx;
    wire       Hsync;
    wire       Vsync;
    wire [3:0] vgaRed;
    wire [3:0] vgaGreen;
    wire [3:0] vgaBlue;


    // Test parameters
    parameter CLOCK_PERIOD = 10;  // 10ns (100MHz)
    parameter UART_PERIOD = 8680;  // ~8.68us for 115200 baud
    parameter CHAR_DELAY = 0;  // 500us between characters
    parameter TEST_DURATION = 100_000_000;  // 100ms simulation

    // File handle for VGA output log
    integer       vga_log;

    // Test message - hello world with newline
    reg     [7:0] test_msg[0:13];
    initial begin
        test_msg[0]  = "H";
        test_msg[1]  = "e";
        test_msg[2]  = "l";
        test_msg[3]  = "l";
        test_msg[4]  = "o";
        test_msg[5]  = " ";
        test_msg[6]  = "W";
        test_msg[7]  = "o";
        test_msg[8]  = "r";
        test_msg[9]  = "l";
        test_msg[10] = "d";
        test_msg[11] = "!";
        test_msg[12] = 8'h0D;  // CR
        test_msg[13] = 8'h0A;  // LF
    end

    wire JB;

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
        .btnC    (btnC),
        .JB      (JB),
        .JC      (JB)         // Loop back JB to JC
    );

    // Clock generation
    always begin
        clk = 0;
        #(CLOCK_PERIOD / 2);
        clk = 1;
        #(CLOCK_PERIOD / 2);
    end

    // UART transmission task
    task send_uart_byte;
        input [7:0] data;
        integer i;
        begin
            // Start bit
            RsRx = 0;
            #UART_PERIOD;

            // Data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                RsRx = data[i];
                #UART_PERIOD;
            end

            // Stop bit
            RsRx = 1;
            #UART_PERIOD;

            // Extra delay after stop bit
            #UART_PERIOD;
        end
    endtask

    // Test stimulus
    // initial begin
        // Initialize log file


    //     // Initialize signals
    //     btnU = 1;
    //     RsRx = 1;  // UART idle state is high
    //     btnC <= 0;

    //     // Reset pulse
    //     #1000 btnU = 0;
    //     #1000;

    //     // Send test message via UART twice to test wrapping
    //     // repeat (1) begin
    //     //     for (integer i = 0; i < 1; i = i + 1) begin
    //     //         send_uart_byte(test_msg[i]);
    //     //         #CHAR_DELAY;
    //     //     end
    //     //     #(CHAR_DELAY * 2);
    //     // end
    //     sw   <= 8'b01000001;
    //     #10 btnC <= 1;
    //     btnC <= 0;
    //     // Wait for display to stabilize
    //     #TEST_DURATION;

    //     // Close log and end simulation
    //     $fclose(vga_log);
    //     $finish;
    // end

    initial begin
        // Initialize signals
        btnU = 1;
        RsRx = 1;  // UART idle state is high
        btnC <= 0;
        sw   <= 8'b01000001;  // Set a specific switch configuration

        // Reset pulse
        #1000 btnU = 0;
        #1000000;

        // Trigger switch reading
        #10 btnC <= 1;
        #10 btnC <= 0;

        #100000;

        #10 btnC <= 1;
        #10 btnC <= 0;

        #100000;

        sw   <= 8'b01000010;  // Set a specific switch configuration

        #10000000;

        #10 btnC <= 1;
        #10 btnC <= 0;

        // Wait for display to stabilize
        #TEST_DURATION;

        $finish;
    end


    initial begin
        vga_log = $fopen("vga_output.txt", "w");
        if (vga_log == 0) begin
            $display("Error: Could not open vga_output.txt");
            $finish;
        end
    end


    // VGA signal logging
    // Format: "time ns: hs vs red green blue"
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