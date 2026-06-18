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

## 2. Floorplan
_(to be filled — unit current-source array + steering switches + bit inverters + mirror)_

## 3. Device placement & matching decisions
_(to be filled — unit-cell replication, common-centroid, dummy devices)_

## 4. DRC / LVS iterations and fixes
_(to be filled)_

## 5. PEX results vs schematic (±1% check on I_out/LSB)
_(to be filled)_

## 6. Compensation elements added (with schematic update)
_(to be filled)_
