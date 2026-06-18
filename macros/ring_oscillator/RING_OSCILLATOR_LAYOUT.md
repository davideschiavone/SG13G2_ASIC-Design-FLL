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

## 2. Generator & flow

Layout is produced by [scripts/genlayout.py](../../scripts/genlayout.py) (a small
Python→Magic-TCL helper: device table, edge-to-edge row placement, M3/M4 over-the-cell
router, port labelling) driven per-cell by
[scripts/gen_ro_layout.py](scripts/gen_ro_layout.py). The Makefile wires it up:

```
make gen-layout CELL=cs_stage     # python generator -> Magic -> layout/cs_stage.{mag,gds}
make magic-drc  CELL=cs_stage     # sak-drc.sh
make lvs        CELL=cs_stage     # extract from .mag (ports preserved) + netgen vs spice/
make verify     CELL=cs_stage     # all three
```

**Why LVS extracts from `.mag`, not `.gds`:** a GDS round-trip drops Magic's port flags,
so single-terminal port nets (the `vbp`/`vbn` bias inputs) extract as floating "no
connects" and netgen can't match them. Extracting straight from the `.mag`
([scripts/mag_extract_lvs.tcl](../../scripts/mag_extract_lvs.tcl)) keeps the ports. The
generator runs `writeall force` so the device subcells are on disk for `.mag` extraction.

## 3. `cs_stage` leaf cell — DONE (DRC + LVS clean)

The matched leaf: one current-starved inverter stage, 4 FETs in a row
(`Mcp` p 2/0.5 · `Mp` p 1/0.13 · `Mn` n 0.5/0.13 · `Mcn` n 1/0.5), each generated with a
**guard ring** (`guard 1`) so it carries its own nwell/psub tap (`B` port) — robust for
DRC and LVS at the cost of area. Devices are placed **edge-to-edge with a 0.7 µm gap**
between full bboxes (the guarded device extent is up to 2.82 µm wide — far larger than the
diffusion). All signals route up from each terminal through an M1→M2→M3→M4 via stack;
nets then run on **M3 horizontal tracks** (one per net) with **M4 vertical jogs** above the
row, and the `VDD`/`VSS` rails run on M3 tracks below the row (the guard `B` ports are at
the bottom). Every terminal's x is distinct, so jogs never collide. **No metal5.**

Result: `make verify CELL=cs_stage` → Magic DRC clean, KLayout DRC clean (via-stack +
M3 verified in both), netgen **"Circuits match uniquely"** vs
[spice/cs_stage.spice](spice/cs_stage.spice).

## 4. DRC / LVS iterations and fixes (what bit us, and the fix)

1. **`getcell` placement units.** `getcell <dev> child 0 0 parent <x> <y>` takes the
   parent ref-point in **internal units (200/µm)**, while painting uses microns. Passing
   lambda (100/µm) placed every device at half-position — paint and devices diverged and
   everything shorted. Fix: `UM_TO_IU = 200`.
2. **Device overlap.** First pitch (2.6 µm) was smaller than the guarded device extent →
   nwells/diffusions merged → giant short to substrate. Fix: place by real full-bbox
   half-widths + gap (`place_row`).
3. **Cell named after the path.** `save layout/cs_stage` made the *cell* "layout/cs_stage";
   extraction's `load cs_stage` then failed. Fix: run Magic with cwd=`layout/`, save bare
   name.
4. **Ports lost.** `label <net> <layer>` needs a position arg (`label <net> center
   <layer>`); ports are made with `port make <i>` on the single label under the cursor box.
   And LVS must extract from `.mag` (see §2), else ports vanish.

## 5. PEX results vs schematic (±1% check)
_(to be filled)_

## 6. Compensation elements added (with schematic update)
_(to be filled)_
