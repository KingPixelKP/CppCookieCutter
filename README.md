# CppCookieCutter

This repository contains a Cookiecutter template for modern C++ projects using CMake.

The generated project will be created in the `{{ cookiecutter.project_slug }}/` directory.

## Generating a Project

```bash
cookiecutter .
```

or

```bash
cookiecutter /path/to/this/template
```

or 

```bash
uvx cookiecutter gh:KingPixelKP/CppTemplate
```

## Generated Project

The generated project includes:

* `CMakePresets.json` with presets for `Debug`, `RelWithDebInfo`, Address/Undefined Sanitizers, and `clang-tidy`
* A reusable `libs/` layout for project libraries
* Optional `examples/` and `benchmarks/` modules
* CPM-managed dependencies organized under `packages/`
* GoogleTest integration for unit tests
* Optional `clang-tidy` and `cppcheck` support
* A `format` target when `clang-format` is available
* A Docker/Podman-based dependency validation helper for clean-room builds
* GitHub Actions and GitLab CI templates
* Additional Cookiecutter templates for generating libraries, executables, benchmarks, and other project components

After generating the project, refer to:

```text
{{ cookiecutter.project_slug }}/README.md
```
