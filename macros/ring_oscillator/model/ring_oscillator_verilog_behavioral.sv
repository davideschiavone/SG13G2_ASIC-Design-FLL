// SPDX-FileCopyrightText: 2026 Davide Schiavone
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
// Description: Behavioral, SIMULATION-ONLY model of the analog current-starved ring
// oscillator (the future macros/ring_oscillator analog macro).
//
// Pure Verilog (NOT Verilog-A): it maps the digital control code directly to an output
// clock frequency, folding in the (idealised) DAC code -> bias-current -> frequency
// response. Higher code => higher frequency. This lets us co-simulate the open-loop
// datapath (fll_digital + RO) long before the transistor-level RO/DAC exist; it is
// replaced by the real analog blocks (SPICE / Verilog-A) in later steps.
//
// UNSYNTHESIZABLE: uses #delays and `real`. Guarded by `ifndef SYNTHESIS so it can
// never leak into synthesis even if accidentally added to a synth source list.

`ifndef SYNTHESIS
`timescale 1ns/1ps
`default_nettype none

module ring_oscillator_verilog_behavioral #(
  parameter int unsigned CODE_W     = 4,
  parameter real         F_MIN_MHZ  = 50.0,   // output frequency at code = 0
  parameter real         F_STEP_MHZ = 10.0    // MHz added per code step (monotonic)
)(
  input  wire              enable_i,           // RO runs while high (models power/bias on)
  input  wire [CODE_W-1:0] code_i,             // control code (= DAC control word)
  output reg               clk_o               // oscillator output
);

  initial clk_o = 1'b0;

  // Free-running toggle at the current half-period; forced low when disabled.
  // The half-period is recomputed from the live code at the start of every half
  // cycle (so a code change takes effect on the next edge). It is always >= the
  // code=0 value, so the delay is never zero; the ZERODLY warning below is only
  // because Verilator cannot prove that statically.
  /* verilator lint_off ZERODLY */
  always begin
    real freq_mhz;
    real half_ns;
    freq_mhz = F_MIN_MHZ + $itor(code_i) * F_STEP_MHZ;   // monotonic: higher code => higher f
    half_ns  = 500.0 / freq_mhz;                          // 1000 / (2 * f_MHz)
    #(half_ns);
    if (enable_i) clk_o = ~clk_o;
    else          clk_o = 1'b0;
  end
  /* verilator lint_on ZERODLY */

endmodule

`default_nettype wire
`endif
