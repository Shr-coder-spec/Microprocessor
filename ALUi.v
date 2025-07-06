`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.06.2025 11:03:12
// Design Name: 
// Module Name: ALUi
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


module ALUi(input [2:0] f3, input [31:0] a, input [11:0] b, output reg [31:0] o, output reg zero, output reg flow);
always @(*)
begin
case (f3)
    3'b111: o = a&b;
    3'b110: o = a|b;
    3'b100: o = a^b;
    default: begin o = a+b; flow = (a[3] == b[3]) && (o[3] != a[3]); zero = (o == 0); end
    endcase
end
endmodule
