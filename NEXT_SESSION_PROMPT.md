# Next session — prompt: redesign the RO schematic for robust oscillation

Paste the STARTER MESSAGE block at the bottom to begin. CLAUDE.md and the project memory
load automatically; this file is the task statement + all the context you need.

---

## TASK

Redesign the **ring-oscillator schematic** so that its **extracted (PEX) layout oscillates
robustly** across the usable bias range — as any real RO should — then re-verify the whole
flow (schematic sim → regenerate layout → DRC/LVS → PEX oscillation). **Only the RO.** The
DAC is finished and signed off (DRC/LVS/PEX clean); do not touch it.

**Drop the ±1 % PEX-vs-schematic requirement for the RO** (the owner has agreed). Just
**document the reason** (below) and replace it with a sensible success criterion.

### New success criterion for the RO (replaces ±1 %)
1. The **PEX (full-RC) layout oscillates** at every bias in the range (e.g. 2 µA → 31 µA),
   from the testbench startup (a startup kick in the TB is allowed — real ROs start from
   thermal noise, which SPICE doesn't have; document it).
2. **Frequency is monotonic** in bias current (so the DAC can tune it), and the range is
   usable (roughly tens-of-MHz to several-hundred-MHz, same ballpark as before).
3. DRC clean + LVS "Circuits match uniquely", and **schematic ↔ layout stay consistent**
   (if you change device sizes, update the SPICE subckt, the xschem schematic via
   `scripts/gen_xschem.py`, the layout generator's `DEVICES`, and `spice/cs_stage.spice`).

### Why ±1 % is dropped (document this in RING_OSCILLATOR_LAYOUT.md)
An oscillator's frequency is set by node capacitance (f ∝ 1/C). The schematic reference has
**zero** interconnect capacitance, so any real layout shifts f by **far more than 1 %** (a
minimal ~1 µm wire on a ~3 fF node is already several %). A literal ±1 % vs the ideal
schematic is therefore **physically impossible** for an RO. The meaningful check is robust
oscillation + monotonic freq-vs-bias (and freq-vs-code through the DAC), and — if a number
is wanted — PEX vs a **PEX-aware reference** (back-annotate the extracted ring-node load
into the SPICE reference; this is where the methodology's "if you add an element to
optimise the layout, add it to the schematic too" applies).

---

## CONTEXT — what exists and what's wrong (from the last session)

**DAC:** done. DRC/LVS clean, full-RC PEX matches schematic to <0.1 %. Leave it.

**RO:** the **layout is good but the design is marginal**:
- The RO layout was rebuilt as a **2-row (PMOS-over-NMOS) channel-routed** floorplan
  (`macros/ring_oscillator/scripts/gen_ro_layout.py`, `build_ring_oscillator`). It is
  **DRC + LVS clean**, and ring-node parasitic capacitance is **~8× lower than the old flat
  layout** (~60 fF → <8 fF; the flat layout's 60 fF was 96 % coupling to a dense
  parallel-track field). So the layout/routing is NOT the problem.
- **The extracted RO does not sustain oscillation.** Verified exhaustively: device-only,
  C-only, and full-RC extractions; with and without a differential startup kick on a
  labelled ring node; at 16/31/60 µA. Forcing the ring into a valid oscillating state with
  initial conditions, it **decays to the mid-rail metastable point within ~0.5 µs**. The
  *schematic* oscillates fine (even with 3 fF lumped on each ring node), but the extracted
  netlist does not.
- Conclusion: **the v1 current-starved RO is a marginal oscillator** — aggressive
  current-starving (long-L `Mcp`/`Mcn`, weak inverter drive) gives too little per-stage
  loop gain, so once realistic device parasitics are present the loop no longer
  starts/sustains. The old *flat* layout only *appeared* to oscillate (37 MHz @ 31 µA)
  because its large parasitic cross-coupling perturbed the ring — an artifact. This is a
  **design-margin** problem, not a layout bug. Full write-up: `RING_OSCILLATOR_LAYOUT.md`
  §6.

### The current RO design (what to change)
`spice/ring_oscillator.spice` — 5 current-starved inverter stages + bias + output buffer:
```
cs_stage:  Mcp pmos w=2u  l=0.5u  (header, gate=vbp)
           Mp  pmos w=1u  l=0.13u (pull-up, gate=in)
           Mn  nmos w=0.5u l=0.13u(pull-down, gate=in)
           Mcn nmos w=1u  l=0.5u  (footer, gate=vbn=ibias)
bias:      Mbn nmos 1/0.5 diode, Mmir nmos 1/0.5, Mbp pmos 2/0.5
buffer:    Mb1p/Mb1n (1/0.13, 0.5/0.13), Mb2p/Mb2n (2/0.13, 1/0.13)
```
The long-L (0.5 µm) starving devices + small inverter are the likely culprits for low gain.

---

## SUGGESTED APPROACH

1. **Boost oscillation margin in the schematic** (`spice/ring_oscillator.spice`). Keep the
   current-starved topology (frequency MUST stay tunable by `ibias` for the DAC). Ideas, in
   order of likely impact:
   - Make the **inverter devices stronger** (larger W on `Mp`/`Mn`) so per-stage gm/gain is
     comfortably > 1.
   - **Relax the starving** — shorter L on `Mcp`/`Mcn` (e.g. 0.5 µm → 0.18–0.25 µm) and/or
     a more generous current-source sizing, so the stages aren't starved into low gain.
   - Optionally restructure (e.g. starve only the NMOS footer, or use a single shared
     current source per rail) — but keep it odd-stage and DAC-tunable.
2. **Prove margin in SPICE before any layout work:**
   - `make -C macros/ring_oscillator sim` → oscillates, monotonic freq-vs-`ibias`, usable range.
   - **Margin sanity:** add lumped caps (a few fF per ring node AND on the starved internal
     `pp`/`nn` nodes) and re-sim → must STILL oscillate. Better: build the device-level
     extracted netlist with junction parasitics and confirm it oscillates with a startup
     kick. Only proceed to layout once the design oscillates *with* realistic loading.
3. **Propagate the size changes** so schematic ↔ layout stay LVS-consistent:
   - `spice/ring_oscillator.spice` and `spice/cs_stage.spice`
   - `schematic/xschem/ring_oscillator.sch` via `scripts/gen_xschem.py` (golden for LVS)
   - `macros/ring_oscillator/scripts/gen_ro_layout.py` `DEVICES{}` — if you add a new device
     size, **re-probe its geometry headless**: `magic::gencell_makecell sg13g2::sg13_lv_*
     w .. l .. ng 1 m 1 guard 1`, then read `box values` (full bbox → `fhw`/`fhh`) and the
     `<< labels >>` rlabel coords (→ `D/S/G/B` port offsets), as documented in
     `RING_OSCILLATOR_LAYOUT.md` §1.
4. **Re-run the layout loop:** `make -C macros/ring_oscillator verify CELL=ring_oscillator`
   (gen + DRC + LVS), then `make pex CELL=ring_oscillator` and the PEX oscillation check.
   The PEX TB is `testbenches/spice/tb_ring_oscillator_pex.spice`; ring nodes are labelled
   `n1..n5` in the layout (non-port) so you can inject a startup kick
   (`Ikick VSS Xro.n1 PULSE(...)`) or set `.ic` on them.
5. **Document** in `RING_OSCILLATOR_LAYOUT.md`: the design change + rationale, the new
   freq-vs-bias (schematic and PEX), and the ±1 %-dropped reason above.

## CONSTRAINTS
- Target **ihp-sg13g2**; `sg13_lv_nmos`/`sg13_lv_pmos`; **metal5 forbidden** (user area).
- Keep RO **DAC-tunable** (frequency set by `ibias`); keep it odd-stage.
- Keep DRC/LVS clean; keep schematic (SPICE + xschem) and layout LVS-equivalent.
- Tools run via `./run.sh "<cmd>"`; GUI on noVNC (`:1`). Headless first.

## KEY FILES
- `spice/ring_oscillator.spice`, `spice/cs_stage.spice` (RO + leaf SPICE)
- `schematic/xschem/ring_oscillator.sch` (+ `scripts/gen_xschem.py`)
- `macros/ring_oscillator/scripts/gen_ro_layout.py` (layout generator; `DEVICES`, builders)
- `macros/ring_oscillator/Makefile` (sim / gen-layout / magic-drc / lvs / pex / sim-pex)
- `macros/ring_oscillator/RING_OSCILLATOR_LAYOUT.md` (full design log + §6 diagnosis)
- `macros/ring_oscillator/testbenches/spice/tb_ring_oscillator.spice` (golden freq sweep),
  `tb_ring_oscillator_pex.spice` (post-layout)

---

## STARTER MESSAGE (paste this)

> Redesign the RO schematic so the extracted (PEX) layout oscillates robustly across the
> bias range, per `NEXT_SESSION_PROMPT.md`. The v1 current-starved RO is too marginal
> (low loop gain) — it oscillates in the ideal schematic but the extracted netlist decays
> to mid-rail. Keep it current-starved and DAC-tunable, just give it real oscillation
> margin (stronger inverters / relaxed starving). Prove the design oscillates *with*
> realistic junction-cap loading in SPICE first, then propagate sizes to the xschem
> schematic + layout generator (re-probe any new device geometry), regenerate, and verify
> DRC/LVS clean + PEX oscillation. Drop ±1 % for the RO and document why (f ∝ 1/C → a
> zero-parasitic schematic can't be matched to ±1 % by any layout). Don't touch the DAC.
