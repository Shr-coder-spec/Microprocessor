`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.07.2025 03:26:43
// Design Name: 
// Module Name: mem_forward
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

module mem_forward (
    input  wire [31:0] instr_ex_mem,       // Store instruction in EX/MEM
    input  wire [31:0] ex_mem_rs2_val,     // Original rs2 value (from regfile)

    input  wire [31:0] instr_mem_wb,       // Instruction in MEM/WB
    input  wire [31:0] mem_wb_output,      // Final result of MEM/WB stage

    input  wire [31:0] ex_mem_output,      // ALU output from EX/MEM (e.g., for ALU ops)

    output reg  [31:0] store_data_final    // Final value to store
    //output reg forwarded
);

    wire [4:0] rs2_ex_mem = instr_ex_mem[24:20];
    wire [4:0] rd_ex_mem  = instr_ex_mem[11:7];  // not used
    wire [4:0] rd_mem_wb  = instr_mem_wb[11:7];

    wire [6:0] opcode_mem_wb = instr_mem_wb[6:0];

    always @(*) begin
        
        store_data_final = ex_mem_rs2_val;  // Default: take it directly

        // Check if MEM/WB has the most recent version of rs2
        if ((rd_mem_wb == rs2_ex_mem) && (rd_mem_wb != 5'd0)) begin
            store_data_final = mem_wb_output; 
        end
        
    end

endmodule

