#[[
Configures optional project-wide tooling integrations.

Enables the `lld` linker when it is available, and wires `clang-tidy` and
`cppcheck` into CMake when the corresponding project options are enabled.
]]#
function(configure_project_tooling)
    find_program(LLD_PROGRAM ld.lld lld-link)
    if(LLD_PROGRAM AND NOT MSVC)
        set(
            ${PROJECT_NAME_UPPER}_LINKER_DEFINITIONS
            -fuse-ld=lld
            PARENT_SCOPE
        )
    endif()

    if(${PROJECT_NAME_UPPER}_ENABLE_CLANG_TIDY)
        find_program(CLANG_TIDY_PROGRAM clang-tidy)
        if(CLANG_TIDY_PROGRAM)
            set(CMAKE_CXX_CLANG_TIDY "${CLANG_TIDY_PROGRAM}" PARENT_SCOPE)
        else()
            message(WARNING "clang-tidy requested but not found")
        endif()
    endif()

    if(${PROJECT_NAME_UPPER}_ENABLE_CPPCHECK)
        find_program(CPPCHECK_PROGRAM cppcheck)
        if(CPPCHECK_PROGRAM)
            set(
                CMAKE_CXX_CPPCHECK
                "${CPPCHECK_PROGRAM};--enable=warning,style,performance,portability;--inline-suppr;--error-exitcode=2"
                PARENT_SCOPE
            )
        else()
            message(WARNING "cppcheck requested but not found")
        endif()
    endif()
endfunction()

#[[
Applies the project's standard warnings, linker options, and sanitizers.

Arguments:
    TARGET_NAME: Target to configure.
]]#
function(configure_target TARGET_NAME)
    get_target_property(_target_type ${TARGET_NAME} TYPE)

    if(_target_type STREQUAL "INTERFACE_LIBRARY")
        set(_scope INTERFACE)
    else()
        set(_scope PRIVATE)
    endif()

    set(_compile_options ${${PROJECT_NAME_UPPER}_COMPILE_DEFINITIONS})
    if(CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU")
        list(APPEND _compile_options -Wconversion -Wsign-conversion)
    elseif(MSVC)
        set(_compile_options /W4 /permissive- /WX)
    endif()

    if(_compile_options)
        target_compile_options(
            ${TARGET_NAME}
            ${_scope}
            ${_compile_options}
        )
    endif()

    if(${PROJECT_NAME_UPPER}_LINKER_DEFINITIONS)
        target_link_options(
            ${TARGET_NAME}
            ${_scope}
            ${${PROJECT_NAME_UPPER}_LINKER_DEFINITIONS}
        )
    endif()

    if(NOT "${${PROJECT_NAME_UPPER}_SANITIZERS}" STREQUAL "")
        target_compile_options(
            ${TARGET_NAME}
            ${_scope}
            -fsanitize=${${PROJECT_NAME_UPPER}_SANITIZERS}
            -fno-omit-frame-pointer
        )

        target_link_options(
            ${TARGET_NAME}
            ${_scope}
            -fsanitize=${${PROJECT_NAME_UPPER}_SANITIZERS}
        )
    endif()
endfunction()

#[[
Adds a GoogleTest executable and registers its discovered test cases with CTest.

Arguments:
    TARGET_NAME: Name of the test executable to create.

Keyword arguments:
    SOURCES: Source files compiled into the test target.
    LIBRARIES: Additional libraries linked into the test target.
]]#
function(add_project_test TARGET_NAME)
    set(_options)
    set(_one_value_args)
    set(_multi_value_args SOURCES LIBRARIES)
    cmake_parse_arguments(TEST "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

    add_executable(${TARGET_NAME} ${TEST_SOURCES})
    target_link_libraries(${TARGET_NAME} PRIVATE ${TEST_LIBRARIES} GTest::gtest_main)
    configure_target(${TARGET_NAME})
    gtest_discover_tests(${TARGET_NAME})
endfunction()

#[[
Adds a `format` target that runs `clang-format` over project C++ sources.

The target is created only when `clang-format` is available and at least one
matching source file is found.

Keyword arguments:
    DIRECTORIES: Additional root-level source directories to scan.
]]#
function(add_format_target)
    set(_options)
    set(_one_value_args)
    set(_multi_value_args DIRECTORIES)
    cmake_parse_arguments(FORMAT "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

    find_program(CLANG_FORMAT_PROGRAM clang-format)
    if(NOT CLANG_FORMAT_PROGRAM)
        message(WARNING "clang-format not found; skipping format target")
        return()
    endif()

    set(
        _format_directories
        src
        libs
        examples
        benchmarks
    )

    foreach(_format_directory IN LISTS FORMAT_DIRECTORIES)
        if(IS_ABSOLUTE "${_format_directory}" OR "${_format_directory}" MATCHES "[/\\\\]")
            message(
                FATAL_ERROR
                "add_format_target(DIRECTORIES ...) only accepts root-level directory names; got \"${_format_directory}\""
            )
        endif()

        if(NOT IS_DIRECTORY "${CMAKE_SOURCE_DIR}/${_format_directory}")
            message(
                FATAL_ERROR
                "add_format_target(DIRECTORIES ...) expected a directory at \"${CMAKE_SOURCE_DIR}/${_format_directory}\""
            )
        endif()

        list(APPEND _format_directories "${_format_directory}")
    endforeach()

    list(REMOVE_DUPLICATES _format_directories)

    set(_format_globs)
    foreach(_format_directory IN LISTS _format_directories)
        list(APPEND _format_globs
            ${CMAKE_SOURCE_DIR}/${_format_directory}/*.cpp
            ${CMAKE_SOURCE_DIR}/${_format_directory}/*.hpp
        )
    endforeach()

    file(
        GLOB_RECURSE _format_sources
        CONFIGURE_DEPENDS
        ${_format_globs}
    )

    if(_format_sources)
        add_custom_target(
            format
            COMMAND ${CLANG_FORMAT_PROGRAM} -i ${_format_sources}
            COMMENT "Formatting project sources with clang-format"
        )
    endif()

    message(STATUS "Added \"format\" build target")
endfunction()

#[[
Includes the `test` directory when `${PROJECT_NAME_UPPER}_BUILD_TESTS` is enabled.
#]]
macro(include_test)
    if(${PROJECT_NAME_UPPER}_BUILD_TESTS)
        message(STATUS "Configuring tests")
        add_subdirectory(test)
    endif()
endmacro()

#[[
Includes the `benchmark` directory when
`${PROJECT_NAME_UPPER}_BUILD_BENCHMARKS` is enabled.
#]]
macro(include_benchmark)
    if(${PROJECT_NAME_UPPER}_BUILD_BENCHMARKS)
        message(STATUS "Configuring benchmarks")
        add_subdirectory(benchmark)
    endif()
endmacro()
