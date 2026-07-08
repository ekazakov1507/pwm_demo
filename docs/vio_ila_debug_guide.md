# VIO/ILA Debug Guide

> Legacy note: the current Z7-Lite button-controlled top-level does not instantiate VIO or ILA. This guide is retained only for older debug builds based on the previous direct/buffered mode-control design.

This guide covers the optional debug build for `src/main.vhd`. The debug build adds Xilinx VIO and ILA IP around the top-level reset, PWM mode, and selected PWM output signals.

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

These names are local IP instance/module names. They do not appear as separate IP Catalog products. In Vivado IP Catalog, the base products are still:

```text
Virtual Input/Output
Integrated Logic Analyzer
```

When `debug=DEBUG`, `tcl\common.tcl` creates or reconfigures those XCI files, runs `generate_target all`, and runs `synth_ip -force` so stale ignored IP DCPs do not keep old probe widths.

## VIO Controls

The VIO runs in the internal `clk` domain and has two 3-bit output probes.

| VIO output | Signal | Width | Meaning |
|------------|--------|-------|---------|
| `probe_out0` | `vio_rst_ctrl` | 3 | Reset control bus. |
| `probe_out1` | `vio_pwm_mode_ctrl` | 3 | PWM mode control bus. |

Both control buses use the same bit layout:

| Bit | Name | Meaning |
|-----|------|---------|
| `[0]` | `force` | Additive force-high control. Physical input is still preserved. |
| `[1]` | `override_en` | Enables direct VIO override of the effective control. |
| `[2]` | `override_value` | Effective value when override is enabled. |

The effective controls are:

```vhdl
rst_request <= vio_rst_ctrl(vio_override_value_bit) when (vio_rst_ctrl(vio_override_en_bit) = '1') else
               sys_rst or vio_rst_ctrl(vio_force_bit);

pwm_mode_request <= vio_pwm_mode_ctrl(vio_override_value_bit) when
                    (vio_pwm_mode_ctrl(vio_override_en_bit) = '1') else
                    sys_pwm_mode or vio_pwm_mode_ctrl(vio_force_bit);
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

Trigger ILA on the raw VIO bits in `debug_probe_rst_ctrl` or on the effective request bit. If `sys_rst` is already high, toggling only `vio_rst_ctrl[0]` does not change `rst_request`; trigger on the raw force bit itself or use override mode.

## PWM Mode Debug Workflow

If physical PWM mode is low and you only want to force buffered mode from VIO:

```text
vio_pwm_mode_ctrl[1] = 0
vio_pwm_mode_ctrl[0] = 1  -> request buffered mode
vio_pwm_mode_ctrl[0] = 0  -> release VIO force
```

If the physical PWM mode input is fixed high and you need to select direct mode:

```text
vio_pwm_mode_ctrl[1] = 1
vio_pwm_mode_ctrl[2] = 0  -> force direct mode
vio_pwm_mode_ctrl[2] = 1  -> force buffered mode
```

Changing the synchronized PWM mode also intentionally causes a reset pulse so the selected PWM branch switches cleanly.

## ILA Probe Map

The ILA runs in the internal `clk` domain and has four grouped probes.

| ILA probe | Signal | Width | Notes |
|-----------|--------|-------|-------|
| `probe0` | `debug_probe_rst_ctrl` | 6 | Physical, VIO, effective, and synchronized reset controls. |
| `probe1` | `debug_probe_pwm_mode_ctrl` | 6 | Physical, VIO, effective, and synchronized PWM mode controls. |
| `probe2` | `debug_probe_p_selected` | 4 | Lower selected PWM outputs, zero-padded if needed. |
| `probe3` | `debug_probe_p_n_selected` | 4 | Lower selected PWM_N outputs, zero-padded if needed. |

`debug_probe_rst_ctrl` bit layout:

| Bit | Signal |
|-----|--------|
| `[5]` | `sys_rst` |
| `[4]` | `vio_rst_ctrl[2]` override value |
| `[3]` | `vio_rst_ctrl[1]` override enable |
| `[2]` | `vio_rst_ctrl[0]` force |
| `[1]` | `rst_request` |
| `[0]` | `rst` |

`debug_probe_pwm_mode_ctrl` bit layout:

| Bit | Signal |
|-----|--------|
| `[5]` | `sys_pwm_mode` |
| `[4]` | `vio_pwm_mode_ctrl[2]` override value |
| `[3]` | `vio_pwm_mode_ctrl[1]` override enable |
| `[2]` | `vio_pwm_mode_ctrl[0]` force |
| `[1]` | `pwm_mode_request` |
| `[0]` | `pwm_mode_sel` |

Useful triggers:

| Case | Trigger |
|------|---------|
| Watch VIO reset click even when physical reset is high | edge on `debug_probe_rst_ctrl[4]`, `[3]`, or `[2]` |
| Watch effective reset request | edge on `debug_probe_rst_ctrl[1]` |
| Watch internal reset release | falling edge on `debug_probe_rst_ctrl[0]` |
| Watch VIO PWM mode click | edge on `debug_probe_pwm_mode_ctrl[4]`, `[3]`, or `[2]` |
| Watch selected mode change | edge on `debug_probe_pwm_mode_ctrl[0]` |
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

The expected VIO shape is two 3-bit outputs. The expected ILA shape is four probes with widths 6, 6, 4, and 4. If Hardware Manager shows six one-bit VIO outputs, 14 ILA probes, or the older two-output/eight-probe shape, the hardware was built from stale debug IP. Re-run the debug build. The Tcl flow uses `synth_ip -force`, so it should regenerate the ignored IP DCPs.

If the ILA does not trigger when clicking `vio_rst_ctrl[0]`, check whether `sys_rst` is already high. In that case, `rst_request` remains high because force mode is OR-based. Trigger on `debug_probe_rst_ctrl[2]` or use reset override mode.

If PWM outputs are all zero, check `rst` and `rst_request` first. `p_selected` and `p_n_selected` are intentionally held at idle while internal reset is asserted.
