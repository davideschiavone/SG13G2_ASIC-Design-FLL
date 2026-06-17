# SPDX-FileCopyrightText: 2026 Davide Schiavone
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

MAKEFILE_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

RUN_TAG = $(shell ls -1 $(LIBRELANE_DIR)/runs 2>/dev/null | tail -n 1)

# Variables
TOP = fll_digital_top

.DEFAULT_GOAL := help

# Cell name for verification targets (default: top-level cell)
# Override with: make <target> CELL=<cellname>
CELL ?= $(TOP)

# Set the waveform viewer GTKWave or Surfer (default: gtkwave)
WAVEFORM_VIEWER ?= gtkwave

# Folder structure
COCOTB_DIR      := testbenches/cocotb
SCRIPTS_DIR     := scripts
REPORT_DIR      := verification
SRC_DIR         := rtl
NET_NL_DIR      := netlist/nl
NET_PNL_DIR     := netlist/pnl
NET_SPICE_DIR   := netlist/spice
XSPICE_DIR      := netlist/xspice
LIBRELANE_DIR   := flow/librelane
FLOW_FINAL_DIR  := flow/final
FINAL_DIR       := final

# constants.sv defines the `FLL_* macros and must compile before any module that
# references them, so it is the first entry in MODULES_SIM.
MODULES_SYNTH := \
	$(SRC_DIR)/fll_digital.sv \
	$(SRC_DIR)/fll_digital_top.sv

MODULES_SIM := \
	$(SRC_DIR)/constants.sv \
	$(MODULES_SYNTH)


# Help Target
help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z0-9_.-]+:.*## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "}; {printf "  %-20s %s\n", $$1, $$2}'
.PHONY: help
# ================================================================================================


# Linter Targets
lint-verilog: ## Lint all RTL source files with Verilator
	verilator --lint-only -I"$(SRC_DIR)" $(SRC_DIR)/constants.sv $(MODULES_SYNTH)
.PHONY: lint-verilog
# ================================================================================================


# Simulation Targets
sim-rtl-cocotb: ## Run RTL simulation of CELL cell with cocotb (usage: make sim-rtl-cocotb [CELL=<cellname>])
	cd $(COCOTB_DIR) && python3 $(CELL)_tb.py
.PHONY: sim-rtl-cocotb

sim-gl-cocotb: ## Run gate-level simulation of CELL cell with cocotb (usage: make sim-gl-cocotb [CELL=<cellname>])
	cd $(COCOTB_DIR) && GL=1 python3 $(CELL)_tb.py
.PHONY: sim-gl-cocotb

sim-view-cocotb: ## View CELL cell cocotb simulation waveforms (usage: make sim-view-cocotb [CELL=<cellname>] [WAVEFORM_VIEWER=<gtkwave|surfer>])
	$(WAVEFORM_VIEWER) $(COCOTB_DIR)/sim_build/$(CELL).fst
.PHONY: sim-view-cocotb

sim-all: ## Lint + RTL cocotb simulation
	$(MAKE) lint-verilog
	$(MAKE) sim-rtl-cocotb
.PHONY: sim-all
# ================================================================================================


# LibreLane Targets (flow/librelane/config.yaml is added at the hardening step)
librelane: ## Run LibreLane with Magic and KLayout DRC checks.
	librelane $(LIBRELANE_DIR)/config.yaml --pdk ${PDK} --pdk-root ${PDK_ROOT} --manual-pdk --save-views-to $(FLOW_FINAL_DIR)/
.PHONY: librelane

librelane-nodrc: ## Run LibreLane without DRC checks
	librelane $(LIBRELANE_DIR)/config.yaml --pdk ${PDK} --pdk-root ${PDK_ROOT} --manual-pdk --save-views-to $(FLOW_FINAL_DIR)/ --skip KLayout.DRC --skip Magic.DRC
.PHONY: librelane-nodrc

librelane-openroad: ## Open the last LibreLane run in OpenROAD GUI
	librelane $(LIBRELANE_DIR)/config.yaml --pdk ${PDK} --pdk-root ${PDK_ROOT} --manual-pdk --last-run --flow OpenInOpenROAD
.PHONY: librelane-openroad

librelane-klayout: ## Open the last LibreLane run in KLayout
	librelane $(LIBRELANE_DIR)/config.yaml --pdk ${PDK} --pdk-root ${PDK_ROOT} --manual-pdk --last-run --flow OpenInKLayout
.PHONY: librelane-klayout
# ================================================================================================
