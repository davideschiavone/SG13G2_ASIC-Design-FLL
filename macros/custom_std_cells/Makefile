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

GEN_FLAGS := --lib $(LIB) \
             $(addprefix --cell-verilog ,$(CELL_V)) \
             $(addprefix --cell-spice ,$(CELL_SP)) \
             --model-lib $(MODEL_LIB) --model-section $(MODEL_SECTION) --vdd $(VDD) \
             $(addprefix --custom-netlist ,$(CUSTOM)) \
             $(addprefix --module ,$(MODULE)) \
             -o $(TB_DIR)

.DEFAULT_GOAL := help

help: ## Show this help message
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'
.PHONY: help

generate: ## Regenerate tb/sv and tb/spice from the netlist and the PDK
	python3 $(GEN) $(NETLIST) $(GEN_FLAGS)
.PHONY: generate

# Only auto-regenerate when nothing was generated yet or the inputs moved on. A run that
# passes CUSTOM= or MODULE= always regenerates, since those change what is emitted.
$(TB_DIR)/sv/Makefile $(TB_DIR)/spice/Makefile: $(NETLIST) $(GEN)
	@$(MAKE) --no-print-directory -C $(MAKEFILE_DIR) generate

verilator: $(TB_DIR)/sv/Makefile ## Run every generated testbench with Verilator
	@$(MAKE) --no-print-directory -C $(TB_DIR)/sv verilator
.PHONY: verilator

icarus: $(TB_DIR)/sv/Makefile ## Run every generated testbench with Icarus Verilog
	@$(MAKE) --no-print-directory -C $(TB_DIR)/sv icarus
.PHONY: icarus

sv: $(TB_DIR)/sv/Makefile ## Run the SystemVerilog testbenches (Verilator + Icarus)
	@$(MAKE) --no-print-directory -C $(TB_DIR)/sv all
.PHONY: sv

spice: ## Run the transistor-level SPICE testbenches with ngspice
	@[ -n "$(CUSTOM)$(MODULE)" ] || [ -f $(TB_DIR)/spice/Makefile ] || \
		$(MAKE) --no-print-directory -C $(MAKEFILE_DIR) generate
	@[ -z "$(CUSTOM)$(MODULE)" ] || $(MAKE) --no-print-directory -C $(MAKEFILE_DIR) generate
	@$(MAKE) --no-print-directory -C $(TB_DIR)/spice spice
.PHONY: spice

all: sv spice ## Run every testbench: SystemVerilog and SPICE
.PHONY: all

clean: ## Delete the whole generated tb/ directory (testbenches and build products)
	rm -rf $(TB_DIR)
.PHONY: clean

clean-build: ## Delete only the simulator build products, keep the generated testbenches
	@[ -f $(TB_DIR)/sv/Makefile ] && $(MAKE) --no-print-directory -C $(TB_DIR)/sv clean || true
	@[ -f $(TB_DIR)/spice/Makefile ] && $(MAKE) --no-print-directory -C $(TB_DIR)/spice clean || true
.PHONY: clean-build
