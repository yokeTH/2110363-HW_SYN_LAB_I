`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/05/2024 11:26:47 AM
// Design Name:
// Module Name: testShiftAB
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


module testShiftAB();
    wire[1:0] q1, q2;
    reg clock, d;
    
    shiftA s1(q1,clock,d);
    shiftB s2(q2,clock,d);
    
    always @(*) begin
        #5
        clock = ~clock;
    end
    
    initial begin
        #0
        clock = 0;
        d     = 0;
        
        #5
        d = 1;
        
        #35
        d = 0;
        
        #50
        $finish;
    end
    always @(*) begin
        #8
        d = ~d;
    end
endmodule
