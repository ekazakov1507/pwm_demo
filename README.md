# PWM Demo - FPGA Pulse Width Modulation Generator

A modular FPGA-based PWM generator implemented in VHDL for Xilinx Zynq-7000 series devices, featuring symmetrical PWM generation with dead-time control and buffered multi-channel output.

## Overview

This project implements a high-frequency PWM modulation system with the following key features:

- **Symmetrical (center-aligned) PWM** generation for reduced harmonic distortion
- **Multi-channel output** (default: 4 channels with complementary pairs)
- **Dead-time insertion** to prevent shoot-through in power electronics applications
- **Buffered architecture** using asynchronous FIFOs for reliable clock domain crossing
- **MMCM clock generation** for board-clock-derived `clk` and `clk_pwm` domains
- **Runtime buffered-PWM frequency stepping** with `/2`, `/4`, `/8`, and `/16` post-dividers
- **Sine-wave soft-start ramp** after reset to avoid an immediate full-amplitude step
- **16-bit source samples truncated into a build-time fixed PWM/FIFO resolution**
- **Configurable parameters** including pulse timing, dead-time cycles, and reference signal type

## Technical Specifications

### Current Configuration (v4)
- **PWM Frequency:** button-selectable from ~195.3125 kHz to ~24.414 kHz at the default 8-bit resolution
- **Modulation:** Sine LUT source; current board constraints yield ~24.4 kHz for `clk` / 2048
- **Resolution:** fixed at build time with `pwm_resolution_bits`; default is 8-bit
- **Clock Frequency:** 50 MHz `clk` and raw 200 MHz `clk_pwm`, derived from the 100 MHz board input constraints
- **Dead Time:** 4 effective PWM ticks; default `/2` gives ~40 ns
- **Buffer Depth:** 16384 samples in the buffered branch
- **Wave Table Length:** 2048 points
- **Sine Soft Start:** 2048 `clk` cycles by default

### Architecture
```
System Clock (100 MHz, constrained by board XDC)
    ↓
[IBUF] → [BUFG] → [MMCM]
                     ↓
              clk (50 MHz) ──→ [16-bit Sine Generator]
                            └──→ [Truncate to pwm_resolution_bits]
                            └──→ [Buffered PWM / FIFO] ──→ [OBUF] → PWM Outputs
              clk_pwm (200 MHz raw) ──→ [/2 /4 /8 /16 tick] ──→ [Buffered PWM Reference Counters]
```

## Project Structure

```
pwm_demo/
├── src/                        # Source files
│   ├── main.vhd               # Top-level design
│   ├── pwm_core/rtl/          # Reusable PWM core submodule
│   │   ├── pwm/               # pwm_mch, pwm_1ch, drive package
│   │   ├── counters/          # Reference counter implementations
│   │   ├── signal_chain/      # Scalers including FP23 support
│   │   ├── fp23/              # Packed FP23 helpers
│   │   └── utils/             # Range divider and dead-time generator
│   ├── pwm/                   # Demo-specific PWM wrappers
│   │   └── pwm_mch_buf.vhd    # Multi-channel buffered PWM with CDC
│   ├── signal_chain/          # Demo-specific signal generation & conditioning
│   │   ├── sine_gen_simple.vhd  # Sine wave LUT with optional ramp
│   │   └── data_decimator.vhd
│   ├── buffers/               # FIFO buffers
│   │   └── async_fifo.vhd     # Asynchronous FIFO for clock domain crossing
│   └── utils/                 # Utility modules
│       ├── edge_delay.vhd
│       └── pwm_clk_post_scaler.vhd
├── tb/                         # Testbenches
│   ├── tb_main.vhd
│   ├── tb_pwm_1ch.vhd
│   ├── tb_pwm_mch.vhd
│   ├── tb_counters.vhd
│   ├── tb_async_fifo.vhd
│   ├── tb_scalers.vhd
│   ├── tb_range_divider_pkg.vhd
│   ├── tb_output_control.vhd
│   └── ...
├── constraints/                # Pin constraints for target boards
│   ├── Zybo_board.xdc         # Digilent Zybo Z7
│   ├── Z7_LITE.xdc            # Microphase Z7-Lite
│   └── Antminer-S9.xdc        # Antminer S9 (custom target)
├── octave/                     # MATLAB/Octave simulation scripts
│   ├── pwm_platform.m         # Main simulation script
│   ├── pwm_c.m                # Symmetrical PWM model
│   ├── table_cos.m            # Cosine table generation
│   ├── cos_table_gen.m        # Cosine table helper
│   ├── cos-table.txt          # Pre-computed cosine values
│   ├── cos-table_signed.txt   # Signed cosine table
│   └── cos-table_unsigned.txt # Unsigned cosine table
├── tools/                      # Python build/simulation/archive utilities
├── sim/                        # Simulation files
└── ip/                         # Generated IP cores
```

