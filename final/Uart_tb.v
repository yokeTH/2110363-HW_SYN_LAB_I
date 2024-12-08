`timescale 1ns / 1ps

module Uart_tb ();
    // Parameters
    localparam CLOCK_FREQ = 100_000_000;
    localparam BAUD_RATE = 9600;
    localparam SAMPLING_RATE = 16;
    localparam CLK_PERIOD = 10;  // 100MHz clock

    // Test signals
    reg         clk = 0;
    reg         rst_n = 0;  // Added reset
    reg         RsRx = 1;  // Initialize to idle state
    wire        RsTx;
    wire [ 7:0] data_out;
    wire        receiving;
    wire        received;
    wire        sent;
    wire        sending;

    // Test status
    reg  [31:0] test_count = 0;
    reg  [31:0] errors = 0;

    // Instantiate UART
    Uart #(
        .CLOCK_FREQ   (CLOCK_FREQ),
        .BAUD_RATE    (BAUD_RATE),
        .SAMPLING_RATE(SAMPLING_RATE)
    ) uart_inst (
        .clk      (clk),
        .RsRx     (RsRx),
        .RsTx     (RsTx),
        .data_out (data_out),
        .receiving(receiving),
        .received (received),
        .sent     (sent),
        .sending  (sending)
    );

    // Clock generation
    always #(CLK_PERIOD / 2) clk = ~clk;

    // Calculate exact bit period
    localparam real ACTUAL_BAUD_PERIOD = 1.0 * CLOCK_FREQ / BAUD_RATE;
    localparam BIT_PERIOD = 1_000_000_000 / BAUD_RATE;  // in ns

    // Task to send a byte through RsRx
    task send_byte;
        input [7:0] byte_to_send;
        integer i;
        begin
            test_count = test_count + 1;

            // Start bit (low)
            @(posedge clk);
            RsRx = 0;
            #(BIT_PERIOD);

            // Data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                RsRx = byte_to_send[i];
                #(BIT_PERIOD);
            end

            // Stop bit (high)
            RsRx = 1;
            #(BIT_PERIOD);

            // Extra idle time
            #(BIT_PERIOD / 2);
        end
    endtask

    // Task to verify received data
    task verify_data;
        input [7:0] expected_data;
        begin
            @(posedge received);
            if (data_out !== expected_data) begin
                $display("Error: Expected %h, Got %h at time %t", expected_data, data_out, $time);
                errors = errors + 1;
            end else begin
                $display("Success: Correctly received %h at time %t", data_out, $time);
            end
        end
    endtask

    // Monitor RsTx output
    reg [7:0] received_byte;
    task monitor_tx;
        integer i;
        begin
            // Wait for start bit
            @(negedge RsTx);
            #(BIT_PERIOD / 2);  // Move to middle of start bit

            if (RsTx !== 0) begin
                $display("Error: Invalid start bit at time %t", $time);
                errors = errors + 1;
            end
            #(BIT_PERIOD);

            // Sample data bits
            for (i = 0; i < 8; i = i + 1) begin
                received_byte[i] = RsTx;
                #(BIT_PERIOD);
            end

            // Verify stop bit
            if (RsTx !== 1) begin
                $display("Error: Invalid stop bit at time %t", $time);
                errors = errors + 1;
            end
        end
    endtask

    // Test stimulus
    initial begin
        // Initialize and reset
        rst_n = 0;
        RsRx  = 1;
        #(CLK_PERIOD * 10);
        rst_n = 1;
        #(CLK_PERIOD * 10);

        // Test Case 1: Single byte transmission
        $display("\nTest Case 1: Sending single byte 0xA5");
        fork
            send_byte(8'hA5);
            verify_data(8'hA5);
        join

        // Test Case 2: Multiple bytes with minimum gap
        $display("\nTest Case 2: Sending multiple bytes");
        fork
            begin
                send_byte(8'h55);
                send_byte(8'hAA);
            end
            begin
                verify_data(8'h55);
                verify_data(8'hAA);
            end
        join

        // Test Case 3: Loopback verification
        $display("\nTest Case 3: Testing loopback");
        fork
            send_byte(8'h33);
            begin
                @(posedge sending);
                monitor_tx();
            end
        join

        // Report results
        #(BIT_PERIOD * 2);
        $display("\nTest Summary:");
        $display("Total Tests: %0d", test_count);
        $display("Total Errors: %0d", errors);
        $display("Test %s", (errors == 0) ? "PASSED" : "FAILED");
        $finish;
    end

    // Timeout watchdog
    initial begin
        #(BIT_PERIOD * 5000);
        $display("Error: Test timeout");
        $finish;
    end

    // Generate VCD file
    initial begin
        $dumpfile("uart_tb.vcd");
        $dumpvars(0, Uart_tb);
    end

endmodule
