`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.06.2025 21:25:03
// Design Name: 
// Module Name: jump
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

//MAKE SURE TO PASS ON PC IN DATAPATH
module jump(input clk, input [31:0] i, input [9:0] pc, input comparator, output reg [9:0] pc_updated, output reg taken);
//jump-2, branch case
reg [255:0] bp;
initial
begin bp = 256'b0; end
wire [7:0] address = pc[7:0];
wire [6:0] opcode = i[6:0];
wire [20:0] imm;
assign imm = {i[31],         // imm[20]
                i[19:12],     // imm[19:12]
                i[20],        // imm[11]
                i[30:21],     // imm[10:1]
                1'b0};                  // imm[0] always zero (word-aligned)
// Sign-extend to 32-bit
wire [31:0] imm_J;
reg [9:0] store_pc;
assign imm_J = {{11{imm[20]}}, imm};  // sign-extend to 32-bit
always @(*)
begin
//if(comparator)
//pc_updated = branch_target;
//else
//begin
if(opcode == 7'b1100111) pc_updated = pc+ imm_J;
else if(opcode == 7'b1100011)
begin
    if(bp[address])
    begin pc_updated = pc + imm_J; taken = 1; end
    else
    begin pc_updated = pc + 4; taken = 0; end 
end
else
pc_updated = pc+4;
end
always @(posedge clk) 
begin
if(comparator)
bp[store_pc[7:0]]<= ~bp[store_pc[7:0]]; // the previous program counter

store_pc <= pc;
end
endmodule
