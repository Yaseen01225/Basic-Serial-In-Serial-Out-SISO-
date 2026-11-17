# SISO Basics — 4-Bit Serial-In, Serial-Out Shift Register

**Project:** Shift Register Design Suite  
**Phase:** 1.1  
**Design:** 4-Bit SISO Shift Register  
**HDL:** Verilog-2001 / IEEE 1364-2005  
**Design style:** Sequential RTL  
**Register width:** 4 bits  
**Reset:** Asynchronous, active-low  
**Clock:** 100 MHz in the supplied testbench

---

## 1. Project Overview

This project demonstrates the operation and verification of a four-stage **Serial-In, Serial-Out (SISO) shift register** using Verilog HDL.

A SISO shift register accepts serial data one bit at a time. At each rising edge of the clock, the new input bit enters the first register stage while the previously stored bits move one stage toward the serial output.

The design contains four storage stages:

```text
              Four-bit shift chain
        +------+------+------+------+
 SI --->| Q0   | Q1   | Q2   | Q3   |----> SO
        +------+------+------+------+
          ^      ^      ^      ^
          |      |      |      |
          +------+------+------+------ CLK
```

The serial output is taken from the most-significant stage:

```verilog
assign serial_out = so[3];
```

In the supplied RTL, the four-bit output port `so[3:0]` is connected to the complete internal register state. This is intentionally useful for observing the shifting mechanism and the contents of all four stages during learning and simulation. **It is a state-observation bus, not a functional parallel-data output.** The serial output bit is `so[3]`.

> **Important classification:** This project is SISO, not SIPO. Some comments and display strings in the supplied RTL and testbench still contain the older SIPO wording and refer to `so[3:0]` as a parallel output. Those labels do not match the intended project classification clarified here. Interpret `so[3:0]` as the exposed internal-state view and `so[3]` as the serial-output tap.

---

## 2. Project Objectives

The project is intended to help learners understand:

1. Serial data input and serial data output.
2. Four-stage shift-register architecture.
3. Rising-edge-triggered sequential logic.
4. Asynchronous active-low reset.
5. Non-blocking assignments in clocked RTL.
6. Verilog concatenation and part-select operations.
7. Continuous assignment and signal connectivity.
8. Testbench clock generation and stimulus scheduling.
9. Reference-model-based verification.
10. PASS/FAIL reporting and waveform inspection.

---

## 3. Project Files

| File | Description |
|---|---|
| `siso(1).v` | Supplied synthesizable RTL design containing module `siso_4bit`. |
| `siso_tb(1).v` | Supplied simulation testbench containing module `siso_tb`. |
| `README.md` | Project overview, architecture, operating principle, verification notes and run instructions. |
| `siso_tb.vcd` | VCD waveform output requested by the testbench when the simulator supports `$dumpfile` and `$dumpvars`. |

For convenience, the source files may be renamed to `siso.v` and `siso_tb.v`. If renamed, use those names in the compile commands below.

---

## 4. Design Interface

The supplied RTL module is named `siso_4bit`.

| Signal | Direction | Width | Description |
|---|---:|---:|---|
| `clk` | Input | 1 bit | Clock. Shifting occurs on its rising edge. |
| `rst_n` | Input | 1 bit | Asynchronous active-low reset. |
| `si` | Input | 1 bit | Serial data input. |
| `so` | Output | 4 bits | Exposed view of the internal four-bit shift-register state. |
| `so[3]` | Output tap | 1 bit | Most-significant stage, used as the serial output. |

### 4.1 Internal register

```verilog
reg [3:0] shift_reg;
```

`shift_reg` stores the four bits of the shift chain. The state is written as:

```text
shift_reg[3:0] = {Q3, Q2, Q1, Q0}
```

### 4.2 Shift operation

The central RTL expression is:

```verilog
shift_reg <= {shift_reg[2:0], si};
```

The concatenation forms a new four-bit value from the previous bits `[2:0]` and the new serial input bit `si`.

The resulting stage transfers are:

```text
New Q0 = SI
New Q1 = Old Q0
New Q2 = Old Q1
New Q3 = Old Q2
```

Therefore, data moves in the direction:

```text
SI -> Q0 -> Q1 -> Q2 -> Q3 -> SO
```

### 4.3 Reset operation

The design uses:

```verilog
always @(posedge clk or negedge rst_n)
```

- When `rst_n` becomes `0`, the register is cleared asynchronously.
- When `rst_n` is `1`, the register shifts on each rising edge of `clk`.

Reset value:

```verilog
shift_reg <= 4'b0000;
```

---

## 5. SISO Operation and Data Propagation

The supplied testbench applies this serial input sequence:

```text
SI = 1, 0, 1, 1, 0, 0
```

The initial state after reset is `0000`.

