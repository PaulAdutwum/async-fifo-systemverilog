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
- [x] **Block 3: Dual-Port RAM Array & Gray-Code Converters**
  - Parameterized binary-to-Gray counter (`gray_counter.sv`) — this is what the FIFO's read/write pointers will actually be.
  - Dual-clock, dual-port memory array (`dual_port_ram.sv`) — the actual FIFO storage, independent write and read clocks.
  - Testbenches for both (`testbench_gray_counter.sv`, `testbench_dual_port_ram.sv`), each with self-checking pass/fail output instead of just printing waveforms.
- [ ] **Block 4: Top-Level Asynchronous FIFO & Self-Checking Testbench**
  - Full/Empty flag logic and a randomized verification suite.

Blocks 1 through 3 work and are simulated. Block 4 — wiring all of this into the actual FIFO — is next.

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

### Block 3: Gray-Code Counter

1. Compile the design and testbench:
   ```bash
   iverilog -g2012 -o sim.out gray_counter.sv testbench_gray_counter.sv
   ```
2. Run it:
   ```bash
   vvp sim.out
   ```
3. It prints the binary and Gray value every cycle and checks that Gray only ever changes by one bit. Open `wave_gray_counter.vcd` to see it visually.

### Block 3: Dual-Port RAM

1. Compile the design and testbench:
   ```bash
   iverilog -g2012 -o sim.out dual_port_ram.sv testbench_dual_port_ram.sv
   ```
2. Run it:
   ```bash
   vvp sim.out
   ```
3. It writes 16 values in on `wclk`, reads them all back on the independent `rclk`, and reports pass/fail for each address. Open `wave_dual_port_ram.vcd` to watch the two clocks run at different rates.

---

## What's Involved, and Why

**Sequential vs. combinational logic** — everything I've built so far is sequential: outputs only change on the rising edge of `clk`, which means the circuit has memory instead of just reacting instantly. This is the base unit that every synchronous digital system is made of, all the way up to a CPU.

**D flip-flop (Block 1)** — the smallest piece of memory in this project. On every rising clock edge it copies `d` to `q`, and a synchronous reset can force `q` back to 0. Every other block I build is made out of this one.

**Clock domain crossing (CDC)** — this is the actual problem the whole FIFO exists to solve. Any time a signal moves from logic running on one clock into logic running on a different, unrelated clock, there's a risk: if you happen to sample the signal the instant it's changing, the receiving flip-flop can go metastable — it doesn't settle cleanly to a 0 or a 1 for an unpredictable amount of time, and that bad value can leak into the rest of the circuit. An async FIFO has exactly this problem, since the write side and read side run on separate clocks.

**2-stage synchronizer (Block 2)** — the standard fix for CDC. Instead of sampling the incoming signal with one flip-flop, I pass it through two in series. The first one absorbs the metastability and gets a full clock period to settle before the second one samples it. By the time the signal reaches `sync_out`, it's had two clock edges to resolve to a clean value.

**Gray-code counter (Block 3)** — a normal binary counter can flip several bits at once when it increments (0111 -> 1000 changes all 4 bits). If a synchronizer catches that mid-transition, it can land on a completely wrong number, not just a slightly-off one. Gray code guarantees only one bit ever changes per count, so a synchronizer catching it mid-transition still lands on either the old value or the new value, never garbage in between. This is what the FIFO's read and write pointers will be built from in Block 4, so they can cross the synchronizer safely.

**Dual-port RAM (Block 3)** — the actual storage for the FIFO. One port writes on `wclk`, the other reads on `rclk`, and the two clocks don't need any relationship to each other at all — that's what makes this genuinely "asynchronous" instead of just "two clocks that happen to be related." I tested it with a 4ns write clock and a 7ns read clock on purpose, since they don't share a nice common multiple, so the two sides actually drift against each other the way two independent oscillators would on real hardware.

**Where this is going** — Block 4 connects the synchronizer, gray counter, and RAM into the actual FIFO: a write pointer and read pointer (both Gray-coded), each one synchronized into the other clock domain to generate full/empty flags, plus a self-checking testbench instead of me eyeballing waveforms.

---

## Bugs I Ran Into Building This

Worth writing down since I'll hit these again:

- **Reading a signal right after `@(posedge clk)` can give you the old value.** The flip-flop's output updates via a non-blocking assignment (`<=`), which is scheduled to happen *after* the current simulation time step settles. If a testbench does `@(posedge clk); $display(...)` on the same edge, it can read the value from *before* the edge instead of after it. Fixed it by adding a tiny `#1` delay after the `@(posedge clk)` before reading anything.
- **A loop counter has to be wide enough for the range it counts through.** In the RAM testbench I had a 4-bit `raddr` looping `while (raddr < 16)` — but 4 bits can only hold 0-15, so `raddr` never actually reaches 16, it just wraps back to 0 forever. Infinite loop, simulation hangs. Fixed it by using a separate wide `integer` for the loop count and only truncating it down to the address width when I actually drive the port.
- **This build of Icarus Verilog doesn't support `assert property` / SVA at all** (not even the simplest case), and `$countones()` gave wrong answers when called inside a `$display` argument list. Ended up writing both checks (single-bit Gray transitions, RAM read-back) as plain `if` statements instead of assertions or system functions — less elegant, but it actually runs correctly on this toolchain.
