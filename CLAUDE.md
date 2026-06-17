## What this is
A minimal mixed-signal test chip — a Frequency-Locked Loop (FLL) — for **TinyTapeout**
on the IHP SG13G2 130nm open PDK. Digital-on-top mixed signal:
- **Digital (SystemVerilog):** frequency counter + integrator FSM. Counts a ring-VCO
  over a window of reference-clock cycles, compares against a target, drives an
  8-bit DAC control word to lock the VCO to ~2x the reference frequency. Hardened
  to a macro via LibreLane.
- **Analog (Xschem schematic + layout):** 5-stage ring-oscillator VCO with varactor
  (load-cap) frequency control; 8-bit current-steering DAC converting the control
  word to the VCO control voltage.
- **Integration:** hardened digital macro placed beside the analog macros, routed
  together, dropped into the **TinyTapeout analog tile**. Digital pins for
  clk/reset/dac bus; analog pins (ua[0..]) for control voltage and VCO feedback.

Owner: Davide Schiavone (GitHub: davideschiavone).
Remote: github.com/davideschiavone/SG13G2_ASIC-Design-FLL

## Repository scaffold & provenance (READ THIS — it changed)
This repo is built on JKU's LibreLane-based **ihp-sg13g2-ams-chip-template** (Simon
Dorrer & Harald Pretl, JKU Linz), used as the **development scaffold**. It is
Makefile-driven; `make help` lists every target.

- It previously used JKU's older **ORFS** template (SG13G2_ASIC-Design-Template). On
  2026-06-17 the scaffold was migrated ORFS -> LibreLane AMS. The ORFS scaffold is
  gone from the working tree (recoverable via git history + public upstream); only its
  `.xspice` gate-level co-sim methodology is kept under `reference/orfs-xspice/`.
- Attribution to Dorrer/Pretl/JKU and the original templates is preserved in
  `README.md` (provenance banner) and `CITATION.cff`.

**Scaffold vs. final vehicle — IMPORTANT divergence:**
- The AMS template's own flow builds a **QFN-32, 1.6×1.6 mm padframe chip**. We use it
  ONLY as a development scaffold: LibreLane macro hardening, Xschem analog entry, and
  per-macro DRC/LVS/PEX. **Its padframe / top-level assembly is NOT the FLL's tapeout
  vehicle.**
- The FLL's tapeout target is a **TinyTapeout analog tile**. At top level we adapt the
  hardened FLL macros into the TinyTapeout analog harness, NOT the template padframe.
- Keep the TinyTapeout constraints (below) as hard requirements from day one.

### How the template maps onto the FLL
The template ships two example macros under `macros/`; each is the pattern for our blocks:
- `macros/counter/` — **digital** macro: SV RTL → cocotb → LibreLane harden
  (`flow/librelane/config.yaml`, `pin_order.cfg`, SDCs). → pattern for the **FLL
  controller** (frequency counter + integrator FSM).
- `macros/inverter/` — **analog** macro: Xschem schematic → hand layout GDS →
  DRC/LVS/PEX. → pattern for the **ring-VCO** and **8-bit DAC**.
- `rtl/chip_top.sv` + `rtl/chip_core.sv` + `flow/librelane/` — the template's padframe
  top level (scaffold only; see divergence above).

## Environment — DO NOT reinstall or recreate any of this
- You (Claude Code) run on the HOST (Ubuntu 24.04). Docker is installed and working.
- The EDA toolchain is an ALREADY-RUNNING container:
  - name:  iic-osic-tools_xvnc_uid_1000
  - image: hpretl/iic-osic-tools:2026.05 (template requires 2026.05 or later)
  - ships: Xschem, Magic, KLayout, ngspice, Yosys, OpenROAD, OpenSTA, Netgen,
    LibreLane, cocotb, Verilator, iverilog, + the ihp-sg13g2 PDK.
- GUI desktop is viewed in a browser via noVNC at
  http://localhost/?password=abc123 (VNC display :1). The human drives GUI tools there.

## Path mapping — the one place host and container meet
host `~/eda/designs`  ==  container `/foss/designs`
- This project: host `~/eda/designs/SG13G2_ASIC-Design-FLL`
  == container `/foss/designs/SG13G2_ASIC-Design-FLL`
