// SPDX-FileCopyrightText: 2026 Davide Schiavone
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
// Description: Verilator (self-checking, --binary --timing) testbench for the
// fll_digital macro. It instantiates BOTH the DUT (fll_digital_top) and the
// behavioral ring-oscillator model, closing the open-loop datapath:
//
//   code_i -> fll_digital -> dac_code -> RO model -> ro_clk -> fll_digital -> fout
//
// Checks, for several codes: (1) fout period == 1024 * RO period (divide-by-1024
// against the modeled RO frequency), and (2) monotonicity — higher code yields a
// higher fout frequency.

`timescale 1ns/1ps
`default_nettype none

module fll_digital_tb;

  localparam int unsigned DAC_W      = 4;
  localparam real         F_MIN_MHZ  = 50.0;   // must match the RO model defaults
  localparam real         F_STEP_MHZ = 10.0;
  localparam int unsigned DIV        = 1024;   // fll_digital ÷1024

  logic             clock_i   = 1'b0;
  logic             reset_n_i = 1'b0;
  logic [DAC_W-1:0] code_i    = '0;

  wire [DAC_W-1:0]  dac_code;
  wire              ro_clk;
  wire              fout;

  // 50 MHz reference clock (20 ns period)
  always #10 clock_i = ~clock_i;

  // DUT
  fll_digital_top dut (
    .clock_i    (clock_i),
    .reset_n_i  (reset_n_i),
    .code_i     (code_i),
    .ro_clk_i   (ro_clk),
    .dac_code_o (dac_code),
    .fout_o     (fout)
  );

  // Behavioral ring-oscillator model (simulation only): dac_code -> ro_clk frequency.
  ring_oscillator_verilog_behavioral #(
    .CODE_W     (DAC_W),
    .F_MIN_MHZ  (F_MIN_MHZ),
    .F_STEP_MHZ (F_STEP_MHZ)
  ) ro (
    .enable_i (reset_n_i),
    .code_i   (dac_code),
    .clk_o    (ro_clk)
  );

  // Per-code measured fout period (ns), indexed by code.
  real fout_period [0:(1<<DAC_W)-1];
  int  errors = 0;

  // Measure one full fout period (rising edge to rising edge).
  task automatic measure_fout_period(output real period_ns);
    real t0;
    @(posedge fout);
    t0 = $realtime;
    @(posedge fout);
    period_ns = $realtime - t0;
  endtask

  // Apply a code, let it propagate, measure fout, and check the ÷1024 ratio.
  task automatic check_code(input int unsigned code);
    real meas, f_ro_mhz, exp_ns;
    code_i = code[DAC_W-1:0];
    @(posedge clock_i);            // dac_code latches the new code
    #1;
    measure_fout_period(meas);
    fout_period[code] = meas;
    f_ro_mhz = F_MIN_MHZ + code * F_STEP_MHZ;
    exp_ns   = DIV * 1000.0 / f_ro_mhz;        // fout period = DIV * RO period
    $display("  code=%20d  dac_code=%20d  f_RO=%6.1f MHz | fout meas=%9.1f ns  exp=%9.1f ns  (%0.3f MHz)",
             code, dac_code, f_ro_mhz, meas, exp_ns, 1000.0/meas);
    if (meas > exp_ns*1.01 || meas < exp_ns*0.99) begin
      $display("    FAIL: fout period off by > 1%% vs ideal ÷1024");
      errors++;
    end
  endtask

  // Watchdog
  initial begin
    #2_000_000;  // 2 ms sim time
    $display("TIMEOUT — fout did not behave as expected");
    $fatal;
  end

  initial begin
    $display("== fll_digital + behavioral ring-oscillator (open-loop DCO) ==");
    reset_n_i = 1'b0;
    code_i    = '0;
    repeat (5) @(posedge clock_i);
    reset_n_i = 1'b1;
    @(posedge clock_i);

    check_code(0);
    check_code(2);
    check_code(8);
    check_code(15);

    // Monotonicity: higher code => higher fout frequency => shorter period.
    if (!(fout_period[15] < fout_period[8] &&
          fout_period[8]  < fout_period[2] &&
          fout_period[2]  < fout_period[0])) begin
      $display("  FAIL: fout period is not monotonically decreasing with code");
      errors++;
    end else begin
      $display("  monotonic: period(0) > period(2) > period(8) > period(15)  OK");
    end

    if (errors == 0) $display("== ALL CHECKS PASSED ==");
    else begin
      $display("== %0d CHECK(S) FAILED ==", errors);
      $fatal;
    end
    $finish;
  end

endmodule

`default_nettype wire
