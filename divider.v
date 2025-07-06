`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2025 17:35:38
// Design Name: 
// Module Name: divider
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

//q/m 
module divider(input clk, input [31:0] d1, input [31:0] d2, output o);
parameter s0= 0, s1 = 1, s2 = 2, s3 = 3;
reg [30:0] q, m;
reg [63:0] c;
reg [1:0] PS, NS;
reg [5:0] counter; //counts to 32
assign o = c[30:0];
always @(posedge clk)
NS<=PS;
always @(*)
begin
case(PS)
    s0: begin
        if(d1[31])
        c = {32'b0, ~d1[30:0] +1};
        else
        c = {32'b0, d1[30:0]};
        if(d2[31])
        m = ~d2[30:0] +1;
        else
        m = d2[30:0];
        NS = s1;
        counter = 32;
        end
    s1: begin 
        if(c[63])
        c = (c<<1)+m;
        else
        c = (c<<1)-m;
        counter = counter -1;
        if(counter==0)
        NS = s2;
        else
        NS = s1;
        end
    s2: begin
        if(c[63])
        c= c+m; NS = s2; end
    default: NS = s0;
    endcase
end
endmodule
