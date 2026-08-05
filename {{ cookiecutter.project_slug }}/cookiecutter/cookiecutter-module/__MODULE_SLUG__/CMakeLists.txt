message(STATUS "Configuring \"{% raw %}{{ cookiecutter.module_slug }}{% endraw %}\" for \"{{ cookiecutter.project_name }}
\"")

file(GLOB children RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "*")

foreach(child ${children})
    if(IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${child}"
       AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${child}/CMakeLists.txt")
        add_subdirectory(${child})
    endif()
endforeach()