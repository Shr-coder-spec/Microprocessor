`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.06.2025 18:54:33
// Design Name: 
// Module Name: c_stall
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


module c_stall(
    input  wire [31:0] if_id_instr,     // Branch instr in IF/ID
    input  wire [31:0] id_ex_instr,     // instr in ID/EX
    input  wire [31:0] ex_mem_instr,    // instr in EX/MEM
    output reg         id_stall         // Stall signal
);

    // Field extraction
    wire [4:0] if_id_rs1    = if_id_instr[19:15];
    wire [4:0] if_id_rs2    = if_id_instr[24:20];

    wire [6:0] if_id_opcode = if_id_instr[6:0];
    wire [4:0] id_ex_rd     = id_ex_instr[11:7];

    wire [6:0] ex_mem_opcode = ex_mem_instr[6:0];
    wire [4:0] ex_mem_rd     = ex_mem_instr[11:7];

    wire ex_mem_is_load = (ex_mem_opcode == 7'b0000011); // load opcodes (LW)
    always @(*) begin
        id_stall = 1'b0; // default: no stall
        if(if_id_opcode == 7'b1100011) begin //only if instruction is a comparator
        
        if ((id_ex_rd != 5'b00000) &&
           ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2))) begin
            id_stall = 1'b1;
        end
        
        else if ((ex_mem_rd != 5'b00000) &&
                ((ex_mem_rd == if_id_rs1) || (ex_mem_rd == if_id_rs2))&& ex_mem_is_load) begin
            id_stall = 1'b1;
        end end
    end

endmodule
