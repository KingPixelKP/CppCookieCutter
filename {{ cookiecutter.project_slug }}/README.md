# {{ cookiecutter.project_name }}

A modern C++23 project template built with CMake.

## Features

* `CMakePresets.json` with presets for:
  * `Debug`
  * `RelWithDebInfo`
  * Address/Undefined Sanitizers (`ASan`/`UBSan`)
  * `clang-tidy`
* Reusable `libs/` layout for project libraries
* Optional `examples/` and `benchmarks/` modules
* CPM-based dependency management with packages organized under `packages/`
* GoogleTest integration for unit testing
* Optional `clang-tidy` and `cppcheck` support
* `format` build target when `clang-format` is available
* A Docker/Podman-based dependency validation helper for clean-room builds
* GitHub Actions and GitLab CI templates
* Cookiecutter templates with a `create.py` helper for generating additional libraries, executables, benchmarks, and other project components

## Building

Configure the project:

```bash
cmake --preset debug
```

Build:

```bash
cmake --build --preset debug
```

Run the test suite:

```bash
ctest --preset debug
```

## Dependency Validation

To verify that your dependency declarations are enough for a fresh Linux
environment, run the project inside the bundled container check:

```bash
scripts/check-dependencies.sh
```

This builds a local image from `docker/dependency-check.Dockerfile`, copies the
project into a clean Ubuntu-based container, and runs:

```bash
cmake --preset debug
cmake --build --preset debug
ctest --preset debug
```

Useful variations:

```bash
scripts/check-dependencies.sh --preset release
scripts/check-dependencies.sh --skip-tests
scripts/check-dependencies.sh --container-tool podman
```

This is especially helpful after adding or updating files under `packages/`, or when you want to confirm the project does not rely on undeclared host packages. It complements CI, but only validates the Linux container toolchain defined in
`docker/dependency-check.Dockerfile`.

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

If you change the project name in the `project(...)` declaration, update any project-specific cache variables in `CMakePresets.json` (for example, `CPPTEMPLATE_SANITIZERS` and `CPPTEMPLATE_ENABLE_CLANG_TIDY`).

A quick way to do this is:

```bash
sed -i 's/cpptemplate/myproject/g; s/CPPTEMPLATE/MYPROJECT/g' CMakeLists.txt CMakePresets.json
```

> [!NOTE]
> Replace `cpptemplate` and `CPPTEMPLATE` with your project's lowercase and uppercase names, respectively.

## Authors

__AUTHORS__

## Acknowledgements

This project was generated from the **CppCookieCutter**.

The template repository contains updates, additional generators, and documentation:

* https://github.com/KingPixelKP/CppCookieCutter.git
