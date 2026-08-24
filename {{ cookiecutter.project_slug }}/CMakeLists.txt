cmake_minimum_required(VERSION 3.25)
project({{ cookiecutter.project_slug }} VERSION {{ cookiecutter.project_version }} LANGUAGES CXX)

string(TOUPPER ${PROJECT_NAME} PROJECT_NAME_UPPER)
set(${PROJECT_NAME_UPPER}_ROOT_DIR ${CMAKE_CURRENT_SOURCE_DIR})

option(${PROJECT_NAME_UPPER}_BUILD_TESTS "Build tests" ON)
option(${PROJECT_NAME_UPPER}_BUILD_EXAMPLES "Build example programs" {% if cookiecutter.project_type == "app" %}OFF{% else %}ON{% endif %})
option(${PROJECT_NAME_UPPER}_BUILD_BENCHMARKS "Build benchmarks" OFF)
option(${PROJECT_NAME_UPPER}_ENABLE_CLANG_TIDY "Run clang-tidy during builds" OFF)
option(${PROJECT_NAME_UPPER}_ENABLE_CPPCHECK "Run cppcheck during builds" OFF)
option(${PROJECT_NAME_UPPER}_ENABLE_COVERAGE "Enable coverage instrumentation" OFF)
option(${PROJECT_NAME_UPPER}_BUILD_DOCS "Build documentation" {% if cookiecutter.include_docs == "y" %}ON{% else %}OFF{% endif %})
option(${PROJECT_NAME_UPPER}_INSTALL "Enable install and package export rules" {% if cookiecutter.include_install_rules == "y" %}ON{% else %}OFF{% endif %})
option(${PROJECT_NAME_UPPER}_USE_PACKAGE_LOCK "Use the CPM package lock at packages/package-lock.cmake" OFF)

if(${PROJECT_NAME_UPPER}_INSTALL)
  include(GNUInstallDirs)
  include(CMakePackageConfigHelpers)
endif()

if(${PROJECT_NAME_UPPER}_BUILD_TESTS)
  enable_testing()
  include(GoogleTest)
endif()

set(CMAKE_CXX_STANDARD {{ cookiecutter.cpp_standard }})
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if(CMAKE_EXPORT_COMPILE_COMMANDS)
  file(CREATE_LINK
    "${CMAKE_BINARY_DIR}/compile_commands.json"
    "${CMAKE_SOURCE_DIR}/compile_commands.json"
    SYMBOLIC
  )
endif()

# includes
set(${PROJECT_NAME_UPPER}_COMPILE_DEFINITIONS -Wall -Wextra -Wpedantic -Werror)
set(${PROJECT_NAME_UPPER}_LINKER_DEFINITIONS "")
set(${PROJECT_NAME_UPPER}_SANITIZERS
  ""
  CACHE STRING
  "Comma-separated list of sanitizers (e.g. address,undefined,thread)"
)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/packages)

find_program(CCACHE_PROGRAM ccache)

if(CCACHE_PROGRAM)
  set(CMAKE_C_COMPILER_LAUNCHER ${CCACHE_PROGRAM})
  set(CMAKE_CXX_COMPILER_LAUNCHER ${CCACHE_PROGRAM})
else()
  message(WARNING "ccache not found; compiler launcher will not be configured")
endif()

# Tools
include(tools)
include(package)
include(workspace)
configure_project_tooling()

# CPM package manager
include(CPM)

set(${PROJECT_NAME_UPPER}_PACKAGE_LOCK_FILE
  "${CMAKE_CURRENT_SOURCE_DIR}/packages/package-lock.cmake"
)

if(${PROJECT_NAME_UPPER}_USE_PACKAGE_LOCK)
  CPMUsePackageLock("${${PROJECT_NAME_UPPER}_PACKAGE_LOCK_FILE}")
endif()

