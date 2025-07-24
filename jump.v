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
begin bp = {256{1'b1}}; end
wire [7:0] address = pc[7:0];
wire [6:0] opcode = i[6:0];
wire [12:0] immB_raw;
assign immB_raw = {
    i[31],        // imm[12]
    i[7],         // imm[11]
    i[30:25],     // imm[10:5]
    i[11:8],      // imm[4:1]
    1'b0          // imm[0], always 0 (aligned)
};

wire [31:0] immB;
assign immB = {{19{immB_raw[12]}}, immB_raw};  // sign-extend to 32 bits
reg [9:0] store_pc;
always @(*)
begin
//if(comparator)
//pc_updated = branch_target;
//else
//begin
if(opcode == 7'b1100111) pc_updated = pc+ immB;
else if(opcode == 7'b1100011)
begin
    if(bp[address])
    begin pc_updated = pc + immB; taken = 1; end
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
