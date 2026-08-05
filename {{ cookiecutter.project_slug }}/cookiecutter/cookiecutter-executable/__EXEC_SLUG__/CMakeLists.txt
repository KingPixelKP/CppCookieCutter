message(STATUS "Configuring Executable: \"{% raw %}{{ cookiecutter.exec_name }}{% endraw %}\" for \"{{ cookiecutter.project_name }}
\"")

add_executable({% raw %}{{ cookiecutter.exec_slug }}{% endraw %} src/{% raw %}{{ cookiecutter.exec_slug }}{% endraw %}.cpp)

configure_target({% raw %}{{ cookiecutter.exec_slug }}{% endraw %})