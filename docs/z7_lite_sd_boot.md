# Microphase Z7-Lite SD Boot

The bitstream programmed from Vivado Hardware Manager over JTAG is volatile. After a power cycle the Zynq PL is empty again, so the PWM design stops until the FPGA is programmed again.

For persistent startup on the Microphase Z7-Lite, boot the Zynq device from microSD. The SD card contains a `BOOT.bin` image with two partitions:

- `z7_lite_fsbl.elf`: Zynq FSBL for PS startup and PL configuration.
- `z7-lite-sd-boot.bit`: the generated PWM PL bitstream.

This flow does not add Linux and does not add a PS-side application. The ARM core only runs the FSBL far enough to configure the PL from the boot image.

## Build

Run from the repository root:

```powershell
python .\tools\build_z7_lite_sd_boot.py
```

The generated files are written under:

```text
build\z7_lite_sd_boot\
```

The SD-card image is:

```text
build\z7_lite_sd_boot\BOOT.bin
```

The Python script uses Vivado and SDK 2018.3 from the default Xilinx install paths:

- `C:\Xilinx\Vivado\2018.3\bin\vivado.bat`
- `C:\Xilinx\SDK\2018.3\bin\xsct.bat`
- `C:\Xilinx\SDK\2018.3\bin\bootgen.bat`

## SD Card Use

1. Format the microSD card as FAT32.
2. Copy `BOOT.bin` to the root of the card.
3. Insert the card into the Z7-Lite.
4. Set jumper `J1` to the board's SD boot position.
5. Power-cycle the board.

After boot, the existing PWM outputs should appear on the same GPIO1 pins defined in `constraints\Z7_LITE.xdc`.

## Implementation Notes

- The SD card is connected to Zynq PS MIO, so no SD-card pins are added to the PL XDC file.
- The PS handoff is PS-only: SD0, UART0 on MIO14/MIO15 for optional FSBL diagnostics, and 16-bit DDR3 settings for the XC7Z020 Z7-Lite variant.
- The PWM logic remains a PL-only VHDL design. It still uses the board `sys_clk` pin and does not depend on a PS AXI connection.

## References

- Microphase Z7-LITE reference manual: https://fpga-docs.microphase.cn/projects/documentation-of-microphase-fpga-board/en/latest/DEV_BOARD/Z7-LITE/Z7-Lite_Reference_Manual.html
- AMD Zynq-7000 boot image flow: https://docs.amd.com/r/2023.2-English/ug1283-bootgen-user-guide/Zynq-7000-SoC-Boot-and-Configuration
- AMD Zynq-7000 FSBL overview: https://docs.amd.com/r/en-US/ug821-zynq-7000-swdev/First-Stage-Bootloader
- AMD Bootgen command example: https://docs.amd.com/r/en-US/ug821-zynq-7000-swdev/Bootgen-Command-Example
