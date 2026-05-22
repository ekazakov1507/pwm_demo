# PWM Demo - FPGA Pulse Width Modulation Generator

A modular FPGA-based PWM generator implemented in VHDL for Xilinx Zynq-7000 series devices, featuring symmetrical PWM generation with dead-time control and buffered multi-channel output.

## Overview

This project implements a high-frequency PWM modulation system with the following key features:

- **Symmetrical (center-aligned) PWM** generation for reduced harmonic distortion
- **Multi-channel output** (default: 4 channels with complementary pairs)
- **Dead-time insertion** to prevent shoot-through in power electronics applications
- **Buffered architecture** using asynchronous FIFOs for reliable clock domain crossing
- **MMCM clock generation** for precise frequency control
- **Configurable parameters** including data width, dead-time cycles, and reference signal type

## Technical Specifications

### Current Configuration (v3)
- **PWM Frequency:** ~1 MHz (symmetrical)
- **Modulation:** 100 kHz sinusoidal signal
- **Resolution:** 6-bit PWM (configurable)
- **Clock Frequency:** 250 MHz (system), derived from 125 MHz input
- **Dead Time:** 4 clock cycles
- **Buffer Depth:** 1024 samples
- **Wave Table Length:** 2048 points

### Architecture
```
System Clock (125 MHz)
    ↓
[IBUF] → [BUFG] → [MMCM]
                     ↓
              clk (250 MHz) ──→ [Sine Generator] ──→ [PWM Module] ──→ [OBUF] → PWM Outputs
              clk_pwm (125 MHz) ──→ [Reference Counter]
```

## Project Structure

```
pwm_demo/
├── src/                        # Source files
│   ├── main.vhd               # Top-level design
│   ├── pwm/                   # PWM generation modules
│   │   ├── pwm_1ch.vhd        # Single-channel PWM with dead-time
│   │   └── pwm_mch_buf.vhd    # Multi-channel buffered PWM
│   ├── counters/              # Counter implementations
│   │   ├── up_counter_signed.vhd
│   │   ├── up_counter_unsigned.vhd
│   │   ├── updown_counter_signed.vhd
│   │   └── updown_counter_unsigned.vhd
│   ├── signal_chain/          # Signal generation & conditioning
│   │   ├── sine_gen_simple.vhd  # Sine wave lookup table
│   │   ├── data_decimator.vhd
│   │   ├── scaler_signed.vhd
│   │   └── scaler_unsigned.vhd
│   ├── buffers/               # FIFO buffers
│   │   └── async_fifo.vhd     # Asynchronous FIFO for clock domain crossing
│   └── utils/                 # Utility modules
│       ├── edge_delay.vhd
│       └── range_divider_pkg.vhd
├── tb/                         # Testbenches
│   ├── tb_main.vhd
│   ├── tb_pwm_1ch.vhd
│   ├── tb_pwm_mch.vhd
│   ├── tb_counters.vhd
│   ├── tb_async_fifo.vhd
│   ├── tb_sync_fifo.vhd
│   └── ...
├── constraints/                # Pin constraints for target boards
│   ├── Zybo_board.xdc         # Digilent Zybo Z7
│   ├── Z7_LITE.xdc            # Microphase Z7-Lite
│   └── Antminer-S9.xdc        # Antminer S9 (custom target)
├── octave/                     # MATLAB/Octave simulation scripts
│   ├── pwm_platform.m         # Main simulation script
│   ├── pwm_c.m                # Symmetrical PWM model
│   ├── table_cos.m            # Cosine table generation
│   └── cos_table.txt          # Pre-computed cosine values
├── python/                     # Python utilities
├── sim/                        # Simulation files
└── ip/                         # Generated IP cores
```

## Supported Hardware

This project has been developed and tested on the following Xilinx Zynq-7000 development boards:

- **[Digilent Zybo Z7](https://digilent.com/reference/programmable-logic/zybo-z7/start)** - Zynq-7010/7020
- **[Microphase Z7-Lite](https://github.com/hw/Microphase-Z7-Lite)** - Zynq-7010/Zynq-7020 variants; SD boot wrapper targets XC7Z020
- **[MYiR Z-turn Board V2](https://www.myirtech.com/list.asp?id=708)** - Zynq-7020
- **Antminer S9** - Custom ASIC miner board (repurposed)

## Requirements

### Software
- **Xilinx Vivado 2018.3** (or compatible version)
- **GNU Octave 9.0+** or MATLAB (for algorithm validation)
- **Python 3.x** (optional, for utilities)

### Hardware
- Xilinx Zynq-7000 FPGA (Z7010/Z7020)
- Appropriate constraint file for your target board

## Quick Start

For complete PowerShell/Vivado batch commands for synthesis, simulation, bitstream generation, and Z7-Lite `BOOT.bin`, see [docs/console_build_guide.md](docs/console_build_guide.md).

### 1. Open Project in Vivado
```bash
# Launch Vivado 2018.3
vivado &

# Open the project
File → Open Project → Select pwm_demo.xpr
```

### 2. Run Synthesis & Implementation
```bash
# In Vivado Tcl Console:
launch_runs synth_1 -jobs 4
wait_on_run synth_1

launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
```

### 3. Generate Bitstream
```bash
launch_runs impl_1 -to_step write_bitstream
```

### 4. Program FPGA
```bash
open_hw_manager
connect_hw_server
current_hw_target [get_hw_targets]
open_hw_target
set_property PROGRAM.FILE {<path_to_bitstream>} [current_hw_device]
program_hw_devices
```

JTAG programming is volatile on Zynq boards: after a power cycle the PL bitstream is gone. For persistent Microphase Z7-Lite startup from microSD, generate a Zynq boot image instead:

```powershell
.\tools\build_z7_lite_sd_boot.ps1
```

Copy `build\z7_lite_sd_boot\BOOT.bin` to the root of a FAT32 microSD card, set the Z7-Lite `J1` boot-mode jumper to SD boot, and power-cycle the board. See [docs/z7_lite_sd_boot.md](docs/z7_lite_sd_boot.md) for the full flow.

### Firmware Build Archive

Use `tools\manage_firmware_builds.py` to keep experiment firmware outputs grouped with their build parameters.

```bash
# Show generated firmware files that are not archived by SHA-256 hash yet.
python tools/manage_firmware_builds.py check

# Archive a bitstream with experiment metadata.
python tools/manage_firmware_builds.py archive --bitstream-path bit/Z7_LITE/main.bit --experiment exp01 --board Z7_LITE --build-param pwm_frequency_hz=1000000 --build-param modulation_frequency_hz=100000

# List archived builds.
python tools/manage_firmware_builds.py list
```

Each archive entry is written under `build_archive\build_YYYY_MM_DD_expNN\` and contains the firmware file plus `parameters.json`. The JSON records the firmware SHA-256 hash, extracted `src\main.vhd` generics/constants, supplied experiment parameters, optional generic overrides, and Git state. Firmware binaries inside `build_archive\` are ignored by Git; metadata remains visible for review.

### 5. Run Simulations
```tcl
# In Vivado Tcl Console:
launch_simulation
```

```powershell
# From PowerShell:
.\tools\sim_pwm_demo.ps1 -Testbench tb_pwm_mch
```

## Design Parameters

The top-level module (`main.vhd`) accepts the following generics:

| Parameter | Default | Description |
|-----------|---------|-------------|
| `num_channels` | 4 | Number of PWM output channels |
| `data_width` | 6 | PWM resolution in bits |
| `num_dead_time_cycles` | 4 | Dead-time duration in clock cycles |
| `buffer_depth` | 1024 | Depth of input data buffer |
| `wave_length` | 2048 | Sine wave table length |
| `ref_type` | "SYMMETRICAL" | Reference signal type |
| `ref_step` | 1 | Reference counter increment |
| `ref_updwn` | '1' | Up/down counting mode |

## Algorithm Description

### PWM Generation
The system implements **symmetrical (center-aligned) PWM** where:
- The reference counter counts up and down (triangle wave)
- Input waveform value is compared against reference counter
- PWM output toggles when reference crosses waveform value
- Center-aligned PWM reduces harmonic content compared to edge-aligned

### Clock Architecture
- **Input Clock:** 125 MHz from external oscillator
- **System Clock (clk):** 250 MHz via MMCM (for PWM logic)
- **PWM Clock (clk_pwm):** 125 MHz via MMCM (for reference counter)
- **Asynchronous FIFO:** Bridges clock domain between sine generator and PWM module

### Dead-Time Insertion
- Complementary PWM outputs (PWM and PWM_N) include programmable dead-time
- Prevents shoot-through current in bridge configurations
- Configurable via `num_dead_time_cycles` generic

## Algorithm Versions

### Version 3 (Current) - Reference-Aligned Modulation
- Module signal adapts to reference signal characteristics
- Integer-only counter increments for simplicity
- Optimized for 1 MHz PWM with 250 MHz clock
- Uses symmetrical PWM with triangle reference

### Version 2 (Legacy) - Module-Aligned Reference
- Reference signal adapts to module signal
- Required fractional MMCM dividers (not supported)
- Effective PWM frequency: 0.9765 MHz (with 250 MHz clock)

### Version 1 (Legacy) - High Resolution
- 16-bit resolution with 100 MHz clock
- PWM frequency range: 1.5 kHz to 1.2 MHz
- Trade-off table between frequency and resolution

## Validation & Simulation

### Octave Simulation
The `octave/` directory contains MATLAB-compatible scripts for algorithm validation:

```bash
# Run PWM platform simulation
octave-cli pwm_platform.m

# Generate cosine table
octave-cli table_cos.m
```

### VHDL Testbenches
Comprehensive testbenches are provided in `tb/`:

```bash
# Run specific testbench in Vivado
launch_simulation -scripts_only
```

## TO DO

- [ ] Address timing closure warnings for Z7020
- [ ] Complete timing constraint validation
- [ ] Add support for asymmetrical PWM mode
- [ ] Implement dynamic frequency control
- [ ] Add documentation for Python utilities

## License

This project is provided as-is for educational and research purposes.

## Contact & Support

For issues, questions, or contributions, please open an issue in the repository.

---

**Development Environment:** Xilinx Vivado 2018.3  
**Target Devices:** Xilinx Zynq-7000 (XC7Z010/XC7Z020)  
**Language:** VHDL-2008  
**Last Updated:** 2026-04-09
