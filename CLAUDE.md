## What this is
A minimal mixed-signal test chip for **TinyTapeout** on the IHP SG13G2 130nm open PDK.
The project name is **FLL** (Frequency-Locked Loop), but **v1 is intentionally
open-loop** — it is a digitally-controlled ring oscillator (DCO) with a frequency
monitor output, NOT a closed-loop frequency *lock*. The goal of v1 is to learn and
exercise the full open-source mixed-signal flow end-to-end, not to build a
high-quality FLL. (Closed-loop locking — frequency counter + servo — is a documented
future extension; see "Future work".)

Digital-on-top mixed signal, v1 (open-loop DCO):
- **Digital (SystemVerilog, macro `fll_digital`):** registers a 4-bit user code to a
  DAC control word, and divides the ring-oscillator output by 1024 to a monitor pin
  (for an LED / oscilloscope). No frequency counter, no servo. Hardened to a macro via
  LibreLane.
- **Analog (Xschem schematic + layout):** 5-stage **current-starved ring oscillator**
  whose frequency is set by a bias current; **4-bit current-steering DAC** that turns
  the digital code into that bias current.
- **Integration:** hardened `fll_digital` macro placed beside the analog macros, routed
  together, dropped into the **TinyTapeout analog tile**. Digital pins for clk/reset/
  4-bit code/monitor-out; analog pins (ua[0..]) for bias/observation.

Owner: Davide Schiavone (GitHub: davideschiavone).
Remote: github.com/davideschiavone/SG13G2_ASIC-Design-FLL

## FLL v1 design spec (open-loop DCO) — the build target
Signal flow (fully on-chip except observation pins):
`ui_in[3:0] → (clk reg) → dac_code[3:0] → 4b current-steering DAC → bias current →
current-starved ring oscillator → ro_clk → ÷1024 → uo_out[0] (monitor)`

**Digital macro `fll_digital` — behavior**
- `dac_code[3:0] <= ui_in[3:0]` registered on `clk` (open-loop control word to the DAC).
- ÷1024 divider: 10-bit counter clocked by `ro_clk`; `fout = cnt[9]` (= f_RO / 1024).
- Two independent clock domains that exchange NO data (`clk`→DAC code; `ro_clk`→divider)
  — so there is no metastable CDC. `fout` is a free-running divided clock driven to a pad.

**Pin map (TinyTapeout digital interface; all projects get it)**
| Pin | Dir | Use |
| --- | --- | --- |
| `clk` | in | system clock (registers `dac_code`) |
| `rst_n` | in | async reset (`dac_code`→`DAC_RST`, divider→0) |
| `ena` | in | tile enable (TT-managed) |
| `ui_in[3:0]` | in | **4-bit frequency control code** |
| `ui_in[7:4]` | in | unused |
| `uo_out[0]` | out | **`fout` = RO ÷ 1024** → GPIO → LED / scope |
| `uo_out[7:4]` | out | `dac_code` echo (observability) |
| `uo_out[3:1]` | out | 0 |
| `uio_*` | — | unused (`uio_oe = 8'h00`) |

**Internal macro ports:** `dac_code[3:0]` (out → DAC macro), `ro_clk` (in ← RO macro).

**Analog pins (`ua`, used in order — finalize when the analog macros are designed):**
`ua[0]` = DAC bias / RO control node (observe or force); `ua[1]` = external reference
current/voltage in; `ua[2]` = optional raw RO tap for scope (the digital `fout` is the
primary measurement path).

**Parameters (SV localparams):** `DAC_W=4`, divider `DIV=1024` (`DIV_W=10`, `fout=cnt[9]`),
`DAC_RST=8` (mid-code, RO mid-range). No counter/target/window/step/tol in v1.

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
  (`flow/librelane/config.yaml`, `pin_order.cfg`, SDCs). → pattern for `fll_digital`.
- `macros/inverter/` — **analog** macro: Xschem schematic → hand layout GDS →
  DRC/LVS/PEX. → pattern for the **ring oscillator** and the **4-bit DAC**.
- `rtl/chip_top.sv` + `rtl/chip_core.sv` + `flow/librelane/` — the template's padframe
  top level (scaffold only; see divergence above).

## Environment — check before assuming it's running
- You (Claude Code) run on the HOST (Ubuntu 24.04). Docker is installed and working.
- The EDA toolchain runs in a container, image `hpretl/iic-osic-tools:2026.05` (or
  later), named `iic-osic-tools_xvnc_uid_<hostuid>` — the uid suffix is
  `$(id -u)` on the host, NOT necessarily 1000. Check first:
  `docker ps -a --filter name=iic-osic-tools`.
