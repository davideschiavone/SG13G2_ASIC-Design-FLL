// SPDX-FileCopyrightText: 2026 Davide Schiavone
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
// Description: Shared constants for the fll_digital macro (FLL v1, open-loop DCO).
//
// Implemented as `define macros (not a SystemVerilog package) for Yosys
// compatibility — its Verilog frontend cannot parse `import pkg::*;` in a
// module header. Compile constants.sv before any module that references the
// macros (the Makefile lists it first in MODULES_SIM).

`ifndef __FLL_DIGITAL_CONSTANTS__
`define __FLL_DIGITAL_CONSTANTS__

// System / reference clock frequency for simulation (Hz)
`define FLL_CLK_FREQ_DEFAULT   50.0e6

// Nominal ring-oscillator frequency for simulation (Hz).
// In RTL sim the analog RO is modeled simply as a clock on ro_clk_i.
`define FLL_RO_FREQ_DEFAULT    100.0e6

// DAC control-word width (bits)
`define FLL_DAC_W              4

// Frequency-monitor divider width: fout = ro_clk / 2**FLL_DIV_W  (10 => /1024)
`define FLL_DIV_W             10

// DAC reset/default code: mid-scale of a 4-bit code (8 of 0..15)
`define FLL_DAC_RST            8

`endif
