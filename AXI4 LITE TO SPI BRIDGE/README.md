# 🚀 AXI4-Lite to SPI Bridge using Verilog HDL

<p align="center">

![Vivado](https://img.shields.io/badge/Tool-Vivado%202023.2-blue)
![Language](https://img.shields.io/badge/Language-Verilog-orange)
![Protocol](https://img.shields.io/badge/Protocol-AXI4--Lite-green)
![SPI](https://img.shields.io/badge/Protocol-SPI-red)
![FPGA](https://img.shields.io/badge/FPGA-Artix--7-purple)

</p>

---

# 📖 Project Overview

The **AXI4-Lite to SPI Bridge** is a Register Transfer Level (RTL) design implemented using **Verilog HDL**. It enables communication between an **AXI4-Lite Master** and an **SPI Peripheral** by converting AXI memory-mapped transactions into SPI serial communication.

This project demonstrates the implementation of an **AXI4-Lite Slave Interface**, **SPI Master Controller**, register mapping, address decoding, and SPI data transmission.

The design was developed and functionally verified using **AMD Xilinx Vivado 2023.2**.

---

# 🏗️ Architecture Diagram

> Add your architecture image here.

```text
                +-------------------------+
                |      AXI Master         |
                +------------+------------+
                             |
                      AXI4-Lite Interface
                             |
                             v
               +--------------------------+
               |      AXI4-Lite Slave     |
               |    Register Interface    |
               +------------+-------------+
                            |
                            |
                            v
                 +-----------------------+
                 |      SPI Master       |
                 +------------+----------+
                              |
          +-------------------+-------------------+
          |                   |                   |
        MOSI                MISO               SCLK
                              |
                            CS_N
                              |
                      SPI Peripheral
```

---

# ✨ Features

- AXI4-Lite Slave Interface
- SPI Master Controller
- Memory-Mapped Register Interface
- AXI Read & Write Transactions
- Register Address Decoder
- Configurable SPI Clock Divider
- CPOL & CPHA Configuration
- Full Duplex SPI Communication
- RTL Design
- Behavioral Simulation
- Vivado Project

---

# 📂 Project Structure

```
AXI4-Lite-to-SPI-Bridge/
│
├── RTL/
│   ├── axi4_lite_spi_bridge.v
│   ├── axi4_lite_slave.v
│   └── spi_master.v
│
├── TB/
│   └── tb_axi4_lite_spi_bridge.v
│
├── Images/
│   ├── architecture.png
│   ├── rtl_schematic.png
│   ├── waveform_axi_write.png
│   ├── waveform_axi_read.png
│   └── waveform_spi_transfer.png
│
├── Constraints/
│   └── a.xdc
│
└── README.md
```

---

# 📋 Register Map

| Address | Register | Description |
|----------|----------|-------------|
| 0x00 | Control Register | SPI Control Register |
| 0x04 | Status Register | SPI Status Register |
| 0x08 | TXDATA Register | SPI Transmit Data |
| 0x0C | RXDATA Register | SPI Receive Data |
| 0x10 | Clock Divider Register | SPI Clock Divider |

---

# ⚙️ Tools Used

| Tool | Version |
|------|---------|
| AMD Vivado | 2023.2 |
| Language | Verilog HDL |
| Simulator | XSim |
| FPGA | Artix-7 |

---

# 🔍 Functional Verification

The following functionality has been verified through behavioral simulation.

✅ AXI Write Transaction

✅ AXI Read Transaction

✅ Register Write Operation

✅ Register Read Operation

✅ SPI Clock Generation

✅ MOSI Data Transmission

✅ MISO Data Reception

✅ Chip Select (CS_N)

✅ Clock Divider

✅ Reset Functionality

---

# 📷 RTL Schematic

> Save your RTL schematic as:

```
Images/rtl_schematic.png
```

Then uncomment the line below.

```markdown
![RTL Schematic](Images/rtl_schematic.png)
```

---

# 📈 Simulation Results

Save your waveform screenshots as:

```
Images/waveform_axi_write.png

Images/waveform_axi_read.png

Images/waveform_spi_transfer.png
```

Then use

```markdown
## AXI Write

![AXI Write](Images/waveform_axi_write.png)

## AXI Read

![AXI Read](Images/waveform_axi_read.png)

## SPI Transfer

![SPI](Images/waveform_spi_transfer.png)
```

---

# 🔄 Design Flow

```
Verilog RTL
      │
      ▼
Behavioral Simulation
      │
      ▼
RTL Verification
      │
      ▼
Run Synthesis
      │
      ▼
Run Implementation
      │
      ▼
Generate Bitstream
      │
      ▼
Program FPGA
```

---

# 📊 Project Status

| Stage | Status |
|--------|--------|
| RTL Design | ✅ Completed |
| Behavioral Simulation | ✅ Completed |
| RTL Verification | ✅ Completed |
| Synthesis | ✅ Completed |
| Implementation | ✅ Completed |
| Bitstream Generation | ⚠ Pending (Board Constraint Configuration) |
| FPGA Hardware Validation | ⏳ Pending |

---

# 🧠 Skills Demonstrated

- RTL Design
- Digital Logic Design
- Verilog HDL
- AXI4-Lite Protocol
- SPI Protocol
- FSM Design
- Register Design
- Address Decoding
- FPGA Design Flow
- Functional Verification
- Vivado Design Suite

---

# 🚀 Future Enhancements

- Hardware Validation on Artix-7 FPGA
- Support for Multiple SPI Slaves
- Interrupt Generation
- FIFO Integration
- SystemVerilog Assertions (SVA)
- UVM Verification Environment

---

# ▶️ How to Run

1. Open the project in Vivado 2023.2.
2. Run Behavioral Simulation.
3. Verify AXI Read and Write Transactions.
4. Run Synthesis.
5. Open RTL Schematic.
6. Configure the correct Artix-7 `.xdc` constraints file.
7. Generate the Bitstream.
8. Program the FPGA.

---

# 👨‍💻 Author

## Kaviyarasan R

**Electronics and Communication Engineering**

### 📧 Email

kavirenganathan2004@gmail.com

### 💼 LinkedIn

https://www.linkedin.com/in/kaviyarasan-r-615748239/

### 🐙 GitHub

https://github.com/kavisanbro

---

# 🙏 Acknowledgement

This project was developed to strengthen practical knowledge in **RTL Design**, **FPGA Design**, **Digital System Design**, and **Design Verification** using Verilog HDL and AMD Vivado.

---

⭐ If you found this project useful, consider giving it a **Star** on GitHub.
