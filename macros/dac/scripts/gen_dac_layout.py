#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 Davide Schiavone
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
"""
Generate the 4-bit current-steering DAC layout (Magic TCL) for ihp-sg13g2.

Binary weights (1x/2x/4x/8x) are built from REPLICATED UNIT DEVICES (not the gencell `m`
multiplier — that only arrays *unconnected* fingers here). netgen reduces parallel unit
devices back to m, so this still LVS-matches the schematic's `m={mw}` (see
macros/dac/spice/dac4_lay.spice, the implementable core with `vpcs` as a bias pin).

Usage: python3 macros/dac/scripts/gen_dac_layout.py dac4 layout
"""
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "..", "scripts"))
from genlayout import Layout   # noqa: E402


def build_dac4(outdir, mkport=True):
    """dac4 VDD VSS b0 b1 b2 b3 iout vpcs (current-steering DAC core, ideal ref off-chip)."""
    lo = Layout("dac4")
    lo.header()
    lo.begin_cell()

    # Device row: reference mirror | all current sources (grouped for matching) |
    # all 'to' steer nmos | all 'do' steer nmos | bit inverters | dump diode.
    row = [("Mpref", "pmos_2_1")]
    src, to, do, inv = [], [], [], []
    for i in range(4):
        mw = 1 << i
        for j in range(mw):
            src.append((f"Msrc{i}_{j}", "pmos_2_1"))
            to.append((f"Mto{i}_{j}", "nmos_1_0p13"))
            do.append((f"Mdo{i}_{j}", "nmos_1_0p13"))
        inv += [(f"Minvp{i}", "pmos_1_0p13"), (f"Minvn{i}", "nmos_0p5_0p13")]
    row += src + to + do + inv + [("Mdump", "nmos_1_0p5")]
    lo.place_row(row, gap=0.7)

    # --- connectivity (term order D G S B) ---
    nets = {}

    def add(inst, **conn):
        for term, net in conn.items():
            nets.setdefault(net, []).append((inst, term))

    add("Mpref", D="vpcs", G="vpcs", S="VDD", B="VDD")
    add("Mdump", D="ndump", G="ndump", S="VSS", B="VSS")
    for i in range(4):
        mw = 1 << i
        for j in range(mw):
            add(f"Msrc{i}_{j}", D=f"cs{i}", G="vpcs",     S="VDD",    B="VDD")
            add(f"Mto{i}_{j}",  D="iout",   G=f"b{i}",    S=f"cs{i}",  B="VSS")
            add(f"Mdo{i}_{j}",  D="ndump",  G=f"b{i}b",   S=f"cs{i}",  B="VSS")
        add(f"Minvp{i}", D=f"b{i}b", G=f"b{i}", S="VDD", B="VDD")
        add(f"Minvn{i}", D=f"b{i}b", G=f"b{i}", S="VSS", B="VSS")

    # --- route: power below, signals above ---
    ports = {"VDD", "VSS", "vpcs", "iout", "b0", "b1", "b2", "b3"}
    lo.route_net("VDD", nets.pop("VDD"), track_y=-2.7, mkport=mkport)
    lo.route_net("VSS", nets.pop("VSS"), track_y=-3.3, mkport=mkport)
    order = ["vpcs", "iout", "ndump",
             "cs0", "cs1", "cs2", "cs3",
             "b0", "b1", "b2", "b3",
             "b0b", "b1b", "b2b", "b3b"]
    y = 2.4
    for net in order:
        lo.route_net(net, nets.pop(net), track_y=y, mkport=(mkport and net in ports))
        y += 0.5
    assert not nets, f"unrouted nets: {list(nets)}"

    lo.finish(outdir)
    return lo


BUILDERS = {"dac4": build_dac4}

if __name__ == "__main__":
    cell = sys.argv[1] if len(sys.argv) > 1 else "dac4"
    outdir = sys.argv[2] if len(sys.argv) > 2 else "layout"
    mkport = "--noport" not in sys.argv
    lo = BUILDERS[cell](outdir, mkport=mkport)
    sys.stdout.write(lo.tcl())
