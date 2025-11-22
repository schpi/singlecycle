module instr_mem (
    input  [31:0] address,       // from PC
    output [31:0] instruction    // fetched instruction
);

    reg [7:0] ram [0:31];        // 32 bytes = 8 instructions

    reg [31:0] instr_out;
    wire [4:0] addr = address[4:0];  // cover full 32 bytes

    assign instruction = instr_out;

    initial begin
        // 1) 0x00900493 (addi x9, x0, 9)
        ram[0] = 8'h93;
        ram[1] = 8'h04;
        ram[2] = 8'h90;
        ram[3] = 8'h00;

        // 2) 0x00500293 (addi x5, x0, 5)
        ram[4] = 8'h93;
        ram[5] = 8'h02;
        ram[6] = 8'h50;
        ram[7] = 8'h00;

        // 3) 0xfe54ae23 (sw x5, -20(x9))
        ram[8]  = 8'h23;
        ram[9]  = 8'hAE;
        ram[10] = 8'h54;
        ram[11] = 8'hFE;

        // 4) 0xffc4a303 (lw x6, -4(x9))
        ram[12] = 8'h03;
        ram[13] = 8'hA3;
        ram[14] = 8'hC4;
        ram[15] = 8'hFF;

        // 5) 0x0064a423 (sw x6, 8(x9))
        ram[16] = 8'h23;
        ram[17] = 8'hA4;
        ram[18] = 8'h64;
        ram[19] = 8'h00;

        // 6) 0x0062e233 (or x4, x5, x6)
        ram[20] = 8'h33;
        ram[21] = 8'hE2;
        ram[22] = 8'h62;
        ram[23] = 8'h00;

        // 7) 0xfe420ae3 (beq x4, x4, offset)
        ram[24] = 8'hE3;
        ram[25] = 8'h0A;
        ram[26] = 8'h42;
        ram[27] = 8'hFE;
    end

    always @(*) begin
        instr_out = {
            ram[addr + 3],
            ram[addr + 2],
            ram[addr + 1],
            ram[addr + 0]
        };
    end
endmodule

`timescale 1ns/1ps

module tb_instr_mem;

    reg  [31:0] address;
    wire [31:0] instruction;

    instr_mem uut (
        .address(address),
        .instruction(instruction)
    );

    task print_instruction;
        input [127:0] instr_name;
        begin
            $display("Address: 0x%0h | Instruction: 0x%08h | %0s", address, instruction, instr_name);
        end
    endtask

    initial begin
        $display("\n=== Instruction Memory Test Start ===\n");

        address = 0;     #10; print_instruction("addi x9, x0, 9");
        address = 4;     #10; print_instruction("addi x5, x0, 5");
        address = 8;     #10; print_instruction("sw x5, -20(x9)");
        address = 12;    #10; print_instruction("lw x6, -4(x9)");
        address = 16;    #10; print_instruction("sw x6, 8(x9)");
        address = 20;    #10; print_instruction("or x4, x5, x6");
        address = 24;    #10; print_instruction("beq x4, x4, L1");

        $display("\n=== Test Completed ===");
        $stop;
    end

endmodule
