add_project_test(
    {% raw %}{{ cookiecutter.lib_slug }}{% endraw %}_test
    SOURCES {% raw %}{{ cookiecutter.lib_slug }}{% endraw %}.cpp
    LIBRARIES {% raw %}{{ cookiecutter.lib_slug }}{% endraw %}
)
