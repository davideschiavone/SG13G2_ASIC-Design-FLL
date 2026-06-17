#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 Davide Schiavone
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
"""
Generate Xschem schematics (.sch) for the FLL analog blocks (ring oscillator, 4-bit
current-steering DAC) from a structured device/net description that MIRRORS the
hand-written SPICE in macros/*/spice/. Connectivity is by net-label (a lab_wire is
placed on every device pin), so the netlisted schematic is electrically identical to
the SPICE by construction. These schematics are for VISUALIZATION in Xschem; the
SPICE files remain the simulation source of truth.

Run (from repo root, inside the container):  python3 scripts/gen_xschem.py
"""
from itertools import count

# Device pin offsets for rot=0 flip=0 (from the PDK symbols).
NMOS = {"d": (20, -30), "g": (-20, 0), "s": (20, 30), "b": (20, 0)}
PMOS = {"d": (20, 30),  "g": (-20, 0), "s": (20, -30), "b": (20, 0)}
ISRC = {"p": (0, -30), "m": (0, 30)}

HEADER = "v {xschem version=3.4.8RC file_version=1.3}\nG {}\nK {}\nV {}\nS {}\nE {}\n"

_lid = count(1)
_pid = count(1)


def _label(x, y, net):
    return f"C {{devices/lab_wire.sym}} {x} {y} 0 0 {{name=l{next(_lid)} lab={net}}}\n"


def mos(name, kind, x, y, nets, w, l, ng=1, m=1):
    sym = "sg13_lv_nmos.sym" if kind == "nmos" else "sg13_lv_pmos.sym"
    model = "sg13_lv_nmos" if kind == "nmos" else "sg13_lv_pmos"
    pins = NMOS if kind == "nmos" else PMOS
    if name.startswith("X"):
        name = name[1:]  # spiceprefix=X already adds the X => avoid double-X in netlist
    body = f"name={name}\nl={l}\nw={w}\nng={ng}\nm={m}\nmodel={model}\nspiceprefix=X\n"
    out = f"C {{{sym}}} {x} {y} 0 0 {{{body}}}\n"
    for pin, net in nets.items():
        dx, dy = pins[pin]
        out += _label(x + dx, y + dy, net)
    return out


def isrc(name, x, y, pnet, mnet, value):
    out = f"C {{devices/isource.sym}} {x} {y} 0 0 {{name={name} value=\"{value}\"}}\n"
    out += _label(x + ISRC["p"][0], y + ISRC["p"][1], pnet)
    out += _label(x + ISRC["m"][0], y + ISRC["m"][1], mnet)
    return out


def port(name, kind, x, y):
    sym = {"i": "devices/ipin.sym", "o": "devices/opin.sym", "io": "devices/iopin.sym"}[kind]
    return f"C {{{sym}}} {x} {y} 0 0 {{name=P{next(_pid)} lab={name}}}\n"


def title(text, x, y):
    return f"T {{{text}}} {x} {y} 0 0 0.5 0.5 {{}}\n"


