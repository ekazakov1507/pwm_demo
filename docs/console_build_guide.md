# Console Build Guide

This guide covers the local Windows/Vivado 2018.3 console flow for:

- `pwm_demo`: board top, simulation helper, bitstream builds, Z7-Lite SD boot image.
- `pwm_core`: reusable HDL core only; no board top or bitstream by itself.

The commands below assume PowerShell.

## Tool Setup

Use the installed Vivado/SDK 2018.3 tools:

```powershell
$Vivado  = "C:\Xilinx\Vivado\2018.3\bin\vivado.bat"
$Xsct    = "C:\Xilinx\SDK\2018.3\bin\xsct.bat"
$Bootgen = "C:\Xilinx\SDK\2018.3\bin\bootgen.bat"
```

If you prefer commands without full paths, add both tool directories to `PATH`:

```powershell
$env:Path = "C:\Xilinx\Vivado\2018.3\bin;C:\Xilinx\SDK\2018.3\bin;$env:Path"
```

After cloning or copying the repositories, initialize submodules:

```powershell
cd C:\Users\user\VivadoProjects\2018-3\pwm_demo
git submodule update --init --recursive
```

## `pwm_demo` Bitstream

Run these commands from the `pwm_demo` repo root:

```powershell
cd C:\Users\user\VivadoProjects\2018-3\pwm_demo
& $Vivado -mode batch -source tcl\build_z7-lite.tcl
```

Other board scripts:

```powershell
& $Vivado -mode batch -source tcl\build_zybo-zynq.tcl
& $Vivado -mode batch -source tcl\build_antminer-s9.tcl
```

The board scripts call `tcl\common.tcl`, read all VHDL sources as VHDL-2008, read the selected XDC, run:

```text
synth_design -> opt_design -> place_design -> phys_opt_design -> route_design -> write_bitstream
```

Outputs are written under a board-specific folder in `bit\`, for example
`bit\Z7_LITE\` or `bit\ZYBO_ZYNQ\`:

- `<board-folder>\<board>-<config>_synth.dcp`
- `<board-folder>\<board>-<config>_impl.dcp`
- `<board-folder>\<board>-<config>_timing_summary.rpt`
- `<board-folder>\<board>-<config>_utilization.rpt`
- `<board-folder>\<board>-<config>.bit`

The normal config name is inferred from constants and generics in `src\main.vhd`
when no `-tclargs` are supplied. You can also pass a custom config name and
top-level generic overrides:

```powershell
& $Vivado -mode batch -source tcl\build_z7-lite.tcl -tclargs quick_test "num_channels=2"
```

### PWM Resolution/Frequency Reference

The current buffered PWM path uses a raw `clk_pwm` of 200 MHz and symmetrical
PWM. Runtime button presses select the post-divider, while
`pwm_resolution_bits` is fixed at build time.

```text
pwm_frequency = 200 MHz / (post_divider * 2 * 2**pwm_resolution_bits)
```

The table below uses the current runtime divider range, `/2` through `/16`.
For a hypothetical no-post-divider `/1` path, double the `/2` frequency.

| Resolution (`pwm_resolution_bits`) | Runtime divider | PWM frequency |
|------------------------------------|-----------------|---------------|
| 5 | `/2` | 1.562500 MHz |
| 5 | `/4` | 781.250000 kHz |
| 5 | `/8` | 390.625000 kHz |
| 5 | `/16` | 195.312500 kHz |
| 6 | `/2` | 781.250000 kHz |
| 6 | `/4` | 390.625000 kHz |
| 6 | `/8` | 195.312500 kHz |
| 6 | `/16` | 97.656250 kHz |
| 7 | `/2` | 390.625000 kHz |
| 7 | `/4` | 195.312500 kHz |
| 7 | `/8` | 97.656250 kHz |
| 7 | `/16` | 48.828125 kHz |
| 8 | `/2` | 195.312500 kHz |
| 8 | `/4` | 97.656250 kHz |
| 8 | `/8` | 48.828125 kHz |
| 8 | `/16` | 24.414062 kHz |
| 9 | `/2` | 97.656250 kHz |
| 9 | `/4` | 48.828125 kHz |
| 9 | `/8` | 24.414062 kHz |
| 9 | `/16` | 12.207031 kHz |
| 10 | `/2` | 48.828125 kHz |
| 10 | `/4` | 24.414062 kHz |
| 10 | `/8` | 12.207031 kHz |
| 10 | `/16` | 6.103516 kHz |

The `-tclargs` format is:

```text
-tclargs <config_name> "<generic_name=value generic_name=value ...>"
```

`<config_name>` is only the output-name tag. It does not change hardware by
itself. The build script sanitizes it for filenames, so `my_config` becomes
`my-config` in `z7-lite-my-config.bit`.

Useful examples:

```powershell
# 5-bit firmware: 1.5625 MHz at /2, 781.25 kHz at /4, 390.625 kHz at /8.
& $Vivado -mode batch -source tcl\build_z7-lite.tcl -tclargs r5_pd2_16 "pwm_resolution_bits=5"

