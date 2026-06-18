# SPDX-FileCopyrightText: 2026 Davide Schiavone
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
# Ring-oscillator macro (analog, schematic-level SPICE). No layout yet.

MAKEFILE_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

SPICE_DIR := spice
TB_DIR    := testbenches/spice
SCH_DIR   := schematic/xschem

# GUI targets render on the noVNC desktop (Xvnc display :1). Override if needed.
DISPLAY ?= :1

.DEFAULT_GOAL := help

help: ## Show this help message
	@echo 'Usage: make [target]   (GUI targets need a display; default DISPLAY=:1 -> noVNC)'
	@grep -E '^[a-zA-Z0-9_.-]+:.*## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "}; {printf "  %-16s %s\n", $$1, $$2}'
.PHONY: help

sim: ## Run the RO frequency-vs-bias-current sweep (ngspice, batch -> table)
	cd $(TB_DIR) && ngspice -b tb_ring_oscillator.spice
.PHONY: sim

sim-dacro: ## Run the combined DAC+RO code->frequency sweep (ngspice, batch -> table)
	cd $(TB_DIR) && ngspice -b tb_dac_ro.spice
.PHONY: sim-dacro

sim-wave: ## Plot the RO transient v(clk), v(nbias) in ngspice (GUI on $(DISPLAY))
	cd $(TB_DIR) && DISPLAY=$(DISPLAY) ngspice tb_ring_oscillator_wave.spice
.PHONY: sim-wave

xschem: ## Open the ring_oscillator schematic in Xschem (GUI on $(DISPLAY))
	cd $(SCH_DIR) && DISPLAY=$(DISPLAY) xschem --rcfile xschemrc ring_oscillator.sch
.PHONY: xschem
