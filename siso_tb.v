
`timescale 1ns / 1ps

// ============================================================================
// Project        : Shift Register Design Suite
// Design         : 4-Bit Serial-In Serial-Out (SISO) Shift Register
// Module         : siso_tb
// File Name      : siso_tb.v
//
// Problem Statement:
// ------------------
// Develop a Verilog testbench to verify a 4-bit Serial-In Serial-Out
// (SISO) shift register.
//
// The testbench generates a 100 MHz clock, applies an asynchronous
// active-low reset, and transmits a predefined serial input sequence.
//
// It verifies that each input bit enters the shift register correctly,
// propagates through the four stages, and becomes available at the
// 4-bit parallel output SO[3:0].
//
// Verification Objectives:
// ------------------------
// 1. Generate a 100 MHz clock with a 10 ns period.
// 2. Verify asynchronous active-low reset.
// 3. Apply a predefined serial input sequence.
// 4. Verify all four internal register stages.
// 5. Verify the complete 4-bit parallel output.
// 6. Detect incorrect, unknown (X), and high-impedance (Z) values.
// 7. Generate a professional simulation report.
//
// Test Configuration:
// -------------------
// DUT Module       : siso_4bit
// Register Width   : 4 bits
// Output Width     : 4 bits
// Clock Period     : 10 ns
// Clock Frequency  : 100 MHz
// Reset Type       : Asynchronous, active-low
// Input Sequence   : 1, 0, 1, 1, 0, 0
//
// Developer        : Ghulam Yaseen Nangraj
// Date             : 2026-11-16
// HDL Standard     : IEEE 1364-2005 (Verilog-2001)
// Development Tool : AMD Xilinx Vivado 2025.2.1
// Simulator        : XSIM
//
// ============================================================================

module siso_tb;

    // ========================================================================
    // 1. TESTBENCH SIGNAL DECLARATIONS
    // ========================================================================

    reg clk;
    reg rst_n;
    reg si;

    // Four-bit parallel output from the DUT.
    wire [3:0] so;

    // Independent reference model for expected register contents.
    reg [3:0] expected_reg;

    // Verification counters.
    integer error_count;
    integer test_count;


    // ========================================================================
    // 2. DEVICE UNDER TEST (DUT) INSTANTIATION
    // ========================================================================

    siso_4bit dut (
        .clk   (clk),
        .rst_n (rst_n),
        .si    (si),
        .so    (so)
    );


    // ========================================================================
    // 3. CLOCK GENERATION
    // ========================================================================
    // Clock Period    = 10 ns
    // Clock Frequency = 100 MHz
    //
    // Clock toggles every 5 ns:
    // Logic 0 = 5 ns
    // Logic 1 = 5 ns
    // ========================================================================

    initial begin
        clk = 1'b0;
    end

    always #5 clk = ~clk;


    // ========================================================================
    // 4. WAVEFORM DUMP CONFIGURATION
    // ========================================================================
    // Generate a VCD waveform file for external waveform analysis.
    // Vivado XSIM also provides its native waveform viewer.
    // ========================================================================

    initial begin
        $dumpfile("siso_tb.vcd");
        $dumpvars(0, siso_tb);
    end


    // ========================================================================
    // 5. MAIN TEST SEQUENCE
    // ========================================================================

    initial begin

        // --------------------------------------------------------------------
        // Initialize Testbench Variables
        // --------------------------------------------------------------------

        rst_n        = 1'b0;
        si           = 1'b0;
        expected_reg = 4'b0000;

        error_count  = 0;
        test_count   = 0;


        // --------------------------------------------------------------------
        // Display Simulation Header
        // --------------------------------------------------------------------

        $display("");
        $display("==============================================================");
        $display("             SISO SHIFT REGISTER VERIFICATION");
        $display("==============================================================");
        $display(" Design          : 1-Bit SISO Shift Register");
        $display(" Clock Frequency : 100 MHz");
        $display(" Clock Period    : 10 ns");
        $display(" Reset           : Asynchronous Active-Low");
        $display(" Input           : Serial (SI)");
        $display(" Output          : Serial (SO[3])");
        $display(" Input Sequence  : 1 0 1 1 0 0");
        $display("==============================================================");
        $display("");


        // ====================================================================
        // TEST 1: ASYNCHRONOUS RESET VERIFICATION
        // ====================================================================
        // Assert reset independently of the clock.
        // Verify that all four register stages and parallel outputs clear.
        // ====================================================================

        $display("TEST 1: ASYNCHRONOUS RESET VERIFICATION");
        $display("--------------------------------------------------------------");

        // Wait without requiring a clock edge.
        #2;

        test_count = test_count + 1;

        // Check internal register and external parallel output.
        if ((dut.shift_reg !== 4'b0000) ||
            (so !== 4'b0000)) begin

            error_count = error_count + 1;

            $display(" [FAIL] Asynchronous reset verification");
            $display("        Expected Q  : 0000");
            $display("        Actual Q    : %b", dut.shift_reg);
            $display("        Expected SO : 0000");
            $display("        Actual SO   : %b", so);

        end
        else begin

            $display(" [PASS] Asynchronous reset cleared all four stages.");
            $display("        Q  = %b", dut.shift_reg);
            $display("        SO = %b", so);

        end


        // Keep reset asserted for additional clock activity.
        #18;

        // Release reset at the falling clock edge.
        @(posedge clk);
        rst_n = 1'b1;


        // ====================================================================
        // TEST 2: SERIAL DATA PROPAGATION VERIFICATION
        // ====================================================================
        // Apply six serial input bits.
        // Verify the Serial output after every edge.
        // ====================================================================

        $display("");
        $display("TEST 2: SERIAL DATA PROPAGATION VERIFICATION");
        $display("--------------------------------------------------------------");

        $display("Cycle | SI | Expected Q | Actual Q | Expected SO | Actual SO");
        $display("--------------------------------------------------------------");


        // --------------------------------------------------------------------
        // Input Bit 1
        // --------------------------------------------------------------------

        @(negedge clk);        
        si = 1'b1;
        apply_and_check(1);


        // --------------------------------------------------------------------
        // Input Bit 2
        // --------------------------------------------------------------------

        @(negedge clk);
        si = 1'b0;
        apply_and_check(2);


        // --------------------------------------------------------------------
        // Input Bit 3
        // --------------------------------------------------------------------

        @(negedge clk);
        si = 1'b1;
        apply_and_check(3);


        // --------------------------------------------------------------------
        // Input Bit 4
        // --------------------------------------------------------------------

        @(negedge clk);
        si = 1'b1;
        apply_and_check(4);


        // --------------------------------------------------------------------
        // Input Bit 5
        // --------------------------------------------------------------------

        @(negedge clk);
        si = 1'b0;
        apply_and_check(5);


        // --------------------------------------------------------------------
        // Input Bit 6
        // --------------------------------------------------------------------

        @(negedge clk);
        si = 1'b0;
        apply_and_check(6);


        // ====================================================================
        // TEST 3: FINAL VERIFICATION REPORT
        // ====================================================================

        $display("");
        $display("==============================================================");
        $display("                  VERIFICATION SUMMARY");
        $display("==============================================================");

        $display(" Total Test Cases       : %0d", test_count);
        $display(" Passed Test Cases      : %0d", test_count - error_count);
        $display(" Failed Test Cases      : %0d", error_count);

        $display("--------------------------------------------------------------");

        if (error_count == 0) begin

            $display(" FINAL STATUS           : PASS");
            $display(" RESULT                 : ALL TESTS PASSED");

        end
        else begin

            $display(" FINAL STATUS           : FAIL");
            $display(" RESULT                 : VERIFICATION ERRORS DETECTED");

        end

        $display("==============================================================");
        $display("");

        // Allow the final simulation messages to complete.
        #10;
        $finish;

    end


    // ========================================================================
    // 6. SERIAL INPUT APPLICATION AND VERIFICATION TASK
    // ========================================================================
    //
    // Operation:
    // 1. Update the independent reference model.
    // 2. Wait for the rising clock edge.
    // 3. Allow DUT non-blocking assignments to complete.
    // 4. Compare all four internal register bits.
    // 5. Compare all four parallel output bits.
    // 6. Update verification counters.
    // 7. Display individual PASS/FAIL results.
    //
    // Case inequality ( !== ) detects X and Z values.
    // ========================================================================

    task apply_and_check;

        input integer cycle_number;

        begin

            // Update the independent reference model.
            expected_reg = {expected_reg[2:0], si};

            // Wait for the active clock edge.
            @(posedge clk);

            // Allow DUT non-blocking assignments to complete.
            #1;

            test_count = test_count + 1;


            // ----------------------------------------------------------------
            // Compare Expected and Actual Register Contents
            // ----------------------------------------------------------------

            if ((dut.shift_reg !== expected_reg) ||
                (so !== expected_reg)) begin

                error_count = error_count + 1;

                // Report verification failure.
                $display(
                    " %5d | %b  |    %b    |   %b   |     %b     |   %b   [FAIL]",
                    cycle_number,
                    si,
                    expected_reg,
                    dut.shift_reg,
                    expected_reg,
                    so
                );

            end
            else begin

                // Report successful verification.
                $display(
                    " %5d | %b  |    %b    |   %b   |     %b     |   %b   [PASS]",
                    cycle_number,
                    si,
                    expected_reg,
                    dut.shift_reg,
                    expected_reg,
                    so
                );

            end

        end

    endtask


    // ========================================================================
    // 7. END OF TESTBENCH
    // ========================================================================

endmodule

// ============================================================================
// END OF FILE: siso_tb.v
// ============================================================================
