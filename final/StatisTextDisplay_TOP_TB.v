module StatisTextDisplay_TOP_TB;
    // Test bench signals
    reg           clk;
    reg           btnU;
    reg           RsRx;
    wire          RsTx;
    wire          Hsync;
    wire          Vsync;
    wire    [3:0] vgaRed;
    wire    [3:0] vgaGreen;
    wire    [3:0] vgaBlue;

    // File handle for VGA simulation output
    integer       file;

    // Clock generation parameters
    // 100MHz system clock (10ns period)
    parameter CLOCK_PERIOD = 0.01;  // 10ns in us timescale

    // Instantiate the Unit Under Test (UUT)
    StaticTextDisplay_Top uut (
        .clk     (clk),
        .btnU    (btnU),
        .RsRx    (RsRx),
        .RsTx    (RsTx),
        .Hsync   (Hsync),
        .Vsync   (Vsync),
        .vgaRed  (vgaRed),
        .vgaGreen(vgaGreen),
        .vgaBlue (vgaBlue)
    );

    // Clock generation
    always begin
        clk = 0;
        #(CLOCK_PERIOD / 2);
        clk = 1;
        #(CLOCK_PERIOD / 2);
    end

    // Convert 4-bit color to 3-bit binary string
    function [2:0] to_3bit;
        input [3:0] color;
        begin
            // Simple conversion by taking the top 3 bits
            to_3bit = color[3:1];
        end
    endfunction

    // Test stimulus and logging
    initial begin
        // Initialize file for writing
        file = $fopen("vga_output.txt", "w");
        if (file == 0) begin
            $display("Error: Could not open file");
            $finish;
        end

        // Initialize inputs
        btnU = 1;  // Assert reset
        RsRx = 0;

        // Wait 100us for global reset
        #100;
        btnU = 0;  // Release reset

        // Run simulation for 1 second (1,000,000 us)
        #1_000_000;

        // Close file and end simulation
        $fclose(file);
        $finish;
    end

    // Simulation time counter for more readable output
    reg [31:0] sim_time_ns;
    initial sim_time_ns = 0;
    always @(posedge clk) sim_time_ns = sim_time_ns + 10;  // Increment by 10ns each clock

    // Log VGA signals at every clock rising edge
    always @(posedge clk) begin
        // Format: time ns: hsync vsync red green blue
        $fwrite(file, "%0d ns: %b %b %03b %03b %03b\n", sim_time_ns, Hsync, Vsync, to_3bit(vgaRed),
                to_3bit(vgaGreen), to_3bit(vgaBlue));
    end
endmodule
