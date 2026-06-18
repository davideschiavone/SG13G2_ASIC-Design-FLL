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


BUILDERS = {"cs_stage": build_cs_stage}

if __name__ == "__main__":
    cell = sys.argv[1] if len(sys.argv) > 1 else "cs_stage"
    outdir = sys.argv[2] if len(sys.argv) > 2 else "layout"
    mkport = "--noport" not in sys.argv
    lo = BUILDERS[cell](outdir, mkport=mkport)
    sys.stdout.write(lo.tcl())
