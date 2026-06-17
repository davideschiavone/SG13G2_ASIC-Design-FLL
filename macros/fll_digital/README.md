# `fll_digital` macro — FLL v1 digital core (open-loop DCO controller)

The digital macro of the FLL test chip. **v1 is open-loop** (no frequency counter,
no servo, no lock detect — see [`../../CLAUDE.md`](../../CLAUDE.md)). It:

1. **Registers a DAC control word** from `code_i` (in the `clock_i` domain). The word
   `dac_code_o` drives the analog 4-bit current-steering DAC, which sets the bias
   current of the current-starved ring oscillator.
2. **Divides the ring-oscillator clock** `ro_clk_i` by 1024 to produce `fout_o`, a slow
   frequency-monitor output for an LED / oscilloscope.

The two clock domains (`clock_i`, `ro_clk_i`) exchange no data, so there is no data CDC.

## Interface (`fll_digital_top` — the hardened unit)
| Port | Dir | Width | Description |
| --- | --- | --- | --- |
| `clock_i` | in | 1 | system / reference clock |
| `reset_n_i` | in | 1 | active-low reset |
| `code_i` | in | `DAC_W` (4) | user frequency control code |
| `ro_clk_i` | in | 1 | ring-oscillator output (clock from the analog RO) |
| `dac_code_o` | out | `DAC_W` (4) | DAC control word (to the analog DAC macro) |
| `fout_o` | out | 1 | `ro_clk_i` / 1024 frequency monitor |

Parameters live in [`rtl/constants.sv`](rtl/constants.sv): `FLL_DAC_W=4`,
`FLL_DIV_W=10` (÷1024), `FLL_DAC_RST=8`.

## Files
- `rtl/constants.sv` — shared `define constants.
- `rtl/fll_digital.sv` — open-loop core (DAC register + ÷1024 divider).
- `rtl/fll_digital_top.sv` — wrapper (active-low→active-high reset); hardened unit.
- `testbenches/cocotb/fll_digital_top_tb.py` — RTL/GL cocotb tests.

## Run (inside the IIC-OSIC-TOOLS container, via `../../run.sh`)
```
make lint-verilog       # Verilator lint
make sim-rtl-cocotb     # RTL cocotb tests (reset defaults, code pass-through, ÷1024)
```
LibreLane hardening config (`flow/librelane/`) is added at the hardening step; that
needs a second generated clock on `ro_clk_i` in the SDC.
