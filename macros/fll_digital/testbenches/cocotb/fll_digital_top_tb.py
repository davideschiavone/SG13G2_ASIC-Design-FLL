# SPDX-FileCopyrightText: 2026 Davide Schiavone
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
# Description: cocotb testbench for the fll_digital macro (FLL v1, open-loop DCO).
#   - DAC control word is a registered pass-through of code_i (clock_i domain).
#   - fout_o is ro_clk_i divided by 2**DIV_W (= 1024).

import os
import re
import logging
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, FallingEdge, ClockCycles
from cocotb_tools.runner import get_runner

sim      = os.getenv("SIM", "icarus")
pdk_root = os.getenv("PDK_ROOT", Path("~/.ciel").expanduser())
pdk      = os.getenv("PDK", "ihp-sg13g2")
scl      = os.getenv("SCL", "sg13g2_stdcell")
# GL=1 selects the gate-level netlist; anything else stays in RTL mode.
gl       = os.getenv("GL", "0").strip().lower() in ("1", "true", "yes", "on")

hdl_toplevel = "fll_digital_top"

# Defaults sourced from rtl/constants.sv — single source of truth shared with the DUT.
_CONSTANTS_SV = Path(__file__).resolve().parent / "../../rtl/constants.sv"


def _read_define(name: str) -> str:
    """Extract the value of a `define <name> <value>` macro from rtl/constants.sv."""
    text = _CONSTANTS_SV.read_text()
    m = re.search(rf"^\s*`define\s+{re.escape(name)}\s+(\S+)", text, re.MULTILINE)
    if m is None:
        raise RuntimeError(f"`{name} not found in {_CONSTANTS_SV}")
    return m.group(1)


DAC_W        = int(_read_define("FLL_DAC_W"))
DIV_W        = int(_read_define("FLL_DIV_W"))
DAC_RST      = int(_read_define("FLL_DAC_RST"))
DIV          = 1 << DIV_W                       # divide ratio (1024)
CLK_FREQ_MHZ = int(float(_read_define("FLL_CLK_FREQ_DEFAULT")) / 1e6)
RO_FREQ_MHZ  = int(float(_read_define("FLL_RO_FREQ_DEFAULT")) / 1e6)


def _start_clock(signal, freq_mhz):
    """Start a free-running clock on `signal` at freq_mhz MHz."""
    period_ns = round(1 / freq_mhz * 1000, 4)
    cocotb.start_soon(Clock(signal, period_ns, "ns").start())


async def start_up(dut):
    """Start both clocks, apply reset, leave reset deasserted and code_i = 0."""
    _start_clock(dut.clock_i, CLK_FREQ_MHZ)
    _start_clock(dut.ro_clk_i, RO_FREQ_MHZ)

    dut.code_i.value = 0
    dut.reset_n_i.value = 0
    await ClockCycles(dut.clock_i, 3)
    dut.reset_n_i.value = 1
    await RisingEdge(dut.clock_i)
    await Timer(1, "ns")


@cocotb.test()
async def test_reset_defaults(dut):
    """After reset, dac_code_o == DAC_RST and fout_o == 0."""
    log = logging.getLogger("fll_tb")

    _start_clock(dut.clock_i, CLK_FREQ_MHZ)
    _start_clock(dut.ro_clk_i, RO_FREQ_MHZ)
    dut.code_i.value = 0
    dut.reset_n_i.value = 0
    await ClockCycles(dut.clock_i, 3)
    await Timer(1, "ns")

    assert int(dut.fout_o.value) == 0, \
        f"fout not 0 under reset (got {int(dut.fout_o.value)})"
    assert int(dut.dac_code_o.value) == DAC_RST, \
        f"dac_code not DAC_RST={DAC_RST} under reset (got {int(dut.dac_code_o.value)})"

    log.info("Reset defaults OK.")


@cocotb.test()
async def test_code_passthrough(dut):
    """dac_code_o follows code_i (registered, one clock later) across the full range."""
    log = logging.getLogger("fll_tb")
    await start_up(dut)

    for code in range(1 << DAC_W):
        dut.code_i.value = code
        await RisingEdge(dut.clock_i)
        await Timer(1, "ns")
        got = int(dut.dac_code_o.value)
        assert got == code, f"dac_code expected {code}, got {got}"

    log.info("Code pass-through OK across all %d codes.", 1 << DAC_W)


@cocotb.test()
async def test_divide_by_1024(dut):
    """fout_o = ro_clk_i / DIV: high after DIV/2 ro edges, low again after DIV."""
    log = logging.getLogger("fll_tb")
    await start_up(dut)

    # Re-assert reset to clear the ro-domain divider to a known state (div_cnt = 0).
    dut.reset_n_i.value = 0
    await ClockCycles(dut.clock_i, 2)
    await Timer(1, "ns")
    assert int(dut.fout_o.value) == 0, "fout not 0 after reset"

    # Deassert reset cleanly between ro edges, then count ro rising edges.
    await FallingEdge(dut.ro_clk_i)
    dut.reset_n_i.value = 1

    half = DIV // 2
    for _ in range(half):
        await RisingEdge(dut.ro_clk_i)
    await Timer(1, "ns")
    assert int(dut.fout_o.value) == 1, \
        f"fout should be high after {half} ro edges (got {int(dut.fout_o.value)})"

    for _ in range(half):
        await RisingEdge(dut.ro_clk_i)
    await Timer(1, "ns")
    assert int(dut.fout_o.value) == 0, \
        f"fout should be low after {DIV} ro edges (got {int(dut.fout_o.value)})"

    log.info("Divide-by-%d OK.", DIV)


def fll_digital_top_runner():
    proj_path = Path(__file__).resolve().parent

    sources  = []
    includes = [proj_path / "../../rtl/"]

    if gl:
        # SCL models + unpowered gate-level netlist of the macro
        sources.append(Path(pdk_root) / pdk / "libs.ref" / scl / "verilog" / f"{scl}.v")
        sources.append(Path(pdk_root) / pdk / "libs.ref" / scl / "verilog" / "sg13g2_udp.v")
        sources.append(proj_path / f"../../final/nl/{hdl_toplevel}.nl.v")
    else:
        sources.append(proj_path / "../../rtl/constants.sv")
        sources.append(proj_path / "../../rtl/fll_digital.sv")
        sources.append(proj_path / "../../rtl/fll_digital_top.sv")

    build_args = []
    if sim == "icarus":
        # -gno-specify: skip specify blocks (sg13g2_stdcell.v specify paths
        # iverilog cannot parse); harmless for RTL.
        build_args = ["-DSIM", "-gno-specify"]
    if sim == "verilator":
        build_args = ["--timing", "--trace", "--trace-fst", "--trace-structs"]

    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel=hdl_toplevel,
        always=True,
        includes=includes,
        build_args=build_args,
        waves=True,
        timescale=("1ns", "1fs"),
    )
    runner.test(
        hdl_toplevel=hdl_toplevel,
        test_module="fll_digital_top_tb",
        waves=True,
    )


if __name__ == "__main__":
    fll_digital_top_runner()
