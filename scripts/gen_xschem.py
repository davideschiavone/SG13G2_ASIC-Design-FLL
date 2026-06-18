#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 Davide Schiavone
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
"""
Generate Xschem schematics (.sch) for the FLL analog blocks (ring oscillator, 4-bit
current-steering DAC). Style: transistors are placed in STACKS so series source/drain
pins coincide (a real connection, drawn as touching device stubs); signal nets are
drawn as WIRES; power and bias rails (VDD, VSS, vbp, vbn/ibias, vpcs) are shown as
net-name LABELS (standard practice — fully wiring rails across many stages is a mess).

Connectivity mirrors the hand SPICE in macros/*/spice/, and every schematic is verified
to netlist identically (xschem -n). These schematics are for VISUALIZATION; the SPICE
files remain the simulation source of truth.

Run (from repo root, in the container):  python3 scripts/gen_xschem.py
"""
from itertools import count

# Device pin offsets for rot=0 flip=0 (from the PDK symbols).
NMOS = {"d": (20, -30), "g": (-20, 0), "s": (20, 30), "b": (20, 0)}
PMOS = {"d": (20, 30),  "g": (-20, 0), "s": (20, -30), "b": (20, 0)}
ISRC = {"p": (0, -30), "m": (0, 30)}

HEADER = "v {xschem version=3.4.8RC file_version=1.3}\nG {}\nK {}\nV {}\nS {}\nE {}\n"
_lid = count(1)
_pid = count(1)


def P(kind, x, y, which):
    """Absolute coordinate of a device pin."""
    off = (NMOS if kind == "nmos" else PMOS)[which]
    return (x + off[0], y + off[1])


def mos(name, kind, x, y, w, l, ng=1, m=1):
    sym = "sg13_lv_nmos.sym" if kind == "nmos" else "sg13_lv_pmos.sym"
    model = "sg13_lv_nmos" if kind == "nmos" else "sg13_lv_pmos"
    if name.startswith("X"):
        name = name[1:]  # spiceprefix=X adds the X
    body = f"name={name}\nl={l}\nw={w}\nng={ng}\nm={m}\nmodel={model}\nspiceprefix=X\n"
    out = f"C {{{sym}}} {x} {y} 0 0 {{{body}}}\n"
    # bulk tie (label at the body pin)
    bx, by = P(kind, x, y, "b")
    out += lab(bx, by, "VDD" if kind == "pmos" else "VSS")
    return out


def isrc(name, x, y, pnet, mnet, value):
    out = f"C {{devices/isource.sym}} {x} {y} 0 0 {{name={name} value=\"{value}\"}}\n"
    out += lab(x + ISRC["p"][0], y + ISRC["p"][1], pnet)
    out += lab(x + ISRC["m"][0], y + ISRC["m"][1], mnet)
    return out


def lab(x, y, net):
    return f"C {{devices/lab_wire.sym}} {x} {y} 0 0 {{name=l{next(_lid)} lab={net}}}\n"


def port(name, kind, x, y):
    sym = {"i": "devices/ipin.sym", "o": "devices/opin.sym", "io": "devices/iopin.sym"}[kind]
    return f"C {{{sym}}} {x} {y} 0 0 {{name=P{next(_pid)} lab={name}}}\n"


def wire(x1, y1, x2, y2):
    return f"N {x1} {y1} {x2} {y2} {{}}\n"


def title(text, x, y):
    return f"T {{{text}}} {x} {y} 0 0 0.4 0.4 {{}}\n"


