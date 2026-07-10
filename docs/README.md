# PWM Demo - Design Documentation

## Overview

Comprehensive design documentation for the FPGA-based PWM generator implemented in VHDL for Xilinx Zynq-7000 devices.

---

## Documentation Structure

```
docs/
├── README.md                  ← You are here
├── vio_ila_debug_guide.md     # VIO/ILA debug guide
├── architecture/              # System-level architecture
│   ├── overview.md            # Top-level system architecture
│   ├── hierarchy.md           # Module hierarchy tree
│   └── clock_domains.md       # Clock domain analysis
│
├── src/                       # Source file documentation
│   ├── main.md                # Top-level design (main.vhd)
│   ├── pwm/                   # PWM modules
│   │   └── README.md          # pwm_1ch, pwm_mch_buf, pwm_mch
│   ├── counters/              # Counter implementations
│   │   └── README.md          # Up/Up-Down counters
│   ├── signal_chain/          # Signal generation & processing
│   │   └── README.md          # Sine gen, decimator, scalers
│   ├── buffers/               # Clock domain crossing
│   │   └── README.md          # Async FIFO
│   └── utils/                 # Utility modules
│       └── README.md          # Edge delay, range divider
│
└── tb/                        # Testbench documentation (TODO)
    └── README.md
```

---

## Quick Navigation

### Getting Started

- [Console Build Guide](./console_build_guide.md) - PowerShell/Vivado batch synthesis, simulation, bitstream, and SD boot flows
- [Architecture Overview](./architecture/overview.md) - Start here for system-level understanding
- [Module Hierarchy](./architecture/hierarchy.md) - Complete module tree and dependencies
- [Clock Domains](./architecture/clock_domains.md) - Clock architecture and CDC
- [Microphase Z7-Lite SD Boot](./z7_lite_sd_boot.md) - Persistent PL startup from microSD

### Module Documentation

#### Top-Level Design
- [main.vhd](./src/main.md) - Top-level orchestration, clock tree, and I/O

#### PWM Generation
- [PWM Modules](./src/pwm/README.md) - Single and multi-channel PWM with buffering; reusable core RTL lives under `src/pwm_core/rtl`
  - `pwm_1ch.vhd` - Single channel with dead-time
  - `pwm_1ch_drive_pkg.vhd` - Complementary pre-drive leg functions
  - `pwm_mch_buf.vhd` - Multi-channel buffered
  - `pwm_mch.vhd` - Multi-channel direct PWM branch

#### Counter Modules
- [Counters](./src/counters/README.md) - Reference waveform counters from `src/pwm_core/rtl/counters`
  - `up_counter_signed.vhd`
  - `up_counter_unsigned.vhd`
  - `updown_counter_signed.vhd`
  - `updown_counter_unsigned.vhd`

#### Signal Processing
- [Signal Chain](./src/signal_chain/README.md) - Demo sine/decimator plus core scaler modules
  - `sine_gen_simple.vhd` - Sine wave LUT with optional soft-start ramp
  - `data_decimator.vhd` - Sample rate conversion
  - `scaler_signed.vhd` - Signed amplitude scaling
  - `scaler_unsigned.vhd` - Unsigned scaling with offset

#### Clock Domain Crossing
- [Buffers](./src/buffers/README.md) - Asynchronous FIFO
  - `async_fifo.vhd` - Dual-clock FIFO with Gray code pointers

#### Utilities
- [Utils](./src/utils/README.md) - Supporting modules
  - `dead_time_generator.vhd` - PWM leg dead time (used by `pwm_1ch`)
  - `edge_delay.vhd` - Programmable delay (general-purpose)
  - `pwm_clk_post_scaler.vhd` - Buffered PWM `/2`, `/4`, `/8`, `/16` tick generator
  - `range_divider_pkg.vhd` - Channel phase distribution

---

## System Architecture

### Block Diagram

