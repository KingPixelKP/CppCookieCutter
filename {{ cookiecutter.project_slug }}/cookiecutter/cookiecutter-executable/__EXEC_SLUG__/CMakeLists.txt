message(STATUS "Configuring Executable: \"{% raw %}{{ cookiecutter.exec_name }}{% endraw %}\"")

add_executable({% raw %}{{ cookiecutter.exec_slug }}{% endraw %} src/{% raw %}{{ cookiecutter.exec_slug }}{% endraw %}.cpp)

configure_target({% raw %}{{ cookiecutter.exec_slug }}{% endraw %})