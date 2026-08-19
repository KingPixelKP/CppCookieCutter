#!/usr/bin/env python3

from pathlib import Path
import argparse
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parent

TEMPLATES = {
    "static-lib": (
        ROOT / "cookiecutter" / "cookiecutter-static-lib",
        ROOT / "libs",
    ),
    "shared-lib": (
        ROOT / "cookiecutter" / "cookiecutter-shared-lib",
        ROOT / "libs",
    ),
    "interface": (
        ROOT / "cookiecutter" / "cookiecutter-interface",
        ROOT / "libs",
    ),
    "app": (
        ROOT / "cookiecutter" / "cookiecutter-executable",
        ROOT / "apps",
    ),
    "benchmark": (
        ROOT / "cookiecutter" / "cookiecutter-benchmark",
        ROOT / "benchmarks",
    ),
}


def resolve_cookiecutter_command() -> list[str]:
    if shutil.which("cookiecutter"):
        return ["cookiecutter"]

    if shutil.which("uvx"):
        return ["uvx", "cookiecutter"]

    raise FileNotFoundError(
        "Neither 'cookiecutter' nor 'uvx' is available on PATH."
    )


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Generate a project component."
    )

    parser.add_argument(
        "kind",
        choices=TEMPLATES.keys(),
        help="Component to create.",
    )

    parser.add_argument(
        "--no-input",
        action="store_true",
        help="Run Cookiecutter without prompting.",
    )

    parser.add_argument(
        "extra",
        nargs="*",
        help="Extra cookiecutter key=value arguments.",
    )

    args, unknown = parser.parse_known_args()

    template, output = TEMPLATES[args.kind]

    output.mkdir(exist_ok=True)

    try:
        cmd = [
        *resolve_cookiecutter_command(),
        str(template),
        "--output-dir",
        str(output),
        ]
    except FileNotFoundError as error:
        print(error, file=sys.stderr)
        return 1

    if args.no_input:
        cmd.append("--no-input")

    cmd.extend(args.extra)
    cmd.extend(unknown)

    return subprocess.run(cmd).returncode


if __name__ == "__main__":
    sys.exit(main())