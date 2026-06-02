#!/usr/bin/env python3
"""Repair Vivado project/XSim compile order for pwm_demo."""

from __future__ import annotations

import argparse
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path


DESIGN_FILES = (
    "src/pwm_core/rtl/fp23/fp23_pkg.vhd",
    "src/pwm_core/rtl/utils/range_divider_pkg.vhd",
    "src/pwm_core/rtl/utils/dead_time_generator.vhd",
    "src/pwm_core/rtl/counters/up_counter_unsigned.vhd",
    "src/pwm_core/rtl/counters/up_counter_signed.vhd",
    "src/pwm_core/rtl/counters/updown_counter_unsigned.vhd",
    "src/pwm_core/rtl/counters/updown_counter_signed.vhd",
    "src/pwm_core/rtl/signal_chain/scaler_fp23.vhd",
    "src/pwm_core/rtl/signal_chain/scaler_unsigned.vhd",
    "src/pwm_core/rtl/signal_chain/scaler_signed.vhd",
    "src/pwm_core/rtl/pwm/pwm_1ch_drive_pkg.vhd",
    "src/pwm_core/rtl/pwm/pwm_1ch.vhd",
    "src/pwm_core/rtl/pwm/pwm_mch.vhd",
    "src/utils/edge_delay.vhd",
    "src/buffers/async_fifo.vhd",
    "src/signal_chain/data_decimator.vhd",
    "src/signal_chain/sine_gen_simple.vhd",
    "src/pwm/pwm_mch_buf.vhd",
    "src/main.vhd",
)

DEFAULT_SIM_FILES = (
    "tb/tb_counters.vhd",
    "tb/tb_output_control.vhd",
    "tb/tb_async_fifo.vhd",
    "tb/tb_scalers.vhd",
    "tb/tb_pwm_1ch.vhd",
    "tb/tb_pwm_mch.vhd",
    "tb/tb_range_divider_pkg.vhd",
    "tb/tb_main.vhd",
)

XPR_FILTER_MARKER = '      <Filter Type="Srcs"/>'
XPR_CONFIG_MARKER = "      <Config>"
XPR_BD_PATH = "$PSRCDIR/sources_1/bd/design_1/design_1.bd"
XSIM_PRJ_PATH = Path("pwm_demo.sim/sim_1/behav/xsim/tb_pwm_mch_vhdl.prj")
TB_LINE_RE = re.compile(r'"\.\./\.\./\.\./\.\./tb/.+\.vhd"\s*\\\s*$')


def repo_root_default() -> Path:
    return Path(__file__).resolve().parents[1]


def xpr_file_entry(path: str, *, implementation: bool = False, user_disabled: bool = False) -> str:
    attrs: list[str] = []
    if user_disabled:
        attrs.append('          <Attr Name="UserDisabled" Val="1"/>')

    attrs.append('          <Attr Name="UsedIn" Val="synthesis"/>')
    if implementation:
        attrs.append('          <Attr Name="UsedIn" Val="implementation"/>')
    attrs.append('          <Attr Name="UsedIn" Val="simulation"/>')

    lines = [
        f'      <File Path="{path}">',
        "        <FileInfo>",
        *attrs,
        "        </FileInfo>",
        "      </File>",
    ]
    return "\r\n".join(lines)


def validate_existing_files(repo_root: Path) -> None:
    missing = [path for path in DESIGN_FILES if not (repo_root / path).is_file()]
    if missing:
        formatted = "\n".join(f"  {path}" for path in missing)
        raise FileNotFoundError(f"Required VHDL sources are missing:\n{formatted}")


def repair_xpr(repo_root: Path) -> None:
    xpr_path = repo_root / "pwm_demo.xpr"
    if not xpr_path.exists():
        print(f"Skipped missing {xpr_path}")
        return

    xpr = xpr_path.read_text(encoding="utf-8-sig")
    start = xpr.find(XPR_FILTER_MARKER)
    end = xpr.find(XPR_CONFIG_MARKER, start)
    if start < 0 or end < 0:
        raise ValueError(f"Could not locate sources_1 file list in {xpr_path}")

    entries = [xpr_file_entry(f"$PPRDIR/{path}") for path in DESIGN_FILES]
    entries.append(xpr_file_entry(XPR_BD_PATH, implementation=True, user_disabled=True))

    updated = (
        xpr[: start + len(XPR_FILTER_MARKER)]
        + "\r\n"
        + "\r\n".join(entries)
        + "\r\n"
        + xpr[end:]
    )

    ET.fromstring(updated)
    xpr_path.write_text(updated, encoding="utf-8", newline="")
    print(f"Repaired {xpr_path}")


def repair_xsim_prj(repo_root: Path) -> None:
    prj_path = repo_root / XSIM_PRJ_PATH
    if not prj_path.exists():
        print(f"Skipped missing {prj_path}")
        return

    existing = prj_path.read_text(encoding="utf-8-sig").splitlines()
    tb_lines = [line for line in existing if TB_LINE_RE.match(line)]
    if not tb_lines:
        tb_lines = [f'"../../../../{path}" \\' for path in DEFAULT_SIM_FILES]

    lines = [
        "# compile vhdl design source files",
        "vhdl xil_defaultlib  \\",
        *(f'"../../../../{path}" \\' for path in DESIGN_FILES),
        *tb_lines,
        "",
        "# Do not sort compile order",
        "nosort",
        "",
    ]

    prj_path.write_text("\r\n".join(lines), encoding="utf-8", newline="")
    print(f"Repaired {prj_path}")


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--repo-root",
        type=Path,
        default=repo_root_default(),
        help="pwm_demo repository root. Defaults to this script's parent repo.",
    )
    parser.add_argument(
        "--skip-xsim-prj",
        action="store_true",
        help="Only repair pwm_demo.xpr; leave generated XSim .prj untouched.",
    )
    return parser.parse_args(argv)


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    repo_root = args.repo_root.resolve()

    try:
        validate_existing_files(repo_root)
        repair_xpr(repo_root)
        if not args.skip_xsim_prj:
            repair_xsim_prj(repo_root)
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