- Anything OUTSIDE `~/eda/designs` on the host is INVISIBLE to the container tools.
- Host user and container user are both uid 1000, so files created by container
  tools come back owned by the host user — no chown needed.

## How you work here
**Edit files** with your normal file tools on the HOST path (this repo). Because the
folder is bind-mounted, edits are instantly visible inside the container. No docker cp.

**Run EDA tools** inside the container via the wrapper `./run.sh`, which is:
```bash
#!/usr/bin/env bash
exec docker exec -i iic-osic-tools_xvnc_uid_1000 \
  bash -lc "export PDK=ihp-sg13g2; cd /foss/designs/SG13G2_ASIC-Design-FLL && $*"
```
The build flow is `make` (run `./run.sh "make help"` to list targets). Examples:
- `./run.sh "make sim-rtl-cocotb CELL=<cell>"`   # RTL cocotb sim
- `./run.sh "make sim-gl-xschem CELL=<cell>"`     # gate-level mixed-signal in Xschem
- `./run.sh "make build-<macro>"`                 # harden a macro with LibreLane
- `./run.sh "make klayout-lvs CELL=<cell>"`       # LVS a cell

The template Makefiles self-locate (`MAKEFILE_DIR := $(shell dirname $(realpath …))`)
and use relative paths, so the rename to SG13G2_ASIC-Design-FLL does not break them.
Note: `flow/artistic` is a git submodule (pulp-platform ArtistIC, logo/fill only) and
is NOT fetched; run `make init-submodules` if/when logo or fill steps are needed.

Headless first. Author netlists/SPICE decks as text and simulate with `ngspice -b`;
the human opens Xschem/KLayout in the browser to view or tweak. GUI Make targets
(`librelane-openroad`, `librelane-klayout`, `sim-view-*`) launch on the noVNC display
:1 and will block a headless `run.sh` call — let the human drive those.

Everything tool-related must target the **ihp-sg13g2** PDK, never sky130.

## Methodology (work in this order)
1. RTL first: write + lint + cocotb-sim the digital controller standalone as a macro
   under `macros/` (pattern: `macros/counter/`). Headless.
2. Analog blocks: VCO and DAC as Xschem schematics under their own `macros/` dirs
   (pattern: `macros/inverter/`); characterize each headless in ngspice (VCO freq vs
   Vctrl DC sweep; DAC monotonicity/INL).
3. Mixed-signal co-sim: closed-loop testbench with a BEHAVIORAL Verilog-A model of
   the controller + transistor-level analog; verify it actually locks (transient).
4. Harden digital with LibreLane -> macro (gds/lef/lib) via `make build-<controller>`.
5. Gate-level mixed-signal re-verify: swap the behavioral model for the hardened
   netlist (XSPICE event-driven model — see `reference/orfs-xspice/` for the qflow
   `.xspice` approach, or the template's `sim-gl-xschem`); confirm lock survives gate
   delays.
6. Analog layout in KLayout/Magic (human does GUI work; you prep what you can);
   DRC/LVS/PEX clean each macro (`make klayout-lvs` / `make magic-lvs`).
7. Top-level: adapt the hardened FLL macros into the **TinyTapeout analog harness**
   (NOT the template padframe); floorplan + route + DRC/LVS; export final GDS.
8. Fill TinyTapeout `info.yaml`, run precheck.

## Constraints
- TinyTapeout analog: 1x2 or 2x2 tile only; analog pads ua[0]..ua[5] used in order
  from 0; metal5 forbidden in the user area. Keep area/floorplan honest from step 1.
- The template padframe (QFN-32, 1.6×1.6 mm) is scaffold only — do not assume it as
  the tapeout vehicle.
- Target node: ihp-sg13g2.

## Working style
- The owner is an RTL/architecture person, NOT an analog-layout expert. Explain
  analog steps a bit more; move fast on RTL/flow.
- Be technically precise and honest. If a number, area, or "this will lock" claim
  isn't backed by a sim or datasheet, say so and label it a guess. No padding.
  Bottom-up arithmetic over hand-waving.
- Push back on anything that won't DRC/LVS or won't fit the tile.
- Small, reviewable steps. Show what you're about to run before big operations
  (layout edits, LibreLane runs). git commit per milestone.
