module alu_1 (
    input  [31:0] a,            // 32-bit input a
    input  [31:0] b,            // 32-bit input b
    input  [2:0]  ALUC,         // 3-bit control signal
    output [31:0] c             // 32-bit output result
);

    reg [31:0] result;          // Internal register to hold result

    // Assign result to output
    assign c = result;

    // Combinational ALU logic
    always @(*) begin
        case (ALUC)
            3'b000: result = a + b;         // ADD
            3'b001: result = a - b;         // SUB
            3'b010: result = a & b;         // AND
            3'b011: result = a | b;         // OR
            3'b100: result = a ^ b;         // XOR
            3'b101: result = (a < b) ? 32'd1 : 32'd0; // Set if Less Than (SLT)
            default: result = 32'b0;          // Default: zero
        endcase
    end

endmodule
