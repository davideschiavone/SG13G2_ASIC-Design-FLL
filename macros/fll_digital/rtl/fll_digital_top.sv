// SPDX-FileCopyrightText: 2026 Davide Schiavone
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
// Description: Top-level wrapper of the fll_digital macro. Converts the active-low
// reset to the core's active-high reset; otherwise a thin pass-through. This is the
// unit hardened by LibreLane.

`default_nettype none
`ifndef __FLL_DIGITAL_TOP__
`define __FLL_DIGITAL_TOP__

module fll_digital_top #(
  parameter  int unsigned      DAC_W   = `FLL_DAC_W,
  parameter  int unsigned      DIV_W   = `FLL_DIV_W,
  parameter  logic [DAC_W-1:0] DAC_RST = `FLL_DAC_RST
)(
  input  logic              clock_i,    // system / reference clock
  input  logic              reset_n_i,  // active-low reset
  input  logic [DAC_W-1:0]  code_i,     // user frequency control code

  input  logic              ro_clk_i,   // ring-oscillator output (from analog RO)

  output logic [DAC_W-1:0]  dac_code_o, // to current-steering DAC
  output logic              fout_o      // ro_clk_i / 2**DIV_W frequency monitor
);

  // Internal active-high reset (wrapper handles polarity conversion)
  logic reset;
  assign reset = ~reset_n_i;

  fll_digital #(
    .DAC_W   (DAC_W),
    .DIV_W   (DIV_W),
    .DAC_RST (DAC_RST)
  ) fll_digital_0 (
    .clock_i    (clock_i),
    .reset_i    (reset),
    .code_i     (code_i),
    .ro_clk_i   (ro_clk_i),
    .dac_code_o (dac_code_o),
    .fout_o     (fout_o)
  );

endmodule // fll_digital_top

`endif
`default_nettype wire
