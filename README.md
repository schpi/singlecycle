<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>single-cycle-riscv — README</title>
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial; line-height:1.6; padding:28px; color:#222; max-width:980px; margin:auto; }
    h1,h2,h3 { color:#0b63a6; }
    pre { background:#f6f8fa; padding:12px; border:1px solid #e1e4e8; overflow:auto; }
    code { font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, "Roboto Mono", "Courier New", monospace; background:#fff3cd; padding:2px 4px; border-radius:4px; }
    .badge { display:inline-block; margin-right:8px; }
    table { border-collapse:collapse; margin-top:6px; }
    td,th { border:1px solid #e1e4e8; padding:6px 10px; }
    footer { margin-top:26px; color:#666; font-size:0.95rem; }
    .note { background:#eef6ff; padding:8px; border-left:4px solid #0b63a6; margin:12px 0; }
  </style>
</head>
<body>
  <h1>single-cycle-riscv</h1>
  <p><strong>Single-cycle RV32I CPU implementation</strong> — Reference/simple educational implementation of the RISC-V RV32I instruction set in Verilog/SystemVerilog. Suitable for study, simulation and small FPGA experiments.</p>

  <h2>Quick links</h2>
  <p class="badge"><code>rv32i</code> • <code>single-cycle</code> • <code>Verilog</code></p>

  <h2>Overview</h2>
  <p>This repository contains a single-clock-cycle CPU core that implements the <strong>RV32I</strong> base integer instruction set. The design prioritizes clarity and simplicity over performance: every instruction completes in one clock cycle (so clock period must accommodate the slowest instruction). It is ideal for learning how the datapath and control signals map to RISC-V instructions.</p>

  <h2>Features</h2>
  <ul>
    <li>RV32I base integer instruction set (arithmetic, logical, branches, loads/stores, jal/jalr).</li>
    <li>Verilog/SystemVerilog RTL implementation.</li>
    <li>Simple memory model: synchronous instruction/data memory or separate instruction ROM + data RAM.</li>
    <li>Basic testbench with a small instruction/test harness and assembly test programs.</li>
    <li>Support for simulation with <code>iverilog</code> / <code>vvp</code> and optional <code>verilator</code> flow.</li>
    <li>Optional integration guidance for FPGA (pinout & memory mapping left for user).</li>
  </ul>

  <h2>Repository layout</h2>
  <pre><code>
single-cycle-riscv/
├── rtl/
│   ├── cpu.sv            # top-level CPU module (SystemVerilog)
│   ├── datapath.sv       # datapath: ALU, regfile, imm generator
│   └── control.sv        # control unit (instruction decode -> control signals)
├── mem/
│   ├── instr_rom.vhd     # or .sv / .hex test ROM
│   └── data_ram.sv
├── tb/
│   ├── tb_cpu.sv         # testbench (drives clocks, loads instruction memory)
│   └── test_vectors/     # example test programs in assembly / hex
├── tools/
│   ├── build.sh          # helper build scripts (iverilog/verilator)
│   └── objdump_helper.py # optional helpers
├── docs/
│   └── design_notes.md
├── Makefile
└── README.html           # this file
  </code></pre>

  <h2>Design summary</h2>
  <p>High-level datapath components:</p>
  <ul>
    <li><strong>Program Counter (PC)</strong> — holds next instruction address; updated every cycle.</li>
    <li><strong>Instruction Memory</strong> — read-only ROM for instruction fetch.</li>
    <li><strong>Register File</strong> — 32 x 32-bit registers. Writes occur in the same cycle as instruction (since single-cycle).</li>
    <li><strong>ALU</strong> — performs arithmetic/logical ops.</li>
    <li><strong>Immediate Generator</strong> — extracts immediates per RISC-V encodings.</li>
    <li><strong>Data Memory</strong> — synchronous RAM for loads/stores.</li>
    <li><strong>Control Unit</strong> — decodes opcode/funct fields to generate control signals and ALU control.</li>
  </ul>

  <div class="note">
    <strong>Important:</strong> Single-cycle means all operations (fetch, decode, execute, memory, write-back) happen in one clock cycle. This simplifies control but limits clock frequency and makes memory interface timing critical.
  </div>

  <h2>Supported instructions (subset)</h2>
  <p>Typical supported RV32I list (reference implementation):</p>
  <ul>
    <li>R-type: <code>add</code>, <code>sub</code>, <code>sll</code>, <code>slt</code>, <code>sltu</code>, <code>xor</code>, <code>srl</code>, <code>sra</code>, <code>or</code>, <code>and</code></li>
    <li>I-type: <code>addi</code>, <code>andi</code>, <code>ori</code>, <code>xori</code>, <code>slti</code>, shifts, <code>jalr</code>, loads (<code>lb</code>, <code>lh</code>, <code>lw</code>)</li>
    <li>S-type: <code>sb</code>, <code>sh</code>, <code>sw</code></li>
    <li>B-type: <code>beq</code>, <code>bne</code>, <code>blt</code>, <code>bge</code>, <code>bltu</code>, <code>bgeu</code></li>
    <li>U-type: <code>lui</code>, <code>auipc</code></li>
    <li>J-type: <code>jal</code></li>
  </ul>

  <h2>Build & simulate</h2>
  <p>Below are example flows. Adjust paths and filenames to match this repo.</p>

  <h3>Prerequisites</h3>
  <ul>
    <li><code>iverilog</code> and <code>vvp</code> — fast, simple open-source simulator.</li>
    <li>Optional: <code>verilator</code> for cycle-accurate C++ simulation and faster regression tests.</li>
    <li>Optional: RISC-V GCC toolchain (<code>riscv64-unknown-elf-gcc</code>) to build test programs.</li>
    <li>Optional: <code>gtkwave</code> to view VCD traces.</li>
  </ul>

  <h3>Simulate with iverilog</h3>
  <pre><code># from repository root
make sim
# or manually:
iverilog -g2012 -o tb_cpu.vvp rtl/*.sv mem/*.sv tb/tb_cpu.sv
vvp tb_cpu.vvp
# produce waveform:
vvp tb_cpu.vvp
# if testbench writes dump.vcd:
gtkwave dump.vcd
  </code></pre>

  <h3>Simulate with Verilator</h3>
  <pre><code># basic verilator flow (Linux)
# generate C++ sim
verilator -Wall --cc --exe tb/tb_cpu.cpp rtl/*.sv mem/*.sv --Mdir obj_dir
# build
make -C obj_dir -j -f Vcpu.mk Vcpu
# run
obj_dir/Vcpu
  </code></pre>

  <h3>Assemble and run a small program</h3>
  <pre><code># assemble example.S -> example.elf
riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -o prog.elf prog.S
# extract binary/hex for ROM (using objcopy)
riscv64-unknown-elf-objcopy -O binary prog.elf prog.bin
xxd -e prog.bin | awk '{print $2 $3 $4 $5}' > mem/instr.hex  # example convert to hex words
# run simulator which reads mem/instr.hex at init
vvp tb_cpu.vvp
  </code></pre>

  <h2>Testbench</h2>
  <p>Testbench responsibilities:</p>
  <ul>
    <li>Initialize instruction memory from <code>mem/instr.hex</code>.</li>
    <li>Provide clock & reset sequences.</li>
    <li>Optionally provide a simple UART console mapping or memory-mapped I/O for printf-style output.</li>
    <li>Dump waveforms (<code>$dumpfile</code> / <code>$dumpvars</code>) for waveform debug.</li>
  </ul>

  <h2>Known limitations</h2>
  <ul>
    <li>No pipelining: single-cycle limits max frequency.</li>
    <li>No MMU or privileged modes — user-level only.</li>
    <li>Alignment checks / exceptions are minimal or not implemented.</li>
    <li>CSR instructions (system instructions) are not implemented in the base design (unless explicitly added).</li>
  </ul>

  <h2>Design notes & verification</h2>
  <p>Recommended verification approach:</p>
  <ol>
    <li>Unit test ALU and immediate generator with directed tests.</li>
    <li>Run small assembled test programs exercising branches, loads/stores, register hazards, sign/zero extension.</li>
    <li>Compare results of memory/register state with a golden model (Spike ISA simulator or reference traces).</li>
  </ol>

  <h2>Contributing</h2>
  <p>Contributions are welcome. Typical improvements:</p>
  <ul>
    <li>Implement full RV32I test-suite and add regression harness.</li>
    <li>Add CSR and privileged-mode support.</li>
    <li>Port to FPGA (add top-level constraints and board support).</li>
    <li>Convert to a pipelined design or add hazard forwarding/exceptions.</li>
  </ul>
  <p>When contributing, please:</p>
  <ol>
    <li>Open an issue describing the change or bug.</li>
    <li>Submit a branch or a pull request with tests and documentation updates.</li>
  </ol>

  <h2>Example code snippets</h2>
  <h3>Top-level CPU (simplified)</h3>
  <pre><code>// rtl/cpu.sv  (very small illustrative extract)
module cpu (
  input  logic        clk,
  input  logic        rst_n
);
  logic [31:0] pc, next_pc;
  logic [31:0] instr;
  // instruction fetch
  instr_mem imem(.addr(pc[31:2]), .data(instr));
  // decode
  logic [6:0] opcode = instr[6:0];
  // datapath instances: regfile, alu, immgen, data mem...
  // PC update logic (branches/jal/jalr)
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) pc <= 32'h0000_0000;
    else pc <= next_pc;
  end
endmodule
  </code></pre>

  <h3>Register file (sketch)</h3>
  <pre><code>// rtl/regfile.sv
module regfile (
  input  logic        clk,
  input  logic        we,
  input  logic  [4:0] ra1, ra2, wa,
  input  logic [31:0] wd,
  output logic [31:0] rd1, rd2
);
  logic [31:0] regs[31];
  assign rd1 = (ra1==0)? 32'd0 : regs[ra1];
  assign rd2 = (ra2==0)? 32'd0 : regs[ra2];
  always_ff @(posedge clk) if (we && wa != 0) regs[wa] <= wd;
endmodule
  </code></pre>

  <h2>License</h2>
  <p>MIT License — see <code>LICENSE</code> for details.</p>

  <h2>Acknowledgements & references</h2>
  <p>This project follows the RV32I base ISA specification. For learning resources, consult the official RISC-V specification and common CPU design textbooks or tutorials.</p>

  <h2>Contact</h2>
  <p>For questions or contributions, please open an issue or pull request on the repository.</p>

  <footer>
    <p>Generated README — good starting point for a single-cycle RISC-V educational project. Adjust instruction set and toolchain instructions to match your environment.</p>
  </footer>
</body>
</html>