The following table shows the expected register states. State notation is `[Q3 Q2 Q1 Q0]`.

| Event | Serial input | State after rising edge | Serial output `so[3]` |
|---|---:|---:|---:|
| Reset | — | `0000` | `0` |
| Cycle 1 | `1` | `0001` | `0` |
| Cycle 2 | `0` | `0010` | `0` |
| Cycle 3 | `1` | `0101` | `0` |
| Cycle 4 | `1` | `1011` | `1` |
| Cycle 5 | `0` | `0110` | `0` |
| Cycle 6 | `0` | `1100` | `1` |

### 5.1 Understanding the four-stage propagation

Consider the first input bit, `1`:

| Clock transfer | Q3 | Q2 | Q1 | Q0 |
|---|---:|---:|---:|---:|
| Before input | 0 | 0 | 0 | 0 |
| First rising edge: SI = 1 | 0 | 0 | 0 | 1 |
| Second rising edge | 0 | 0 | 1 | 0 |
| Third rising edge | 0 | 1 | 0 | 0 |
| Fourth rising edge | 1 | 0 | 0 | 0 |

The bit enters Q0 on the first rising edge and reaches Q3 on the fourth rising edge. Thus, it takes four sampled register states, counting the insertion edge, for the bit to appear at the Q3 serial-output tap.

---

## 6. Verilog HDL Techniques Used

### 6.1 Module declaration

```verilog
module siso_4bit (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       si,
    output wire [3:0] so
);
```

A module defines a hardware design unit and its external interface.

### 6.2 `wire`

A `wire` is a Verilog net used to connect signals. The module inputs and output bus are declared as wires in the supplied design.

### 6.3 `reg`

A `reg` is a procedural variable type. The internal `shift_reg` is assigned inside an `always` block. In this clocked process, it represents the stored state of the four register stages.

### 6.4 Vector declaration

```verilog
reg [3:0] shift_reg;
```

This declares a four-bit vector with bit indices 3, 2, 1 and 0.

### 6.5 Event control

```verilog
always @(posedge clk or negedge rst_n)
```

The `@` event control suspends the procedural block until one of the listed signal transitions occurs.

### 6.6 Non-blocking assignment

```verilog
shift_reg <= {shift_reg[2:0], si};
```

The `<=` operator is a non-blocking assignment. It is the preferred assignment style for clocked sequential logic because register updates are scheduled together rather than being applied immediately in procedural statement order.

### 6.7 Concatenation

```verilog
{shift_reg[2:0], si}
```

Concatenation joins multiple bit expressions into one vector. Here, a three-bit part-select and one serial input bit form a four-bit next-state value.

### 6.8 Part-select

```verilog
shift_reg[2:0]
```

A part-select selects a range of bits from a vector. It selects bits 2, 1 and 0 from `shift_reg`.

### 6.9 Continuous assignment

```verilog
assign so = shift_reg;
```

A continuous assignment drives the output bus from the internal state. Whenever `shift_reg` changes, the value visible on `so` follows it.

### 6.10 Bit-select

```verilog
so[3]
```

A bit-select selects one bit from a vector. In this project, bit 3 is the serial-output tap.

---

## 7. Testbench Overview

The supplied testbench module is `siso_tb`. It instantiates the design as `dut` and applies stimulus to its inputs.

The testbench is simulation code; it is not part of the synthesized shift-register hardware.

### 7.1 DUT instantiation

```verilog
siso_4bit dut (
    .clk   (clk),
    .rst_n (rst_n),
    .si    (si),
    .so    (so)
);
```

Named port connections explicitly associate each DUT port with a testbench signal.

### 7.2 Clock generation

```verilog
initial begin
    clk = 1'b0;
end

always #5 clk = ~clk;
```

The clock toggles every 5 ns.

- Clock period = 10 ns
- Clock frequency = 1 / 10 ns = 100 MHz
- High time = 5 ns
- Low time = 5 ns

The `#5` delay is a simulation timing control, not a physical delay element inferred in the RTL.

### 7.3 Testbench stimulus

The testbench drives `si` on falling clock edges and the DUT samples it on rising edges. This separates input changes from the active sampling edge.

The six applied bits are:

```text
1 -> 0 -> 1 -> 1 -> 0 -> 0
```

### 7.4 Reference model

The testbench declares:

```verilog
reg [3:0] expected_reg;
```

It updates the expected state using:

```verilog
expected_reg = {expected_reg[2:0], si};
```

This provides an expected result to compare with the DUT after each rising edge.

### 7.5 Reusable verification task

The testbench defines a task named:

```verilog
task apply_and_check;
```

The task updates the reference model, waits for the rising edge, allows the DUT's non-blocking assignment to settle, compares expected and actual values, updates counters and prints a result.

