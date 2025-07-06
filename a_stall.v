`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.06.2025 14:07:45
// Design Name: 
// Module Name: a_stall
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
module a_stall (
    input  wire [31:0] id_ex_instr,     // instruction in ID/EX stage
    input  wire [31:0] ex_mem_instr,    // instruction in EX/MEM stage
    output reg         ex_stall         // stall signal to freeze IF/ID, ID/EX
);

    // Extract fields
    wire [6:0] id_ex_opcode   = id_ex_instr[6:0];
    wire [4:0] id_ex_rs1      = id_ex_instr[19:15];
    wire [4:0] id_ex_rs2      = id_ex_instr[24:20];

    wire [6:0] ex_mem_opcode  = ex_mem_instr[6:0];
    wire [4:0] ex_mem_rd      = ex_mem_instr[11:7];

    // Load detection: opcode = 0000011 (LW, LH, LB, etc.)
    wire ex_mem_is_load = (ex_mem_opcode == 7'b0000011);

    always @(*) begin
        ex_stall = 1'b0; // default: no stall

        if (ex_mem_is_load &&
            (ex_mem_rd != 5'b00000) && // ignore x0
            ((ex_mem_rd == id_ex_rs1) || (ex_mem_rd == id_ex_rs2))) begin
            ex_stall = 1'b1; // Stall needed
        end
    end

endmodule

