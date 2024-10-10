`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/07/2024 12:02:38 PM
// Design Name:
// Module Name: TestBCDCounterAndSinglePulser
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


module TestBCDCounterAndSinglePulser();
    wire [3:0] outputs;
    wire d, cout, bout;
    reg clk, pushed, set9, set0, up, down;
    
    SinglePulser sp(d, pushed, clk);
    BCDCounter bcd(outputs, cout, bout, up, down, set9, set0, clk);
    
    always @(*) begin
        clk = ~clk;
        # 10;
    end
    
    initial begin
        clk = 0;
    end
    
    initial begin
        pushed = 0;
        
        # 5
        
        pushed = 1;
        
        # 20
        
        pushed = 0;
        
        # 10
        
        pushed = 1;
        
        # 1000
        
        $finish;
    end
    
    initial begin
        up   = 0;
        down = 0;
        set9 = 0;
        set0 = 1;
        
        # 20
        set0 = 0;
        up   = 1;
        
        # 300
        
        up = 0;
        
        # 10
        
        set9 = 1;
        
        # 20
        
        set9 = 0;
        
        # 10
        
        down = 1;
        
        # 300
        
        down = 0;
        
        # 10
        
        set0 = 1;
        
        # 20
        
        set0 = 0;
    end
endmodule
