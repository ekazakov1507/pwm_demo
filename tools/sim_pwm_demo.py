#!/usr/bin/env python3
import argparse
import os
import sys
import subprocess
from pathlib import Path

def convert_to_xsim_path(path: Path) -> str:
    """Converts a path to an absolute path with forward slashes for XSIM."""
    return str(path.resolve()).replace("\\", "/")

def assert_file_exists(path: Path, description: str):
    """Checks if a file exists, raises FileNotFoundError if not."""
    if not path.is_file():
        raise FileNotFoundError(f"{description} not found: {path}")

def invoke_checked(file_path: Path, arguments: list, step: str, working_directory: Path):
    """Runs a command and checks its exit code."""
    print(f"==> {step}", flush=True)
    cmd = [str(file_path)] + [str(arg) for arg in arguments]

    if os.name == "nt" and str(file_path).lower().endswith((".bat", ".cmd")):
        result = subprocess.run(
            subprocess.list2cmdline(cmd),
            shell=True,
            cwd=str(working_directory),
        )
    else:
        result = subprocess.run(cmd, cwd=str(working_directory))

    if result.returncode != 0:
        raise RuntimeError(f"{step} failed with exit code {result.returncode}")

def main():
    parser = argparse.ArgumentParser(description="Vivado XSIM wrapper for PWM testbenches.")
    
    testbench_choices = [
        "tb_main",
        "tb_pwm_1ch",
        "tb_pwm_mch",
        "tb_async_fifo",
        "tb_counters",
        "tb_scalers",
        "tb_range_divider_pkg"
    ]
    
    parser.add_argument(
        "--testbench",
        type=str,
        default="tb_main",
        choices=testbench_choices,
        help="Testbench to run"
    )
    parser.add_argument(
        "--runtime",
        type=str,
        help="Simulation runtime (e.g., '20 us'). Defaults to predefined values."
    )
    parser.add_argument(
        "--vivado-bin",
        type=str,
        default=r"C:\Xilinx\Vivado\2018.3\bin",
        help="Path to Vivado bin directory"
    )
    
    args = parser.parse_args()
    
    testbench = args.testbench
    runtime_arg = args.runtime
    vivado_bin_arg = args.vivado_bin

    # Resolve repository root (parent of the script's directory)
    repo_root = Path(__file__).resolve().parent.parent
    vivado_bin = Path(vivado_bin_arg).resolve()

    # Define tool paths
    xvhdl = vivado_bin / "xvhdl.bat"
    xelab = vivado_bin / "xelab.bat"
    xsim = vivado_bin / "xsim.bat"

    assert_file_exists(xvhdl, "xvhdl")
    assert_file_exists(xelab, "xelab")
    assert_file_exists(xsim, "xsim")

    # Default runtimes for each testbench
    default_runtimes = {
        "tb_main": "1100 us",
        "tb_pwm_1ch": "110 us",
        "tb_pwm_mch": "260 us",
        "tb_async_fifo": "20 us",
        "tb_counters": "2 us",
        "tb_scalers": "35 us",
        "tb_range_divider_pkg": "1 us"
    }

    runtime = runtime_arg if runtime_arg else default_runtimes[testbench]

    # List of VHDL design files
    design_files = [
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
        "src/utils/pwm_clk_post_scaler.vhd",
        "src/pwm/pwm_mch_buf.vhd",
        "src/main.vhd",
        f"tb/{testbench}.vhd"
    ]

    # Assert all design files exist
    for rel_path in design_files:
        assert_file_exists(repo_root / rel_path, "VHDL source")

    # Create build directory
    build_dir = repo_root / "build" / "sim" / testbench
    build_dir.mkdir(parents=True, exist_ok=True)

    project_file = build_dir / f"{testbench}.prj"
    run_file = build_dir / f"run_{testbench}.tcl"
    snapshot = f"{testbench}_sim"

    # Generate .prj file
    project_lines = []
    for rel_path in design_files:
        source_path = convert_to_xsim_path(repo_root / rel_path)
        project_lines.append(f'vhdl work "{source_path}"')
    
    project_file.write_text("\n".join(project_lines) + "\n", encoding="ascii")

    # Generate .tcl run file
    if runtime.lower() in ["all", "runall"]:
        run_lines = ["run all", "quit"]
    else:
        run_lines = [f"run {runtime}", "quit"]
    
    run_file.write_text("\n".join(run_lines) + "\n", encoding="ascii")

    # Convert paths for XSIM
    project_file_for_xsim = convert_to_xsim_path(project_file)
    run_file_for_xsim = convert_to_xsim_path(run_file)

    # Compile VHDL
    invoke_checked(
        file_path=xvhdl,
        arguments=["--2008", "--relax", "--prj", project_file_for_xsim],
        step=f"Compile VHDL for {testbench}",
        working_directory=build_dir
    )

    # Elaborate
    invoke_checked(
        file_path=xelab,
        arguments=["--debug", "typical", "--relax", "-L", "unisim", testbench, "-s", snapshot],
        step=f"Elaborate {testbench}",
        working_directory=build_dir
    )

    # Run Simulation
    invoke_checked(
        file_path=xsim,
        arguments=[snapshot, "--tclbatch", run_file_for_xsim],
        step=f"Run {testbench} for {runtime}",
        working_directory=build_dir
    )

    # Check for failures in xsim.log
    xsim_log = build_dir / "xsim.log"
    if xsim_log.is_file():
        with open(xsim_log, "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                if "Failure:" in line or "Fatal:" in line:
                    raise RuntimeError(f"Simulation reported a failure: {line.strip()}")

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
