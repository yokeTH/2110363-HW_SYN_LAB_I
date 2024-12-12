`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2024 03:43:33 AM
// Design Name: 
// Module Name: ImagePixelController
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


module ImagePixelController (
    input  wire        reset,
    input  wire [ 9:0] pixel_x,
    input  wire [ 9:0] pixel_y,
    input  wire        video_on,
    output wire [11:0] image_rgb
);
    // Image dimensions (640x480)
    localparam IMAGE_WIDTH = 640;
    localparam IMAGE_HEIGHT = 480;

    // ROM parameters
    localparam ROM_ADDR_WIDTH = 19;  // log2(640 * 480)

    // Image ROM
    wire [              11:0] rom_data;
    reg  [ROM_ADDR_WIDTH-1:0] rom_addr;

    // ROM instantiation
    ImageROM image_rom (
        .addr(rom_addr),
        .data(rom_data)
    );

    // Address calculation
    always @(*) begin
        // Check if pixel is within image boundaries
        if (video_on && pixel_x < IMAGE_WIDTH && pixel_y < IMAGE_HEIGHT) begin
            // Linear address calculation
            rom_addr = pixel_y * IMAGE_WIDTH + pixel_x;
        end else begin
            rom_addr = 0;
        end
    end

    // Output assignment
    assign image_rgb = rom_data;

endmodule

// ROM module for storing image data
module ImageROM #(
    parameter IMAGE_WIDTH  = 640,
    parameter IMAGE_HEIGHT = 480
) (
    input  wire [18:0] addr,
    output reg  [11:0] data
);
    // Use a large enough memory to hold 640x480 12-bit pixels
    reg [11:0] rom_memory[0:IMAGE_WIDTH*IMAGE_HEIGHT-1];

    // Initialize ROM from memory file
    initial begin
        $readmemh("image.mem", rom_memory);
    end

    // Synchronous read
    always @(*) begin
        data <= rom_memory[addr];
    end
endmodule
