# AMBA AXI-Lite Slave Protocol Verification Framework

A robust, python-driven functional verification environment for an AMBA AXI-Lite 32-bit Slave peripheral. Built using **Cocotb** and **Icarus Verilog**, this framework simulates asynchronous multi-channel handshaking (Write Address, Write Data, Write Response, Read Address, Read Data) and validates full register data integrity.

## 🚀 Key Features
* **Protocol Compliance & Handshaking:** Explicitly models and verifies AXI-Lite master/slave valid/ready handshakes.
* **Reusable Verification Tasks:** Features custom asynchronous Python helper tasks (`axi_write` and `axi_read`) to automate bus transactions.
* **Multi-Register Stress Testing:** Validates concurrent write and readback sequences across multiple address spaces (`0x0` to `0xC`).

## 📂 Project Structure
```text
axi_lite_verification/
├── rtl/
│   └── axi_lite_slave.v    # Synthesizable AXI-Lite Slave RTL (4x 32-bit Registers)
├── sim/
│   ├── test_axi_lite.py    # Python Cocotb Testbench & Bus Verification Tasks
│   └── Makefile            # Simulation Build Automation Script
└── .gitignore
