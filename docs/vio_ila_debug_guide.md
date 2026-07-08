# VIO/ILA Debug Guide

This guide covers the optional debug build for `src/main.vhd`. The debug build adds Xilinx VIO and ILA IP around reset, the resolution/frequency step input, the selected runtime resolution, and the selected PWM outputs.

Default builds use `debug = "NO_DEBUG"` and do not instantiate or require the debug IP.

## Build Commands

Run from the `pwm_demo` repo root:

```powershell
$Vivado = "C:\Xilinx\Vivado\2018.3\bin\vivado.bat"

& $Vivado -mode batch -source tcl\build_z7-lite.tcl -tclargs z7_debug "debug=DEBUG"
& $Vivado -mode batch -source tcl\build_zybo-zynq.tcl -tclargs zybo_debug "debug=DEBUG"
```

Expected debug artifacts:

| Board | Bitstream | Probe file |
|-------|-----------|------------|
| Z7-Lite | `bit\z7-lite-z7-debug.bit` | `bit\z7-lite-z7-debug.ltx` |
| Zybo | `bit\zybo-zynq-zybo-debug.bit` | `bit\zybo-zynq-zybo-debug.ltx` |

Generated IP products are local build artifacts under `ip\debug\` and are ignored by Git. The source of truth is `tcl\common.tcl`.

## IP Generation Model

The VHDL top declares generated IP components named:

```text
vio_pwm_debug
ila_pwm_debug
```

When `debug=DEBUG`, `tcl\common.tcl` creates or reconfigures those XCI files, disables out-of-context synth checkpoints, and runs `generate_target all`. The debug IP is then synthesized with the top-level design, so stale ignored IP DCPs cannot keep old probe widths.

## VIO Controls

The VIO runs in the internal `clk` domain and has two 3-bit output probes.

| VIO output | Signal | Width | Meaning |
|------------|--------|-------|---------|
| `probe_out0` | `vio_rst_ctrl` | 3 | Reset control bus. |
| `probe_out1` | `vio_resolution_step_ctrl` | 3 | Resolution/frequency step control bus. |

Both control buses use the same bit layout:

| Bit | Name | Meaning |
|-----|------|---------|
| `[0]` | `force` | Additive force-high control. Physical input is still preserved. |
| `[1]` | `override_en` | Enables direct VIO override of the effective control. |
| `[2]` | `override_value` | Effective value when override is enabled. |

The effective controls are:

```vhdl
rst_request <= vio_rst_ctrl(2) when (vio_rst_ctrl(1) = '1') else
               sys_rst or vio_rst_ctrl(0);

resolution_step_request <= vio_resolution_step_ctrl(2) when
                           (vio_resolution_step_ctrl(1) = '1') else
                           sys_pwm_mode or vio_resolution_step_ctrl(0);
