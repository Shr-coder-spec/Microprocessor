`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.06.2025 18:57:16
// Design Name: 
// Module Name: dpath
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
module dpath(input reset, input clk);
reg [31:0] instruction [0:1023];
reg [31:0] reg_bank[0:31];
integer sd;
reg [9:0] pc, depc;
reg [31:0] fdi, fdpc;
reg [31:0] dei, de_rs1, de_rs2;
//reg [2:0] ID_EX_type, EX_MEM_type, MEM_WB_type; reg EX_MEM_cond; MEM_WB_LMD
reg [31:0] emi, emo, em_rs2;
reg [31:0] mbi, mbo, mbl;
reg fdt;
initial
begin
pc =0;
for(sd = 0; sd <32; sd=sd+1)//initialising the regbank
reg_bank[sd] = 32'b0;
        for (sd = 10; sd < 1024; sd = sd + 1) begin
            instruction[sd] = 32'h00000013;
        end
$readmemh("program.hex", instruction);
        
/*     instruction[0] = 32'h06400513; 
    instruction[1] = 32'h00a00113; // addi x2, x0, 1
    instruction[2] = 32'h002081b3; // bne x1, x2, +8 (not taken)
    instruction[3] = 32'h40118233; // addi x3, x0, 42
    instruction[4] = 32'h00220463; // beq x1, x2, +8 (taken)
    instruction[5] = 32'h001242b3; // addi x3, x0, 99 (skipped)
    instruction[6] = 32'h00029463; // addi x4, x0, 123
    instruction[7] = 32'h06300313;
    instruction[8] = 32'h004003ef;
    instruction[9] = 32'h0ff3e413; */
        for (sd = 10; sd < 1024; sd = sd + 1) begin
            instruction[sd] = 32'h00000013;
        end
depc=0; fdi=32'h00000013; fdpc= 0; dei = 32'h00000013; 
de_rs1 =0; de_rs2 =0; emi = 32'h00000013; mbi = 32'h00000013;
emo = 0; mbo = 0; mbl = 0; em_rs2 = 0;
end

localparam Noop =  32'h00000013;
wire comparator;
wire [4:0] rs1, rs2;
wire [31:0] inst, alu_out;
wire overflow, taken, ex_stall, id_stall, zero;
assign inst = instruction[pc/4];
assign rs1 = fdi[19:15];
assign rs2 = fdi[24:20];
wire[31:0] rs1_val, rs2_val, write_back_data;


assign write_back_data = (mbi[6:0]==7'b0000011)? mbl : mbo;
assign rs1_val = ((rs1 == mbi[11:7]) && wen && (mbi[11:7] != 5'd0))? write_back_data : reg_bank[rs1];
assign rs2_val = ((rs2 == mbi[11:7]) && wen && (mbi[11:7] != 5'd0))? write_back_data : reg_bank[rs2];


wire [31:0] c_rs1, c_rs2, a_rs1, a_rs2;
wire [9:0] branch_target, pc_updated;
jump j1(clk, inst, pc, comparator, pc_updated, taken);
comparator c1(fdi, c_rs1, c_rs2, fdt, fdpc, comparator, branch_target);
ALU a1(dei, a_rs1, a_rs2, depc, alu_out, zero, overflow);
a_forwarding fa1(
    dei,     // instruction in ID/EX stage
    emi,    // instruction in EX/MEM stage
    mbi,    // instruction in MEM/WB stage
    emo,   // rd value in EX/MEM stage
    mbo, mbl,   // rd value in MEM/WB stage
    de_rs1,   // rs1 value from regfile for ID/EX stage
    de_rs2,   // rs2 value from regfile for ID/EX stage
    a_rs1,   // final value for ALU input A (rs1)
    a_rs2 );
c_forwarding fc1(fdi, dei, emi, mbi, emo, mbo, mbl, rs1_val, rs2_val, c_rs1, c_rs2);
a_stall s1(dei, emi, ex_stall);
c_stall s2(fdi, dei, emi, id_stall);
wire [31:0] load_value;
wire [4:0] w_addr;
wire [31:0] w_data;
wire [31:0] m_rs2;
mem_stage m1(emi, emo, m_rs2, load_value);
mem_forward fm1(emi, em_rs2, mbi, w_data, emo, m_rs2); 

wire wen;
write_stage w1(mbi, mbl, mbo, w_addr, w_data, wen);
always @(posedge clk)
begin
if (ex_stall)
begin
emi<= 32'h00000013; em_rs2<=0; 
mbi<=emi; mbo<=emo; mbl<= load_value;
if(wen)
reg_bank[w_addr]<= w_data;
end

else if(id_stall)
begin
dei<= 32'h00000013; de_rs1<= 0; de_rs2<=0;
emi<=dei; emo<=alu_out; em_rs2<= de_rs2;
mbi<=emi;  mbo<=  emo; mbl<= load_value;
if(wen)
reg_bank[w_addr]<= w_data;
end

else
begin
emi<=dei; emo<=alu_out; em_rs2<= de_rs2;
mbi<=emi; mbl<=load_value; mbo<= emo;  // make sure to erase in case of comparator high

if(wen)
reg_bank[w_addr]<= w_data;

if(comparator)
begin
pc<= branch_target;
fdi<= Noop; dei<= Noop; de_rs1<= 0; de_rs2<= 0;
end
else begin
pc<= pc_updated;
fdi<= inst; fdpc<=pc; fdt<=taken;
dei<=fdi; depc<=fdpc; de_rs1<= rs1_val; de_rs2<= rs2_val; end
end
end
endmodule
