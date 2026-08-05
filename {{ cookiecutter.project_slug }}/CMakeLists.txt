cmake_minimum_required(VERSION 3.25)
project({{ cookiecutter.project_slug }} VERSION 1.0.0 LANGUAGES CXX)

string(TOUPPER ${PROJECT_NAME} PROJECT_NAME_UPPER)
option(${PROJECT_NAME_UPPER}_BUILD_TESTS "Build tests" ON)
option(${PROJECT_NAME_UPPER}_BUILD_EXAMPLES "Build example programs" ON)
option(${PROJECT_NAME_UPPER}_BUILD_BENCHMARKS "Build benchmarks" OFF)
option(${PROJECT_NAME_UPPER}_ENABLE_CLANG_TIDY "Run clang-tidy during builds" OFF)
option(${PROJECT_NAME_UPPER}_ENABLE_CPPCHECK "Run cppcheck during builds" OFF)

if(${PROJECT_NAME_UPPER}_BUILD_TESTS)
  enable_testing()
  include(GoogleTest)
endif()

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

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

add_subdirectory(libs)

if(${PROJECT_NAME_UPPER}_BUILD_EXAMPLES)
  add_subdirectory(examples)
endif()

if(${PROJECT_NAME_UPPER}_BUILD_BENCHMARKS)
  add_subdirectory(benchmarks)
endif()

# Main Executable
add_executable(${PROJECT_NAME} src/main.cpp)
target_link_libraries(${PROJECT_NAME}
  PRIVATE
  math
  fmt::fmt
)
configure_target(${PROJECT_NAME})
add_format_target()