```

Use force mode when the physical input is working normally and you only need to drive the control high from VIO. Use override mode when the physical input is fixed high or you need direct VIO control of the effective signal.

## Reset Debug Workflow

If physical reset is low and you only want to force reset from VIO:

```text
vio_rst_ctrl[1] = 0
vio_rst_ctrl[0] = 1  -> request reset
vio_rst_ctrl[0] = 0  -> release VIO force
```

If physical reset is stuck high and OR-force cannot release it:

```text
vio_rst_ctrl[1] = 1
vio_rst_ctrl[2] = 0  -> force effective reset low
vio_rst_ctrl[2] = 1  -> force effective reset high
```

## Resolution Step Debug Workflow

Reset selects 6-bit mode. Each valid press of the effective resolution-step signal cycles:

```text
6 -> 7 -> 8 -> 4 -> 5 -> 6
```

To emulate one button press from VIO when the physical button is low:

```text
vio_resolution_step_ctrl[1] = 0
vio_resolution_step_ctrl[0] = 1  -> press
vio_resolution_step_ctrl[0] = 0  -> release before the next press
```

The press must remain high long enough for `button_debounce_cycles`. Human-speed VIO clicks are normally much longer than that. After the debounced rising edge, the top-level blanks the outputs, holds the sine and PWM/FIFO branches in reset for `pwm_mode_switch_delay_cycles`, commits the next `resolution_sel`, then releases reset.

If the physical step input is stuck high and you need direct control:

```text
vio_resolution_step_ctrl[1] = 1
vio_resolution_step_ctrl[2] = 0  -> force effective step low
vio_resolution_step_ctrl[2] = 1  -> force effective step high
```

Return `vio_resolution_step_ctrl[2]` low before generating the next rising edge.

## ILA Probe Map

The ILA runs in the internal `clk` domain and has four grouped probes.

| ILA probe | Signal | Width | Notes |
|-----------|--------|-------|-------|
| `probe0` | `debug_probe_rst_ctrl` | 8 | Physical, VIO, effective reset, MMCM lock, and internal resets. |
| `probe1` | `debug_probe_resolution_ctrl` | 8 | Physical, VIO, effective step, and selected resolution. |
| `probe2` | `debug_probe_p_selected` | 4 | Lower selected PWM outputs, zero-padded if needed. |
| `probe3` | `debug_probe_p_n_selected` | 4 | Lower selected PWM_N outputs, zero-padded if needed. |

`debug_probe_rst_ctrl` bit layout:

| Bit | Signal |
|-----|--------|
| `[7]` | `sys_rst` |
| `[6]` | `vio_rst_ctrl[2]` override value |
| `[5]` | `vio_rst_ctrl[1]` override enable |
| `[4]` | `vio_rst_ctrl[0]` force |
| `[3]` | `rst_request` |
| `[2]` | `mmcm_clk_lock` |
| `[1]` | `sine_rst` |
| `[0]` | `pwm_rst` |

`debug_probe_resolution_ctrl` bit layout:

| Bit | Signal |
|-----|--------|
| `[7]` | `sys_pwm_mode` physical step input |
| `[6]` | `vio_resolution_step_ctrl[2]` override value |
| `[5]` | `vio_resolution_step_ctrl[1]` override enable |
| `[4]` | `vio_resolution_step_ctrl[0]` force |
| `[3]` | `resolution_step_request` |
| `[2:0]` | `resolution_sel` (`000`=4-bit, `001`=5-bit, `010`=6-bit, `011`=7-bit, `100`=8-bit) |

Useful triggers:

| Case | Trigger |
|------|---------|
| Watch VIO reset click even when physical reset is high | edge on `debug_probe_rst_ctrl[6]`, `[5]`, or `[4]` |
| Watch effective reset request | edge on `debug_probe_rst_ctrl[3]` |
| Watch PWM reset release | falling edge on `debug_probe_rst_ctrl[0]` |
| Watch VIO step click | edge on `debug_probe_resolution_ctrl[6]`, `[5]`, or `[4]` |
| Watch effective step request | edge on `debug_probe_resolution_ctrl[3]` |
| Watch selected resolution change | value/change trigger on `debug_probe_resolution_ctrl[2:0]` |
| Watch PWM output activity | value/change trigger on `debug_probe_p_selected` or `debug_probe_p_n_selected` |

## Programming With Bit And LTX

In Vivado Hardware Manager, program the device with the matching `.bit` and `.ltx`. The files must come from the same debug build.

Example Tcl for Z7-Lite:

```tcl
set bit_file "C:/Users/user/VivadoProjects/2018-3/pwm_demo/bit/z7-lite-z7-debug.bit"
set ltx_file "C:/Users/user/VivadoProjects/2018-3/pwm_demo/bit/z7-lite-z7-debug.ltx"

open_hw_manager
connect_hw_server
open_hw_target

set dev [current_hw_device]
set_property PROGRAM.FILE $bit_file $dev
set_property PROBES.FILE $ltx_file $dev
program_hw_devices $dev
refresh_hw_device $dev
```

For Zybo, use:

```tcl
set bit_file "C:/Users/user/VivadoProjects/2018-3/pwm_demo/bit/zybo-zynq-zybo-debug.bit"
set ltx_file "C:/Users/user/VivadoProjects/2018-3/pwm_demo/bit/zybo-zynq-zybo-debug.ltx"
```

## Troubleshooting

The expected VIO shape is two 3-bit outputs. The expected ILA shape is four probes with widths 8, 8, 4, and 4. If Hardware Manager shows the older 6, 6, 4, 4 ILA shape, the hardware was built from stale debug IP. Re-run the debug build; the Tcl flow regenerates the XCI targets and synthesizes the debug IP with the top-level design.

If the ILA does not trigger when clicking `vio_rst_ctrl[0]`, check whether `sys_rst` is already high. In that case, `rst_request` remains high because force mode is OR-based. Trigger on `debug_probe_rst_ctrl[4]` or use reset override mode.

If a VIO step click does not change `resolution_sel`, make sure the effective step input was released low before pressing again and that reset is not active. Watch `debug_probe_resolution_ctrl[3]` for the effective step and `debug_probe_rst_ctrl[0]` for PWM reset release.

If PWM outputs are all zero, check `pwm_rst`, `rst_request`, and the selected resolution first. `p_selected` and `p_n_selected` are intentionally held at idle while internal PWM reset is asserted.
