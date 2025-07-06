`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.06.2025 12:44:43
// Design Name: 
// Module Name: comparator
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

module comparator(
    input  wire [31:0] i,            // full 32-bit instruction
    input  wire [31:0] rs1_val,     // value of rs1
    input  wire [31:0] rs2_val, 
    input taken,
    input pc,     
    output reg  c,                    // output only when conditions dont match
    output reg [9:0] branch_target                  
);

    wire [6:0]  opcode;
    wire [2:0]  funct3;
    wire [31:0] branch_offset;
    assign branch_offset = {{19{i[31]}}, i[31], i[7], i[30:25], i[11:8], 1'b0};
    assign opcode = i[6:0];
    assign funct3 = i[14:12];
    reg r;

    always @(*) begin
        r = 0;  // Default: branch not taken

        if (opcode == 7'b1100011) begin // Branch instructions
            case(funct3)
                3'b000: r = (rs1_val == rs2_val); // BEQ
                3'b001: r = (rs1_val != rs2_val); // BNE
                3'b100: r = ($signed(rs1_val) < $signed(rs2_val)); // BLT (signed)
                3'b101: r = ($signed(rs1_val) >= $signed(rs2_val)); // BGE (signed)
                3'b110: r = (rs1_val < rs2_val); // BLTU (unsigned)
                3'b111: r = (rs1_val >= rs2_val); // BGEU (unsigned)    
                default: r = 0;
            endcase
        end
        else begin
            r = 0; // Not a branch instruction
        end
        if(r==1)
        branch_target = pc + branch_offset;
        else
        branch_target = pc + 4;
    
    if(r!=taken && opcode == 7'b1100011) // decision point (right decision has been taken or no) only for branch
    c=1;
    else
    c=0;
end   
endmodule

