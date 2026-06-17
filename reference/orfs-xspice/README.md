# ORFS `.xspice` co-simulation — reference snapshot

This folder is a **reference artifact**, not part of the active build flow.

It preserves the `.xspice` gate-level co-simulation methodology from the repository's
previous scaffold: JKU's ORFS-based **SG13G2_ASIC-Design-Template** by Simon Dorrer
(Institute for Integrated Circuits and Quantum Computing, JKU Linz).

On 2026-06-17 this repo migrated from that ORFS template to the LibreLane-based
**ihp-sg13g2-ams-chip-template** (see top-level `CLAUDE.md`). The full ORFS scaffold
was removed from the working tree; it remains recoverable from this repo's git
history and from the public upstream template.

## What's here
- `verilog2xspice.sh` — drives the qflow chain `vlog2Verilog` → `vlog2Spice` →
  `spi2xspice.py` to turn a synthesized gate-level Verilog netlist into a `.xspice`
  event-driven model.
- `spi2xspice.py` — qflow helper: SPICE + liberty → `.xspice`.
- `counter_board/` — example outputs (`.vp`, `.spice`, `.xspice`) for the 4-bit
  counter, showing the `.subckt` + pin-order convention an Xschem testbench expects.

## Why keep it
The LibreLane AMS template already does gate-level mixed-signal sim via its own
`sim-gl-xschem` Make target. This snapshot is retained only as a worked reference for
the qflow `.xspice` conversion approach, in case it's useful for the FLL controller's
gate-level mixed-signal verification.
