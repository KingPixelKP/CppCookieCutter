# {{ cookiecutter.project_name }}

{{ cookiecutter.project_description }}

This project was generated in `{{ cookiecutter.project_type }}` mode.

## Features

* `CMakePresets.json` with presets for:
  * `Debug`
  * `RelWithDebInfo`
  * Address/Undefined Sanitizers (`ASan`/`UBSan`)
  * `clang-tidy`
* Reusable `libs/` layout for project libraries
* Per-package `example/` and `benchmark/` discovery for optional example and benchmark binaries
* Reusable `package()` and `workspace()` CMake helpers for component and workspace discovery
* Nix flake that pins the toolchain, every library and the CMake helpers in `flake.lock`
* Sandboxed `nix build` (shared) and `nix build .#static` (fully static, musl) packages
* GoogleTest integration for unit testing
* Optional `clang-tidy` and `cppcheck` support
* `format` build target when `clang-format` is available
* Extra `tsan` and `coverage` CMake presets for concurrency debugging and coverage runs
{% if cookiecutter.include_docs == "y" %}
* Optional Doxygen documentation support
{% endif %}
{% if cookiecutter.include_ci == "y" %}
* Nix-based GitHub Actions and GitLab CI templates
{% endif %}

## Requirements

Only the [Nix](https://nixos.org/download/) package manager, on any Linux distribution, macOS, or
WSL2 (NixOS is not required). Flakes must be enabled:

```text
# ~/.config/nix/nix.conf
experimental-features = nix-command flakes
```

The [Determinate Nix installer](https://determinate.systems/nix-installer/) enables flakes by default.

Everything else (compiler, CMake, Ninja, libraries and the
[Cookie-Cmake](https://github.com/KingPixelKP/Cookie-Cmake) helpers) comes from the flake and is
pinned by hash in `flake.lock`.

> [!IMPORTANT]
> Flakes only see files tracked by git. `git add` new files before running `nix build` or
> `nix develop`, or Nix will not find them.

## Nix Builds

```bash
nix build              # shared build, runs ctest in the sandbox; output in ./result
nix build .#static     # fully static (musl) build for release
nix flake check        # builds and tests both packages
nix flake update       # move every pinned input (nixpkgs, Cookie-Cmake) forward
```

## Development

Enter the dev shell, which provides the build dependencies plus `clang-tools`, `gdb`, `gcovr` and
Google Benchmark, and exports `COOKIE_CMAKE_DIR` for CMake:

```bash
nix develop
cmake --preset debug
```

Configuring outside `nix develop` fails because CMake cannot find Cookie-Cmake or the libraries.
Launch your editor from the dev shell so CMake Tools and clangd see the same environment.

### direnv

With [direnv](https://direnv.net/) (ideally with [nix-direnv](https://github.com/nix-community/nix-direnv)
for caching), the included `.envrc` loads the dev shell whenever you `cd` into the project:

```bash
direnv allow
```

On first entry it also runs `cmake --preset debug`, so `compile_commands.json` is linked into the
project root for clangd. Editors with a direnv extension pick up the same environment.

The default project uses [`fmt`](https://github.com/fmtlib/fmt), plus GoogleTest and Google Benchmark
when tests and benchmarks are enabled. Examples and benchmarks are discovered from each package's
`example/` and `benchmark/` directories.

## Adding Libraries

Libraries come from [nixpkgs](https://search.nixos.org/packages). To add one:

1. Add the nixpkgs attribute to the function arguments and `buildInputs` in [`package.nix`](./package.nix).
2. Add the matching `find_package(<Name> CONFIG REQUIRED)` to [`CMakeLists.txt`](./CMakeLists.txt).
3. Link the target, for example with `BIN_DEPS` / `LIB_DEPS` in `package(...)`.

Common libraries:

| nixpkgs attribute | `find_package` name | Target |
| --- | --- | --- |
| `fmt` | `fmt` | `fmt::fmt` |
| `gtest` | `GTest` | `GTest::gtest_main` |
| `gbenchmark` | `benchmark` | `benchmark::benchmark` |
| `spdlog` | `spdlog` | `spdlog::spdlog` |
| `abseil-cpp` | `absl` | `absl::<component>` |
| `cli11` | `CLI11` | `CLI11::CLI11` |
| `entt` | `EnTT` | `EnTT::EnTT` |
| `nlohmann_json` | `nlohmann_json` | `nlohmann_json::nlohmann_json` |
| `pugixml` | `pugixml` | `pugixml::pugixml` |
| `raylib` | `raylib` | `raylib` |
| `yaml-cpp` | `yaml-cpp` | `yaml-cpp::yaml-cpp` |

Library versions follow the nixpkgs revision in `flake.lock`. To pin a specific version, override
the package in [`flake.nix`](./flake.nix) with `overrideAttrs` and a `fetchFromGitHub` source.

## Project Layout

To add a new library package, create a new folder under [`libs/`](./libs/) with a minimal
[`CMakeLists.txt`](./libs/math/CMakeLists.txt) that calls `package(...)`, then add `src/`,
`include/`, `test/`, `example/`, or `benchmark/` directories as needed.

If a package needs runtime assets, add a sibling `data/` directory under `bin/`, `test/`,
`example/`, or `benchmark/`. The `package()` helper copies those directories into the matching
build output folder so the executables can load assets with stable relative paths.

Build:

```bash
cmake --build --preset debug
```

Run the test suite:

```bash
ctest --preset debug
```

Additional presets:

```bash
cmake --preset tsan
cmake --build --preset tsan
ctest --preset tsan

cmake --preset coverage
cmake --build --preset coverage
ctest --preset coverage

cmake --build --preset coverage --target coverage-report
```

When `gcovr` is available, the `coverage-report` target writes HTML and XML
reports under `.build/coverage/coverage/`.

{% if cookiecutter.include_docs == "y" %}
## Documentation

Build the Doxygen docs with:

```bash
cmake --build --preset debug --target docs
```
{% endif %}

{% if cookiecutter.include_install_rules == "y" %}
## Install And Package Export

Install the project to a local prefix with:

```bash
cmake --preset release
cmake --build --preset release
cmake --install .build/release --prefix ./install
```

{% if cookiecutter.project_type != "app" %}
Consumers can then use:

```cmake
find_package({{ cookiecutter.project_slug }} CONFIG REQUIRED)
target_link_libraries(my_target PRIVATE {{ cookiecutter.project_slug }}::math)
```
{% endif %}
{% endif %}


## Sanitizers

Configure and build with AddressSanitizer and UndefinedBehaviorSanitizer:

```bash
cmake --preset asan
cmake --build --preset asan
ctest --preset asan
```

## Static Analysis

Configure and build with `clang-tidy` enabled:

```bash
cmake --preset clang-tidy
cmake --build --preset clang-tidy
```

## Renaming the Project

If you change the project name in the `project(...)` declaration, update any project-specific cache variables in [`CMakePresets.json`](./CMakePresets.json) and [`package.nix`](./package.nix) (for example, `CPPTEMPLATE_SANITIZERS` and `CPPTEMPLATE_ENABLE_CLANG_TIDY`).

A quick way to do this is:

```bash
sed -i 's/cpptemplate/myproject/g; s/CPPTEMPLATE/MYPROJECT/g' CMakeLists.txt CMakePresets.json package.nix
```

> [!NOTE]
> Replace `cpptemplate` and `CPPTEMPLATE` with your project's lowercase and uppercase names, respectively.

## Authors

__AUTHORS__

{% if cookiecutter.license != "None" %}
## License

See [`LICENSE`](./LICENSE).
{% endif %}

## Acknowledgements

This project was generated from the **CppCookieCutter**.

The template repository contains updates, additional generators, and documentation:

* <https://github.com/KingPixelKP/CppCookieCutter.git>

The CMake function directory used to provide versioned CMake helpers is:

* <https://github.com/KingPixelKP/Cookie-Cmake.git>