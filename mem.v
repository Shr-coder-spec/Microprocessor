`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.06.2025 22:19:15
// Design Name: 
// Module Name: mem
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

module mem_stage (
    input  wire [31:0] ex_mem_instr,   // Instruction in EX/MEM stage
    input  wire [31:0] mem_addr,       // ALU computed address
    input  wire [31:0] rs2_val,        // Value to store (for SW/SH/SB)
    //input forwarded,
    output reg  [31:0] mem_read_data   // Data read from memory (for LW/LH/LB)
);

    // 1024 x 32-bit memory
    reg [31:0] memory [0:1023];
    integer sd;
initial begin
    for(sd=0; sd<1024; sd= sd+1)
    memory[sd] =0;
        //$readmemh("memory_init.hex", memory);
    end
    // Extract opcode and funct3
    wire [6:0] opcode = ex_mem_instr[6:0];
    wire [2:0] funct3 = ex_mem_instr[14:12];

    always @(*) begin
        mem_read_data = mem_addr; // default

        case (opcode)
            // LOADS
            7'b0000011: begin // Load
                case (funct3)
                    3'b010: begin // LW (Load Word)
                        mem_read_data = memory[mem_addr];
                    end
                    3'b001: begin // LH (Load Halfword, signed)
                        if (mem_addr[1] == 1'b0) begin
                            mem_read_data = {{16{memory[mem_addr][15]}}, memory[mem_addr][15:0]}; // lower half
                        end else begin
                            mem_read_data = {{16{memory[mem_addr][31]}}, memory[mem_addr][31:16]}; // upper half
                        end
                    end
                    3'b000: begin // LB (Load Byte, signed)
                        case (mem_addr[1:0])
                            2'b00: mem_read_data = {{24{memory[mem_addr][7]}},  memory[mem_addr][7:0]};
                            2'b01: mem_read_data = {{24{memory[mem_addr][15]}}, memory[mem_addr][15:8]};
                            2'b10: mem_read_data = {{24{memory[mem_addr][23]}}, memory[mem_addr][23:16]};
                            2'b11: mem_read_data = {{24{memory[mem_addr][31]}}, memory[mem_addr][31:24]};
                        endcase
                    end
                    default: mem_read_data = 32'b0;
                endcase
            end

            // STORES
            7'b0100011: begin // Store
                case (funct3)
                    3'b010: begin // SW (Store Word)
                        memory[mem_addr] = rs2_val;
                    end
                    3'b001: begin // SH (Store Halfword)
                        if (mem_addr[1] == 1'b0)
                            memory[mem_addr][15:0]  = rs2_val[15:0]; // lower half
                        else
                            memory[mem_addr][31:16] = rs2_val[15:0]; // upper half
                    end
                    3'b000: begin // SB (Store Byte)
                        case (mem_addr[1:0])
                            2'b00: memory[mem_addr][7:0]   = rs2_val[7:0];
                            2'b01: memory[mem_addr][15:8]  = rs2_val[7:0];
                            2'b10: memory[mem_addr][23:16] = rs2_val[7:0];
                            2'b11: memory[mem_addr][31:24] = rs2_val[7:0];
                        endcase
                    end
                    default: ; // do nothing
                endcase
            end

            default: ; // Not a load/store
        endcase
    end

endmodule