# ----------------------------------------------------------------------------------
def gen_ring_oscillator():
    s = HEADER
    s += title("Current-starved ring oscillator (5 stages) == ring_oscillator.spice  "
               "[VDD/VSS/vbp/ibias are labeled rails]", -400, -160)
    COLW = 180

    def stage(i, x, innet, outnet):
        t = ""
        # stacked: Mcp(0) Mp(60) Mn(120) Mcn(180); series pins coincide on the right
        t += mos(f"XMcp{i}", "pmos", x, 0,   w="2u",   l="0.5u")
        t += mos(f"XMp{i}",  "pmos", x, 60,  w="1u",   l="0.13u")
        t += mos(f"XMn{i}",  "nmos", x, 120, w="0.5u", l="0.13u")
        t += mos(f"XMcn{i}", "nmos", x, 180, w="1u",   l="0.5u")
        # rail / bias labels
        t += lab(*P("pmos", x, 0,   "s"), "VDD")     # Mcp source
        t += lab(*P("pmos", x, 0,   "g"), "vbp")     # Mcp gate
        t += lab(*P("nmos", x, 180, "s"), "VSS")     # Mcn source
        t += lab(*P("nmos", x, 180, "g"), "ibias")   # Mcn gate (= Vbn)
        # input gate bus (Mp.g & Mn.g tied) -> wire vertical + name it
        gpx, _ = P("pmos", x, 60, "g")               # (x-20, 60)
        t += wire(gpx, 60, gpx, 120)
        t += lab(gpx, 90, innet)
        # output node (Mp.d == Mn.d coincide at (x+20,90)) -> name it
        ox, oy = P("pmos", x, 60, "d")               # (x+20, 90)
        t += lab(ox, oy, outnet)
        return t

    # ring chain: stage i drives n{i}; stage1 input is the feedback n5
    ins  = ["n5", "n1", "n2", "n3", "n4"]
    outs = ["n1", "n2", "n3", "n4", "n5"]
    for i in range(5):
        s += stage(i + 1, i * COLW, ins[i], outs[i])

    # --- bias generator (left), connected by labels (vbp / ibias / VDD / VSS) ---
    bx = -260
    s += mos("XMbp",  "pmos", bx, 0,   w="2u", l="0.5u")   # diode: d=g=vbp, s=VDD
    s += lab(*P("pmos", bx, 0, "s"), "VDD")
    s += lab(*P("pmos", bx, 0, "g"), "vbp")
    s += lab(*P("pmos", bx, 0, "d"), "vbp")
    s += mos("XMmir", "nmos", bx, 120, w="1u", l="0.5u")   # d=vbp, g=ibias, s=VSS
    s += lab(*P("nmos", bx, 120, "d"), "vbp")
    s += lab(*P("nmos", bx, 120, "g"), "ibias")
    s += lab(*P("nmos", bx, 120, "s"), "VSS")
    s += mos("XMbn",  "nmos", bx - 150, 120, w="1u", l="0.5u")  # diode: d=g=ibias, s=VSS
    s += lab(*P("nmos", bx - 150, 120, "d"), "ibias")
    s += lab(*P("nmos", bx - 150, 120, "g"), "ibias")
    s += lab(*P("nmos", bx - 150, 120, "s"), "VSS")
    s += port("ibias", "io", bx - 320, 120)
    s += lab(bx - 320, 120, "ibias")

    # --- ring signal wiring: out_i (x_i+20,90) -> in_{i+1} ((x_{i+1})-20,90) ---
    for i in range(4):
        ox = i * COLW + 20
        ix = (i + 1) * COLW - 20
        s += wire(ox, 90, ix, 90)
    # feedback n5 -> stage1 input: carried by the net label "n5" (stage5 out and
    # stage1 in are both labeled n5). A drawn wrap-around wire would cross pin columns.

    # --- output buffer (two stacked inverters), taps n5 ---
    xb = 5 * COLW + 40
    s += mos("XMb1p", "pmos", xb, 0,   w="1u",   l="0.13u")
    s += mos("XMb1n", "nmos", xb, 60,  w="0.5u", l="0.13u")
    s += mos("XMb2p", "pmos", xb, 150, w="2u",   l="0.13u")
    s += mos("XMb2n", "nmos", xb, 210, w="1u",   l="0.13u")
    s += lab(*P("pmos", xb, 0,   "s"), "VDD")
    s += lab(*P("nmos", xb, 60,  "s"), "VSS")
    s += lab(*P("pmos", xb, 150, "s"), "VDD")
    s += lab(*P("nmos", xb, 210, "s"), "VSS")
    # inv1 input = n5 (gates of Mb1p/Mb1n)
    g1x, _ = P("pmos", xb, 0, "g")
    s += wire(g1x, 0, g1x, 60) + lab(g1x, 30, "n5")
    # inv1 output b1 (Mb1p.d == Mb1n.d at (xb+20,30))
    b1x, b1y = P("pmos", xb, 0, "d")
    s += lab(b1x, b1y, "b1")
    # inv2 input = b1 (carried by label b1 from inv1 output to this gate bus)
    g2x, _ = P("pmos", xb, 150, "g")
    s += wire(g2x, 150, g2x, 210) + lab(g2x, 180, "b1")
    # inv2 output = clk
    cx, cy = P("pmos", xb, 150, "d")
    s += lab(cx, cy, "clk")
    s += wire(cx, cy, cx + 60, cy) + port("clk", "o", cx + 60, cy)

    # ports for rails
    s += port("VDD", "io", -260, -120) + lab(-260, -120, "VDD")
    s += port("VSS", "io", -260, 360) + lab(-260, 360, "VSS")
    return s


