// SPDX-FileCopyrightText: 2026 Davide Schiavone
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
// Description: FLL v1 digital core — an OPEN-LOOP digitally-controlled oscillator
// controller. It does two independent things:
//   1. Registers a DAC control word from code_i (clock_i domain). The DAC sets the
//      bias current of the analog current-starved ring oscillator.
//   2. Divides the ring-oscillator clock (ro_clk_i) by 2**DIV_W to produce a slow
//      frequency-monitor output fout_o (for an LED / oscilloscope).
//
// v1 is intentionally OPEN-LOOP: there is no frequency counter, no servo and no
// lock detect. Closing the loop is documented future work (see CLAUDE.md).
//
// Clock domains: clock_i and ro_clk_i are independent and exchange NO data, so
// there is no data clock-domain crossing. The divider uses an asynchronous reset
// because the RO may not be oscillating while reset is asserted; the monitor's
// phase is irrelevant, so the reset-deassertion crossing into the ro_clk_i domain
// is benign (worst case: one count of phase offset).

`default_nettype none
`ifndef __FLL_DIGITAL__
`define __FLL_DIGITAL__

module fll_digital #(
  parameter int unsigned      DAC_W   = `FLL_DAC_W,
  parameter int unsigned      DIV_W   = `FLL_DIV_W,
  parameter logic [DAC_W-1:0] DAC_RST = `FLL_DAC_RST
)(
  // clock_i domain
  input  logic              clock_i,    // system / reference clock
  input  logic              reset_i,    // active-high reset
  input  logic [DAC_W-1:0]  code_i,     // user frequency control code

  // ring-oscillator domain
  input  logic              ro_clk_i,   // ring-oscillator output (clock from analog RO)

  output logic [DAC_W-1:0]  dac_code_o, // to current-steering DAC (sets RO bias current)
  output logic              fout_o      // ro_clk_i / 2**DIV_W frequency monitor
);

  // --- DAC control word: registered pass-through, open loop (clock_i domain) ---
  always_ff @(posedge clock_i) begin
    if (reset_i) begin
      dac_code_o <= DAC_RST;
    end else begin
      dac_code_o <= code_i;
    end
  end

  // --- Frequency monitor: free-running divider in the ro_clk_i domain ---
  logic [DIV_W-1:0] div_cnt;
  always_ff @(posedge ro_clk_i or posedge reset_i) begin
    if (reset_i) begin
      div_cnt <= '0;
    end else begin
      div_cnt <= div_cnt + 1;
    end
  end

  assign fout_o = div_cnt[DIV_W-1];

endmodule // fll_digital

`endif
`default_nettype wire
