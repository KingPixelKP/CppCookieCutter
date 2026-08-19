cmake_minimum_required(VERSION 3.25)
project({{ cookiecutter.project_slug }} VERSION 1.0.0 LANGUAGES CXX)

string(TOUPPER ${PROJECT_NAME} PROJECT_NAME_UPPER)
set(${PROJECT_NAME_UPPER}_ROOT_DIR ${CMAKE_CURRENT_SOURCE_DIR})

option(${PROJECT_NAME_UPPER}_BUILD_TESTS "Build tests" ON)
option(${PROJECT_NAME_UPPER}_BUILD_EXAMPLES "Build example programs" ON)
option(${PROJECT_NAME_UPPER}_BUILD_BENCHMARKS "Build benchmarks" OFF)
option(${PROJECT_NAME_UPPER}_ENABLE_CLANG_TIDY "Run clang-tidy during builds" OFF)
option(${PROJECT_NAME_UPPER}_ENABLE_CPPCHECK "Run cppcheck during builds" OFF)
option(${PROJECT_NAME_UPPER}_BUILD_DOCS "Build documentation" OFF)
option(${PROJECT_NAME_UPPER}_USE_PACKAGE_LOCK "Use the CPM package lock at packages/package-lock.cmake" OFF)

if(${PROJECT_NAME_UPPER}_BUILD_TESTS)
  enable_testing()
  include(GoogleTest)
endif()

set(CMAKE_CXX_STANDARD 23)
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
set(${PROJECT_NAME_UPPER}_LINKER_DEFINITIONS -fuse-ld=lld)
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
include(spdlog)
include(abseil)
include(pugixml)
include(yamlcpp)
include(nlohmannjson)
include(raylib)
include(entt)

if(${PROJECT_NAME_UPPER}_BUILD_TESTS)
  include(gtest)
endif()

if(${PROJECT_NAME_UPPER}_BUILD_BENCHMARKS)
  include(benchmark)
endif()

if(${PROJECT_NAME_UPPER}_BUILD_EXAMPLES)
  add_subdirectory(examples)
endif()

if(${PROJECT_NAME_UPPER}_BUILD_BENCHMARKS)
  add_subdirectory(benchmarks)
endif()

if(${PROJECT_NAME_UPPER}_BUILD_DOCS)
    add_subdirectory(docs)
endif()

# Find modules
set(EXCLUDED_MODULES
  src
  include
  cmake
  packages
  test
  benchmarks
  examples
  docs
)

file(GLOB children RELATIVE "${CMAKE_SOURCE_DIR}" "*")

foreach(child IN LISTS children)
  if(NOT IS_DIRECTORY "${CMAKE_SOURCE_DIR}/${child}")
    continue()
  endif()

  if(child IN_LIST EXCLUDED_MODULES)
    continue()
  endif()

  if(child MATCHES "^\\.")
    continue()
  endif()

  if(EXISTS "${CMAKE_SOURCE_DIR}/${child}/CMakeLists.txt")
    add_subdirectory("${child}")
  endif()
endforeach()

# Main Executable
add_executable(${PROJECT_NAME} src/main.cpp)
target_link_libraries(${PROJECT_NAME}
  PRIVATE
  math
  fmt::fmt
)
configure_target(${PROJECT_NAME})
add_format_target()