set(_package_lock_build_dir "${CMAKE_BINARY_DIR}/package-lock")
set(_package_lock_configure_args
  -S "${CMAKE_CURRENT_SOURCE_DIR}"
  -B "${_package_lock_build_dir}"
  -D${PROJECT_NAME_UPPER}_USE_PACKAGE_LOCK=ON
  -DCPM_INCLUDE_ALL_IN_PACKAGE_LOCK=ON
  -D${PROJECT_NAME_UPPER}_BUILD_TESTS=${${PROJECT_NAME_UPPER}_BUILD_TESTS}
  -D${PROJECT_NAME_UPPER}_BUILD_EXAMPLES=${${PROJECT_NAME_UPPER}_BUILD_EXAMPLES}
  -D${PROJECT_NAME_UPPER}_BUILD_BENCHMARKS=${${PROJECT_NAME_UPPER}_BUILD_BENCHMARKS}
  -D${PROJECT_NAME_UPPER}_BUILD_DOCS=OFF
  -D${PROJECT_NAME_UPPER}_ENABLE_CLANG_TIDY=OFF
  -D${PROJECT_NAME_UPPER}_ENABLE_CPPCHECK=OFF
  -D${PROJECT_NAME_UPPER}_ENABLE_COVERAGE=OFF
  -D${PROJECT_NAME_UPPER}_INSTALL=${${PROJECT_NAME_UPPER}_INSTALL}
)

if(CMAKE_GENERATOR)
  list(APPEND _package_lock_configure_args -G "${CMAKE_GENERATOR}")
endif()

if(CMAKE_GENERATOR_PLATFORM)
  list(APPEND _package_lock_configure_args -A "${CMAKE_GENERATOR_PLATFORM}")
endif()

if(CMAKE_GENERATOR_TOOLSET)
  list(APPEND _package_lock_configure_args -T "${CMAKE_GENERATOR_TOOLSET}")
endif()

if(CMAKE_C_COMPILER)
  list(APPEND _package_lock_configure_args "-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}")
endif()

if(CMAKE_CXX_COMPILER)
  list(APPEND _package_lock_configure_args "-DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}")
endif()

if(CMAKE_TOOLCHAIN_FILE)
  list(APPEND _package_lock_configure_args "-DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}")
endif()

add_custom_target(package-lock
  COMMAND ${CMAKE_COMMAND} ${_package_lock_configure_args}
  COMMAND ${CMAKE_COMMAND} --build "${_package_lock_build_dir}" --target cpm-update-package-lock
  COMMENT "Generating CPM package lock at ${${PROJECT_NAME_UPPER}_PACKAGE_LOCK_FILE}"
  USES_TERMINAL
  VERBATIM
)

# Packages
include(fmt)

if(${PROJECT_NAME_UPPER}_BUILD_TESTS)
  include(gtest)
endif()

if(${PROJECT_NAME_UPPER}_BUILD_BENCHMARKS)
  include(benchmark)
endif()

if(${PROJECT_NAME_UPPER}_BUILD_DOCS AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/docs/CMakeLists.txt")
  add_subdirectory(docs)
endif()

# Find workspace members
set(EXCLUDED_WORKSPACE_MEMBERS
  src
  include
  cmake
  packages
  test
  docs
)

workspace(
  DISCOVER
  libs
  EXCLUDE
  ${EXCLUDED_WORKSPACE_MEMBERS}
)

{% if cookiecutter.project_type in ["app", "hybrid"] %}

# Main Executable
package(
  NAME ${PROJECT_NAME}
  BIN
  BIN_DEPS
  {% if cookiecutter.project_type == "hybrid" %}
  math
  {% endif %}
  fmt::fmt
)
{% endif %}

if(${PROJECT_NAME_UPPER}_INSTALL)
  set(_package_config_install_dir "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}")

  configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/project-config.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
    INSTALL_DESTINATION "${_package_config_install_dir}"
  )

  write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
  )

  install(
    EXPORT ${PROJECT_NAME}Targets
    FILE "${PROJECT_NAME}Targets.cmake"
    NAMESPACE ${PROJECT_NAME}::
    DESTINATION "${_package_config_install_dir}"
  )

  install(
    FILES
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
    DESTINATION "${_package_config_install_dir}"
  )
endif()

add_coverage_report_target()
add_format_target()
