# `ring_oscillator` macro (analog — to be designed)

This will hold the FLL's analog **current-starved ring oscillator**: a 5-stage ring
whose frequency is set by a bias current supplied by the 4-bit current-steering DAC
(`dac_code` from [`../fll_digital`](../fll_digital)). Schematic (Xschem), layout, and
DRC/LVS/PEX will follow the `macros/inverter` pattern.

## What's here now
- `model/ring_oscillator_verilog_behavioral.sv` — a **simulation-only, pure-Verilog**
  behavioral model. It maps the control code directly to an output clock frequency
  (folding in an idealised DAC response), so the open-loop datapath
  (`fll_digital` + RO) can be co-simulated before any transistors exist. It is
  unsynthesizable and guarded by `` `ifndef SYNTHESIS ``. It is used by the Verilator
  testbench at
  [`../fll_digital/testbenches/verilator/`](../fll_digital/testbenches/verilator/).

The behavioral model is the first rung of the analog ladder: it will be superseded by
a Verilog-A model and then the transistor-level RO + DAC in later steps.
