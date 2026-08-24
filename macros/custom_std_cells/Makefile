# Custom (AION) standard-cell macros: generate and run the exhaustive testbenches.
#
# gen_cell_tb.py itself is PDK-agnostic and takes every library path on the command
# line. This Makefile pre-fills the ihp-sg13g2 paths so that in this repo a plain
# `make generate` / `make all` just works.

MAKEFILE_DIR := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

PDK_ROOT ?= /foss/pdks
PDK      ?= ihp-sg13g2
STDCELL  := $(PDK_ROOT)/$(PDK)/libs.ref/sg13g2_stdcell

# Gold oracle: the `function` attributes of the standard cells. Any corner will do --
# the functions are identical -- so the typical corner is used.
LIB      ?= $(STDCELL)/lib/sg13g2_stdcell_typ_1p20V_25C.lib

# Simulation models for the standard cells, needed to elaborate the netlist.
CELL_V   ?= $(STDCELL)/verilog/sg13g2_stdcell.v $(STDCELL)/verilog/sg13g2_udp.v

NETLIST  ?= $(MAKEFILE_DIR)aion_cells.v
TB_DIR   ?= $(MAKEFILE_DIR)tb
GEN      := $(MAKEFILE_DIR)scripts/gen_cell_tb.py

GEN_FLAGS := --lib $(LIB) $(addprefix --cell-verilog ,$(CELL_V)) -o $(TB_DIR)

.DEFAULT_GOAL := help

help: ## Show this help message
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'
.PHONY: help

generate: ## Regenerate tb/ from the netlist and the PDK Liberty functions
	python3 $(GEN) $(NETLIST) $(GEN_FLAGS)
.PHONY: generate

$(TB_DIR)/Makefile: $(NETLIST) $(GEN)
	@$(MAKE) --no-print-directory -C $(MAKEFILE_DIR) generate

verilator: $(TB_DIR)/Makefile ## Run every generated testbench with Verilator
	@$(MAKE) --no-print-directory -C $(TB_DIR) verilator
.PHONY: verilator

icarus: $(TB_DIR)/Makefile ## Run every generated testbench with Icarus Verilog
	@$(MAKE) --no-print-directory -C $(TB_DIR) icarus
.PHONY: icarus

all: $(TB_DIR)/Makefile ## Run every generated testbench with both simulators
	@$(MAKE) --no-print-directory -C $(TB_DIR) all
.PHONY: all

clean: ## Delete the whole generated tb/ directory (testbenches and build products)
	rm -rf $(TB_DIR)
.PHONY: clean

clean-build: ## Delete only the simulator build products, keep the generated testbenches
	@[ -f $(TB_DIR)/Makefile ] && $(MAKE) --no-print-directory -C $(TB_DIR) clean || true
.PHONY: clean-build
