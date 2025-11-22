module pc_cnt (
    input wire clk,
    input wire reset,
    input wire [31:0] pcnext,
    output reg [31:0] pc
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 32'b0;  // ? Start from address 0x00000000
        else
            pc <= pcnext;
    end

endmodule

`timescale 1ns / 1ps

`timescale 1ns / 1ps

module tb_pc_cnt;

    reg clk;
    reg reset;
    reg [31:0] pcnext;
    wire [31:0] pc;

    // Instantiate DUT
    pc_cnt uut (
        .clk(clk),
        .reset(reset),
        .pcnext(pcnext),
        .pc(pc)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        $display("\n=== STARTING PC_CNT TEST ===");

        clk = 0;
        reset = 1;
        pcnext = 32'h00000000;  // Init pcnext

        // Apply reset for 10ns
        #10;
        reset = 0; // ? Now PC := 0 after this

        // Hold pcnext = 0 to show PC = 0 first
        #10;
        $display("Time = %0t | PC = %h", $time, pc);  // Expect: 0x00000000

        // Cycle 1: pcnext = 4
        pcnext = 32'd4;
        #10;
        $display("Time = %0t | PC = %h", $time, pc);  // Expect: 0x00000004

        // Cycle 2: pcnext = 8
        pcnext = 32'd8;
        #10;
        $display("Time = %0t | PC = %h", $time, pc);  // Expect: 0x00000008

        // Cycle 3: pcnext = 12
        pcnext = 32'd12;
        #10;
        $display("Time = %0t | PC = %h", $time, pc);  // Expect: 0x0000000C

        // Reset again
        reset = 1;
        #10;
        reset = 0;
        pcnext = 32'd0; // Hold pcnext at 0
        #10;
        $display("Time = %0t | PC = %h (After Reset)", $time, pc); // Expect: 0x00000000

        $display("=== END OF TEST ===");
        $stop;
    end

endmodule
