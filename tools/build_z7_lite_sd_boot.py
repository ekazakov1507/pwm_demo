#!/usr/bin/env python3
import os
import sys
import argparse
import subprocess
import shutil
from pathlib import Path

def get_full_path(path):
    return str(Path(path).resolve())

def assert_file_exists(path, description):
    if not Path(path).is_file():
        raise FileNotFoundError(f"{description} not found: {path}")

def invoke_checked(file_path, arguments, step, cwd=None, env=None):
    print(f"==> {step}", flush=True)
    cmd = [str(file_path)] + [str(arg) for arg in arguments]
    
    if os.name == 'nt' and str(file_path).lower().endswith(('.bat', '.cmd')):
        cmd_str = subprocess.list2cmdline(cmd)
        result = subprocess.run(cmd_str, shell=True, cwd=cwd, env=env)
    else:
        result = subprocess.run(cmd, cwd=cwd, env=env)
        
    if result.returncode != 0:
        raise RuntimeError(f"{step} failed with exit code {result.returncode}")

def remove_generated_directory(path, build_dir):
    full_path = Path(path).resolve()
    full_build_dir = Path(build_dir).resolve()
    
    # Проверка безопасности: удаляем только если папка находится внутри build_dir
    try:
        full_path.relative_to(full_build_dir)
    except ValueError:
        raise ValueError(f"Refusing to delete path outside build directory: {full_path}")
        
    if full_path.exists():
        shutil.rmtree(full_path)

def remove_generated_temp_directory(path):
    full_path = Path(path).resolve()
    if os.name == 'nt':
        temp_root = Path("C:/tmp").resolve()
    else:
        temp_root = Path("/tmp").resolve()
        
    try:
        full_path.relative_to(temp_root)
    except ValueError:
        raise ValueError(f"Refusing to delete path outside {temp_root}: {full_path}")
        
    if full_path.exists():
        shutil.rmtree(full_path)

def to_xilinx_path(path):
    """Конвертирует путь в формат с прямыми слэшами для Xilinx утилит."""
    return str(Path(path).resolve()).replace("\\", "/")

def to_repo_relative_xilinx_path(path, repo_root):
    full_path = Path(path).resolve()
    full_repo_root = Path(repo_root).resolve()
    
    try:
        rel_path = full_path.relative_to(full_repo_root)
    except ValueError:
        raise ValueError(f"Path is not under repo root: {full_path}")
        
    return str(rel_path).replace("\\", "/")

