# Asynchronous FIFO Design & Pre-Silicon Verification Engine

An open-source digital hardware design and verification project implementing a dual-clock **Asynchronous FIFO** (First-In, First-Out) memory buffer in SystemVerilog. Built to demonstrate Clock Domain Crossing (CDC) management, metastability mitigation using Gray-code pointer synchronization, and automated verification using SystemVerilog Assertions (SVA).

---

## Project Roadmap & Status

This project is constructed incrementally from base digital logic blocks up to a complete dual-clock memory architecture:

- [x] **Block 1: D Flip-Flop with Synchronous Reset**
  - Synthesizable sequential logic design (`d_flip_flop.sv`).
  - Cycle-accurate testbench (`testbench_d_flip_flop.sv`) with clock generation and stimulus control.
  - Verified signal behavior and rising clock edge transitions via VCD waveform traces.
- [ ] **Block 2: 2-Stage Flip-Flop Synchronizer**
  - Metastability resolution for multi-clock signals.
- [ ] **Block 3: Dual-Port RAM Array & Gray-Code Converters**
  - Binary-to-Gray pointer translation to ensure 1-bit transition steps.
- [ ] **Block 4: Top-Level Asynchronous FIFO & Self-Checking Testbench**
  - Full/Empty flag logic and randomized verification suite with SystemVerilog Assertions (SVA).

---

## Toolchain (Hardware-Free)

- **Language:** SystemVerilog (IEEE 1800-2012)
- **Compiler & Simulator Engine:** Icarus Verilog (`iverilog`)
- **Simulation Execution Engine:** `vvp`
- **Waveform Inspector:** VS Code WaveTrace Extension / GTKWave (`.vcd` format)

---

## Running Simulations

To run the simulation and generate timing trace files for the completed modules:

### Block 1: D Flip-Flop

1. **Compile the RTL design and testbench:**
   ```bash
   iverilog -g2012 -o sim.out d_flip_flop.sv testbench_d_flip_flop.sv
   ```
