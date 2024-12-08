`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2024 03:42:05 AM
// Design Name: 
// Module Name: ps2_keyboard
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


module ps2_keyboard (
    input  wire       clk,         // System clock
    input  wire       ps2_clk,     // PS2 clock from keyboard
    input  wire       ps2_data,    // PS2 data from keyboard
    output wire [7:0] ascii_code,  // ASCII output
    output wire       ascii_valid  // High when new ASCII code is ready
);

    wire [8:0] rx_data;
    wire       rx_ready;

    ps2 p2_instant (
        .reset   (0),
        .ps2_data(ps2_data),
        .ps2_clk (ps2_clk),
        .rx_data (rx_data),
        .rx_ready(rx_ready)
    );

    ps2_scan2ascii decoder (
        .clk           (clk),
        .ps2_code_new  (rx_ready),
        .ps2_code      (rx_data[7:0]),
        .ascii_code_new(ascii_valid),
        .ascii_code    (ascii_code)
    );


endmodule
