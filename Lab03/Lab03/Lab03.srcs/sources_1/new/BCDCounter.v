`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/07/2024 09:06:26 AM
// Design Name:
// Module Name: BCDCounter
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


module BCDCounter(output reg [3:0] outputs,
                  output reg cout,
                  output reg bout,
                  input up,
                  input down,
                  input set9,
                  input set0,
                  input clk);
    
    always @(posedge clk) begin
        
        bout <= 0;
        cout <= 0;
        
        case ({up, down})
            4'b01: begin
                outputs <= (outputs+9)%10;
                bout <= outputs == 0;
            end
            4'b10: begin
                outputs <= (outputs+1)%10;
                cout <= outputs == 0;
            end
        endcase
        
        case ({set9, set0})
            4'b01: begin
                outputs <= 0;
            end
            4'b10: begin
                outputs <= 9;
            end
        endcase
    end

endmodule
