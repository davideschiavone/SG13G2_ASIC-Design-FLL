# SPDX-FileCopyrightText: 2026 Davide Schiavone
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
# Mixed-signal co-simulation: fll_digital RTL (Verilator/d_cosim) + analog DAC+RO.

TB  := tb_mixed_dac_ro.spice
RAW := tb_mixed_dac_ro.raw
VCD := tb_mixed_dac_ro.vcd

# GUI targets render on the noVNC desktop (Xvnc display :1). Override if needed.
DISPLAY ?= :1

.DEFAULT_GOAL := help

help: ## Show this help message
	@echo 'Usage: make [target]   (GUI targets need a display; default DISPLAY=:1 -> noVNC)'
	@grep -E '^[a-zA-Z0-9_.-]+:.*## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "}; {printf "  %-10s %s\n", $$1, $$2}'
.PHONY: help

build: ## Verilator-build the fll_digital cosim shared lib (fll_digital.so)
	./build_cosim.sh
.PHONY: build

sanity: ## Cosim sanity check (no analog): verify dac_code_o tracks code_i
	ngspice -b tb_cosim_sanity.spice
.PHONY: sanity

sim: ## Run the full mixed-signal cosim (writes ASCII raw); needs fll_digital.so (make build)
	ngspice -b $(TB)
.PHONY: sim

vcd: ## Convert the last raw -> VCD for GTKWave
	python3 raw2vcd.py $(RAW) $(VCD)
.PHONY: vcd

wave: ## Convert + open the mixed-signal waveforms in GTKWave (GUI on $(DISPLAY))
	$(MAKE) vcd
	DISPLAY=$(DISPLAY) gtkwave $(VCD)
.PHONY: wave

plot: ## Open the last raw in ngspice's NATIVE plotter, no VCD (GUI on $(DISPLAY)); 'quit' to exit
	DISPLAY=$(DISPLAY) ngspice plot_raw.spice
.PHONY: plot

all: ## build + sim + open waveforms in GTKWave
	$(MAKE) build
	$(MAKE) sim
	$(MAKE) wave
.PHONY: all
