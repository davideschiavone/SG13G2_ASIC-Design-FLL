<!-- SPDX-FileCopyrightText: 2026 Davide Schiavone -->
<!-- SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1 -->

# 4-bit current-steering DAC layout — design log

Living document. Records every layout decision for the 4-bit binary-weighted
current-steering DAC (`dac4`, ports `VDD VSS b0 b1 b2 b3 iout`), from schematic to a
DRC/LVS-clean, PEX-verified GDS on **ihp-sg13g2**.

The schematic ([schematic/xschem/dac4.sch](schematic/xschem/dac4.sch)) and the SPICE subckt
([spice/dac4.spice](spice/dac4.spice)) are the **golden reference**; LVS compares the
layout against them.

---

## 1. Layout approach: **scripted (Magic TCL), generated from Python**

Same decision and rationale as the ring oscillator — see
[../ring_oscillator/RING_OSCILLATOR_LAYOUT.md](../ring_oscillator/RING_OSCILLATOR_LAYOUT.md)
§1 for the validated toolchain (Magic `gencell_makecell` device factory, `getcell … parent
x y` placement, painted routing, headless LVS/DRC/PEX) and the units/geometry notes.

The DAC is **even more matching-critical** than the RO: it is a set of binary-weighted
current sources (1×/2×/4×/8×) whose ratio accuracy *is* the DAC's linearity. Scripted
layout lets us build all weights from a single **unit current-source cell** replicated
1/2/4/8 times (common-centroid / interdigitated where it helps), which is the standard way
to get good current matching and exactly what hand layout makes tedious and error-prone.

### DAC-specific building blocks (from [spice/dac4.spice](spice/dac4.spice))
- `dac_inv` — a small complement inverter per bit (b → b̄), wp=1µ wn=0.5µ l=0.13µ.
- `dac_steer` — one binary-weighted steering cell: a PMOS current source (`m` units of a
  unit device wps=2µ lps=1µ) plus an NMOS steering pair (to `iout` / to `ndump`). Built
  with multiplier `mw` = 1/2/4/8 so all weights share the **same unit device**.
- reference mirror (`Mpref`, ideal `IREF`=2µA), shared dump diode (`Mdump`).

## 2. Generator & flow — DONE (DRC + LVS clean)

Built by the shared [scripts/genlayout.py](../../scripts/genlayout.py) router driven by
[scripts/gen_dac_layout.py](scripts/gen_dac_layout.py); same Makefile targets as the RO
(`make verify CELL=dac4`). Result: Magic DRC clean + netgen **"Circuits match uniquely"**
vs [spice/dac4_lay.spice](spice/dac4_lay.spice).

```
make verify CELL=dac4   # gen-layout + magic-drc + lvs
```

## 3. Two design realities that shaped the layout/LVS

1. **The ideal reference current source is not silicon.** `dac4.spice` drives the mirror
   node `vpcs` from an ideal `Iref`. A layout can't contain that, so the DAC macro exposes
   **`vpcs` as a bias pin** (a testbench / the future on-chip reference drives it). The LVS
   reference [spice/dac4_lay.spice](spice/dac4_lay.spice) is `dac4.spice` minus `Iref`,
   with `vpcs` added to the port list. Macro ports: `VDD VSS b0 b1 b2 b3 iout vpcs`.
2. **Binary weights = replicated UNIT devices, not `m={mw}`.** The gencell `m` multiplier
   only arrays *unconnected* fingers (verified: an m=2 device extracts as two separate
   transistors with `D0/D1`…). So each weight is built from `mw` identical unit devices
   (source pmos 2/1, steering nmos 1/0.13). netgen merges parallel devices by **summing
   width**, so the LVS reference must *also* use explicit units (an `m={mw}` reference
   mismatches on `w`: layout `w=8u` vs schematic `w=2u`). `dac4_lay.spice` therefore lists
   the units explicitly. Same transistors, same currents — and now both sides merge
   identically and LVS matches.

## 4. Floorplan & matching

Flat row, **current sources grouped together on the left** (`Mpref` + all 15 unit source
PMOS adjacent → best ratio matching for the binary weights), then the steering switch
NMOS, the 4 bit inverters, and the dump diode. All nets route on M3 tracks above the row
(`vpcs`, `iout`, `ndump`, per-bit `cs0..3`, `b0..3`, `b0b..3b`) with `VDD`/`VSS` rails
below. **No metal5.**

Honest notes: (a) like the RO this flat one-row floorplan is correct but **wide and not
compact**; if PEX fails ±1% the fix is a compact common-centroid current-source array.
(b) Real DAC matching (gradients, common-centroid, dummies) is a v2 concern — nominal PEX
(§5) has no device mismatch, so it tests parasitics, not matching.

## 5. PEX results vs schematic — PASS (≪ ±1%)

Full-RC extraction from the `.mag` ([scripts/mag_extract_pex.tcl](../../scripts/mag_extract_pex.tcl),
417 R + 350 C) → [testbenches/spice/tb_dac4_pex.spice](testbenches/spice/tb_dac4_pex.spice)
drives `vpcs` with the ideal 2 µA and sweeps code 0→15. Compared to the schematic golden
(`make sim`):

| code | golden I_out (µA) | PEX I_out (µA) | Δ |
| ---: | ---: | ---: | ---: |
| 1  | 2.0743  | 2.0742  | <0.01% |
| 3  | 6.2055  | 6.1997  | 0.094% (worst) |
| 7  | 14.4321 | 14.4321 | <0.01% |
| 8  | 16.4830 | 16.4829 | <0.01% |
| 15 | 30.7852 | 30.7851 | <0.01% |

All codes agree to **well within ±1%** (worst case 0.094%). The current-steering DAC is
robust to layout parasitics at DC — the parasitic R on `iout`/`vpcs`/rails barely
perturbs the steered currents — so **no compensation elements were needed** and the wide
flat floorplan is acceptable for this macro.

Reproduce: `make magic-pex CELL=dac4` (GDS, sak-pex) or the `.mag` flow above, then
`ngspice -b tb_dac4_pex.spice`.

## 6. Compensation elements added (with schematic update)

None required — PEX already meets ±1% (§5). No schematic change.

## 6. Compensation elements added (with schematic update)
_(to be filled)_
