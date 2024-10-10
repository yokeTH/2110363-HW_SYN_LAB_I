`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/05/2024 09:44:29 AM
// Design Name:
// Module Name: testFullAdder
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


module testFullAdder();
    reg a,b,cin;
    wire cout,s;
    
    
    fullAdder a1(cout,s,a,b,cin);
    
    initial
    begin
        $monitor("time %t: {%b %b} <- {%d %d %d}", $time,cout,s,a,b,cin);
        a   = 0;
        b   = 0;
        cin = 0;
        
        #10;
        
        a   = 1;
        b   = 0;
        cin = 0;
        
        #10;
        
        a   = 0;
        b   = 1;
        cin = 0;
        
        #10;
        
        a   = 1;
        b   = 1;
        cin = 0;
        
        #10;
        
        a   = 0;
        b   = 0;
        cin = 1;
        
        #10;
        
        a   = 1;
        b   = 0;
        cin = 1;
        
        #10;
        
        a   = 0;
        b   = 1;
        cin = 1;
        
        #10;
        
        a   = 1;
        b   = 1;
        cin = 1;
        
        #10;
        $finish;
    end
endmodule
