<!-- SPDX-FileCopyrightText: 2026 Davide Schiavone -->
<!-- SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1 -->

# Ring-oscillator layout — design log

Living document. Records every layout decision for the current-starved 5-stage ring
oscillator (`ring_oscillator`, ports `VDD VSS ibias clk`), from schematic to a
DRC/LVS-clean, PEX-verified GDS on **ihp-sg13g2**.

The schematic ([schematic/xschem/ring_oscillator.sch](schematic/xschem/ring_oscillator.sch))
and the SPICE subckt ([spice/ring_oscillator.spice](spice/ring_oscillator.spice)) are the
**golden reference**; LVS compares the layout against them and they stay the SPICE
simulation source of truth.

---

## 1. Layout approach: **scripted (Magic TCL), generated from Python**

Decision (confirmed with the owner): produce the layout **by script**, not by hand in the
GUI. This mirrors how the schematics were produced ([scripts/gen_xschem.py](../../scripts/gen_xschem.py)),
fits the project's headless-first working style, and makes the layout **reproducible and
git-diffable** (a generator script instead of an opaque hand-drawn `.gds`). The RO is a
**regular, matching-sensitive array** (5 identical starved stages + a bias cell + a
2-stage output buffer) — exactly the case where scripted placement guarantees matched,
abutted devices better than hand drawing.

GUI (Magic/KLayout on the noVNC desktop) is kept only as a **fallback** for inspecting a
stubborn DRC violation; the generate → LVS → DRC → PEX loop is driven headless.

### Why this is feasible here (validated, not assumed)
I probed the PDK and proved the full toolchain headless before committing to it:

- **Device factory — Magic gencells.** The PDK ships parametric device generators
  (`sg13g2::sg13_lv_nmos` / `sg13_lv_pmos` in `ihp-sg13g2-fet.tcl`). Headless, the working
  call is:
  ```tcl
  set dev [magic::gencell_makecell sg13g2::sg13_lv_nmos w 1.0 l 0.13 ng 1 m 1]
  ```
  `gencell_makecell` creates a DRC-clean device **cell** (with diffusion/gate contacts and
  full metal1/metal2 access) and returns its name — without the interactive instance
  placement that breaks under `-dnull`.
- **Placement — `getcell` with an explicit ref-point.** The interactive form relies on the
  cursor/box and fails in batch ("the box is in cell … not in the edit cell"). The robust
  form takes explicit coordinates and sidesteps the box entirely:
  ```tcl
  getcell $dev child 0 0 parent <x> <y>   ;# child's (0,0) lands at parent (x,y)
  ```
- **Routing — painted rectangles** (`box <llx> <lly> <urx> <ury> ; paint <layer>`) and
  labels (`label <name> <layer>`) in Magic's native layer names.
- **Verification — already headless** via the inverter Makefile pattern: Magic+Netgen LVS
  (`sak-lvs.sh`), Magic DRC (`sak-drc.sh`), KLayout DRC/LVS (`run_drc.py`/`run_lvs.py`),
  PEX (`sak-pex.sh` / `kpex`).
- **KLayout PCells are NOT shipped** in this PDK (only `autorun.lym`), so KLayout is
  used for verification only, not device generation. Magic is the generation engine.

A throwaway test generated a sized NMOS, placed two instances at explicit coordinates, and
came back **DRC-clean** — confirming the approach end-to-end.

### Units and device geometry (from a probed `sg13_lv_nmos`, w=1.0 l=0.13)
- **1 Magic internal unit = 5 nm**, i.e. **200 internal units = 1 µm** (`magscale 1 2`).
  In scripts I use the `um` suffix (`box 0 0 1um 0.5um`) to stay in microns.
- Single-finger FET geometry: vertical **poly gate** (length in x), **drain on the left**
  (ndiff contact `ndiffc`), **source on the right**, poly contacts top & bottom of the gate.
  Terminal ports the gencell labels: `D` (ndiffc, left), `S` (ndiffc, right), `G`
  (polycont, gate). These are the routing connection points.

---

## 2. Floorplan
_(to be filled as the layout is built — leaf `cs_stage`, then the 5-stage chain + bias + buffer)_

## 3. Device placement & matching decisions
_(to be filled)_

## 4. DRC / LVS iterations and fixes
_(to be filled)_

## 5. PEX results vs schematic (±1% check)
_(to be filled)_

## 6. Compensation elements added (with schematic update)
_(to be filled)_