### 7.6 Case inequality

The testbench uses:

```verilog
!==
```

Case inequality detects mismatches involving `0`, `1`, `X` and `Z`. This is useful for catching unknown or high-impedance values during simulation.

### 7.7 Verification counters

- `test_count` records the number of checks.
- `error_count` records the number of failed checks.
- Passed checks are calculated as `test_count - error_count`.

The final report prints PASS when `error_count` is zero; otherwise, it prints FAIL.

---

## 8. Verification Plan

The supplied testbench implements three main test sections.

| Test section | Verification purpose |
|---|---|
| Test 1 — Asynchronous reset | Checks that the internal register and exposed output state clear to `0000` after reset assertion. |
| Test 2 — Serial data propagation | Applies six serial input bits and checks the expected four-bit state after each rising edge. |
| Test 3 — Final verification report | Prints total checks, passed checks, failed checks and final status. |

### 8.1 Reset check

The testbench asserts `rst_n = 0`, waits for 2 ns and checks:

```text
Expected shift_reg = 0000
Expected so         = 0000
```

The check is performed without waiting for a clock edge, consistent with the asynchronous reset behavior.

### 8.2 Data propagation check

After reset release, the testbench applies the six-bit input sequence and compares:

- `dut.shift_reg` against `expected_reg`.
- `so` against `expected_reg`.

The testbench uses hierarchical access to inspect `dut.shift_reg`. This is a simulation verification technique; it does not add a hardware port.

### 8.3 Important interpretation of the output check

The supplied testbench checks all four bits of `so` because the project exposes the internal state for observation. This verifies the state propagation across all stages. The intended serial output remains the single bit `so[3]`.

---

## 9. Simulation and Waveform Generation

The testbench requests a Value Change Dump (VCD) file:

```verilog
initial begin
    $dumpfile("siso_tb.vcd");
    $dumpvars(0, siso_tb);
end
```

A VCD file records signal-value changes over simulation time. It can be inspected using a compatible waveform viewer, such as GTKWave.

The testbench also uses simulator system tasks:

| System task | Purpose |
|---|---|
| `$display` | Prints formatted messages to the simulation console. |
| `$dumpfile` | Specifies the VCD output filename. |
| `$dumpvars` | Selects the hierarchy and signals to record. |
| `$finish` | Ends the simulation. |

The supplied testbench identifies Vivado XSIM as its development simulator and includes VCD dump calls. VCD support and waveform viewing depend on the selected simulator and its configuration.

---

## 10. Running with Icarus Verilog

The original README gives the following commands:

```bash
iverilog -o siso_sim siso.v siso_tb.v
vvp siso_sim
```

If the uploaded filenames are retained with parentheses, use:

```bash
iverilog -o siso_sim "siso(1).v" "siso_tb(1).v"
vvp siso_sim
```

If compilation succeeds, `vvp` runs the simulation. The testbench prints reset and data-propagation checks followed by a final verification summary. The VCD file is requested as `siso_tb.vcd`.

### 10.1 Viewing the VCD waveform

If GTKWave is installed:

```bash
gtkwave siso_tb.vcd
```

Useful signals to inspect include:

- `clk`
- `rst_n`
- `si`
- `so[3:0]`
- `dut.shift_reg`
- `expected_reg`

Observe that `so[3]` becomes the serial output bit after the input data has propagated through the four stages.

---

## 11. Running with AMD Xilinx Vivado / XSIM

The supplied testbench header identifies AMD Xilinx Vivado 2025.2.1 and XSIM.

A typical behavioral simulation workflow is:

1. Open the Vivado project.
2. Add the SISO RTL file as a Design Source.
3. Add the testbench file as a Simulation Source.
4. Confirm `siso_tb` is selected as the simulation top.
5. Run **Run Behavioral Simulation**.
6. Inspect the Tcl Console for the testbench report.
7. Inspect the waveform window.
8. Add `clk`, `rst_n`, `si`, `so`, and `dut.shift_reg` to the waveform if they are not already visible.

### Suggested waveform observations

| Signal | What to observe |
|---|---|
| `clk` | A 10 ns period clock. |
| `rst_n` | Low during reset and high during normal operation. |
| `si` | The serial sequence `1, 0, 1, 1, 0, 0`. |
| `dut.shift_reg` | The four-bit state after each rising edge. |
| `so[3:0]` | Follows the internal register state. |
| `so[3]` | The serial-output tap at the final stage. |

---

## 12. Expected Verification Results

For the supplied six-bit sequence, the expected states are:

```text
Reset : 0000
Cycle 1: 0001
Cycle 2: 0010
Cycle 3: 0101
Cycle 4: 1011
Cycle 5: 0110
Cycle 6: 1100
```