- **If it's not running**, bootstrap it from the HOST shell (not via `./run.sh` —
  that talks to the container, which doesn't exist yet):
  ```bash
  make docker-install   # once: fetches the IIC-OSIC-TOOLS launcher to ~/tools
  make docker-start     # pulls the image (2026.05+) and starts the container
  ```
  See `make help` for `docker-install` / `docker-start` / `docker-stop` /
  `docker-status`. Don't `docker rm`/recreate a container that's already running and
  has state in it — check status first.
- Ships: Xschem, Magic, KLayout, ngspice, Yosys, OpenROAD, OpenSTA, Netgen,
  LibreLane, cocotb, Verilator, iverilog, + the ihp-sg13g2 PDK.
- GUI desktop is viewed in a browser via noVNC at
  http://localhost/?password=abc123 (VNC display :1). The human drives GUI tools there.

## Path mapping — the one place host and container meet
`docker-start` mounts the PARENT of this repo (host) to container `/foss/designs`,
so this repo lands at container `/foss/designs/SG13G2_ASIC-Design-FLL` regardless of
where it's cloned on the host. Anything outside that mounted parent dir is INVISIBLE
to the container tools. Host and container run as the same uid (`$(id -u)`), so files
created by container tools come back owned by the host user — no chown needed.

## How you work here
**Edit files** with your normal file tools on the HOST path (this repo). Because the
folder is bind-mounted, edits are instantly visible inside the container. No docker cp.

**Run EDA tools** inside the container via the wrapper `./run.sh`, which is:
```bash
#!/usr/bin/env bash
exec docker exec -i "iic-osic-tools_xvnc_uid_$(id -u)" \
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

## Methodology (work in this order) — v1 open-loop
1. **RTL (M0):** write + lint + cocotb-sim `fll_digital` standalone as a macro under
   `macros/fll_digital/` (pattern: `macros/counter/`). Check: code→`dac_code`, ÷1024
   divider, reset, pin map. Headless.
2. **Analog blocks:** 4-bit current-steering DAC and current-starved ring oscillator as
   Xschem schematics under their own `macros/` dirs (pattern: `macros/inverter/`);
   characterize each headless in ngspice — DAC: code→bias current (monotonicity);
   RO: bias current→frequency (monotonic, usable range).
3. **Mixed-signal co-sim:** OPEN-loop testbench — drive `ui_in[3:0]`, watch `fout`
   track frequency. Behavioral analog model first, then transistor-level.
4. **Harden digital** with LibreLane -> macro (gds/lef/lib) via `make build-fll_digital`.
5. **Gate-level mixed-signal re-verify:** swap behavioral digital for the hardened
   netlist (template `sim-gl-xschem`, or the qflow `.xspice` approach in
   `reference/orfs-xspice/`); confirm `fout` still tracks code with real gate delays.
6. **Analog layout** in KLayout/Magic (human does GUI work; you prep what you can);
   DRC/LVS/PEX clean each macro (`make klayout-lvs` / `make magic-lvs`).
7. **Top-level:** adapt the hardened macros into the **TinyTapeout analog harness**
   (NOT the template padframe); floorplan + route + DRC/LVS; export final GDS.
8. Fill TinyTapeout `info.yaml`, run precheck.

## Constraints
- TinyTapeout analog: 1x2 or 2x2 tile only; analog pads ua[0]..ua[5] used in order
  from 0; metal5 forbidden in the user area. Keep area/floorplan honest from step 1.
- The template padframe (QFN-32, 1.6×1.6 mm) is scaffold only — do not assume it as
  the tapeout vehicle.
- Target node: ihp-sg13g2.

## Future work (out of scope for v1)
- Close the loop: add a gated frequency counter (RO edges over N `clk` cycles, with a
  proper async CDC), a target multiplier `M` (lock `f_RO = M × f_ref`), a bang-bang/PI
  servo on `dac_code`, and a `locked` flag — turning the open-loop DCO into a real FLL.
- Wider DAC (e.g. 8-bit) for finer frequency resolution.
- A register-file control interface if more configurability is needed.

## Working style
- The owner is an RTL/architecture person, NOT an analog-layout expert. Explain
  analog steps a bit more; move fast on RTL/flow.
- Be technically precise and honest. If a number, area, or "this will lock" claim
  isn't backed by a sim or datasheet, say so and label it a guess. No padding.
  Bottom-up arithmetic over hand-waving.
- Push back on anything that won't DRC/LVS or won't fit the tile.
- Small, reviewable steps. Show what you're about to run before big operations
  (layout edits, LibreLane runs).
- **Commit milestones automatically — do NOT ask for permission to commit each time.**
  Use clear messages, commit per logical milestone, and just report what was committed.
  (Still surface big/destructive operations before running them.)
