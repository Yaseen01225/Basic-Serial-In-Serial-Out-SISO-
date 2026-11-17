
`timescale 1ns / 1ps

// ============================================================================
// Project       : Shift Register Design Suite
// Design        : 4-Bit Serial-In Parallel-Out (SIPO) Shift Register
// Module        : siso_4bit
// File Name     : siso_4bit.v
//
// Problem Statement:
// ------------------
// Design a 4-bit shift register that accepts serial data through SI and
// provides all four stored bits simultaneously through SO[3:0].
//
// Each rising clock edge shifts the existing data toward the MSB and
// inserts the new serial input bit into the LSB.
//
// Reset is asynchronous and active-low.
//
// Developer     : Ghulam Yaseen Nangraj
// Date          : 2026-11-16
// HDL Standard  : IEEE 1364-2005 (Verilog-2001)
// Tool          : Vivado 2025.2.1
//
// ============================================================================

module siso_4bit (

    input  wire       clk,
    input  wire       rst_n,
    input  wire       si,

    output wire [3:0] so

);

    // ------------------------------------------------------------------------
    // Internal 4-bit shift register
    // ------------------------------------------------------------------------

    reg [3:0] shift_reg;

    // ------------------------------------------------------------------------
    // Shift Register Operation
    // ------------------------------------------------------------------------
    // Asynchronous active-low reset:
    //     rst_n = 0 -> Clear all register stages.
    //
    // Normal operation:
    //     Q[0] <= SI
    //     Q[1] <= Q[0]
    //     Q[2] <= Q[1]
    //     Q[3] <= Q[2]
    // ------------------------------------------------------------------------

    always @(posedge clk or negedge rst_n) begin

        if (!rst_n)
            shift_reg <= 4'b0000;

        else
            shift_reg <= {shift_reg[2:0], si};

    end

    // ------------------------------------------------------------------------
    // Parallel Output Assignment
    // ------------------------------------------------------------------------
    // All four register bits are available simultaneously at SO[3:0].
    // ------------------------------------------------------------------------

    assign so = shift_reg;

endmodule
