message(STATUS "Configuring Interface: \"{% raw %}{{ cookiecutter.lib_name }}{% endraw %}\" for \"{{ cookiecutter.project_name }}\"")

add_library({% raw %}{{ cookiecutter.lib_slug }}{% endraw %} INTERFACE)
target_include_directories({% raw %}{{ cookiecutter.lib_slug }}{% endraw %} INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)
configure_target({% raw %}{{ cookiecutter.lib_slug }}{% endraw %})
install_project_target({% raw %}{{ cookiecutter.lib_slug }}{% endraw %})
install_project_headers(${CMAKE_CURRENT_SOURCE_DIR}/include)

include_test()
