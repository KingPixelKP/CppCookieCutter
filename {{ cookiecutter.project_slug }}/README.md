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
* Optional [`examples/`](./examples/) and [`benchmarks/`](./benchmarks/) modules
* CPM-based dependency management with package snippets organized under [`packages/`](./packages/)
* Optional CPM package locking via [`packages/package-lock.cmake`](./packages/package-lock.cmake)
* GoogleTest integration for unit testing
* Optional `clang-tidy` and `cppcheck` support
* `format` build target when `clang-format` is available
* Extra `tsan` and `coverage` CMake presets for concurrency debugging and coverage runs
{% if cookiecutter.include_docs == "y" %}
* Optional Doxygen documentation support
{% endif %}
{% if cookiecutter.include_ci == "y" %}
* A Docker/Podman-based dependency validation helper for clean-room builds
* GitHub Actions and GitLab CI templates
{% endif %}
* Cookiecutter templates with a [`create.py`](./create.py) helper for generating additional libraries, executables, benchmarks, and other project components

## Building

Configure the project:

```bash
scripts/install-deps.sh
cmake --preset debug
```

[`scripts/install-deps.sh`](./scripts/install-deps.sh) currently automates the Linux package setup for
Debian/Ubuntu and Arch-based systems.

The default project only pulls in [`fmt`](./packages/fmt.cmake) plus testing and benchmark dependencies
when those targets are enabled. Additional CPM package snippets live under
[`packages/`](./packages/) and can be included from [`CMakeLists.txt`](./CMakeLists.txt) as your project grows.

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
```

## CPM Package Lock

Generate or refresh the checked-in CPM lockfile:

```bash
cmake --build --preset debug --target package-lock
```

This writes [`packages/package-lock.cmake`](./packages/package-lock.cmake). To make the root build consume that
lockfile during configure, enable:

```bash
cmake --preset debug -D{{ cookiecutter.upper_project_slug }}_USE_PACKAGE_LOCK=ON
```

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

{% if cookiecutter.include_ci == "y" %}
## Dependency Validation

To verify that your dependency declarations are enough for a fresh Linux
environment, run the project inside the bundled CI container:

```bash
scripts/check-dependencies.sh
```

This builds a local image from [`docker/ci.Dockerfile`](./docker/ci.Dockerfile), copies the project into
a clean Ubuntu-based container, and runs:

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

This is especially helpful after adding or updating files under [`packages/`](./packages/), or
when you want to confirm the project does not rely on undeclared host packages.
It complements CI, but only validates the Linux container toolchain defined in
[`docker/ci.Dockerfile`](./docker/ci.Dockerfile).

The system-package source of truth is [`scripts/install-deps.sh`](./scripts/install-deps.sh). The CI image
build runs that script during `docker build`, so if you add a new
`find_package(...)` dependency that requires a preinstalled system package, you
should update [`scripts/install-deps.sh`](./scripts/install-deps.sh). That change will automatically trigger
the CI image refresh in both GitHub Actions and GitLab.

The generated GitHub Actions workflows also reuse this same image. A dedicated
`Publish CI Image` workflow refreshes the GHCR image when the Dockerfile or CI
image wiring changes, and the main Linux CI jobs pull that image instead of
rebuilding it on every run.

The generated GitLab pipeline follows the same pattern with the GitLab
Container Registry. Its `build:ci-image` job only rebuilds the shared CI image
when [`docker/ci.Dockerfile`](./docker/ci.Dockerfile) or related CI-image files change, and the regular
pipeline stages reuse that published image.
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

If you change the project name in the `project(...)` declaration, update any project-specific cache variables in [`CMakePresets.json`](./CMakePresets.json) (for example, `CPPTEMPLATE_SANITIZERS` and `CPPTEMPLATE_ENABLE_CLANG_TIDY`).

A quick way to do this is:

```bash
sed -i 's/cpptemplate/myproject/g; s/CPPTEMPLATE/MYPROJECT/g' CMakeLists.txt CMakePresets.json
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

* https://github.com/KingPixelKP/CppCookieCutter.git