## Supported Hardware

The checked-in constraints and board build scripts currently cover these
Xilinx Zynq-7000 targets:

- **[Digilent Zybo Z7](https://digilent.com/reference/programmable-logic/zybo-z7/start)** - Zynq-7010/7020
- **[Microphase Z7-Lite](https://github.com/hw/Microphase-Z7-Lite)** - Zynq-7010/Zynq-7020 variants; SD boot wrapper targets XC7Z020
- **Antminer S9** - Custom ASIC miner board (repurposed)

### Board Controls

| Board | Reset input | Frequency step input | Mode LED |
|-------|-------------|---------------------------------|----------------|
| Digilent Zybo Z7 | `BTN0` / `sys_rst` | `BTN1` / `sys_pwm_mode` | `LED0` / `sys_led` |
| Microphase Z7-Lite | `sys_rst` button, pin `P16` | `sys_pwm_mode` button, pin `T12` | `sys_led`, pin `P15` |

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
python .\tools\build_z7_lite_sd_boot.py
```

Copy `build\z7_lite_sd_boot\BOOT.bin` to the root of a FAT32 microSD card, set the Z7-Lite `J1` boot-mode jumper to SD boot, and power-cycle the board. See [docs/z7_lite_sd_boot.md](docs/z7_lite_sd_boot.md) for the full flow.

### Firmware Build Archive

Use `tools\manage_firmware_builds.py` to keep experiment firmware outputs grouped with their build parameters.

```bash
# Show generated firmware files that are not archived by SHA-256 hash yet.
python tools/manage_firmware_builds.py check

# Archive a bitstream with experiment metadata.
python tools/manage_firmware_builds.py archive --bitstream-path bit/Z7_LITE/z7-lite-nc4-srcdw16-rw8-pd2-16-dt4-buf16384-wl2048-signed-symmetrical-rs1-ru1.bit --experiment exp01 --board Z7_LITE --build-param pwm_frequency_hz=1000000 --build-param modulation_frequency_hz=100000

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
python .\tools\sim_pwm_demo.py --testbench tb_pwm_mch
```

## Design Parameters

The top-level module (`main.vhd`) accepts the following generics:

| Parameter | Default | Description |
|-----------|---------|-------------|
| `num_channels` | 4 | Number of PWM output channels |
| `debug` | "NO_DEBUG" | Use `"DEBUG"` to instantiate VIO/ILA for reset and divider-step debug |
| `pwm_resolution_bits` | 8 | Fixed buffered PWM resolution for this firmware build |
| `pwm_mode_switch_delay_cycles` | 25,000,000 | Output blanking delay before committing a runtime divider change |
| `button_debounce_cycles` | 1,000,000 | Debounce interval for the divider-step board input in the `clk` domain |
| `resolution_led_on_cycles` | 5,000,000 | LED on interval for each divider-mode blink |
| `resolution_led_off_cycles` | 5,000,000 | LED off interval between divider-mode blinks |
| `resolution_led_pause_cycles` | 25,000,000 | LED pause interval after one complete blink-count group |
| `sine_wave_length` | 2048 | Sine lookup table length in samples |
| `sine_pulse_period_cycles` | 4096 | Pulse frame length in input samples |
| `sine_pulse_start_delay_cycles` | 1024 | Leading neutral/zero samples before each pulse |
| `sine_pulse_duration_cycles` | 2048 | Active pulse duration in input samples |
| `sine_pulse_front_cycles` | 256 | Pulse rising envelope length in input samples |
| `sine_pulse_fall_cycles` | 256 | Pulse falling envelope length in input samples |
| `sine_buffer_prefill_pulses` | 2 | Pulse frames written before buffered output starts |
| `sine_buffer_resume_pulses` | 1 | FIFO level that triggers a refill batch |
| `sine_buffer_refill_batch_pulses` | 1 | Pulse frames written per refill batch |
| `sine_buffer_min_safe_pulses` | 0 | FIFO level that stops buffered output |
| `sine_buffer_margin_samples` | 8 | FIFO full-margin used by the writer |
| `reset_release_cycles` | 5 | Minimum synchronized reset assertion length for sine/PWM reset release |

The top-level instantiates one fixed-resolution buffered PWM branch. The button selects the post-divider:

| Divider | Selector | LED blinks | Default 8-bit PWM frequency |
|---------|----------|------------|-----------------------------|
| `/2` | `00` | 1 | 195.3125 kHz |
| `/4` | `01` | 2 | 97.65625 kHz |
| `/8` | `10` | 3 | 48.828125 kHz |
| `/16` | `11` | 4 | 24.4140625 kHz |

Frequency formula:

```text
pwm_frequency = raw_clk_pwm_hz / (post_divider * 2 * 2**pwm_resolution_bits)
```

## Algorithm Description

### PWM Generation
The system implements **symmetrical (center-aligned) PWM** where:
- The reference counter counts up and down (triangle wave)
- Input waveform value is compared against reference counter
- PWM output toggles when reference crosses waveform value
- Center-aligned PWM reduces harmonic content compared to edge-aligned

### Clock Architecture
- **Input Clock:** 100 MHz in the checked-in board constraints
- **System Clock (clk):** 50 MHz via MMCM ratio in current board builds
- **PWM Clock (clk_pwm):** raw 200 MHz via MMCM ratio in current board builds
- **Asynchronous FIFO:** Bridges clock domain between sine generator and PWM module

### Dead-Time Insertion
- Complementary PWM outputs (PWM and PWM_N) include programmable dead-time
- Prevents shoot-through current in bridge configurations
- Configurable via `num_dead_time_cycles` generic

## Algorithm Versions

### Version 4 (Current) - Fixed Resolution With Runtime Buffered Frequency Step
- Module signal adapts to reference signal characteristics
- Integer-only counter increments for simplicity
- Uses one buffered PWM branch at build-time `pwm_resolution_bits`
- Uses the legacy `sys_pwm_mode` input as a `/2`, `/4`, `/8`, `/16` frequency-step button
- Blinks `sys_led` 1, 2, 3, or 4 times to show the active divider
- Blanks outputs and resets the sine/FIFO/PWM path during runtime divider changes
- Enables sine soft-start ramp after reset
- Uses symmetrical PWM with triangle reference

### Version 3 (Legacy) - Reference-Aligned Modulation
- Used direct and buffered PWM branches selected by `sys_pwm_mode`
- Blanked outputs during runtime mode handoff and during PWM reset

### Version 2 (Legacy) - Module-Aligned Reference
- Reference signal adapts to module signal
- Required fractional MMCM dividers (not supported)
- Historical effective PWM frequency estimate: 0.9765 MHz

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
- [ ] Validate asymmetrical PWM mode in the board top-level flow
- [ ] Extend runtime frequency control beyond the fixed `/2`, `/4`, `/8`, `/16` divider set
- [ ] Add documentation for Python utilities

## License

This project is provided as-is for educational and research purposes.

## Contact & Support

For issues, questions, or contributions, please open an issue in the repository.

---

**Development Environment:** Xilinx Vivado 2018.3  
**Target Devices:** Xilinx Zynq-7000 (XC7Z010/XC7Z020)  
**Language:** VHDL-2008  
**Last Updated:** 2026-07-11
