#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Davide Schiavone
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
#
# Build the fll_digital RTL into a shared library loadable by ngspice's d_cosim
# XSPICE code model (for mixed-signal co-simulation with the analog DAC+RO).
#
# This replicates ngspice's bundled 'vlnggen' script. We cannot call 'vlnggen' via
# ngspice here because ngspice's 'shell' command lowercases the command line, which
# breaks Verilator's case-sensitive flags (-Mdir, --CFLAGS). Running Verilator
# directly from bash preserves case.
#
# Run inside the container (e.g. ../run.sh "cd mixed_signal && ./build_cosim.sh").
set -euo pipefail
cd "$(dirname "$0")"

SRC=/foss/tools/ngspice/share/ngspice/scripts/src   # ngspice cosim shim + headers
OBJ=verilated_obj_dir
PREFIX=Vlng
SO=fll_digital.so
RTL=../macros/fll_digital/rtl
FILES="$RTL/constants.sv $RTL/fll_digital.sv $RTL/fll_digital_top.sv"

rm -rf "$OBJ" "$SO"

# 1) Verilog/SystemVerilog -> C++
verilator --Mdir "$OBJ" --prefix "$PREFIX" --CFLAGS -fpic --cc $FILES

# 2) Generate the port lists the shim #includes, from the Verilated header.
#    e.g.  VL_IN8(&clock_i,0,0);  ->  VL_DATA(8,clock_i,0,0)
for h in inputs outputs inouts; do echo "/* generated: do not edit */" > "$OBJ/$h.h"; done
sed -n 's/.*VL_IN\([0-9]*\)(&\(.*\);.*/VL_DATA(\1,\2/p'    "$OBJ/$PREFIX.h" >> "$OBJ/inputs.h"
sed -n 's/.*VL_OUT\([0-9]*\)(&\(.*\);.*/VL_DATA(\1,\2/p'   "$OBJ/$PREFIX.h" >> "$OBJ/outputs.h"
sed -n 's/.*VL_INOUT\([0-9]*\)(&\(.*\);.*/VL_DATA(\1,\2/p' "$OBJ/$PREFIX.h" >> "$OBJ/inouts.h"

# 3) Compile the ngspice shim + main + design objects.
verilator --Mdir "$OBJ" --prefix "$PREFIX" --CFLAGS "-I$SRC" --CFLAGS -fpic \
  --cc --build --exe "$SRC/verilator_main.cpp" "$SRC/verilator_shim.cpp" $FILES

# 4) Link everything into the shared library d_cosim will load.
g++ --shared "$OBJ"/verilator_shim.o "$OBJ"/verilated*.o "$OBJ/${PREFIX}__ALL.a" \
  -pthread -lpthread -o "$SO"

echo "built $SO  (ports: in[clock_i reset_n_i ro_clk_i code_i3..0]  out[dac_code_o3..0 fout_o])"
