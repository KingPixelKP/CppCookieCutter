#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/install-deps.sh [options]

Install system packages required to configure and build the project.

Options:
  --ci         Non-interactive mode for CI and container builds
  -h, --help   Show this help text
EOF
}

ci_mode=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ci)
      ci_mode=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

apt_packages=(
  bash
  build-essential
  ca-certificates
  clang
  cmake
  git
  lld
  ninja-build
  pkg-config
)

pacman_packages=(
  base-devel
  bash
  ca-certificates
  clang
  cmake
  git
  lld
  ninja
  pkgconf
)

sudo_cmd=()
if [[ "$(id -u)" -ne 0 ]]; then
  if ! command -v sudo >/dev/null 2>&1; then
    echo "sudo is required when running without root privileges." >&2
    exit 1
  fi
  sudo_cmd=(sudo)
fi

if command -v apt-get >/dev/null 2>&1; then
  export DEBIAN_FRONTEND=noninteractive
  "${sudo_cmd[@]}" apt-get update
  "${sudo_cmd[@]}" apt-get install -y --no-install-recommends "${apt_packages[@]}"
  "${sudo_cmd[@]}" rm -rf /var/lib/apt/lists/*
  exit 0
fi

if command -v pacman >/dev/null 2>&1; then
  "${sudo_cmd[@]}" pacman -Sy --needed --noconfirm "${pacman_packages[@]}"
  exit 0
fi

if command -v brew >/dev/null 2>&1; then
  cat <<'EOF' >&2
Homebrew was detected, but this script currently only automates the Debian/Ubuntu
and Arch Linux package sets. Install the equivalent development packages for
your platform, then rerun the build. If you opt into packages such as `raylib`,
install their platform-specific system dependencies as well.
EOF
  exit 1
fi

if [[ "${ci_mode}" == "1" ]]; then
  echo "No supported package manager found for CI dependency installation." >&2
else
  echo "No supported package manager found. This script currently automates Debian/Ubuntu and Arch installs for the default dependency set." >&2
fi
exit 1