```
┌──────────────────────────────────────────────────────────────────┐
│                         PWM Demo System                           │
│                                                                   │
│  sys_clk (100 MHz) ──→ [Clock Tree] ──→ MMCM                     │
│                                            │                      │
│                        ┌───────────────────┴───────────────────┐  │
│                        │                                       │  │
│                    clk (50 MHz)                       raw clk_pwm (200 MHz)
│                        │                                       │  │
│              ┌─────────┴─────────┐                  ┌──────────┴─────────┐
│              │  16-bit Sine      │                  │ Buffered PWM       │
│              │  Generator        │────── CDC ──────→│ PWM Branch         │
│              └─────────┬─────────┘     (FIFO)       └──────────┬─────────┘
│                        │                                       │          │
│                        └────────→ fixed MSB truncation                    │
│                                        + /2,/4,/8,/16 tick                │
│                                                                │          │
│                                                        ┌───────┴───────┐  │
│                                                        │  OBUF × 4    │  │
│                                                        └───────┬───────┘  │
└────────────────────────────────────────────────────────────────┼──────────┘
                                                                 │
                                                 sys_pwm[3:0] ───┘
                                                 sys_pwm_n[3:0]
```

### Key Specifications

| Parameter | Value | Notes |
|-----------|-------|-------|
| **Input Clock** | 100 MHz | Current board XDC constraint |
| **System Clock** | 50 MHz | `clkout1`, MMCM ratio |
| **PWM Clock** | 200 MHz raw | `clkout2`, MMCM ratio |
| **PWM Resolution** | Build-time fixed, default 8-bit | `pwm_resolution_bits` generic |
| **PWM Channels** | 4 | Complementary pairs |
| **PWM Frequency** | ~195.3125 kHz to ~24.414 kHz | Default 8-bit, `/2` to `/16` post-divider |
| **Modulation** | ~24.4 kHz | Sine LUT rate, `clk / 2048` |
| **Dead Time** | 4 effective PWM ticks | ~40 ns in default `/2` mode |

---

## Design Features

### PWM Generation
- ✅ Symmetrical (center-aligned) PWM
- ✅ Complementary outputs with dead-time
- ✅ Multi-channel support (configurable)
- ✅ Buffered architecture for high frequency
- ✅ Runtime buffered PWM frequency step with blanked handoff
- ✅ Pipeline stages for timing closure

### Clock Domain Crossing
- ✅ Asynchronous FIFO with Gray code pointers
- ✅ Metastability-hardened synchronizers
- ✅ Automatic full/empty detection

### Signal Generation
- ✅ Runtime-computed sine wave LUT
- ✅ Optional sine soft-start ramp
- ✅ Sample rate decimation
- ✅ Amplitude scaling with offset
- ✅ Signed and unsigned data formats

### Configurability
- ✅ Generic-based parameters
- ✅ Signed/unsigned data types
- ✅ Symmetrical/asymmetrical PWM modes
- ✅ Configurable build-time resolution and dead-time
- ✅ Configurable reset release and divider switch delay

---

## Target Hardware

### Supported Boards

| Board | FPGA | Status |
|-------|------|--------|
| Digilent Zybo Z7 | Z7010/Z7020 | ✅ Supported |
| Microphase Z7-Lite | Z7010 | ✅ Supported |
| MYiR Z-turn Board V2 | Z7020 | ✅ Supported |
| Antminer S9 | Z7010 | ✅ Supported |

### Runtime Control Pins

| Board | Reset input | Resolution/frequency step input | Resolution LED |
|-------|-------------|---------------------------------|----------------|
| Digilent Zybo Z7 | `BTN0` / `sys_rst` | `BTN1` / `sys_pwm_mode` | `LED0` / `sys_led` |
| Microphase Z7-Lite | `sys_rst` button, pin `P16` | `sys_pwm_mode` button, pin `T12` | `sys_led`, pin `P15` |

### Constraint Files

The Microphase Z7-Lite SD boot wrapper targets the XC7Z020 board variant used by this workspace.

Constraint files are located in `constraints/`:
- `Zybo_board.xdc` - Digilent Zybo Z7
- `Z7_LITE.xdc` - Microphase Z7-Lite
- `Antminer-S9.xdc` - Antminer S9

The Microphase Z7-Lite microSD slot is wired to Zynq PS MIO, not PL pins, so SD boot does not require additions to `Z7_LITE.xdc`.

---

## Design Tools

### Required Software

| Tool | Version | Purpose |
|------|---------|---------|
| Xilinx Vivado | 2018.3 | Synthesis, Implementation, Simulation |
| GNU Octave | 9.0+ | Algorithm validation |
| Python | 3.x | Utilities (optional) |

