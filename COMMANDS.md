# FLL — command cheat-sheet

All EDA tools run **inside the IIC-OSIC-TOOLS container** via the `./run.sh` wrapper
(from the repo root). GUI tools render on the **noVNC desktop** — open it in a browser:

> **http://localhost/?password=abc123**  (Xvnc display `:1`)

`./run.sh "<cmd>"` runs `<cmd>` in the container at the project root. Most Make targets
below take the form `./run.sh "make -C <dir> <target>"`; every Makefile has `make help`.

Quick map of what lives where:

| Block | Dir | Kind |
| --- | --- | --- |
| Digital controller | `macros/fll_digital/` | SystemVerilog (open-loop DCO controller) |
| Ring oscillator | `macros/ring_oscillator/` | analog SPICE + behavioral Verilog model |
| 4-bit DAC | `macros/dac/` | analog SPICE |
| Mixed-signal co-sim | `mixed_signal/` | RTL (Verilator/d_cosim) + analog SPICE |

---

## 1. Digital — `fll_digital` (RTL)

```bash
# Lint (Verilator)
./run.sh "make -C macros/fll_digital lint-verilog"

# RTL simulation with cocotb (Icarus)
./run.sh "make -C macros/fll_digital sim-rtl-cocotb"

# Verilator self-checking TB: fll_digital + behavioral ring oscillator (Flow B)
./run.sh "make -C macros/fll_digital sim-rtl-verilator"

# View the Verilator TB waveform (FST) in GTKWave (noVNC :1)
./run.sh "make -C macros/fll_digital sim-view-verilator"
```

---

## 2. Analog — ring oscillator (`macros/ring_oscillator/`)

```bash
# Frequency vs ideal bias-current sweep (ngspice batch -> table)
./run.sh "make -C macros/ring_oscillator sim"

# Combined DAC + RO: code -> frequency sweep (table)
./run.sh "make -C macros/ring_oscillator sim-dacro"

# Plot the RO transient v(clk)/v(nbias) in ngspice (GUI on noVNC :1)
./run.sh "make -C macros/ring_oscillator sim-wave"

# Plot the combined DAC+RO transient at a fixed code (GUI)
./run.sh "make -C macros/ring_oscillator sim-wave-dacro"

# Open the schematic in Xschem (GUI on noVNC :1)
./run.sh "make -C macros/ring_oscillator xschem"
```
*Characterized (steady-state, 1.5 V): 2 µA→69, 8 µA→278, 16 µA→550, 31 µA→775 MHz.*

---

## 3. Analog — 4-bit DAC (`macros/dac/`)

```bash
# code -> output-current DC characterization (ngspice batch -> table)
./run.sh "make -C macros/dac sim"

# Plot the transfer (I_out vs code) in ngspice (GUI on noVNC :1)
./run.sh "make -C macros/dac sim-wave"

# Open the schematic in Xschem (GUI on noVNC :1)
./run.sh "make -C macros/dac xschem"
```
*Monotonic, ~2.05 µA/LSB; code 15 → 30.8 µA.*

---

## 4. Mixed-signal co-simulation (`mixed_signal/`)

Flow A: `fll_digital` RTL is compiled by **Verilator** into a shared lib loaded by
ngspice's **`d_cosim`** model, co-simulated with the **real transistor** DAC + RO.

```bash
# 1) Build the cosim shared library (Verilator -> fll_digital.so)   [run once]
./run.sh "make -C mixed_signal build"

# 2) Cosim sanity check (no analog): dac_code_o tracks code_i
./run.sh "make -C mixed_signal sanity"

# 3) Full mixed-signal run: fll_digital + real DAC + real RO  (writes ASCII raw)
./run.sh "make -C mixed_signal sim"

# build + sim + open GTKWave, in one go
./run.sh "make -C mixed_signal all"
```
*Verified: code=8 → RO ≈ 604 MHz (matches the all-SPICE result). The transistor RO+DAC
are slow (PSP models) — the full run takes a few minutes.*

### Viewing the mixed-signal waveforms

```bash
# A) ngspice NATIVE plotter (no VCD) — opens the last raw on noVNC :1; type 'quit' to exit
./run.sh "make -C mixed_signal plot"

# B) GTKWave — converts the raw to VCD (raw2vcd.py) and opens it on noVNC :1
./run.sh "make -C mixed_signal wave"

# (just the raw -> VCD conversion, no viewer)
./run.sh "make -C mixed_signal vcd"
```

---

## Waveform viewers — quick reference

| You have | Viewer | Command |
| --- | --- | --- |
| Verilator FST (digital) | GTKWave | `make -C macros/fll_digital sim-view-verilator` |
| ngspice raw (analog/mixed) | ngspice plot | `make -C mixed_signal plot` |
| ngspice raw → VCD (mixed) | GTKWave | `make -C mixed_signal wave` |
| ngspice transient (analog) | ngspice plot | `make -C macros/<ro\|dac> sim-wave` |

Notes:
- `ngspice -b` (batch) **disables** plotting; the `sim-wave`/`plot` targets run ngspice
  *interactively* with `DISPLAY=:1` so plot windows appear on noVNC. Type `quit` to exit.
- GTKWave can't read ngspice rawfiles directly — `mixed_signal/raw2vcd.py` converts them
  to a VCD (nodes become `real` vars, shown as analog traces).
- The testbenches `set filetype=ascii` so their rawfiles are convertible to VCD.

See [`mixed_signal/README.md`](mixed_signal/README.md) and each macro's `README.md` for
details, and [`CLAUDE.md`](CLAUDE.md) for the project overview and v1 spec.
