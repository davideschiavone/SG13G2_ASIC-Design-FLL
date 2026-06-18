# Mixed-signal co-simulation (fll_digital RTL + analog DAC/RO in ngspice)

**Flow A — SPICE testbench, ngspice as master.** The analog DAC + ring oscillator are
simulated as real transistors by ngspice; the `fll_digital` RTL is compiled by
**Verilator** into a shared library and loaded by ngspice's **`d_cosim`** XSPICE code
model. ngspice auto-inserts adc/dac bridges between the digital (event) ports and the
analog nodes. This is the flow shown in ngspice's bundled Xschem example
(`/foss/tools/xschem/share/doc/xschem/ngspice_verilog_cosim/`).

Why a SPICE testbench (not Verilog)? Only ngspice can simulate the real DAC/RO
transistors, so it must be the master. A Verilog-master TB would need *behavioral*
analog models instead (that's the separate "Flow B": the Verilator TB +
`ring_oscillator_verilog_behavioral`).

## Build + run
```
../run.sh "cd mixed_signal && ./build_cosim.sh"          # Verilog -> fll_digital.so
../run.sh "cd mixed_signal && ngspice -b tb_cosim_sanity.spice"   # cosim sanity (no analog)
../run.sh "cd mixed_signal && ngspice -b tb_mixed_dac_ro.spice"   # full mixed-signal
```

## Files
- `build_cosim.sh` — builds `fll_digital.so` for `d_cosim`. (Replicates ngspice's
  `vlnggen`; we run Verilator directly from bash because ngspice's `shell` lowercases
  Verilator's case-sensitive flags `-Mdir`/`--CFLAGS`.)
- `tb_cosim_sanity.spice` — loads `fll_digital` via `d_cosim`, drives clk/reset/code
  digitally, checks `dac_code_o` tracks `code_i` and the divider runs. (No transistors.)
- `tb_mixed_dac_ro.spice` — the real mixed-signal TB: `fll_digital` (cosim) ↔ DAC ↔ RO.

`d_cosim` port mapping for `fll_digital_top`:
`a1 [ clk reset_n ro_clk code3 code2 code1 code0 ] [ dac3 dac2 dac1 dac0 fout ] fll_digital`
(inputs then outputs, in Verilator's port order; buses MSB-first).
