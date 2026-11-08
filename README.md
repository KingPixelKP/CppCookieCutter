# CppCookieCutter

This repository contains a Cookiecutter template for modern C++ projects using CMake.

The generated project will be created in the `{{ cookiecutter.project_slug }}/` directory.

## Requirements

Generated projects build only through [Nix](https://nixos.org/download/) with flakes enabled
(any Linux distribution, macOS, or WSL2; NixOS is not required). When `nix` is on `PATH` and
`initialize_git` is enabled, generation also runs `nix flake lock` so the project starts pinned.

## Generating a Project

With only Nix installed:

```bash
nix run github:KingPixelKP/CppCookieCutter
```

Arguments after `--` go to cookiecutter, for example
`nix run github:KingPixelKP/CppCookieCutter -- --no-input project_name=demo`.

With cookiecutter installed:

```bash
cookiecutter .
```

or

```bash
cookiecutter /path/to/this/template
```

or

```bash
uvx cookiecutter gh:KingPixelKP/CppCookieCutter
```

## Generated Project

The generated project includes:

* `CMakePresets.json` with presets for `Debug`, `RelWithDebInfo`, Address/Undefined Sanitizers, and `clang-tidy`
* Additional `tsan` and `coverage` presets
* A reusable `libs/` layout for project libraries
* Per-package `example/` and `benchmark/` discovery for optional example and benchmark binaries
* Inferred per-target `data/` directories copied into matching build output folders for runtime assets
* Reusable `package()` and `workspace()` CMake helpers for component and workspace discovery
* A Nix flake (`flake.nix` + `package.nix`) that pins the toolchain, libraries and CMake helpers in `flake.lock`
* Sandboxed `nix build` and fully static `nix build .#static` packages
* GoogleTest integration for unit tests
* Optional `clang-tidy` and `cppcheck` support
* Optional install/package export support for generated libraries and executables
* A `format` target when `clang-format` is available
* A `coverage-report` target for coverage-enabled builds when `gcovr` is available
* Nix-based GitHub Actions and GitLab CI templates
* Additional helpers for generating executables, examples, benchmarks, and other project components

## Template Inputs

The template also prompts for a few practical project settings:

* `project_description` for the generated README
* `project_version` for the root `project(...)` version
* `project_type` to start in `hybrid`, `library`, or `app` mode
* `cpp_standard` for the generated `CMakeLists.txt`
* `license`, including `None`, for the generated `LICENSE`
* `include_ci` to keep or remove the CI scaffolding
* `include_docs` to keep or remove the Doxygen scaffolding
* `include_install_rules` to enable install/exported package rules
* `initialize_git` and `create_initial_commit` to make Git setup opt-in instead of automatic

After generating the project, refer to:

```text
{{ cookiecutter.project_slug }}/README.md
```
