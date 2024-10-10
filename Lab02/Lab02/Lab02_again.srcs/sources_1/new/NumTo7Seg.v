`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/07/2024 05:33:22 AM
// Design Name:
// Module Name: NumTo7Seg
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


module NumTo7Seg(output reg [6:0] outputs,
                 input wire [3:0] inputs);
    
    always @(inputs)
        case (inputs)
            4'b0001 : outputs = 7'b1111001;   // 1
            4'b0010 : outputs = 7'b0100100;   // 2
            4'b0011 : outputs = 7'b0110000;   // 3
            4'b0100 : outputs = 7'b0011001;   // 4
            4'b0101 : outputs = 7'b0010010;   // 5
            4'b0110 : outputs = 7'b0000010;   // 6
            4'b0111 : outputs = 7'b1111000;   // 7
            4'b1000 : outputs = 7'b0000000;   // 8
            4'b1001 : outputs = 7'b0010000;   // 9
            4'b1010 : outputs = 7'b0001000;   // A
            4'b1011 : outputs = 7'b0000011;   // b
            4'b1100 : outputs = 7'b1000110;   // C
            4'b1101 : outputs = 7'b0100001;   // d
            4'b1110 : outputs = 7'b0000110;   // E
            4'b1111 : outputs = 7'b0001110;   // F
            default : outputs = 7'b1000000;   // 0
        endcase
    
    
endmodule
