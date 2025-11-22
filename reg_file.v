module reg_file (
    input         clk,             // Clock
    input         reg_write,       // Write enable
    input  [4:0]  read_reg1,       // Read register 1 address
    input  [4:0]  read_reg2,       // Read register 2 address
    input  [4:0]  write_reg,       // Write register address
    input  [31:0] write_data,      // Data to write
    output [31:0] read_data1,      // Output from register 1
    output [31:0] read_data2       // Output from register 2
);

    // 32 registers of 32-bit each
    reg [31:0] registers[0:31];

    // Read Operations (combinational)
    assign read_data1 = (read_reg1 == 0) ? 32'b0 : registers[read_reg1];
    assign read_data2 = (read_reg2 == 0) ? 32'bx : registers[read_reg2];  // Modified to return 'x' when reading x0

    // Write Operation (on positive edge of clock)
    always @(posedge clk) begin
        if (reg_write && write_reg != 0) begin
            registers[write_reg] <= write_data;
        end
    end

endmodule
`timescale 1ns / 1ps

`timescale 1ns / 1ps

module tb_reg_file;

    // Inputs
    reg         clk;
    reg         reg_write;
    reg  [4:0]  read_reg1;
    reg  [4:0]  read_reg2;
    reg  [4:0]  write_reg;
    reg  [31:0] write_data;

    // Outputs
    wire [31:0] read_data1;
    wire [31:0] read_data2;

    // Instantiate the Unit Under Test (UUT)
    reg_file uut (
        .clk(clk),
        .reg_write(reg_write),
        .read_reg1(read_reg1),
        .read_reg2(read_reg2),
        .write_reg(write_reg),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // Clock Generation (10ns period)
    always #5 clk = ~clk;

    // Helper task to display both read data values
    task show_read_output;
        input [4:0] reg1;
        input [4:0] reg2;
        begin
            $display("Time: %0t | read_reg1: x%0d = %h | read_reg2: x%0d = %h",
                    $time, reg1, read_data1, reg2, read_data2);
        end
    endtask

    // Test sequence
    initial begin
        $display("=== Register File Verification TB Started ===");

        // Initialization
        clk = 0;
        reg_write = 0;
        read_reg1 = 0;
        read_reg2 = 0;
        write_reg = 0;
        write_data = 0;

        // Let clock settle
        #10;

        // Test 1: Try writing to x0 (should be ignored)
        reg_write = 1;
        write_reg = 5'd0;
        write_data = 32'hDEADBEEF;
        #10; // One clock cycle

        // Test 1-A: Read from x0 using read_reg1 -> should return 0
        reg_write = 0;
        read_reg1 = 5'd0;
        #1;
        if (read_data1 !== 32'd0)
            $display("? ERROR: x0 should return 0 on read_reg1, got %h", read_data1);
        else
            $display("? PASS: x0 read using read_reg1 returns 0 as expected");

        // Test 1-B: Read from x0 using read_reg2 -> should return X
        read_reg2 = 5'd0;
        #1;
        if (^read_data2 === 1'bx)  // using reduction XOR to detect X
            $display("? PASS: x0 read using read_reg2 returns X as expected: %h", read_data2);
        else
            $display("? ERROR: x0 read using read_reg2 should return X, got %h", read_data2);

        // Test 2: Write to x3
        reg_write = 1;
        write_reg = 5'd3;
        write_data = 32'h12345678;
        #10;

        // Test 3: Read x3 using both read ports
        reg_write = 0;
        read_reg1 = 5'd3;
        read_reg2 = 5'd3;
        #1;
        show_read_output(read_reg1, read_reg2);

        // Check values
        if (read_data1 !== 32'h12345678 || read_data2 !== 32'h12345678)
            $display("? ERROR: Read from x3 failed. Got read_data1=%h, read_data2=%h", read_data1, read_data2);
        else
            $display("? PASS: Read from x3 is correct");

        // Test 4: Simultaneous read from x0 and x3
        read_reg1 = 5'd0;
        read_reg2 = 5'd3;
        #1;
        show_read_output(read_reg1, read_reg2);

        // Test 5: Simultaneous read from x3 and x0 (check that rd2 returns X)
        read_reg1 = 5'd3;
        read_reg2 = 5'd0;
        #1;
        show_read_output(read_reg1, read_reg2);

        if (^read_data2 === 1'bx)
            $display("? PASS: read_reg2 == x0 returns X as expected while read_reg1 == x3");
        else
            $display("? ERROR: read_reg2 == x0 should return X, got %h", read_data2);

        $display("=== Register File Verification TB Completed ===");
        $stop;
    end

endmodule