def main():
    parser = argparse.ArgumentParser(description="Build Z7-Lite SD boot image.")
    
    # Значения по умолчанию зависят от ОС
    if os.name == 'nt':
        default_vivado = r"C:\Xilinx\Vivado\2018.3\bin\vivado.bat"
        default_xsct = r"C:\Xilinx\SDK\2018.3\bin\xsct.bat"
        default_bootgen = r"C:\Xilinx\SDK\2018.3\bin\bootgen.bat"
    else:
        default_vivado = "vivado"
        default_xsct = "xsct"
        default_bootgen = "bootgen"

    parser.add_argument("--vivado", default=default_vivado, help="Path to Vivado executable")
    parser.add_argument("--xsct", default=default_xsct, help="Path to XSCT executable")
    parser.add_argument("--bootgen", default=default_bootgen, help="Path to Bootgen executable")
    parser.add_argument("--build-dir", default=None, help="Build directory")
    parser.add_argument("--bitstream-path", default=None, help="Path to existing bitstream (used with --skip-bitstream)")
    parser.add_argument("--skip-bitstream", action="store_true", help="Skip bitstream generation")
    
    args = parser.parse_args()
    
    # Корень репозитория (родительская папка для скрипта)
    repo_root = Path(__file__).parent.parent.resolve()
    
    if args.build_dir is None:
        build_dir = repo_root / "build" / "z7_lite_sd_boot"
    else:
        build_dir = Path(args.build_dir).resolve()
        
    build_dir.mkdir(parents=True, exist_ok=True)
    
    def check_tool(path, desc):
        p = Path(path)
        # Если указан абсолютный путь или путь с директориями, проверяем существование файла
        if p.is_absolute() or os.sep in path or (os.altsep and os.altsep in path):
            assert_file_exists(p, desc)
        else:
            # Иначе ищем исполняемый файл в системном PATH
            if shutil.which(path) is None:
                raise FileNotFoundError(f"{desc} not found in PATH: {path}")
                
    check_tool(args.vivado, "Vivado")
    check_tool(args.xsct, "XSCT")
    check_tool(args.bootgen, "Bootgen")
    
    build_bitstream_tcl = repo_root / "tcl" / "build_z7_lite_sd_bitstream.tcl"
    export_hdf_tcl = repo_root / "tcl" / "export_z7_lite_ps_hdf.tcl"
    build_fsbl_tcl = repo_root / "tcl" / "build_z7_lite_fsbl.tcl"
    
    assert_file_exists(build_bitstream_tcl, "Z7-Lite bitstream build script")
    assert_file_exists(export_hdf_tcl, "Z7-Lite PS handoff script")
    assert_file_exists(build_fsbl_tcl, "Z7-Lite FSBL build script")
    
    build_dir_for_tcl = to_xilinx_path(build_dir)
    build_bitstream_tcl_for_tcl = to_xilinx_path(build_bitstream_tcl)
    export_hdf_tcl_for_tcl = to_xilinx_path(export_hdf_tcl)
    
    if args.skip_bitstream:
        if not args.bitstream_path:
            raise ValueError("Use --bitstream-path when --skip-bitstream is set.")
        bitstream = Path(args.bitstream_path).resolve()
    else:
        invoke_checked(
            args.vivado,
            ["-mode", "batch", "-nolog", "-nojournal", "-source", build_bitstream_tcl_for_tcl, "-tclargs", build_dir_for_tcl],
            "Build Z7-Lite PWM bitstream"
        )
        bitstream = build_dir / "z7-lite-sd-boot.bit"
        
    assert_file_exists(bitstream, "PWM bitstream")
    
    invoke_checked(
        args.vivado,
        ["-mode", "batch", "-nolog", "-nojournal", "-source", export_hdf_tcl_for_tcl, "-tclargs", build_dir_for_tcl],
        "Export Z7-Lite PS hardware handoff"
    )
    
    hdf = build_dir / "z7_lite_ps.hdf"
    assert_file_exists(hdf, "Z7-Lite PS hardware handoff")
    
    sdk_home = build_dir / "sdk_home"
    sdk_home.mkdir(parents=True, exist_ok=True)
    
    # Изолируем рабочую директорию SDK, меняя HOME-переменные только для дочернего процесса
    env = os.environ.copy()
    env["HOME"] = str(sdk_home)
    env["USERPROFILE"] = str(sdk_home)
    if os.name == 'nt':
        env["HOMEDRIVE"] = sdk_home.drive
        env["HOMEPATH"] = str(sdk_home).replace(sdk_home.drive, "")
        
    remove_generated_directory(build_dir / "sdk_ws", build_dir)
    remove_generated_directory(build_dir / "hsi_fsbl", build_dir)
    
    fsbl = build_dir / "z7_lite_fsbl.elf"
    build_fsbl_tcl_for_xsct = to_repo_relative_xilinx_path(build_fsbl_tcl, repo_root)
    hdf_for_xsct = to_xilinx_path(hdf)
    build_dir_for_xsct = to_xilinx_path(build_dir)
    
    invoke_checked(
        args.xsct,
        [build_fsbl_tcl_for_xsct, hdf_for_xsct, build_dir_for_xsct],
        "Build Zynq FSBL",
        cwd=str(repo_root),
        env=env
    )
    
    assert_file_exists(fsbl, "Zynq FSBL")
    
    bif = build_dir / "z7_lite_sd_boot.bif"
    boot_bin = build_dir / "BOOT.bin"
    
    bif_text = f"""the_ROM_image:
{{
  [bootloader] {to_xilinx_path(fsbl)}
  {to_xilinx_path(bitstream)}
}}
"""
    # Xilinx tools ожидают ASCII-кодировку для BIF
    with open(bif, "w", encoding="ascii") as f:
        f.write(bif_text)
        
    invoke_checked(
        args.bootgen,
        ["-arch", "zynq", "-image", to_xilinx_path(bif), "-o", to_xilinx_path(boot_bin), "-w", "on"],
        "Generate SD-card BOOT.BIN"
    )
    
    assert_file_exists(boot_bin, "SD boot image")
    
    print()
    print(f"BOOT.BIN generated: {boot_bin}")
    print("Copy BOOT.BIN to the FAT32 microSD root and set Z7-Lite J1 to SD boot.")

if __name__ == "__main__":
    main()#
