# SPDX-FileCopyrightText: 2026 Davide Schiavone
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
# Ring-oscillator macro: schematic-level SPICE sims + scripted analog layout (DRC/LVS/PEX).

MAKEFILE_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
REPO_ROOT    := $(MAKEFILE_DIR)/../..

SPICE_DIR := spice
TB_DIR    := testbenches/spice
SCH_DIR   := schematic/xschem
LAY_DIR   := layout
SCRIPTS   := scripts
GEN       := $(SCRIPTS)/gen_ro_layout.py
LVS_DIR   := verification/lvs
DRC_DIR   := verification/drc
PEX_DIR   := netlist/pex
MAGICRC   := $(PDK_ROOT)/$(PDK)/libs.tech/magic/ihp-sg13g2.magicrc
NETGEN_SETUP := $(PDK_ROOT)/$(PDK)/libs.tech/netgen/$(PDK)_setup.tcl

# Cell to operate on for layout/verify targets (leaf cs_stage, or the full ring_oscillator)
CELL ?= ring_oscillator
# PEX extraction mode (1=C, 2=CC, 3=RC)
EXT_MODE ?= 3

# GUI targets render on the noVNC desktop (Xvnc display :1). Override if needed.
DISPLAY ?= :1

.DEFAULT_GOAL := help

help: ## Show this help message
	@echo 'Usage: make [target] [CELL=<cs_stage|ring_oscillator>]'
	@grep -E '^[a-zA-Z0-9_.-]+:.*## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "}; {printf "  %-18s %s\n", $$1, $$2}'
.PHONY: help

# ----- Simulation (schematic-level SPICE) -------------------------------------
sim: ## RO frequency-vs-bias-current sweep (ngspice batch)
	cd $(TB_DIR) && ngspice -b tb_ring_oscillator.spice
.PHONY: sim

sim-dacro: ## Combined DAC+RO code->frequency sweep (ngspice batch)
	cd $(TB_DIR) && ngspice -b tb_dac_ro.spice
.PHONY: sim-dacro

sim-wave: ## Plot RO transient in ngspice (GUI on $(DISPLAY))
	cd $(TB_DIR) && DISPLAY=$(DISPLAY) ngspice tb_ring_oscillator_wave.spice
.PHONY: sim-wave

sim-wave-dacro: ## Plot combined DAC+RO transient (code=8) in ngspice (GUI)
	cd $(TB_DIR) && DISPLAY=$(DISPLAY) ngspice tb_dac_ro_wave.spice
.PHONY: sim-wave-dacro

xschem: ## Open the ring_oscillator schematic in Xschem (GUI)
	cd $(SCH_DIR) && DISPLAY=$(DISPLAY) xschem --rcfile xschemrc ring_oscillator.sch
.PHONY: xschem

# ----- Scripted layout generation ---------------------------------------------
gen-layout: ## Generate layout/$(CELL).{mag,gds} from the Python->Magic-TCL generator
	mkdir -p $(LAY_DIR)
	python3 $(GEN) $(CELL) $(LAY_DIR) > $(LAY_DIR)/_$(CELL).tcl
	cd $(LAY_DIR) && magic -dnull -noconsole -rcfile $(MAGICRC) _$(CELL).tcl
.PHONY: gen-layout

render: ## Render layout/$(CELL).gds to a PNG (offscreen)
	cd $(LAY_DIR) && QT_QPA_PLATFORM=offscreen python3 ../../inverter/scripts/lay2img.py $(CELL).gds _$(CELL).png --width 1800
.PHONY: render

# ----- DRC --------------------------------------------------------------------
magic-drc: ## Magic DRC of $(CELL)
	mkdir -p $(DRC_DIR)
	sak-drc.sh -d -f "*" -w $(DRC_DIR) $(LAY_DIR)/$(CELL).gds $(CELL)
	rm -f $(DRC_DIR)/drc_$(CELL).tcl
.PHONY: magic-drc

klayout-drc: ## KLayout DRC of $(CELL)
	mkdir -p $(DRC_DIR)
	python3 $(PDK_ROOT)/$(PDK)/libs.tech/klayout/tech/drc/run_drc.py \
		--path=$(LAY_DIR)/$(CELL).gds --topcell=$(CELL) --run_dir=$(DRC_DIR) \
		--no_feol --no_density --disable_extra_rules --mp=16
.PHONY: klayout-drc

# ----- LVS (extract from .mag to preserve ports, then netgen) ------------------
lvs: ## LVS layout/$(CELL).mag vs spice/$(CELL).spice (Magic extract + netgen)
	mkdir -p $(LVS_DIR)
	cp $(LAY_DIR)/*.mag $(LVS_DIR)/
	cd $(LVS_DIR) && LVS_CELL=$(CELL) magic -dnull -noconsole -rcfile $(MAGICRC) $(REPO_ROOT)/scripts/mag_extract_lvs.tcl
	cd $(LVS_DIR) && netgen -batch lvs "$(CELL)_lay.spice $(CELL)" \
		"$(MAKEFILE_DIR)/$(SPICE_DIR)/$(CELL).spice $(CELL)" \
		$(NETGEN_SETUP) $(CELL).lvs.out
	@echo "---- LVS result ----"; tail -3 $(LVS_DIR)/$(CELL).lvs.out
.PHONY: lvs

# ----- PEX --------------------------------------------------------------------
magic-pex: ## Magic parasitic extraction of $(CELL) (EXT_MODE=1|2|3, from GDS)
	mkdir -p $(PEX_DIR)
	sak-pex.sh -d -m $(EXT_MODE) -w $(PEX_DIR) $(LAY_DIR)/$(CELL).gds
	mv $(PEX_DIR)/$(CELL).pex.spice $(PEX_DIR)/$(CELL)_magic_pex_$(EXT_MODE).spice
.PHONY: magic-pex

pex: ## Full-RC PEX from .mag (ports preserved) -> testbenches/spice/$(CELL)_pex.spice
	mkdir -p $(PEX_DIR)
	cp $(LAY_DIR)/*.mag $(PEX_DIR)/
	cd $(PEX_DIR) && LVS_CELL=$(CELL) magic -dnull -noconsole -rcfile $(MAGICRC) $(REPO_ROOT)/scripts/mag_extract_pex.tcl
	cp $(PEX_DIR)/$(CELL)_pex.spice $(TB_DIR)/
.PHONY: pex

sim-pex: ## Run the post-layout (PEX) RO frequency sweep (needs `make pex` first)
	cd $(TB_DIR) && ngspice -b tb_ring_oscillator_pex.spice
.PHONY: sim-pex

verify: ## gen + DRC + LVS of $(CELL)
	$(MAKE) gen-layout CELL=$(CELL)
	$(MAKE) magic-drc CELL=$(CELL)
	$(MAKE) lvs CELL=$(CELL)
.PHONY: verify
