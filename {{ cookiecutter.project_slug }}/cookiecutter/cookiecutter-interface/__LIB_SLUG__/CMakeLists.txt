message(STATUS "Configuring Interface: \"{% raw %}{{ cookiecutter.lib_name }}{% endraw %}\" for \"{{ cookiecutter.project_name }}\"")

add_library({% raw %}{{ cookiecutter.lib_slug }}{% endraw %} INTERFACE)
target_include_directories({% raw %}{{ cookiecutter.lib_slug }}{% endraw %} INTERFACE include)
configure_target({% raw %}{{ cookiecutter.lib_slug }}{% endraw %})

include_test()