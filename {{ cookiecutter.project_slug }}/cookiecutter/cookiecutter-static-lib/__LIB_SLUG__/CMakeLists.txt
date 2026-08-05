message(STATUS "Configuring Static Library: \"{% raw %}{{ cookiecutter.lib_name }}{% endraw %}\"")

add_library({% raw %}{{ cookiecutter.lib_slug }}{% endraw %} STATIC
    {% raw %}{{ cookiecutter.lib_slug }}{% endraw %}.cpp
)
target_include_directories({% raw %}{{ cookiecutter.lib_slug }}{% endraw %} PUBLIC include)
configure_target({% raw %}{{ cookiecutter.lib_slug }}{% endraw %})

include_test()