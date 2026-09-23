# Asynchronous FIFO Project

I'm building this to actually learn Verilog instead of just reading about it. The end goal is a dual-clock **Asynchronous FIFO** (First-In, First-Out) memory buffer in SystemVerilog, but I'm not writing it all at once — I'm building it up one block at a time so I understand every piece before I connect it to the next one.

I picked an async FIFO specifically because it forces me to deal with the stuff that actually matters in real digital design: registers and sequential logic, clock domain crossing, metastability, and verifying a design in simulation before it would ever touch real hardware. It's also a real block used in actual chips (UARTs, video pipelines, anywhere two clock domains have to talk to each other), not just a toy exercise.

---

## Where I'm At

I'm working through this incrementally, from the smallest logic block up to the full FIFO:

- [x] **Block 1: D Flip-Flop with Synchronous Reset**
  - The basic 1-bit memory element (`d_flip_flop.sv`).
  - Testbench (`testbench_d_flip_flop.sv`) with clock generation and stimulus.
  - Confirmed it triggers correctly on the rising clock edge by checking the VCD waveform.
- [x] **Block 2: 2-Stage Flip-Flop Synchronizer**
  - Two `d_flip_flop` blocks chained together (`synchronizer_2ff.sv`) to safely bring a signal from one clock domain into another.
  - Testbench (`testbench_synchronizer_2ff.sv`) drives the input off the clock edge to mimic a real asynchronous signal.
- [ ] **Block 3: Dual-Port RAM Array & Gray-Code Converters**
  - Binary-to-Gray pointer translation so pointers only ever change one bit at a time.
- [ ] **Block 4: Top-Level Asynchronous FIFO & Self-Checking Testbench**
  - Full/Empty flag logic and a randomized verification suite.

Blocks 1 and 2 work and are simulated. Block 3 is next.

---

## Toolchain

- **Language:** SystemVerilog (IEEE 1800-2012)
- **Simulator:** Icarus Verilog (`iverilog` to compile, `vvp` to run)
- **Waveform viewer:** VS Code WaveTrace extension / GTKWave (`.vcd` files)

No paid tools, no vendor license needed — everything here runs free and open source.

---

## Running Simulations

### Block 1: D Flip-Flop

1. Compile the design and testbench:
   ```bash
   iverilog -g2012 -o sim.out d_flip_flop.sv testbench_d_flip_flop.sv
   ```
2. Run it:
   ```bash
   vvp sim.out
   ```
3. Open `wave.vcd` in GTKWave (or WaveTrace) to look at the waveform.

### Block 2: 2-Stage Synchronizer

1. Compile the design and testbench:
   ```bash
   iverilog -g2012 -o sim.out d_flip_flop.sv synchronizer_2ff.sv testbench_synchronizer_2ff.sv
   ```
2. Run it:
   ```bash
   vvp sim.out
   ```
3. Open `wave_synchronizer.vcd` and check that `sync_out` follows `async_in`, just delayed by two clock edges instead of reacting right away.

---

## What's Involved, and Why

**Sequential vs. combinational logic** — everything I've built so far is sequential: outputs only change on the rising edge of `clk`, which means the circuit has memory instead of just reacting instantly. This is the base unit that every synchronous digital system is made of, all the way up to a CPU.

**D flip-flop (Block 1)** — the smallest piece of memory in this project. On every rising clock edge it copies `d` to `q`, and a synchronous reset can force `q` back to 0. Every other block I build is made out of this one.

**Clock domain crossing (CDC)** — this is the actual problem the whole FIFO exists to solve. Any time a signal moves from logic running on one clock into logic running on a different, unrelated clock, there's a risk: if you happen to sample the signal the instant it's changing, the receiving flip-flop can go metastable — it doesn't settle cleanly to a 0 or a 1 for an unpredictable amount of time, and that bad value can leak into the rest of the circuit. An async FIFO has exactly this problem, since the write side and read side run on separate clocks.

**2-stage synchronizer (Block 2)** — the standard fix for CDC. Instead of sampling the incoming signal with one flip-flop, I pass it through two in series. The first one absorbs the metastability and gets a full clock period to settle before the second one samples it. By the time the signal reaches `sync_out`, it's had two clock edges to resolve to a clean value.

**Where this is going** — Block 3 adds the actual memory array (dual-port RAM) plus binary-to-Gray code conversion for the read/write pointers, so that when those pointers cross clock domains through the synchronizer, at most one bit changes at a time. Block 4 connects everything into the full FIFO, with full/empty flag logic and a testbench that checks itself instead of me eyeballing waveforms.
