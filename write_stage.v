`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.07.2025 01:19:39
// Design Name: 
// Module Name: write_stage
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

module write_stage (
    input  wire [31:0] instr_wb,         // Instruction in WB stage
    input  wire [31:0] mem_data_out,     // Data from memory (for loads)
    input  wire [31:0] alu_result,       // ALU result from MEM stage

    output reg  [4:0]  reg_write_addr,   // Register to write (rd)
    output reg  [31:0] reg_write_data,   // Data to write
    output reg         reg_write_enable  // High if write is valid
);

    // Extract fields from instruction
    wire [6:0] opcode  = instr_wb[6:0];
    wire [4:0] rd      = instr_wb[11:7];
    wire [2:0] funct3  = instr_wb[14:12];

    // Opcodes
    localparam OPC_LOAD  = 7'b0000011;  // lb, lh, lw, lbu, lhu
    localparam OPC_OPIMM = 7'b0010011;  // addi, etc.
    localparam OPC_OP    = 7'b0110011;  // add, sub, etc.
    localparam OPC_LUI   = 7'b0110111;  // lui
    localparam OPC_AUIPC = 7'b0010111;  // auipc
    localparam OPC_JAL   = 7'b1101111;  // jal
    localparam OPC_JALR  = 7'b1100111;  // jalr

    always @(*) begin
        // Defaults
        reg_write_addr   = rd;
        reg_write_data   = 32'b0;
        reg_write_enable = 1'b0;

        // Only attempt to write if rd != x0
        if (rd != 5'd0) begin
            case (opcode)
                OPC_OPIMM,
                OPC_OP,
                OPC_LUI,
                OPC_AUIPC,
                OPC_JAL,
                OPC_JALR: begin
                    reg_write_data   = alu_result;
                    reg_write_enable = 1'b1;
                end
                OPC_LOAD: begin
                    reg_write_enable = 1'b1;
                    case (funct3)
                        3'b000: reg_write_data = {{24{mem_data_out[7]}},  mem_data_out[7:0]};   // lb
                        3'b001: reg_write_data = {{16{mem_data_out[15]}}, mem_data_out[15:0]};  // lh
                        3'b010: reg_write_data = mem_data_out;                                  // lw
                        3'b100: reg_write_data = {24'b0, mem_data_out[7:0]};                    // lbu
                        3'b101: reg_write_data = {16'b0, mem_data_out[15:0]};                   // lhu
                        default: reg_write_enable = 1'b0; // unknown load type
                    endcase
                end
                default: begin
                    reg_write_enable = 1'b0; // NOPs or store/branch types
                end
            endcase
        end
    end

endmodule


