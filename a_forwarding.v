`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.06.2025 18:25:28
// Design Name: 
// Module Name: a_forwarding
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
module a_forwarding (
    input  wire [31:0] id_ex_instr,     // instruction in ID/EX stage
    input  wire [31:0] ex_mem_instr,    // instruction in EX/MEM stage
    input  wire [31:0] mem_wb_instr,    // instruction in MEM/WB stage
    input  wire [31:0] ex_mem_rd_val,   // rd value in EX/MEM stage
    input  wire [31:0] mbo,   // rd value in MEM/WB stage
    input [31:0] mbl,
    input  wire [31:0] rs1_val_id_ex,   // rs1 value from regfile for ID/EX stage
    input  wire [31:0] rs2_val_id_ex,   // rs2 value from regfile for ID/EX stage
    output reg  [31:0] alu_operand_a,   // final value for ALU input A (rs1)
    output reg  [31:0] alu_operand_b    // final value for ALU input B (rs2)
);

    // Extract fields from instructions
    wire [4:0] id_ex_rs1  = id_ex_instr[19:15];
    wire [4:0] id_ex_rs2  = id_ex_instr[24:20];
    wire [4:0] ex_mem_rd  = ex_mem_instr[11:7];
    wire [4:0] mem_wb_rd  = mem_wb_instr[11:7];
    reg [31:0] mem_wb_rd_val;
    always @(*)
    begin
    if(mem_wb_instr[6:0]==7'b0000011)
    mem_wb_rd_val = mbl;
    else
    mem_wb_rd_val = mbo;
    end
    // Check if EX/MEM or MEM/WB will write to rd (basic check: if rd != 0)
    wire ex_mem_regwrite  = (ex_mem_rd != 5'b00000);
    wire mem_wb_regwrite  = (mem_wb_rd != 5'b00000);

    always @(*) begin
        // Default: get operands from register file
        alu_operand_a = rs1_val_id_ex;
        alu_operand_b = rs2_val_id_ex;

        // Forward for operand A (rs1)
        if (ex_mem_regwrite && (ex_mem_rd == id_ex_rs1))
            alu_operand_a = ex_mem_rd_val; // Forward from EX/MEM
        else if (mem_wb_regwrite && (mem_wb_rd == id_ex_rs1))
            alu_operand_a = mem_wb_rd_val; // Forward from MEM/WB

        // Forward for operand B (rs2)
        if (ex_mem_regwrite && (ex_mem_rd == id_ex_rs2))
            alu_operand_b = ex_mem_rd_val; // Forward from EX/MEM
        else if (mem_wb_regwrite && (mem_wb_rd == id_ex_rs2))
            alu_operand_b = mem_wb_rd_val; // Forward from MEM/WB
    end

endmodule
