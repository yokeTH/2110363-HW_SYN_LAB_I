`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/05/2024 11:31:58 PM
// Design Name: 
// Module Name: UartBridge
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


module UartBridge (
    input  wire RsRx,  // USB UART RX
    output wire RsTx,  // USB UART TX
    output wire out,   // JB[0] (A14) - Output
    input  wire in    // JB[1] (A16) - Input
);
    assign out = RsRx;
    assign RsTx = in;

endmodule