# 7-bit firmware: 390.625 kHz at /2, 195.3125 kHz at /4.
& $Vivado -mode batch -source tcl\build_z7-lite.tcl -tclargs r7_pd2_16 "pwm_resolution_bits=7"

# 8-bit firmware: current default resolution, explicit output tag.
& $Vivado -mode batch -source tcl\build_z7-lite.tcl -tclargs r8_pd2_16 "pwm_resolution_bits=8"

# 10-bit firmware: lower PWM frequency, higher duty resolution.
& $Vivado -mode batch -source tcl\build_z7-lite.tcl -tclargs r10_pd2_16 "pwm_resolution_bits=10"

# Debug build with VIO/ILA.
& $Vivado -mode batch -source tcl\build_z7-lite.tcl -tclargs z7_debug "debug=DEBUG"

# Longer active pulse window while keeping the default 8-bit PWM resolution.
& $Vivado -mode batch -source tcl\build_z7-lite.tcl -tclargs pulse_long "sine_pulse_duration_cycles=3072 sine_pulse_front_cycles=512 sine_pulse_fall_cycles=512"
```

After a bitstream build, archive the firmware and record the experiment values:

```powershell
python .\tools\manage_firmware_builds.py archive --bitstream-path .\bit\Z7_LITE\z7-lite-r7-pd2-16.bit --experiment r7_pd2_16 --board Z7_LITE --config-name r7_pd2_16 --generic-override pwm_resolution_bits=7 --build-param raw_clk_pwm_hz=200000000 --build-param post_divider_min=2 --build-param post_divider_max=16
python .\tools\manage_firmware_builds.py list
```

To package a selected Z7-Lite bitstream into an SD-card boot image:

```powershell
python .\tools\build_z7_lite_sd_boot.py --skip-bitstream --bitstream-path .\bit\Z7_LITE\z7-lite-r7-pd2-16.bit
```

The override string can set only top-level `main.vhd` generics:

```text
num_channels
debug
pwm_resolution_bits
pwm_mode_switch_delay_cycles
button_debounce_cycles
resolution_led_on_cycles
resolution_led_off_cycles
resolution_led_pause_cycles
sine_wave_length
sine_pulse_period_cycles
sine_pulse_start_delay_cycles
sine_pulse_duration_cycles
sine_pulse_front_cycles
sine_pulse_fall_cycles
sine_buffer_prefill_pulses
sine_buffer_resume_pulses
sine_buffer_refill_batch_pulses
sine_buffer_min_safe_pulses
sine_buffer_margin_samples
reset_release_cycles
```

Board/build parameters that are currently VHDL constants cannot be changed from
this command yet. That includes `buffer_depth`, `num_dead_time_cycles`,
`input_data_type`, and `ref_type`.

The current board top-level is hardware-button controlled in normal builds. Use `debug=DEBUG` only when you need the optional VIO/ILA wrapper for reset and divider-step debug.

For Zybo, `constraints\Zybo_board.xdc` maps `BTN0` to reset, `BTN1` to the PWM frequency divider step input, and `LED0` to `sys_led`. For Z7-Lite, `constraints\Z7_LITE.xdc` maps the same top-level inputs to board button pins `P16` and `T12`, and maps `sys_led` to pin `P15`.

## `pwm_demo` Checks

Source-based Z7-Lite implementation check:

```powershell
cd C:\Users\user\VivadoProjects\2018-3\pwm_demo
& $Vivado -mode batch -source tcl\check_reqp1840_z7_lite.tcl
```

Outputs go to:

```text
build\reqp1840_check\
```

Project-run check using the existing `.xpr`:

```powershell
& $Vivado -mode batch -source tcl\check_reqp1840_project.tcl
```

This script opens `pwm_demo.xpr`, resets `Z7-LITE` / `Z7-LITE_impl`, runs implementation to `route_design`, then writes DRC/timing/utilization reports to:

```text
build\reqp1840_project_check\
```

## `pwm_demo` Simulation

Use the checked-in Python helper:

```powershell
cd C:\Users\user\VivadoProjects\2018-3\pwm_demo
python .\tools\sim_pwm_demo.py --testbench tb_pwm_mch
```

Supported testbenches:

```text
tb_main
tb_pwm_1ch
tb_pwm_mch
tb_async_fifo
tb_counters
tb_scalers
tb_range_divider_pkg
```

The helper creates a direct XSim work directory under `build\sim\<testbench>\`, writes an XSim `.prj` file, compiles the source list with `xvhdl`, elaborates with `xelab`, then runs `xsim` for a finite default time. A finite runtime matters because several testbenches leave clocks running forever. The helper scans `xsim.log` and exits with an error when XSim reports a VHDL assertion failure.

Override runtime when needed:

```powershell
python .\tools\sim_pwm_demo.py --testbench tb_pwm_1ch --runtime "150 us"
python .\tools\sim_pwm_demo.py --testbench tb_main --runtime "40 us"
```

## Z7-Lite SD Boot Image

JTAG programming is volatile. For persistent Microphase Z7-Lite boot from microSD, build `BOOT.bin`:

```powershell
cd C:\Users\user\VivadoProjects\2018-3\pwm_demo
python .\tools\build_z7_lite_sd_boot.py
```

The Python script runs:

```text
Vivado bitstream build -> Vivado PS HDF export -> XSCT FSBL build -> bootgen BOOT.bin
```

Main output:

```text
build\z7_lite_sd_boot\BOOT.bin
```

Useful options:

```powershell
python .\tools\build_z7_lite_sd_boot.py --skip-bitstream --bitstream-path .\build\z7_lite_sd_boot\z7-lite-sd-boot.bit
python .\tools\build_z7_lite_sd_boot.py --build-dir C:\tmp\z7_lite_sd_boot
```

Copy `BOOT.bin` to the root of a FAT32 microSD card, set the Z7-Lite `J1` boot jumper to SD boot, and power-cycle the board.

## `pwm_core`

`pwm_core` is an HDL-only library. It does not contain:

- board top,
- clocking wrapper,
- XDC constraints,
- bitstream script.

Use it through `pwm_demo`, or compile it alone only as a syntax/synthesis check:

```powershell
cd C:\Users\user\VivadoProjects\2018-3\pwm_demo\src\pwm_core
& $Vivado -mode tcl
```

Then in the Vivado Tcl shell:

```tcl
source tcl/pwm_core_sources.tcl
read_vhdl -vhdl2008 $pwm_core_vhdl_files
synth_design -top pwm_mch -part xc7z020clg400-1 -flatten_hierarchy rebuilt
report_utilization
```

This checks the reusable `pwm_mch` core. It does not produce a usable board bitstream unless you provide a board top and constraints.

## Common Failures

`vivado` is not recognized:

Use the full `$Vivado` path or add `C:\Xilinx\Vivado\2018.3\bin` to `PATH`.

`pwm_core_sources.tcl` or submodule files are missing:

Run `git submodule update --init --recursive` in `pwm_demo`.

Simulation starts but never finishes:

Use `tools\sim_pwm_demo.py` or pass a finite XSim runtime. Several testbenches intentionally keep clocks running.

Z7-Lite `BOOT.bin` build fails during FSBL:

Confirm Xilinx SDK 2018.3 is installed and use `tools\build_z7_lite_sd_boot.py`; it sets a local SDK home and calls XSCT with repo-relative paths for the Windows 2018.3 flow.

Bitstream works over JTAG but disappears after power cycle:

That is expected on Zynq. Use the Z7-Lite SD boot flow and copy `BOOT.bin` to the microSD root.
