#!/usr/bin/env python3

from pathlib import Path
import argparse
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

    args = parser.parse_args()

    template, output = TEMPLATES[args.kind]

    output.mkdir(exist_ok=True)

    cmd = [
        "cookiecutter",
        str(template),
        "--output-dir",
        str(output),
    ]

    if args.no_input:
        cmd.append("--no-input")

    cmd.extend(args.extra)

    return subprocess.run(cmd).returncode


if __name__ == "__main__":
    sys.exit(main())