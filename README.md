# CPPTemplate

This serves as my cmake template for c++ projects.

## What It Includes

- [`CMake presets`](./CMakePresets.json) for `Debug`, `RelWithDebInfo`, `ASan/UBSan`, and `clang-tidy`
- Reusable `libs/` layout for project libraries
- Optional `examples/` and `benchmarks/` directories
- CPM-managed dependencies split into small files under `packages/`
- Test helpers for GoogleTest-based unit tests
- Optional `clang-tidy` and `cppcheck` integration
- A `format` target when `clang-format` is available
- [`GitHub Actions`](./.github/workflows/ci.yml) and [`GitLab CI`](./.gitlab-ci.yml) templates for configure, build, and test
- Cookiecutter templates that may be instanced with [`create.py`](./create.py)

## Common Commands

```bash
cmake --preset debug # configure
cmake --build --preset debug # build
ctest --preset debug # test!
```

```bash
cmake --preset asan
cmake --build --preset asan
ctest --preset asan
```

```bash
cmake --preset clang-tidy
cmake --build --preset clang-tidy
```

If you rename the project in `project(...)`, also update any project-prefixed cache variables in `CMakePresets.json`, such as `CPPTEMPLATE_SANITIZERS` and `CPPTEMPLATE_ENABLE_CLANG_TIDY`.

For a quick rename, you can use:

```bash
sed -i 's/cpptemplate/myproject/g; s/CPPTEMPLATE/MYPROJECT/g' CMakeLists.txt CMakePresets.json
```

**Note:** Obviously you must replace *cpptemplate* and *CPPTEMPLATE* with the name of your project
