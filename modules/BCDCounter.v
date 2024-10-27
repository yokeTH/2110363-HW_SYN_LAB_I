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


module BCDCounter (
    output reg  [3:0] outputs,
    output reg        cout,
    output reg        bout,
    input  wire       up,
    input  wire       down,
    input  wire       set9,
    input  wire       set0,
    input  wire       clk
);

    always @(posedge clk) begin

        bout <= 0;
        cout <= 0;

        case ({
            up, down
        })
            2'b01: begin
                bout    <= outputs == 0;
                outputs <= (outputs + 9) % 10;
            end
            2'b10: begin
                cout    <= outputs == 9;
                outputs <= (outputs + 1) % 10;
            end
            default: ;
        endcase

        case ({
            set9, set0
        })
            2'b01: begin
                outputs <= 0;
            end
            2'b10: begin
                outputs <= 9;
            end
            default: ;
        endcase
    end

endmodule