# ----------------------------------------------------------------------------------
def gen_ring_oscillator():
    s = HEADER
    s += title("Current-starved ring oscillator (5 stages) - schematic == ring_oscillator.spice", -200, -900)

    # Bias generation (column x=0)
    s += mos("XMbn",  "nmos", 0, 0,    {"d": "ibias", "g": "ibias", "s": "VSS", "b": "VSS"}, w="1u", l="0.5u")
    s += mos("XMmir", "nmos", 0, -250, {"d": "vbp",   "g": "ibias", "s": "VSS", "b": "VSS"}, w="1u", l="0.5u")
    s += mos("XMbp",  "pmos", 0, -500, {"d": "vbp",   "g": "vbp",   "s": "VDD", "b": "VDD"}, w="2u", l="0.5u")

    # 5 current-starved inverter stages
    ins  = ["n5", "n1", "n2", "n3", "n4"]
    outs = ["n1", "n2", "n3", "n4", "n5"]
    for i in range(5):
        x = 350 + i * 300
        inn, outn = ins[i], outs[i]
        pp, nn = f"pp{i+1}", f"nn{i+1}"
        s += mos(f"XMcp{i+1}", "pmos", x, -600, {"d": pp,   "g": "vbp",  "s": "VDD", "b": "VDD"}, w="2u",   l="0.5u")
        s += mos(f"XMp{i+1}",  "pmos", x, -400, {"d": outn, "g": inn,    "s": pp,    "b": "VDD"}, w="1u",   l="0.13u")
        s += mos(f"XMn{i+1}",  "nmos", x, -200, {"d": outn, "g": inn,    "s": nn,    "b": "VSS"}, w="0.5u", l="0.13u")
        s += mos(f"XMcn{i+1}", "nmos", x, 0,    {"d": nn,   "g": "ibias","s": "VSS", "b": "VSS"}, w="1u",   l="0.5u")

    # Output buffer (taps n5)
    xb = 350 + 5 * 300
    s += mos("XMb1p", "pmos", xb, -600, {"d": "b1",  "g": "n5", "s": "VDD", "b": "VDD"}, w="1u",   l="0.13u")
    s += mos("XMb1n", "nmos", xb, -400, {"d": "b1",  "g": "n5", "s": "VSS", "b": "VSS"}, w="0.5u", l="0.13u")
    s += mos("XMb2p", "pmos", xb, -200, {"d": "clk", "g": "b1", "s": "VDD", "b": "VDD"}, w="2u",   l="0.13u")
    s += mos("XMb2n", "nmos", xb, 0,    {"d": "clk", "g": "b1", "s": "VSS", "b": "VSS"}, w="1u",   l="0.13u")

    # Ports
    s += port("VDD",   "io", -200, -700)
    s += port("VSS",   "io", -200, 200)
    s += port("ibias", "io", -350, 100)
    s += port("clk",   "o",  xb + 250, -200)
    return s


# ----------------------------------------------------------------------------------
def gen_dac4():
    s = HEADER
    s += title("4-bit current-steering DAC - schematic == dac4.spice (IREF ideal ref)", -200, -1000)

    # Reference: ideal current sets PMOS mirror bias vpcs
    s += mos("XMpref", "pmos", 0, -500, {"d": "vpcs", "g": "vpcs", "s": "VDD", "b": "VDD"}, w="2u", l="1u")
    s += isrc("Iref", 0, -150, "vpcs", "VSS", "2u")

    # Per-bit: complement inverter + steering cell (PMOS source + 2 NMOS switches)
    mw = [1, 2, 4, 8]
    for i in range(4):
        x = 350 + i * 350
        b, bb, cs = f"b{i}", f"b{i}b", f"cs{i}"
        # complement inverter
        s += mos(f"XMinvp{i}", "pmos", x, -900, {"d": bb, "g": b, "s": "VDD", "b": "VDD"}, w="1u",   l="0.13u")
        s += mos(f"XMinvn{i}", "nmos", x, -700, {"d": bb, "g": b, "s": "VSS", "b": "VSS"}, w="0.5u", l="0.13u")
        # steering cell
        s += mos(f"XMsrc{i}", "pmos", x, -350, {"d": cs,      "g": "vpcs", "s": "VDD", "b": "VDD"}, w="2u", l="1u",    m=mw[i])
        s += mos(f"XMto{i}",  "nmos", x, -100, {"d": "iout",  "g": b,      "s": cs,    "b": "VSS"}, w="1u", l="0.13u", m=mw[i])
        s += mos(f"XMdo{i}",  "nmos", x, 150,  {"d": "ndump", "g": bb,     "s": cs,    "b": "VSS"}, w="1u", l="0.13u", m=mw[i])

    # Shared dump diode
    s += mos("XMdump", "nmos", 350 + 4 * 350, 150, {"d": "ndump", "g": "ndump", "s": "VSS", "b": "VSS"}, w="1u", l="0.5u")

    # Ports
    s += port("VDD",  "io", -200, -700)
    s += port("VSS",  "io", -200, 350)
    for i in range(4):
        s += port(f"b{i}", "i", 350 + i * 350 - 60, -900)
    s += port("iout", "io", 350 + 4 * 350 + 200, -100)
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
