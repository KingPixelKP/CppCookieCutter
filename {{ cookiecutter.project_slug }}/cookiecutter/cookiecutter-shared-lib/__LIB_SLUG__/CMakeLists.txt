message(STATUS "Configuring Shared Library: \"{% raw %}{{ cookiecutter.lib_name }}{% endraw %}\" for \"{{ cookiecutter.project_name }}
\"")

add_library({% raw %}{{ cookiecutter.lib_slug }}{% endraw %} SHARED
    {% raw %}{{ cookiecutter.lib_slug }}{% endraw %}.cpp
)
target_include_directories({% raw %}{{ cookiecutter.lib_slug }}{% endraw %} PUBLIC include)
configure_target({% raw %}{{ cookiecutter.lib_slug }}{% endraw %})

include_test()