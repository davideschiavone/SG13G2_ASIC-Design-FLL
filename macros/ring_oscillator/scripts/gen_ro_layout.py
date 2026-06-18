#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 Davide Schiavone
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
"""
Generate the ring-oscillator layout cells (Magic TCL) for ihp-sg13g2.

Cells:
  cs_stage  — one current-starved inverter stage (4 FETs), the matched leaf cell.
  (ring_oscillator — composed from 5 cs_stage + bias + buffer; added later.)

Usage (from repo root, in the container):
  python3 macros/ring_oscillator/scripts/gen_ro_layout.py cs_stage > /tmp/x.tcl
The Makefile target `gen-layout` wires this into Magic and the layout/ dir.
"""
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "..", "scripts"))
from genlayout import Layout   # noqa: E402

# device pitch (centre-to-centre, um) — generous so guard rings clear DRC spacing
PITCH = 2.6


def build_cs_stage(outdir, mkport=True):
    """cs_stage VDD VSS vbp vbn in out  (matches spice/ring_oscillator.spice).
       Row order L->R: Mcp(p,2/0.5) Mp(p,1/0.13) Mn(n,0.5/0.13) Mcn(n,1/0.5)."""
    lo = Layout("cs_stage")
    lo.header()
    lo.begin_cell()

    # Row L->R: Mcp Mp Mn Mcn, placed edge-to-edge with a safe gap (no nwell overlap).
    lo.place_row([("Mcp", "pmos_2_0p5"), ("Mp", "pmos_1_0p13"),
                  ("Mn", "nmos_0p5_0p13"), ("Mcn", "nmos_1_0p5")], gap=0.7)

    # nets: spice connectivity
    #  Mcp: D=pp  S=VDD G=vbp B=VDD
    #  Mp : D=out S=pp  G=in  B=VDD
    #  Mn : D=out S=nn  G=in  B=VSS
    #  Mcn: D=nn  S=VSS G=vbn B=VSS
    # signal/internal nets routed on tracks ABOVE the row
    lo.route_net("out", [("Mp", "D"), ("Mn", "D")], track_y=2.2, mkport=mkport)
    lo.route_net("pp",  [("Mcp", "D"), ("Mp", "S")], track_y=2.7)
    lo.route_net("nn",  [("Mn", "S"), ("Mcn", "D")], track_y=3.2)
    lo.route_net("in",  [("Mp", "G"), ("Mn", "G")], track_y=3.7, mkport=mkport)
    lo.route_net("vbp", [("Mcp", "G")], track_y=4.2, mkport=mkport)
    lo.route_net("vbn", [("Mcn", "G")], track_y=4.7, mkport=mkport)
    # power nets routed on tracks BELOW the row (B/guard ports are at the bottom)
    lo.route_net("VDD", [("Mcp", "S"), ("Mcp", "B"), ("Mp", "B")], track_y=-2.7, mkport=mkport)
    lo.route_net("VSS", [("Mcn", "S"), ("Mcn", "B"), ("Mn", "B")], track_y=-3.2, mkport=mkport)

    lo.finish(outdir)
    return lo


def build_ring_oscillator(outdir, mkport=True):
    """Full current-starved ring oscillator (flat): bias gen + 5 stages + output buffer.
       Ports: VDD VSS ibias clk  (matches spice/ring_oscillator.spice).
       Flat layout: all FETs in one row, routed on M3 tracks (signals above, power below).
    """
    lo = Layout("ring_oscillator")
    lo.header()
    lo.begin_cell()

    # device row, left->right: bias(3) | stage1..5 (4 each) | buffer(4)
    row = [("Mbn", "nmos_1_0p5"), ("Mmir", "nmos_1_0p5"), ("Mbp", "pmos_2_0p5")]
    for i in range(1, 6):
        row += [(f"Mcp{i}", "pmos_2_0p5"), (f"Mp{i}", "pmos_1_0p13"),
                (f"Mn{i}", "nmos_0p5_0p13"), (f"Mcn{i}", "nmos_1_0p5")]
    row += [("Mb1p", "pmos_1_0p13"), ("Mb1n", "nmos_0p5_0p13"),
            ("Mb2p", "pmos_2_0p13"), ("Mb2n", "nmos_1_0p13")]
    lo.place_row(row, gap=0.7)

    # --- build the net -> [(inst,term)] map from the schematic connectivity ---
    # term order in our port table: D G S B
    nets = {}

    def add(inst, **conn):  # conn: D=.., G=.., S=.., B=..
        for term, net in conn.items():
            nets.setdefault(net, []).append((inst, term))

    add("Mbn",  D="ibias", G="ibias", S="VSS", B="VSS")
    add("Mmir", D="vbp",   G="ibias", S="VSS", B="VSS")
    add("Mbp",  D="vbp",   G="vbp",   S="VDD", B="VDD")
    nin = {1: "n5", 2: "n1", 3: "n2", 4: "n3", 5: "n4"}
    for i in range(1, 6):
        add(f"Mcp{i}", D=f"pp{i}", G="vbp",    S="VDD",     B="VDD")
        add(f"Mp{i}",  D=f"n{i}",  G=nin[i],   S=f"pp{i}",  B="VDD")
        add(f"Mn{i}",  D=f"n{i}",  G=nin[i],   S=f"nn{i}",  B="VSS")
        add(f"Mcn{i}", D=f"nn{i}", G="ibias",  S="VSS",     B="VSS")
    add("Mb1p", D="b1",  G="n5", S="VDD", B="VDD")
    add("Mb1n", D="b1",  G="n5", S="VSS", B="VSS")
    add("Mb2p", D="clk", G="b1", S="VDD", B="VDD")
    add("Mb2n", D="clk", G="b1", S="VSS", B="VSS")

    # --- assign tracks and route: power below, everything else above ---
    ports = {"VDD", "VSS", "ibias", "clk"}
    lo.route_net("VDD", nets.pop("VDD"), track_y=-2.7, mkport=mkport)
    lo.route_net("VSS", nets.pop("VSS"), track_y=-3.3, mkport=mkport)
    # remaining signal/bias nets stacked on M3 tracks above the row
    order = ["ibias", "vbp", "clk", "b1",
             "n1", "n2", "n3", "n4", "n5",
             "pp1", "pp2", "pp3", "pp4", "pp5",
             "nn1", "nn2", "nn3", "nn4", "nn5"]
    y = 2.4
    for net in order:
        lo.route_net(net, nets.pop(net), track_y=y, mkport=(mkport and net in ports))
        y += 0.5
    assert not nets, f"unrouted nets: {list(nets)}"

    lo.finish(outdir)
    return lo


BUILDERS = {"cs_stage": build_cs_stage, "ring_oscillator": build_ring_oscillator}

if __name__ == "__main__":
    cell = sys.argv[1] if len(sys.argv) > 1 else "cs_stage"
    outdir = sys.argv[2] if len(sys.argv) > 2 else "layout"
    mkport = "--noport" not in sys.argv
    lo = BUILDERS[cell](outdir, mkport=mkport)
    sys.stdout.write(lo.tcl())
