==============================================================
             SISO SHIFT REGISTER VERIFICATION
==============================================================
 Design          : 1-Bit SISO Shift Register
 Clock Frequency : 100 MHz
 Clock Period    : 10 ns
 Reset           : Asynchronous Active-Low
 Input           : Serial (SI)
 Output          : Serial (SO[3])
 Input Sequence  : 1 0 1 1 0 0
==============================================================

TEST 1: ASYNCHRONOUS RESET VERIFICATION
--------------------------------------------------------------
 [PASS] Asynchronous reset cleared all four stages.
        Q  = 0000
        SO = 0000

TEST 2: SERIAL DATA PROPAGATION VERIFICATION
--------------------------------------------------------------
Cycle | SI | Expected Q | Actual Q | Expected SO | Actual SO
--------------------------------------------------------------
     1 | 1  |    0001    |   0001   |     0001     |   0001   [PASS]
     2 | 0  |    0010    |   0010   |     0010     |   0010   [PASS]
     3 | 1  |    0101    |   0101   |     0101     |   0101   [PASS]
     4 | 1  |    1011    |   1011   |     1011     |   1011   [PASS]
     5 | 0  |    0110    |   0110   |     0110     |   0110   [PASS]
     6 | 0  |    1100    |   1100   |     1100     |   1100   [PASS]

==============================================================
                  VERIFICATION SUMMARY
==============================================================
 Total Test Cases       : 7
 Passed Test Cases      : 7
 Failed Test Cases      : 0
--------------------------------------------------------------
 FINAL STATUS           : PASS
 RESULT                 : ALL TESTS PASSED
==============================================================