The expected serial-output tap values after those six rising edges are:

```text
SO = 0, 0, 0, 1, 0, 1
```

These values are derived from the RTL shift expression and the input sequence. They are expected values, not a claim that a simulator run was performed.

---

## 13. Important Source-Code Notes

The supplied RTL and testbench contain SIPO wording in some headers and console messages, including references to a parallel output. The project title in this README follows the clarified intended function: SISO.

For consistency, consider updating the comments and display text in both source files:

- Replace “Serial-In Parallel-Out (SIPO)” with “Serial-In Serial-Out (SISO)”.
- Describe `so[3:0]` as the **4-bit internal-state observation bus**.
- Describe `so[3]` as the **serial output**.
- Keep the existing four-bit state checks because they help verify and visualize every shift stage.

The RTL behavior need not be changed merely to correct those labels.

### Optional interface refinement

If a future version should make the functional interface explicit, it could expose a separate one-bit `serial_out` port assigned from the MSB register stage, while retaining an optional state-view port for educational waveform inspection. This is a possible refinement, not part of the supplied source implementation.

---

## 14. Key Concepts and Glossary

| Term | Definition |
|---|---|
| SISO | Serial-In, Serial-Out: data enters and leaves one bit at a time. |
| Shift register | A group of storage bits that transfers data between stages. |
| RTL | Register-Transfer Level; describes data storage and transfer behavior. |
| Sequential logic | Logic whose state depends on previous values and triggering events. |
| Flip-flop | A one-bit storage element controlled by a clock or other triggering event. |
| Clock edge | A transition of the clock signal, such as a rising edge. |
| `posedge` | A transition from logic 0 to logic 1. |
| `negedge` | A transition from logic 1 to logic 0. |
| Active-low reset | A reset signal asserted when its value is logic 0. |
| Asynchronous reset | A reset that acts independently of a clock edge. |
| Non-blocking assignment | The `<=` procedural assignment used here for clocked state updates. |
| Concatenation | Joining bit expressions using braces `{ }`. |
| Part-select | Selecting a range of bits from a vector. |
| Bit-select | Selecting one bit from a vector. |
| Continuous assignment | An `assign` statement that continuously drives a net. |
| Testbench | Simulation code used to apply stimulus and check a design. |
| DUT | Device Under Test; the design instance being verified. |
| Reference model | A model that calculates the expected result for comparison. |
| Task | A reusable named procedural block in Verilog. |
| VCD | Value Change Dump; a file format for recording signal transitions. |
| X | Unknown logic value in Verilog's four-state logic. |
| Z | High-impedance logic value in Verilog's four-state logic. |
| Hierarchical reference | Access to a signal inside an instantiated module, such as `dut.shift_reg`. |

---

## 15. Learning Outcomes

After studying and simulating this project, a learner should be able to:

- Explain the operation of a four-stage SISO shift register.
- Distinguish SISO from SIPO.
- Explain why a four-bit state-observation bus does not by itself define the functional output protocol.
- Read and understand a clocked Verilog `always` block.
- Explain asynchronous active-low reset.
- Interpret concatenation and part-select syntax.
- Understand the role of non-blocking assignments in sequential logic.
- Generate clock and serial stimulus in a testbench.
- Build a reference model and compare it with a DUT.
- Detect mismatches and unknown values using case inequality.
- Inspect state propagation using a waveform viewer.

---

## 16. Conclusion

The SISO Basics project demonstrates a four-bit serial shift chain using Verilog HDL. A new input bit enters the least-significant stage on each rising clock edge, while existing bits advance toward the most-significant stage. The bit at `so[3]` is the serial-output tap.

The exposed `so[3:0]` bus makes the complete internal state visible so that learners can follow the shifting mechanism. It is included for observation and verification, not to classify the design as SIPO.

The RTL illustrates sequential logic, asynchronous active-low reset, non-blocking assignments, concatenation and continuous assignment. The testbench adds clock generation, event-driven stimulus, a reference model, reusable verification logic, PASS/FAIL counters and waveform dumping.

**Project classification: SISO — Serial-In, Serial-Out.**

---

## 17. Project Metadata

| Field | Information |
|---|---|
| Project name | SISO Basics |
| Project suite | Shift Register Design Suite |
| Phase | 1.1 |
| Design module | `siso_4bit` |
| Testbench module | `siso_tb` |
| HDL | Verilog-2001 / IEEE 1364-2005 |
| Register width | 4 bits |
| Input type | Serial |
| Functional output | Serial bit from `so[3]` |
| State observation | `so[3:0]` |
| Reset | Asynchronous, active-low |
| Testbench clock | 100 MHz |
| Simulator identified in source | Vivado XSIM |
| Alternative simulator instructions | Icarus Verilog |