# ----------------------------------------------------------------------------------
def gen_dac4():
    s = HEADER
    s += title("4-bit current-steering DAC == dac4.spice  [VDD/VSS/vpcs labeled rails]", -300, -200)
    COLW = 260

    # reference: ideal current sets vpcs (PMOS diode)
    s += mos("XMpref", "pmos", -260, 0, w="2u", l="1u")
    s += lab(*P("pmos", -260, 0, "s"), "VDD")
    s += lab(*P("pmos", -260, 0, "g"), "vpcs")
    s += lab(*P("pmos", -260, 0, "d"), "vpcs")
    s += isrc("Iref", -260, 160, "vpcs", "VSS", "2u")   # isrc() already labels its pins

    mw = [1, 2, 4, 8]
    for i in range(4):
        x = i * COLW
        b, bb, cs = f"b{i}", f"b{i}b", f"cs{i}"
        # complement inverter (stacked pmos/nmos, coincident output)
        s += mos(f"XMinvp{i}", "pmos", x, -120, w="1u",   l="0.13u")
        s += mos(f"XMinvn{i}", "nmos", x, -60,  w="0.5u", l="0.13u")
        s += lab(*P("pmos", x, -120, "s"), "VDD")
        s += lab(*P("nmos", x, -60,  "s"), "VSS")
        gx, _ = P("pmos", x, -120, "g")
        s += wire(gx, -120, gx, -60) + lab(gx, -90, b)
        ox, oy = P("pmos", x, -120, "d")  # inverter output == bb
        s += lab(ox, oy, bb)
        s += port(b, "i", gx - 60, -90) + lab(gx - 60, -90, b)

        # steering cell: PMOS source (mw units) -> cs ; two NMOS switches to iout / ndump
        s += mos(f"XMsrc{i}", "pmos", x, 120, w="2u", l="1u", m=mw[i])
        s += lab(*P("pmos", x, 120, "s"), "VDD")
        s += lab(*P("pmos", x, 120, "g"), "vpcs")
        csx, csy = P("pmos", x, 120, "d")  # (x+20,150)
        s += lab(csx, csy, cs)
        # switches below
        s += mos(f"XMto{i}", "nmos", x - 50, 260, w="1u", l="0.13u", m=mw[i])  # d=iout s=cs g=b
        s += mos(f"XMdo{i}", "nmos", x + 70, 260, w="1u", l="0.13u", m=mw[i])  # d=ndump s=cs g=bb
        # cs: source (bottom) of both switches; wire from Msrc drain down to both
        tox, toy = P("nmos", x - 50, 260, "s")   # (x-30, 290)
        dox, doy = P("nmos", x + 70, 260, "s")   # (x+90, 290)
        s += wire(csx, csy, csx, 290) + wire(tox, 290, dox, 290)
        s += lab(tox, 290, cs)
        # drains -> iout / ndump (labels)
        s += lab(*P("nmos", x - 50, 260, "d"), "iout")
        s += lab(*P("nmos", x + 70, 260, "d"), "ndump")
        # gates
        s += lab(*P("nmos", x - 50, 260, "g"), b)
        s += lab(*P("nmos", x + 70, 260, "g"), bb)

    # shared dump diode
    xd = 4 * COLW
    s += mos("XMdump", "nmos", xd, 260, w="1u", l="0.5u")
    s += lab(*P("nmos", xd, 260, "d"), "ndump")
    s += lab(*P("nmos", xd, 260, "g"), "ndump")
    s += lab(*P("nmos", xd, 260, "s"), "VSS")

    # ports / rails
    s += port("iout", "io", xd + 120, 230) + lab(xd + 120, 230, "iout")
    s += port("VDD", "io", -260, -200) + lab(-260, -200, "VDD")
    s += port("VSS", "io", -260, 360) + lab(-260, 360, "VSS")
    return s


def main():
    targets = {
        "macros/ring_oscillator/schematic/xschem/ring_oscillator.sch": gen_ring_oscillator(),
        "macros/dac/schematic/xschem/dac4.sch": gen_dac4(),
    }
    for path, text in targets.items():
        with open(path, "w") as f:
            f.write(text)
        print(f"wrote {path}  ({text.count(chr(10))} lines)")


if __name__ == "__main__":
    main()
