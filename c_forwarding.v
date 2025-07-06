module c_forwarding(
    input  wire [31:0] if_id_instr,     // current branch instr
    input  wire [31:0] id_ex_instr,     // previous instr (in EX)
    input  wire [31:0] ex_mem_instr,    // EX/MEM
    input  wire [31:0] mem_wb_instr,    // MEM/WB
    //input  wire [31:0] id_ex_rd_val,   // value of rd in ID/EX
    input  wire [31:0] ex_mem_rd_val,  // value of rd in EX/MEM
    input  wire [31:0] mbo,  // value of rd in MEM/WB
    input [31:0] mbl,
    input  wire [31:0] rs1_val_if_id,  // value read from regfile for rs1
    input  wire [31:0] rs2_val_if_id,  // value read from regfile for rs2
    output reg  [31:0] cmp_operand_a,  // final value for comparator operand A (rs1)
    output reg  [31:0] cmp_operand_b   // final value for comparator operand B (rs2)
);

    // Extract fields
    wire [4:0] if_id_rs1   = if_id_instr[19:15];
    wire [4:0] if_id_rs2   = if_id_instr[24:20];

    wire [4:0] id_ex_rd    = id_ex_instr[11:7];
    wire [4:0] ex_mem_rd   = ex_mem_instr[11:7];
    wire [4:0] mem_wb_rd   = mem_wb_instr[11:7];

    wire id_ex_regwrite  = (id_ex_rd != 5'b00000); 
    wire ex_mem_regwrite = (ex_mem_rd != 5'b00000); 
    wire mem_wb_regwrite = (mem_wb_rd != 5'b00000); 
    reg [31:0] mem_wb_rd_val;
    always @(*)
    begin
    if(mem_wb_instr[6:0]==7'b0000011)
    mem_wb_rd_val = mbl;
    else
    mem_wb_rd_val = mbo;
    end
    always @(*) begin
        // Default: get from regfile
        cmp_operand_a = rs1_val_if_id;
        cmp_operand_b = rs2_val_if_id;

        // Forward for rs1
        if (ex_mem_regwrite && (ex_mem_rd == if_id_rs1))
            cmp_operand_a = ex_mem_rd_val;
        else if (mem_wb_regwrite && (mem_wb_rd == if_id_rs1))
            cmp_operand_a = mem_wb_rd_val;

        // Forward for rs2
        if (ex_mem_regwrite && (ex_mem_rd == if_id_rs2))
            cmp_operand_b = ex_mem_rd_val;
        else if (mem_wb_regwrite && (mem_wb_rd == if_id_rs2))
            cmp_operand_b = mem_wb_rd_val;
    end

endmodule
