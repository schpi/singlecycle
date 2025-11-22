module toplvl_processor (
    input clk,
    input reset,
    output MemWrite,             // Memory Write enable
    output [31:0] ALUResult,     // ALU output / Address
    output [31:0] WriteData,     // Data to be written
    output [1:0] ResultSrc       // Control for external logic
);

 // === INTERNAL WIRES ===
wire [31:0] pc;
wire [31:0] pcnext;
wire [31:0] pcplus4;
wire [31:0] pctarget;

wire [31:0] instr;
wire RegWrite, Branch, Jump, PCSrc;
wire [1:0] ALUSrc;
wire [2:0] ImmSrc, ALUControl;
wire [31:0] rd1, rd2;
wire [31:0] imm;
wire [31:0] srcA, srcB, alu_result;
wire Zero;

// === EXEC ENABLE (one-cycle delay after reset)
reg exec_enable;

always @(posedge clk or posedge reset) begin
    if (reset)
        exec_enable <= 0;
    else
        exec_enable <= 1; // enable after 1 cycle
end

// === PROGRAM COUNTER ===
pc_cnt pc_register (
    .clk(clk),
    .reset(reset),
    .pcnext(pcnext),
    .pc(pc)
);

// === INSTRUCTION MEMORY ===
instr_mem imem (
    .address(pc),
    .instruction(instr)
);

// === CONTROL UNIT ===
control_unit cu (
    .opcode(instr[6:0]),
    .funct3(instr[14:12]),
    .funct7(instr[31:25]),
    .Zero(Zero),
    .RegWrite(RegWrite),
    .MemWrite(MemWrite),
    .ALUSrc(ALUSrc),
    .ImmSrc(ImmSrc),
    .ResultSrc(ResultSrc),
    .Branch(Branch),
    .ALUControl(ALUControl),
    .Jump(Jump),
    .PCSrc(PCSrc)
);

// === REGISTER FILE ===
reg_file rf (
    .clk(clk),
    .reg_write(RegWrite),
    .read_reg1(instr[19:15]),
    .read_reg2(instr[24:20]),
    .write_reg(instr[11:7]),
    .write_data(32'b0),  // write-back disabled
    .read_data1(rd1),
    .read_data2(rd2)
);

// === IMMEDIATE GENERATOR ===
immem_ext imm_ext (
    .ImmSrc(ImmSrc),
    .Ins(instr),
    .Imm(imm)
);

// === ALU SOURCES ===
assign srcA = rd1;
assign srcB =
    (ALUSrc == 2'b00) ? rd2 :
    (ALUSrc == 2'b01) ? imm :
    32'b0;

// === ALU ===
alu_1 alu (
    .a(srcA),
    .b(srcB),
    .ALUC(ALUControl),
    .c(alu_result)
);

assign Zero = (alu_result == 0);

// === OUTPUT CONNECTIONS ===
assign ALUResult = alu_result;
assign WriteData = rd2;

// === PC LOGIC ===
assign pcplus4  = pc + 32'd4;
assign pctarget = pc + imm;

// === NEXT PC SELECTION ===
assign pcnext = (exec_enable) ? ((PCSrc) ? pctarget : pcplus4) : pc;

endmodule
