# Console Build Guide

This guide covers the local Windows/Vivado 2018.3 console flow for:

- `pwm_demo`: board top, simulation helper, bitstream builds, Z7-Lite SD boot image.
- `pwm_core`: reusable HDL core only; no board top or bitstream by itself.
- `pwm_lorentz`: Lorentz top that uses `pwm_core` as a submodule and generates local FIFO IP.

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

cd C:\Users\user\VivadoProjects\2018-3\pwm_lorentz
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

Outputs are written under `bit\`:

- `<board>_<config>_synth.dcp`
- `<board>_<config>_impl.dcp`
- `<board>_<config>_timing_summary.rpt`
- `<board>_<config>_utilization.rpt`
- `<board>_<config>.bit`

The normal `z7-lite` config name is inferred from constants in `src\main.vhd`. You can also pass a custom config name and top generic override:

```powershell
& $Vivado -mode batch -source tcl\build_z7-lite.tcl -tclargs quick_test "num_channels=2"
```

Enable the optional VIO/ILA debug IP by passing `debug=DEBUG`. Debug IP output products are generated locally under `ip\debug\`, and debug builds write an `.ltx` probe file beside the bitstream:

```powershell
& $Vivado -mode batch -source tcl\build_z7-lite.tcl -tclargs z7_debug "debug=DEBUG"
& $Vivado -mode batch -source tcl\build_zybo-zynq.tcl -tclargs zybo_debug "debug=DEBUG"
```

The debug VIO exposes additive controls for reset and PWM mode, so the board inputs still work. The ILA captures physical/effective reset and mode controls plus the selected PWM/PWM_N output vectors.

For the local ignored Vivado project, configure the existing Z7-Lite and Zybo synthesis runs for debug with:

```powershell
& $Vivado -mode batch -source tcl\configure_debug_project_runs.tcl
```

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

Use the checked-in PowerShell helper:

```powershell
cd C:\Users\user\VivadoProjects\2018-3\pwm_demo
.\tools\sim_pwm_demo.ps1 -Testbench tb_pwm_mch
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
.\tools\sim_pwm_demo.ps1 -Testbench tb_pwm_1ch -Runtime "150 us"
.\tools\sim_pwm_demo.ps1 -Testbench tb_main -Runtime "40 us"
```

## Z7-Lite SD Boot Image

JTAG programming is volatile. For persistent Microphase Z7-Lite boot from microSD, build `BOOT.bin`:

```powershell
cd C:\Users\user\VivadoProjects\2018-3\pwm_demo
.\tools\build_z7_lite_sd_boot.ps1
```

The wrapper runs:

```text
Vivado bitstream build -> Vivado PS HDF export -> XSCT FSBL build -> bootgen BOOT.bin
```

Main output:

```text
build\z7_lite_sd_boot\BOOT.bin
```

Useful options:

```powershell
.\tools\build_z7_lite_sd_boot.ps1 -SkipBitstream -BitstreamPath .\build\z7_lite_sd_boot\z7-lite-sd-boot.bit
.\tools\build_z7_lite_sd_boot.ps1 -BuildDir C:\tmp\z7_lite_sd_boot
```

Copy `BOOT.bin` to the root of a FAT32 microSD card, set the Z7-Lite `J1` boot jumper to SD boot, and power-cycle the board.

## `pwm_core`

`pwm_core` is an HDL-only library. It does not contain:

- board top,
- clocking wrapper,
- XDC constraints,
- bitstream script.

Use it through `pwm_demo` or `pwm_lorentz`, or compile it alone only as a syntax/synthesis check:

```powershell
cd C:\Users\user\VivadoProjects\2018-3\pwm_core
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

## `pwm_lorentz` Bitstream

Run these commands from the `pwm_lorentz` repo root:

```powershell
cd C:\Users\user\VivadoProjects\2018-3\pwm_lorentz
git submodule update --init --recursive
& $Vivado -mode batch -source tcl\build_z7-lite.tcl
```

Other board scripts:

```powershell
& $Vivado -mode batch -source tcl\build_zybo-zynq.tcl
& $Vivado -mode batch -source tcl\build_antminer-s9.tcl
```

The Lorentz scripts:

- read `src\pwm_core\tcl\pwm_core_sources.tcl`,
- read local Lorentz sources from `tcl\pwm_lorentz_sources.tcl`,
- generate and synthesize `ip\lorentz_fifo`,
- synthesize `src\main.vhd`,
- run implementation,
- write `<board>.bit`, DCPs, timing report, and utilization report in the current working directory.

For repeatable output locations, launch Vivado from the repo root as shown above.

## Common Failures

`vivado` is not recognized:

Use the full `$Vivado` path or add `C:\Xilinx\Vivado\2018.3\bin` to `PATH`.

`pwm_core_sources.tcl` or submodule files are missing:

Run `git submodule update --init --recursive` in `pwm_demo` or `pwm_lorentz`.

Simulation starts but never finishes:

Use `tools\sim_pwm_demo.ps1` or pass a finite XSim runtime. Several testbenches intentionally keep clocks running.

Z7-Lite `BOOT.bin` build fails during FSBL:

Confirm Xilinx SDK 2018.3 is installed and use `tools\build_z7_lite_sd_boot.ps1`; it sets a local SDK home and calls XSCT with repo-relative paths for the Windows 2018.3 flow.

Bitstream works over JTAG but disappears after power cycle:

That is expected on Zynq. Use the Z7-Lite SD boot flow and copy `BOOT.bin` to the microSD root.
