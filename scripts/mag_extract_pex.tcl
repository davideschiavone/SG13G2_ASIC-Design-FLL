# SPDX-FileCopyrightText: 2026 Davide Schiavone
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
#
# Full-RC parasitic extraction of a Magic .mag layout, PRESERVING PORTS (extract from
# .mag, not GDS, so the macro pins survive for the testbench). Mirrors sak-pex.sh mode 3.
#
# Usage: LVS_CELL=<cell> magic -dnull -noconsole -rcfile <magicrc> scripts/mag_extract_pex.tcl
# (cwd = dir holding <cell>.mag and its device subcells). Output: <cell>_pex.spice
set cell $env(LVS_CELL)
load $cell
extract path .
ext2spice lvs
extresist tolerance 10
extract do resistance
extract do unique
extract all
ext2spice extresist on
ext2spice cthresh 0.01
ext2spice -o ${cell}_pex.spice
puts "PEX_DONE ${cell}_pex.spice"
quit -noprompt
