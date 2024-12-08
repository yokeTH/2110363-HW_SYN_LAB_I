`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/05/2024 08:29:43 AM
// Design Name: 
// Module Name: TextDisplayWithBuffer_TB
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


module TextDisplayWithBuffer_TB;
    reg           clk;
    reg           btnU;
    reg           write_enable;
    reg     [6:0] write_x;
    reg     [4:0] write_y;
    reg     [6:0] write_data;
    wire          Hsync;
    wire          Vsync;
    wire    [3:0] vgaRed;
    wire    [3:0] vgaGreen;
    wire    [3:0] vgaBlue;

    // File handle for VGA simulation output
    integer       file;
    integer       frame_count;

    // Message to display
    reg     [7:0] message      [0:31];  // Array to hold the message
    integer       msg_length;

    // Parameters
    parameter CLOCK_PERIOD = 10;  // 10ns (100MHz)
    parameter FRAME_TIME = 16_666_667;  // ~16.7ms in ns
    parameter NUM_FRAMES = 4;  // Number of frames to simulate

    // Instantiate the Unit Under Test (UUT)
    TextDisplayWithBuffer uut (
        .clk         (clk),
        .reset        (btnU),
        .write_enable(write_enable),
        .write_x     (write_x),
        .write_y     (write_y),
        .write_data  (write_data),
        .Hsync       (Hsync),
        .Vsync       (Vsync),
        .vgaRed      (vgaRed),
        .vgaGreen    (vgaGreen),
        .vgaBlue     (vgaBlue)
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
            to_3bit = color[3:1];
        end
    endfunction

    // Initialize message array
    task initialize_message;
        begin
            msg_length          = 0;

            // "Hello World I am Simulation"
            message[msg_length] = "I";
            msg_length          = msg_length + 1;
            message[msg_length] = " ";
            msg_length          = msg_length + 1;
            message[msg_length] = "A";
            msg_length          = msg_length + 1;
            message[msg_length] = "M";
            msg_length          = msg_length + 1;
            message[msg_length] = " ";
            msg_length          = msg_length + 1;
        end
    endtask

    // Test stimulus and logging
    initial begin
        // Initialize message
        initialize_message();

        // Initialize file for writing
        file = $fopen("vga_output.txt", "w");
        if (file == 0) begin
            $display("Error: Could not open file");
            $finish;
        end

        // Initialize signals
        frame_count  = 0;
        btnU         = 0;
        write_enable = 0;
        write_x      = 0;
        write_y      = 0;
        write_data   = 0;

        // Reset pulse
        btnU         = 1;
        #20 btnU = 0;
        #20;

        // Loop for each frame
        for (frame_count = 0; frame_count < NUM_FRAMES; frame_count = frame_count + 1) begin
            // Clear screen at start of each frame
            write_enable = 1;
            write_y      = 0;

            // Write characters up to current frame count
            for (integer i = 0; i <= frame_count && i < msg_length; i = i + 1) begin
                write_x    = i;
                write_data = {1'b0, message[i][6:0]};  // Convert ASCII to 7-bit
                #10;
            end

            write_enable = 0;

            // Wait for one frame period
            #(FRAME_TIME - 10 * (frame_count + 1));
        end

        // Close file and end simulation
        $fclose(file);
        $finish;
    end

    // Simulation time counter for more readable output
    reg [31:0] sim_time_ns;
    initial sim_time_ns = 0;
    always @(posedge clk) sim_time_ns = sim_time_ns + 10;

    // Log VGA signals at every clock rising edge
    always @(posedge clk) begin
        $fwrite(file, "%0d ns: %b %b %03b %03b %03b\n", sim_time_ns, Hsync, Vsync, to_3bit(vgaRed),
                to_3bit(vgaGreen), to_3bit(vgaBlue));
    end
endmodule
