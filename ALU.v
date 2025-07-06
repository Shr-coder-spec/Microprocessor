`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2025 19:52:32
// Design Name: 
// Module Name: ALU
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
//OPCODE USED - 0110011
//A IS THE RS1 VALUE AND B IS RS2
//[31:25] funct7 | [24:20] rs2 | [19:15] rs1 | [14:12] funct3 | [11:7] rd | [6:0] opcode
module ALU(input [31:0] i, input [31:0] a, input [31:0] b, input [9:0] ex_pc, output reg [31:0] o, output reg zero, output reg flow);
wire [9:0] net;
assign net = {i[31:25], i[14:12]};
wire [6:0] opcode;
assign opcode = i[6:0];
wire [2:0] func3;
assign func3 = i[14:12];
wire [11:0] imm;
assign imm = i[31:20];
wire [31:0] imm_ext = {{20{imm[11]}}, imm};
wire [11:0] si = {i[31:25], i[11:7]};
wire [31:0] store_imm = {{20{si[11]}}, si};
always @(*)
begin
if(opcode == 7'b0110011)
begin
case (net)
    0:begin o = a+b;  flow = (a[31] == b[31]) && (o[31] != a[31]); end
    9'b0100000000: begin o = a-b; flow = (a[31] != b[31]) && (o[31] != a[31]); end
    9'b0000000111: o = a&b;
    9'b0000000110: o = a|b;
    9'b0000000100: o = a^b;
    9'b0000000001: o = a << b;//check for imm - OPCODE
    9'b0000000101: o = a>> b; //check for imm
    9'b0100000101: o= a>>>b; //check for imm
    9'b0000000010: o= (a < b) ? 1 : 0;
    endcase
end
else if (opcode == 7'b0010011)
begin
case (func3)
    3'b111: o = a&imm_ext;
    3'b110: o = a|imm_ext;
    3'b100: o = a^imm_ext;
    3'b001: o = a << i[24:20];
    3'b101: begin if(i[30]) o = a >> i[24:20]; else o = a>>> i[24:20]; end
    default: begin o = a+imm_ext; flow = (a[31] == imm_ext[31]) && (o[31] != a[31]);  end
    endcase
end
else if (opcode == 7'b0000011)
o = a+  imm_ext;
else if (opcode == 7'b1100111 | opcode== 7'b1101111)// for both jal, jalr
begin o = ex_pc + 4; flow = (ex_pc[9]==1); end
else if(opcode == 7'b0100011)
begin o = a + store_imm; flow = (a[31] == store_imm[31]) && (o[31] != a[31]); end
else if(opcode == 7'b0110111)
o = i[31:12] <<12;
else
begin o = a + imm_ext; flow = (a[31] == imm_ext[31]) && (o[31] != a[31]); end// base condition
zero = (o == 0);
end
endmodule
