#!/usr/bin/env python3
"""Archive and inspect firmware builds for experiment tracking."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
from collections import OrderedDict
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable


REPO_ROOT = Path(__file__).resolve().parent.parent


def full_path(path: str | Path) -> Path:
    return Path(path).resolve()


def repo_relative(path: str | Path) -> str:
    path = full_path(path)
    try:
        return path.relative_to(REPO_ROOT).as_posix()
    except ValueError:
        return str(path)


def is_relative_to(path: Path, parent: Path) -> bool:
    try:
        path.relative_to(parent)
        return True
    except ValueError:
        return False


def local_iso_from_timestamp(timestamp: float) -> str:
    return datetime.fromtimestamp(timestamp, tz=timezone.utc).astimezone().isoformat()


def now_local_iso() -> str:
    return datetime.now(timezone.utc).astimezone().isoformat()


def safe_name(value: str) -> str:
    result = re.sub(r"[^a-z0-9._-]+", "_", value.strip().lower()).strip("._-")
    if not result:
        raise ValueError(f"name component is empty after sanitizing: {value}")
    return result


def parse_scalar(value: str) -> Any:
    value = value.strip()
    lowered = value.lower()
    if lowered == "true":
        return True
    if lowered == "false":
        return False
    if lowered == "null":
        return None
    if re.fullmatch(r"-?[0-9]+", value):
        return int(value)
    if re.fullmatch(r"-?[0-9]+\.[0-9]+", value):
        return float(value)
    return value


def parse_vhdl_scalar(value: str) -> Any:
    value = value.strip()
    if len(value) >= 2 and value[0] == '"' and value[-1] == '"':
        return value[1:-1]
    if len(value) == 3 and value[0] == "'" and value[-1] == "'":
        return value[1]

    numeric = value.replace("_", "")
    if re.fullmatch(r"-?[0-9]+", numeric):
        return int(numeric)
    if re.fullmatch(r"-?[0-9]+\.[0-9]+", numeric):
        return float(numeric)
    return value


def expand_key_value_items(items: Iterable[str]) -> list[str]:
    expanded: list[str] = []
    for item in items:
        if not item or not item.strip():
            continue
        expanded.extend(part.strip() for part in item.split(",") if part.strip())
    return expanded


def parse_key_values(items: Iterable[str]) -> OrderedDict[str, Any]:
    result: OrderedDict[str, Any] = OrderedDict()
    for item in expand_key_value_items(items):
        key, separator, value = item.partition("=")
        if not separator or not key.strip():
            raise ValueError(f"expected key=value, got: {item}")
        result[key.strip()] = parse_scalar(value)
    return result


def read_vhdl_parameter_block(source: str, pattern: str) -> OrderedDict[str, Any]:
    result: OrderedDict[str, Any] = OrderedDict()
    for match in re.finditer(pattern, source, flags=re.IGNORECASE | re.MULTILINE):
        name = match.group("name")
        raw_type = re.sub(r"\s+", " ", match.group("type")).strip()
        raw_value = match.group("value").strip()
        result[name] = OrderedDict(
            [
                ("type", raw_type),
                ("value", parse_vhdl_scalar(raw_value)),
                ("raw_value", raw_value),
            ]
        )
    return result


def read_vhdl_build_parameters() -> OrderedDict[str, Any]:
    main_path = REPO_ROOT / "src" / "main.vhd"
    if not main_path.is_file():
        return OrderedDict(
            [
                ("source_file", repo_relative(main_path)),
                ("error", "src/main.vhd not found"),
            ]
        )

    source = main_path.read_text(encoding="utf-8")
    generics: OrderedDict[str, Any] = OrderedDict()
    generic_match = re.search(
        r"entity\s+main\s+is\s+generic\s*\((?P<block>.*?)\)\s*;",
        source,
        flags=re.IGNORECASE | re.DOTALL,
    )
    if generic_match:
        generics = read_vhdl_parameter_block(
            generic_match.group("block"),
            r"^\s*(?P<name>[A-Za-z][A-Za-z0-9_]*)\s*:\s*(?P<type>[^:=;\r\n]+?)\s*:=\s*(?P<value>[^;\r\n]+?)\s*;?\s*$",
        )

    constants = read_vhdl_parameter_block(
        source,
        r"^\s*constant\s+(?P<name>[A-Za-z][A-Za-z0-9_]*)\s*:\s*(?P<type>[^:=;\r\n]+?)\s*:=\s*(?P<value>[^;\r\n]+?)\s*;\s*$",
    )

    return OrderedDict(
        [
            ("source_file", repo_relative(main_path)),
            ("top", "main"),
            ("generics", generics),
            ("constants", constants),
        ]
    )


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as file:
        for chunk in iter(lambda: file.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def file_record(path: Path, archive_file_name: str | None = None) -> OrderedDict[str, Any]:
    path = full_path(path)
    stat = path.stat()
    record: OrderedDict[str, Any] = OrderedDict(
        [
            ("path", repo_relative(path)),
            ("size_bytes", stat.st_size),
            ("last_write_time", local_iso_from_timestamp(stat.st_mtime)),
            ("sha256", sha256_file(path)),
        ]
    )
    if archive_file_name:
        record["archive_file"] = archive_file_name
    return record


def git_metadata() -> OrderedDict[str, Any]:
    metadata: OrderedDict[str, Any] = OrderedDict()

    def run_git(*args: str) -> list[str]:
        completed = subprocess.run(
            ["git", "-C", str(REPO_ROOT), *args],
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            check=False,
        )
        if completed.returncode != 0:
            raise RuntimeError("git command failed")
        return completed.stdout.splitlines()

    try:
        commit = run_git("rev-parse", "HEAD")[0]
        branch_lines = run_git("branch", "--show-current")
        status = run_git("status", "--short")
        metadata["commit"] = commit
        metadata["branch"] = branch_lines[0] if branch_lines else ""
        metadata["dirty"] = bool(status)
        metadata["status_short"] = status
    except Exception as exc:  # noqa: BLE001 - metadata is best effort
        metadata["error"] = str(exc)

    return metadata


def import_external_parameters(path: str | None) -> OrderedDict[str, Any] | None:
    if not path:
        return None

    parameter_path = full_path(path)
    if not parameter_path.is_file():
        raise FileNotFoundError(f"parameters file not found: {parameter_path}")

    result: OrderedDict[str, Any] = OrderedDict([("source_file", repo_relative(parameter_path))])
    raw = parameter_path.read_text(encoding="utf-8")
    if parameter_path.suffix.lower() == ".json":
        result["content"] = json.loads(raw)
    else:
        result["content_text"] = raw
    return result


def infer_board_name(path: Path) -> str | None:
    normalized = path.as_posix().lower()
    if re.search(r"z7[_-]lite|z7-lite", normalized):
        return "Z7_LITE"
    if re.search(r"zybo[_-]zynq|zybo-zynq", normalized):
        return "ZYBO_ZYNQ"
    if "antminer" in normalized:
        return "ANTMINER_S9"
    return None


def next_experiment_name(archive_root: Path) -> str:
    date_prefix = datetime.now().strftime("%Y_%m_%d")
    highest = 0
    if archive_root.is_dir():
        pattern = re.compile(rf"^build_{re.escape(date_prefix)}_exp(?P<number>[0-9]+)$")
        for child in archive_root.iterdir():
            if not child.is_dir():
                continue
            match = pattern.match(child.name)
            if match:
                highest = max(highest, int(match.group("number")))
    return f"exp{highest + 1:02d}"


def is_inside_firmware_archive(path: Path) -> bool:
    path = full_path(path)
    directory = path.parent

    while True:
        if not is_relative_to(directory, REPO_ROOT):
            return False

        parameters_json = directory / "parameters.json"
        if parameters_json.is_file():
            try:
                metadata = json.loads(parameters_json.read_text(encoding="utf-8"))
                if metadata.get("archive_schema_version") is not None:
                    return True
            except json.JSONDecodeError:
                return False

        if directory == REPO_ROOT:
            return False
        if directory.parent == directory:
            return False
        directory = directory.parent


def new_archive_name(name: str | None, experiment: str) -> str:
    if name:
        return safe_name(name)
    return f"build_{datetime.now().strftime('%Y_%m_%d')}_{safe_name(experiment)}"


def firmware_candidates(archive_root: Path) -> list[Path]:
    archive_root = full_path(archive_root)
    search_specs = [
        (REPO_ROOT / "bit", ["*.bit", "*.bin"], True),
        (REPO_ROOT / "pwm_demo.runs", ["*.bit"], True),
        (REPO_ROOT / "build", ["*.bit", "BOOT.bin"], True),
        (REPO_ROOT, ["*.bit", "*.bin"], False),
    ]

    seen: set[str] = set()
    candidates: list[Path] = []
    for root, patterns, recursive in search_specs:
        if not root.is_dir():
            continue
        for pattern in patterns:
            iterator = root.rglob(pattern) if recursive else root.glob(pattern)
            for item in iterator:
                if not item.is_file():
                    continue
                resolved = full_path(item)
                key = os.path.normcase(str(resolved))
                if key in seen:
                    continue
                if is_relative_to(resolved, archive_root):
                    continue
                if is_inside_firmware_archive(resolved):
                    continue
                seen.add(key)
                candidates.append(resolved)

    return sorted(candidates, key=lambda item: str(item).lower())


def archived_firmware_hashes(archive_root: Path) -> dict[str, str]:
    hashes: dict[str, str] = {}
    if not archive_root.is_dir():
        return hashes

    for parameters_json in archive_root.rglob("parameters.json"):
        try:
            metadata = json.loads(parameters_json.read_text(encoding="utf-8"))
        except json.JSONDecodeError as exc:
            print(f"warning: could not read archive metadata {parameters_json}: {exc}", file=sys.stderr)
            continue

        source = metadata.get("source", {})
        source_hash = source.get("sha256")
        if source_hash:
            hashes[source_hash.lower()] = parameters_json.parent.name

        for artifact in metadata.get("artifacts", []):
            artifact_hash = artifact.get("sha256")
            if artifact_hash:
                hashes[artifact_hash.lower()] = parameters_json.parent.name

    return hashes


def archive_build(args: argparse.Namespace) -> int:
    archive_root = full_path(args.archive_root)
    bitstream_path = full_path(args.bitstream_path)
    if not bitstream_path.is_file():
        raise FileNotFoundError(f"bitstream not found: {bitstream_path}")

    experiment = args.experiment
    if not experiment and not args.name:
        experiment = next_experiment_name(archive_root)
    elif not experiment:
        experiment = ""

    archive_name = new_archive_name(args.name, experiment)
    archive_dir = archive_root / archive_name
    if archive_dir.exists():
        raise FileExistsError(f"archive already exists: {archive_dir}")

    archive_dir.mkdir(parents=True)

    firmware_name = bitstream_path.name
    archived_bitstream = archive_dir / firmware_name
    shutil.copy2(bitstream_path, archived_bitstream)

    artifacts: list[OrderedDict[str, Any]] = [
        file_record(archived_bitstream, archive_file_name=firmware_name)
    ]

    for artifact_arg in args.additional_artifact:
        artifact_path = full_path(artifact_arg)
        if not artifact_path.is_file():
            raise FileNotFoundError(f"additional artifact not found: {artifact_path}")
        destination = archive_dir / artifact_path.name
        shutil.copy2(artifact_path, destination)
        artifacts.append(file_record(destination, archive_file_name=artifact_path.name))

    board = args.board or infer_board_name(bitstream_path)
    metadata = OrderedDict(
        [
            ("archive_schema_version", 1),
            ("archive_name", archive_name),
            ("created_at", now_local_iso()),
            ("experiment", experiment),
            ("board", board),
            ("config_name", args.config_name or ""),
            ("notes", args.notes or ""),
            ("source", file_record(bitstream_path, archive_file_name=firmware_name)),
            ("artifacts", artifacts),
            (
                "parameters",
                OrderedDict(
                    [
                        ("vhdl", read_vhdl_build_parameters()),
                        ("generic_overrides", parse_key_values(args.generic_override)),
                        ("user", parse_key_values(args.build_param)),
                        ("external", import_external_parameters(args.parameters_path)),
                    ]
                ),
            ),
            ("git", git_metadata()),
        ]
    )

    parameters_json = archive_dir / "parameters.json"
    parameters_json.write_text(json.dumps(metadata, indent=2) + "\n", encoding="ascii")

    print("Archived firmware build:")
    print(f"  {archive_dir}")
    print(f"  {firmware_name}")
    print("  parameters.json")
    return 0


def check_builds(args: argparse.Namespace) -> int:
    archive_root = full_path(args.archive_root)
    archived_hashes = archived_firmware_hashes(archive_root)
    candidates = firmware_candidates(archive_root)
    archived_count = 0
    new_builds: list[Path] = []

    for candidate in candidates:
        candidate_hash = sha256_file(candidate)
        if candidate_hash.lower() in archived_hashes:
            archived_count += 1
        else:
            new_builds.append(candidate)

    print(f"Firmware candidates scanned: {len(candidates)}")
    print(f"Already archived by hash:   {archived_count}")
    print(f"Unarchived builds:          {len(new_builds)}")

    if new_builds:
        print()
        for candidate in new_builds:
            stat = candidate.stat()
            print(
                "NEW  "
                f"{repo_relative(candidate)}  "
                f"{stat.st_size} bytes  "
                f"{datetime.fromtimestamp(stat.st_mtime).strftime('%Y-%m-%d %H:%M:%S')}"
            )
        print()
        print("Archive one with:")
        print(
            "  python tools/manage_firmware_builds.py archive "
            "--bitstream-path <path> --experiment exp01 --board <board>"
        )

    return 2 if args.fail_on_new and new_builds else 0


def list_archives(args: argparse.Namespace) -> int:
    archive_root = full_path(args.archive_root)
    if not archive_root.is_dir():
        print(f"No archive directory found: {archive_root}")
        return 0

    parameter_files = sorted(archive_root.rglob("parameters.json"))
    if not parameter_files:
        print(f"No archived builds found in: {archive_root}")
        return 0

    for parameters_json in parameter_files:
        try:
            metadata = json.loads(parameters_json.read_text(encoding="utf-8"))
        except json.JSONDecodeError as exc:
            print(f"warning: could not read archive metadata {parameters_json}: {exc}", file=sys.stderr)
            continue

        artifact_names = [
            artifact["archive_file"]
            for artifact in metadata.get("artifacts", [])
            if artifact.get("archive_file")
        ]
        print(
            f"{metadata.get('archive_name', parameters_json.parent.name)}  "
            f"board={metadata.get('board', '')}  "
            f"config={metadata.get('config_name', '')}  "
            f"artifacts={','.join(artifact_names)}"
        )
    return 0


def add_archive_root_argument(parser: argparse.ArgumentParser) -> None:
    parser.add_argument(
        "--archive-root",
        default=str(REPO_ROOT / "build_archive"),
        help="archive directory root; default: build_archive",
    )


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Archive firmware outputs and check for unarchived generated builds."
    )
    subparsers = parser.add_subparsers(dest="command")

    archive_parser = subparsers.add_parser("archive", help="archive one firmware build")
    add_archive_root_argument(archive_parser)
    archive_parser.add_argument("--bitstream-path", required=True, help="firmware file to archive")
    archive_parser.add_argument("--experiment", help="experiment id, for example exp01")
    archive_parser.add_argument("--name", help="explicit archive folder name")
    archive_parser.add_argument("--board", help="target board name")
    archive_parser.add_argument("--config-name", help="optional Vivado/build configuration name")
    archive_parser.add_argument("--parameters-path", help="optional JSON/text parameter file to embed")
    archive_parser.add_argument(
        "--build-param",
        action="append",
        default=[],
        help="experiment parameter as key=value; may be repeated or comma-separated",
    )
    archive_parser.add_argument(
        "--generic-override",
        action="append",
        default=[],
        help="Vivado generic override as key=value; may be repeated or comma-separated",
    )
    archive_parser.add_argument(
        "--additional-artifact",
        action="append",
        default=[],
        help="extra artifact to copy into the archive entry",
    )
    archive_parser.add_argument("--notes", help="free-form build notes")
    archive_parser.set_defaults(func=archive_build)

    check_parser = subparsers.add_parser("check", help="find generated firmware not archived by hash")
    add_archive_root_argument(check_parser)
    check_parser.add_argument(
        "--fail-on-new",
        action="store_true",
        help="exit with code 2 when unarchived builds are found",
    )
    check_parser.set_defaults(func=check_builds)

    list_parser = subparsers.add_parser("list", help="list archived firmware builds")
    add_archive_root_argument(list_parser)
    list_parser.set_defaults(func=list_archives)

    return parser


def main(argv: list[str] | None = None) -> int:
    if argv is None:
        argv = sys.argv[1:]
    if not argv:
        argv = ["check"]

    parser = build_parser()
    args = parser.parse_args(argv)
    if not hasattr(args, "func"):
        parser.print_help()
        return 2

    try:
        return args.func(args)
    except Exception as exc:  # noqa: BLE001 - CLI should show concise failures
        print(f"error: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
