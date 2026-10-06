# Asynchronous FIFO with Gray-Code Pointers and 2-Flop Synchronizers (Verilog)

A parameterized **asynchronous (dual-clock) FIFO** in Verilog that safely moves data between two unrelated clock domains using **Gray-coded pointers** and **two-flip-flop synchronizers**.

## Basic Idea: CDC and the Async FIFO

When a design has two parts running on **different, unrelated clocks**, passing data between them is called **Clock Domain Crossing (CDC)**. Sending a multi-bit value directly is unsafe: the receiving clock may sample it while several bits are changing, and read a wrong value (and a flip-flop caught mid-change can go metastable).

An **asynchronous FIFO** solves this for data streams. The writer pushes data in on its clock (`wclk`), the reader pulls data out on its clock (`rclk`), and a memory sits in between. To know whether the FIFO is **full** or **empty**, each side needs the other side's pointer, so the pointers are the only things that cross clock domains. They are crossed safely by using **Gray code** (only one bit changes per step) and **two-flop synchronizers** (so metastability can settle).

## Earlier Design and Its Limitations

I had already built a CDC async FIFO earlier, but it had these flaws:

- **No Gray-code pointer representation:** binary read/write pointers were not converted to Gray code before crossing clock domains, increasing the possibility of unsafe multi-bit transitions during CDC.
- **Unsafe clock-domain crossing:** read and write pointers were not properly synchronized between the two independent clock domains using multi-flop synchronizers.
- **No robust full/empty detection:** full and empty conditions were not derived using synchronized Gray-coded pointers, which can lead to incorrect status indications.
- **Limited protection against overflow and underflow:** the design did not provide a robust mechanism to prevent writes when the FIFO was full or reads when the FIFO was empty.

**How this project fixes them:** pointers are converted to Gray code and pass through 2-flop synchronizers (`sync_r2w`, `sync_w2r`) before use in the other domain. Full and empty are computed from these synchronized Gray pointers, with an extra pointer bit to tell full from empty. Writes are blocked when `wfull` is high and reads when `rempty` is high, so the FIFO cannot overflow or underflow.

Earlier design: [link to my previous async FIFO repo]

## Architecture

![Async FIFO architecture](images/architecture.png)

| Module | Clock domain | Job |
|---|---|---|
| `fifo_top` | none | Top-level wrapper. Only connects the other modules. |
| `fifomem` | writes on `wclk`, reads combinationally | Dual-port memory. Writes when `winc && !wfull`. |
| `wptr_full` | `wclk` | Binary write counter, Gray write pointer, `wfull` flag. |
| `rptr_empty` | `rclk` | Binary read counter, Gray read pointer, `rempty` flag. |
| `sync_r2w` | `wclk` | 2-flop synchronizer: read pointer into the write domain. |
| `sync_w2r` | `rclk` | 2-flop synchronizer: write pointer into the read domain. |

**Flag logic:**
- **Empty:** the next read pointer equals the synchronized write pointer.
- **Full:** the next write pointer equals the synchronized read pointer with its top two bits inverted (the writer is exactly one lap ahead).
- The synchronized pointers are a little out of date, which is safe: a flag may stay asserted slightly longer than necessary, but is never released too early.



## Use of AI

**AI Assistance:** AI tools were used for debugging and resolving simulation-related issues, particularly Questa/ModelSim `.do` file command-line and waveform-access errors, and for formatting and alignment of this README. The design follows Cummings' asynchronous FIFO architecture, and I studied each module to understand how it works.

## References

- Clifford E. Cummings, *Simulation and Synthesis Techniques for Asynchronous FIFO Design*, SNUG 2002