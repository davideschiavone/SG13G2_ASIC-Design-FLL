# Custom (AION) standard-cell macros: generate and run the exhaustive testbenches.
#
# gen_cell_tb.py itself is PDK-agnostic and takes every library path on the command
# line. This Makefile pre-fills the ihp-sg13g2 paths so that in this repo a plain
# `make generate` / `make all` just works.

MAKEFILE_DIR := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

PDK_ROOT ?= /foss/pdks
PDK      ?= ihp-sg13g2
STDCELL  := $(PDK_ROOT)/$(PDK)/libs.ref/sg13g2_stdcell
TECH     := $(PDK_ROOT)/$(PDK)/libs.tech

# Gold oracle: the `function` attributes of the standard cells. Any corner will do --
# the functions are identical -- so the typical corner is used.
LIB      ?= $(STDCELL)/lib/sg13g2_stdcell_typ_1p20V_25C.lib

# Simulation models for the standard cells, needed to elaborate the netlist.
CELL_V   ?= $(STDCELL)/verilog/sg13g2_stdcell.v $(STDCELL)/verilog/sg13g2_udp.v

# Transistor-level views of the same cells, plus the device models ngspice needs.
CELL_SP       ?= $(STDCELL)/spice/sg13g2_stdcell.spice
MODEL_LIB     ?= $(TECH)/ngspice/models/cornerMOSlv.lib
MODEL_SECTION ?= mos_tt
VDD           ?= 1.2

# Optional: SPICE file(s) with your own implementation of one or more modules, as a
# `.subckt` named exactly like the Verilog module. Adds the third way to the SPICE
# comparison.  usage: make spice CUSTOM=/path/to/my_cells.spice
CUSTOM   ?=

# Optional: restrict generation to one or more modules (both SV and SPICE).
#   usage: make spice MODULE=AION_nand2_11
MODULE   ?=

NETLIST  ?= $(MAKEFILE_DIR)aion_cells.v
TB_DIR   ?= $(MAKEFILE_DIR)tb
GEN      := $(MAKEFILE_DIR)scripts/gen_cell_tb.py

# GTKWave cannot read an ngspice rawfile; this converts one to VCD.
RAW2VCD  ?= $(MAKEFILE_DIR)../../mixed_signal/raw2vcd.py

# Which testbench `make wave-sv` / `make wave-spice` opens.
TB       ?=

GEN_FLAGS := --lib $(LIB) \
             $(addprefix --cell-verilog ,$(CELL_V)) \
             $(addprefix --cell-spice ,$(CELL_SP)) \
             --model-lib $(MODEL_LIB) --model-section $(MODEL_SECTION) --vdd $(VDD) \
             --raw2vcd $(RAW2VCD) \
             $(addprefix --custom-netlist ,$(CUSTOM)) \
             $(addprefix --module ,$(MODULE)) \
             -o $(TB_DIR)

.DEFAULT_GOAL := help

help: ## Show this help message
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'
.PHONY: help

# What tb/ was last generated from. MODULE= and CUSTOM= change *which* testbenches are
# emitted, which no file timestamp can express, so the signature is recorded and compared:
# changing either -- including dropping them again to get the full set back -- regenerates.
TB_STAMP := $(TB_DIR)/.generated
TB_SIG   := $(TB_DIR)/.gen_sig
GEN_SIG  := $(strip $(MODULE)|$(CUSTOM))

generate: ## Regenerate tb/sv and tb/spice from the netlist and the PDK
	python3 $(GEN) $(NETLIST) $(GEN_FLAGS)
	@touch $(TB_STAMP) && printf '%s' '$(GEN_SIG)' > $(TB_SIG)
.PHONY: generate

$(TB_STAMP): $(NETLIST) $(GEN)
	@$(MAKE) --no-print-directory -C $(MAKEFILE_DIR) generate

# Every run target goes through this: regenerate if nothing is there yet, if an input
# moved on, or if MODULE=/CUSTOM= differ from the last generation.
ensure-tb: $(TB_STAMP)
	@if [ "$(GEN_SIG)" != "$$(cat $(TB_SIG) 2>/dev/null)" ]; then \
		$(MAKE) --no-print-directory -C $(MAKEFILE_DIR) generate; \
	fi
.PHONY: ensure-tb

verilator: ensure-tb ## Run the generated SystemVerilog testbenches with Verilator
	@$(MAKE) --no-print-directory -C $(TB_DIR)/sv verilator
.PHONY: verilator

icarus: ensure-tb ## Run the generated SystemVerilog testbenches with Icarus Verilog
	@$(MAKE) --no-print-directory -C $(TB_DIR)/sv icarus
.PHONY: icarus

sv: ensure-tb ## Run the SystemVerilog testbenches (Verilator + Icarus)
	@$(MAKE) --no-print-directory -C $(TB_DIR)/sv all
.PHONY: sv

spice: ensure-tb ## Run the transistor-level SPICE testbenches with ngspice
	@$(MAKE) --no-print-directory -C $(TB_DIR)/spice spice
.PHONY: spice

all: sv spice ## Run every testbench: SystemVerilog and SPICE
.PHONY: all

wave-sv: ensure-tb ## Open a SystemVerilog waveform in GTKWave (usage: make wave-sv TB=tb_<module>)
	@$(MAKE) --no-print-directory -C $(TB_DIR)/sv wave $(if $(TB),TB=$(TB),)
.PHONY: wave-sv

wave-spice: ensure-tb ## Open a SPICE waveform in GTKWave (usage: make wave-spice TB=tb_<module>)
	@$(MAKE) --no-print-directory -C $(TB_DIR)/spice wave $(if $(TB),TB=$(TB),)
.PHONY: wave-spice

clean: ## Delete the whole generated tb/ directory (testbenches and build products)
	rm -rf $(TB_DIR)
.PHONY: clean

clean-build: ## Delete only the simulator build products, keep the generated testbenches
	@[ -f $(TB_DIR)/sv/Makefile ] && $(MAKE) --no-print-directory -C $(TB_DIR)/sv clean || true
	@[ -f $(TB_DIR)/spice/Makefile ] && $(MAKE) --no-print-directory -C $(TB_DIR)/spice clean || true
.PHONY: clean-build
