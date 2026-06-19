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

## 5. Full `ring_oscillator` — 2-ROW layout, DRC + LVS clean

Two floorplans were built (history in git):

1. **Flat (first cut):** 27 FETs in one row, every net on stacked parallel M3 tracks.
   DRC/LVS clean but PEX was **~20× too slow**. Per-node PEX extraction showed every ring
   node carried **~60 fF**, of which a measured **96 % was coupling capacitance to other
   nets' routing** (15–17 fF each to several neighbouring gate nets) — i.e. the dense
   parallel-track field, not wire length. Shortening tracks barely helped (~20 %).

2. **2-row (current):** PMOS over NMOS with the ring nodes routed as short, isolated wires
   in the **empty channel** between the rows (M2 trunks + M3 stubs, drains jogged into the
   inter-column gaps to clear the gates). Global DC nets are kept off the channel: `vbp`/
   `ibias` on M3 just above the gates, `VDD`/`VSS` on **wide low-R M4 straps** up top/bottom.
   This removes the parallel-track field: ring-node capacitance drops from ~60 fF to
   **< 8 fF (~8×)**. `make verify CELL=ring_oscillator` → Magic DRC clean + netgen
   **"Circuits match uniquely"** vs [spice/ring_oscillator.spice](spice/ring_oscillator.spice).

   Routing gotchas fixed along the way (all in [scripts/gen_ro_layout.py](scripts/gen_ro_layout.py)):
   the long `n5` feedback shorting M2 drain verticals (→ proper 2-layer channel routing,
   trunks M2 / stubs M3); the current-source **gate and bulk sit at the same device
   centre-x** (→ route gate on M3, bulk on M4 so the coincident verticals don't short);
   the NMOS bulk sitting next to the `ibias` track (→ move the track); and thin power
   routing leaving kΩ of series R (→ wide VDD/VSS straps).

## 6. PEX oscillation — ROOT CAUSE was two testbench bugs, NOT a design-margin defect

**Correction to an earlier conclusion.** A previous pass reported the extracted RO "does
not sustain oscillation … the v1 current-starved RO is a marginal oscillator." That was
**wrong**, and the wrong diagnosis came from two bugs in the *post-layout testbench*, not
from the silicon. With both fixed, **the extracted (full-RC) RO oscillates full-swing and
monotonically across the whole bias range, with enormous startup margin.** The v1 design
and the 2-row layout are kept unchanged (no device resize).

### Bug 1 (the real killer): scrambled supplies from a port-order mismatch
Magic's extractor emits the `.subckt` ports in the order the layout's `port make <i>`
labels were created, which was **`ibias VDD VSS clk`** — *not* the schematic subckt order
`VDD VSS ibias clk`. `tb_ring_oscillator_pex.spice` instantiates **positionally**
(`Xro VDD VSS nbias clk ring_oscillator`), so the circuit's `ibias` pin was tied to the VDD
net, its `VDD` pin to the VSS net, and its `VSS` pin to the bias node. With the supplies
scrambled the extracted RO is **dead** — and no startup kick can ever revive a circuit
whose VDD pin sits at ground. netgen LVS still passed because it matches ports **by name**,
not by position, so the mismatch was invisible to LVS.

**Fix:** the generator now pins the extracted port order to the schematic order via
`lo.port_order = ["VDD","VSS","ibias","clk"]` ([scripts/gen_ro_layout.py](scripts/gen_ro_layout.py)),
and both testbenches carry a comment that positional instantiation must match it. After
regen + re-extract, `.subckt ring_oscillator VDD VSS ibias clk` and the positional TB is
correct.

### Bug 2 (secondary): no startup symmetry-breaker for the *symmetric* schematic
SPICE has no thermal noise. A perfectly symmetric, noiseless ring started by a supply ramp
alone can sit at its mid-rail metastable point forever. This is why the **schematic** sweep
silently produced no result at the low-bias corner (2 µA). The **extracted** ring self-
starts even without a kick — its parasitics are slightly asymmetric (n5 ≈ 7 fF vs ≈ 3.5 fF
on the others), and that mismatch seeds the oscillation — but relying on that is fragile.

**Fix:** both testbenches now inject a tiny current kick on one ring node
(`Ikick VSS Xro.n1 PULSE(0 1u 0.25u 0.1n 0.1n 1n 1)`) as a thermal-noise stand-in. It is a
deliberate over-estimate of real noise: PEX startup was verified down to a **1 nA·2 ns
(~0.5 mV)** perturbation at the worst corner (2 µA) — i.e. >1000× of margin — so loop gain
is comfortably > 1 ([testbenches/spice/tb_ro_pex_margin.spice](testbenches/spice/tb_ro_pex_margin.spice)). On silicon, thermal noise plus power-up asymmetry start it with no
help; the kick exists only so the noiseless simulator leaves the metastable point.

### Result — robust, monotonic oscillation (full-RC PEX, mos_tt, VDD=1.5 V)

| I_bias | schematic f (`make sim`) | PEX full-RC f (`make sim-pex`) |
| ------ | ------------------------ | ------------------------------ |
| 2 µA   | 69.3 MHz   | 33.8 MHz |
| 4 µA   | 130.5 MHz  | 64.8 MHz |
| 8 µA   | 277.7 MHz  | 126.8 MHz |
| 16 µA  | 550.3 MHz  | 239.5 MHz |
| 31 µA  | 774.5 MHz  | 386.9 MHz |

(Both columns measured on the buffered `clk` output.) Full swing (Vpp ≈ 1.35–1.40 V) at
every bias; monotonic over a ~10× tuning range,
tens-to-hundreds of MHz — exactly the usable range targeted. The PEX frequency is ~2×
lower than the schematic because the extracted ring/internal nodes carry real interconnect
+ junction capacitance the ideal schematic lacks (f ∝ 1/C) — see §7. Reproduce:
`make pex CELL=ring_oscillator && make sim-pex` (and `make sim` for the schematic golden).

### Note on the old "8 fF on the internal pp/nn nodes"
Per-node PEX totals do show the internal starved-supply nodes (the inverter sources
`Mp/S`=pp, `Mn/S`=nn) carrying ~8 fF each — more than the ring nodes (~3.5 fF) — because the
long-L (0.5 µm), wide current-source devices have large junction area. That loading lowers
the frequency but does **not** stop oscillation: a margin deck that hangs the full PEX node
loads (8 fF on pp/nn, 4/7 fF on the ring) as lumped caps on the ideal devices still
oscillates full-swing across 2→31 µA ([testbenches/spice/tb_ro_explore.spice](testbenches/spice/tb_ro_explore.spice)).
The loop gain was never the problem.

## 7. Why ±1 % (PEX vs schematic) is dropped for the RO

An oscillator's frequency is set by node capacitance (**f ∝ 1/C**). The schematic reference
has **zero** interconnect capacitance, so any real layout shifts f by **far more than 1 %**
— here the full-RC PEX runs ~2× below the schematic, dominated by genuine ring-node and
internal-node parasitics, not by a layout defect. A minimal ~1 µm wire on a ~3 fF node is
already several percent. A literal ±1 % vs the ideal schematic is therefore **physically
impossible** for an RO, and chasing it would be meaningless.

**Replacement success criterion (agreed with the owner):**
1. The full-RC PEX layout **oscillates at every bias** in range (2 → 31 µA) from the TB
   startup (a documented thermal-noise-stand-in kick is allowed). ✓
2. **Frequency is monotonic** in bias current and the range is usable (tens-to-hundreds of
   MHz). ✓ (table above)
3. **DRC clean**, LVS **"Circuits match uniquely"**, and schematic ↔ layout consistent. ✓

If a single number is still wanted, compare PEX against a **PEX-aware reference** — back-
annotate the *exact* extracted per-node loads into the SPICE reference (the methodology's
"if you add an element to optimise the layout, add it to the schematic too"), then the two
match by construction. The lumped-cap deck `tb_ro_explore.spice` is a first cut at this
(hangs approximate PEX node loads on ideal devices); it oscillates full-swing across the
range but is **not** frequency-calibrated — it under-loads vs the true distributed RC, so
it lands between the schematic and PEX rather than on PEX. Its role here is to prove **loop
gain is fine under realistic loading**, not to reproduce the frequency.
