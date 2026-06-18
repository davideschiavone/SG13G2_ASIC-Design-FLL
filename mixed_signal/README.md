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

## Build + run (Makefile; via `../run.sh "make -C mixed_signal <target>"`)
- `make build`  — Verilator-build `fll_digital.so` for `d_cosim`
- `make sanity` — cosim sanity check (no analog): `dac_code_o` tracks `code_i`
- `make sim`    — full mixed-signal cosim (writes an ASCII raw)
- `make vcd`    — convert the raw → VCD (`raw2vcd.py`)
- `make wave`   — convert + open the waveforms in **GTKWave** (on noVNC `:1`)
- `make all`    — build + sim + wave

## Viewing waveforms (GTKWave)
ngspice writes a SPICE rawfile, which GTKWave can't read. `raw2vcd.py` converts the
ASCII raw into a VCD whose nodes are `real` variables — GTKWave shows them as analog
traces (so `ro_clk`/`nbias` appear as analog and `dac_code`/`fout` as 0/1.5 steps).
The testbenches use `set filetype=ascii` so the raw is convertible. Open with:
```
../run.sh "make -C mixed_signal wave"        # converts + launches GTKWave on noVNC :1
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
