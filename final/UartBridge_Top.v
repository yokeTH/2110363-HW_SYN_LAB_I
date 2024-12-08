`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/05/2024 11:31:58 PM
// Design Name: 
// Module Name: UartBridge_Top
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


module UartBridge_Top (
    input  wire clk,   // Main clock input
    input  wire RsRx,  // UART receive input
    output wire RsTx,  // UART transmit output
    output wire JB,
    input  wire JC
);

    localparam integer SystemClockFreqency = 100_000_000;  // system clock 10 ns
    localparam integer BaudRate = 115200;  // adjust to you baud rate
    localparam integer SamplingRate = 16;  // even value expect 2++

    // Bridge to pass through UART signals
    assign JB = RsRx;     // Pass received data to JB
    assign RsTx = JC;     // Pass JC input to transmitter

endmodule
