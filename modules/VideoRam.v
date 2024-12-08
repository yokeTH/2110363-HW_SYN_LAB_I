`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Thanapon Johdee
//
// Create Date: 12/05/2024 07:11:56 AM
// Design Name:
// Module Name: VideoRam
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


module VideoRam #(
    parameter integer ADDR_WIDTH = 19,  // 640*480 = 307,200 locations
    parameter integer DATA_WIDTH = 12   // 12-bit color (4 bits each for R,G,B)
) (
    input  wire        clk,
    input  wire        we,
    input  wire [18:0] write_addr,  // 640*480 = 307,200 locations
    input  wire [11:0] write_data,
    input  wire [18:0] read_addr,
    output reg  [11:0] read_data
);

    // Declare BRAM
    (* ram_style = "block" *)reg     [DATA_WIDTH-1:0] bram[(2**ADDR_WIDTH)-1:0];

    // Initialize memory to black
    integer                  i;
    initial begin
        for (i = 0; i < (2 ** ADDR_WIDTH); i = i + 1) begin
            bram[i] = 0;
        end
    end

    // Synchronous write
    always @(posedge clk) begin
        if (we) bram[write_addr] <= write_data;
    end

    // Synchronous read
    always @(posedge clk) begin
        read_data <= bram[read_addr];
    end

endmodule
