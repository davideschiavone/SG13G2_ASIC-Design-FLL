# SPDX-FileCopyrightText: 2026 Davide Schiavone
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
#
# Extract a SPICE netlist from a Magic .mag layout for LVS, PRESERVING PORTS.
# We extract from .mag (not GDS) on purpose: a GDS round-trip drops the port flags
# that netgen needs to match single-terminal port nets (e.g. bias inputs).
#
# Usage: LVS_CELL=<cell> magic -dnull -noconsole -rcfile <magicrc> scripts/mag_extract_lvs.tcl
# (run with cwd = the dir holding <cell>.mag and its device subcells)
set cell $env(LVS_CELL)
load $cell
extract all
ext2spice lvs
ext2spice -o ${cell}_lay.spice
puts "EXTRACT_DONE ${cell}_lay.spice"
quit -noprompt
