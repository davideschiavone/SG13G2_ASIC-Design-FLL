#!/usr/bin/env bash
# Like run.sh, but allocates a tty and points at the noVNC X display, for the interactive
# and GUI tools: ngspice's plotter, gtkwave, surfer, xschem, klayout, magic.
#
# Windows open on the noVNC desktop (http://localhost/?password=abc123, display :1) while
# the program's prompt stays in this terminal -- which is what ngspice needs, since it sits
# at its prompt with the plot windows open until you type 'quit'.
#
#   ./run-tty.sh "make -C macros/custom_std_cells plot TB=tb_AION_nand2_11"
#   ./run-tty.sh "ngspice"
#
# Use run.sh for everything headless; it needs no tty and works from scripts and CI.
exec docker exec -it "iic-osic-tools_xvnc_uid_$(id -u)" \
  bash -lc "export PDK=ihp-sg13g2 DISPLAY=\${DISPLAY:-:1}; cd /foss/designs/SG13G2_ASIC-Design-FLL && $*"
