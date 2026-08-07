#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/check-dependencies.sh [options]

Build the project in a fresh container to verify that declared dependencies
and required system packages are sufficient on a clean Ubuntu toolchain.

Options:
  --preset <name>           CMake preset to use (default: debug)
  --image <tag>             Container image tag to build/use
  --container-tool <name>   Container runtime to use (docker or podman)
  --skip-tests              Configure and build, but do not run ctest
  -h, --help                Show this help text
EOF
}

container_tool=""
preset="debug"
image_tag="{{ cookiecutter.project_slug }}-dependency-check"
run_tests=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --preset)
      preset="${2:?missing value for --preset}"
      shift 2
      ;;
    --image)
      image_tag="${2:?missing value for --image}"
      shift 2
      ;;
    --container-tool)
      container_tool="${2:?missing value for --container-tool}"
      shift 2
      ;;
    --skip-tests)
      run_tests=0
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

if [[ -z "${container_tool}" ]]; then
  if command -v docker >/dev/null 2>&1; then
    container_tool="docker"
  elif command -v podman >/dev/null 2>&1; then
    container_tool="podman"
  else
    echo "Neither docker nor podman is installed." >&2
    exit 1
  fi
fi

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dockerfile="${project_dir}/docker/dependency-check.Dockerfile"

if [[ ! -f "${dockerfile}" ]]; then
  echo "Missing Dockerfile: ${dockerfile}" >&2
  exit 1
fi

echo "Building dependency check image '${image_tag}' with ${container_tool}..."
"${container_tool}" build \
  --file "${dockerfile}" \
  --tag "${image_tag}" \
  "${project_dir}"

echo "Running clean-room build with preset '${preset}'..."
"${container_tool}" run --rm \
  --volume "${project_dir}:/src:ro" \
  --workdir /tmp \
  --env PRESET="${preset}" \
  --env RUN_TESTS="${run_tests}" \
  "${image_tag}" \
  bash -lc "
    rm -rf /tmp/project
    cp -a /src/. /tmp/project
    cd /tmp/project
    rm -rf .build build
    cmake --preset \"\${PRESET}\"
    cmake --build --preset \"\${PRESET}\"
    if [[ \"\${RUN_TESTS}\" == \"1\" ]]; then
      ctest --preset \"\${PRESET}\"
    fi
  "
