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
uvx cookiecutter gh:KingPixelKP/CppCookieCutter
```

## Generated Project

The generated project includes:

* `CMakePresets.json` with presets for `Debug`, `RelWithDebInfo`, Address/Undefined Sanitizers, and `clang-tidy`
* A reusable `libs/` layout for project libraries
* Optional `examples/` and `benchmarks/` modules
* CPM package snippets organized under `packages/`, with only the default sample dependencies loaded up front
* GoogleTest integration for unit tests
* Optional `clang-tidy` and `cppcheck` support
* A `format` target when `clang-format` is available
* A Docker/Podman-based dependency validation helper for clean-room builds
* GitHub Actions and GitLab CI templates
* Additional Cookiecutter templates for generating libraries, executables, benchmarks, and other project components

## Template Inputs

The template also prompts for a few practical project settings:

* `project_description` for the generated README
* `project_version` for the root `project(...)` version
* `cpp_standard` for the generated `CMakeLists.txt`
* `include_ci` to keep or remove the CI/container scaffolding
* `include_docs` to keep or remove the Doxygen scaffolding
* `initialize_git` and `create_initial_commit` to make Git setup opt-in instead of automatic

After generating the project, refer to:

```text
{{ cookiecutter.project_slug }}/README.md
```