### Simulation

All modules have corresponding testbenches in `tb/`:

```powershell
python .\tools\sim_pwm_demo.py --testbench tb_main
```

---

## Design Diagrams Index

### Architecture Diagrams

- [System Block Diagram](./architecture/overview.md#block-diagram)
- [Clock Architecture](./architecture/overview.md#clock-architecture)
- [Data Flow](./architecture/overview.md#data-flow)
- [Signal Chain](./architecture/overview.md#signal-chain)

### Module Diagrams

- [main.vhd Block Diagram](./src/main.md#block-diagram)
- [PWM Module Architecture](./src/pwm/README.md#block-diagram)
- [Counter State Machines](./src/counters/README.md#operation)
- [Signal Processing Pipeline](./src/signal_chain/README.md#signal-chain-data-flow)
- [Async FIFO Structure](./src/buffers/README.md#block-diagram)

### Timing Diagrams

- [Dead-Time Waveform](./src/pwm/README.md#dead-time-control)
- [Decimator Timing](./src/signal_chain/README.md#operation-timing)
- [Edge Delay Timing](./src/utils/README.md#timing-diagram)
- [FIFO Synchronization](./src/buffers/README.md#synchronization-timing)

### Hierarchy Diagrams

- [Module Tree](./architecture/hierarchy.md#complete-module-tree)
- [Instantiation Hierarchy](./architecture/hierarchy.md#instantiation-hierarchy)
- [Dependency Graph](./architecture/hierarchy.md#dependency-graph)

---

## Getting Started

### 1. Review Architecture

Start with the [Architecture Overview](./architecture/overview.md) to understand the system-level design.

### 2. Understand Clock Domains

Read about the [Clock Domain Architecture](./architecture/clock_domains.md) to understand CDC.

### 3. Study Key Modules

Focus on these core modules:
- [main.vhd](./src/main.md) - Top-level integration
- [pwm_mch_buf.vhd](./src/pwm/README.md) - Buffered PWM controller
- [async_fifo.vhd](./src/buffers/README.md) - Clock domain crossing

### 4. Run Simulations

Verify understanding by running testbenches in `tb/`.

---

## Design Conventions

### Naming

- **Signals**: lowercase with underscores (`sine_out`)
- **Generics**: lowercase (`data_width`)
- **Constants**: UPPERCASE (`MAX_VALUE`)
- **Entities**: lowercase with underscores (`sine_gen_simple`)

### Data Types

- **SIGNED**: Two's complement representation
- **UNSIGNED**: Binary representation
- **Q-format**: Fixed-point (Q1.15 = 1 sign + 15 fraction bits)

### Clock Domains

- `clk`: System clock (50 MHz in the current board builds)
- `clk_pwm`: Raw PWM clock (200 MHz in the current board builds); buffered PWM advances on `/2`, `/4`, `/8`, or `/16` tick enables
- Prefix signals with domain for clarity

---

## Future Work

### Planned Enhancements

- [ ] Asymmetrical PWM mode validation
- [ ] Dynamic frequency control
- [ ] Enhanced dead-time options
- [ ] Additional waveform generators
- [ ] Testbench documentation

### Known Issues

- MMCM frequencies are approximate
- Timing closure may require board-specific constraints

---

## Document History

| Date | Version | Changes |
|------|---------|---------|
| 2026-06-16 | 1.1 | Updated clocking, reset/mode control, sine ramp, source layout, and simulation command docs |
| 2026-04-09 | 1.0 | Initial documentation release |

---

## Contributing

When adding new modules, please:
1. Create a corresponding README in the module's directory
2. Include Mermaid diagrams for block diagrams
3. Document all generics, ports, and parameters
4. Add timing diagrams where applicable
5. Update this index

---

## See Also

- [Project README](../README.md) - Project overview and quick start
- [Source Code](../src/) - VHDL source files
- [Testbenches](../tb/) - Simulation testbenches
- [Constraints](../constraints/) - Board-specific constraints
- [Microphase Z7-Lite SD Boot](./z7_lite_sd_boot.md) - BOOT.bin generation and SD-card setup

---

**Documentation Generated:** 2026-06-16
**Project Version:** 3.0  
**Target Device:** Xilinx Zynq-7000 (XC7Z010/XC7Z020)
