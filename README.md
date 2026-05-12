# Parameterized ALU – Design & Verification

## Overview
This project implements and verifies a **Parameterized Arithmetic Logic Unit (ALU)** using synthesizable Verilog RTL. The ALU supports both arithmetic and logical operations with parameterized operand width, making the design scalable and reusable.

The project includes:
- RTL ALU Design
- Self-checking Verilog Testbench
- Independent Reference Model
- Functional Verification and Coverage Analysis

Verification was performed using **QuestaSim 10.6c**.

---

## Features

### Arithmetic Operations
- ADD
- SUB
- ADD with Carry
- SUB with Carry
- Increment / Decrement
- Unsigned Compare
- Signed ADD / SUB
- Multiplication Operations

### Logical Operations
- AND / NAND
- OR / NOR
- XOR / XNOR
- NOT
- Shift Left / Right
- Rotate Left / Right

### Additional Features
- Parameterized operand width
- Synchronous design
- Clock Enable (CE)
- Error handling using `ERR`
- Pipeline-based multi-cycle execution
- Self-checking verification environment
- Functional coverage analysis

---

## Project Structure

```text
project/
│
├── src/
│   ├── design/
│   │   └── alu.v
│   │
│   └── tb/
│       ├── tb_design.v
│       └── alu_ref_model.v
│
├── docs/
│   ├── test_plan.md
│   └── verification_report.md
│
└── README.md
