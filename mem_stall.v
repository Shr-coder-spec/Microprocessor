`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.07.2025 03:36:40
// Design Name: 
// Module Name: mem_stall
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

module mem_stall (
    input  wire [31:0] instr_ex_mem,   // Instruction in EX stage (maybe a load)
    input  wire [31:0] instr_id,       // Instruction in ID stage (may depend on it)

    output reg         mem_stall       // Stall signal (1 = stall)
);

    wire [6:0] opcode_ex_mem = instr_ex_mem[6:0];
    wire [4:0] rd_ex_mem     = instr_ex_mem[11:7];

    wire [4:0] rs1_id        = instr_id[19:15];
    wire [4:0] rs2_id        = instr_id[24:20];

    localparam OPC_LOAD = 7'b0000011;

    always @(*) begin
        mem_stall = 1'b0;

        if (opcode_ex_mem == OPC_LOAD && rd_ex_mem != 5'd0) begin
            if ((rs1_id == rd_ex_mem) || (rs2_id == rd_ex_mem)) begin
                mem_stall = 1'b1;
            end
        end
    end

endmodule
