add_project_test(
    {% raw %}{{ cookiecutter.lib_slug }}{% endraw %}_test
    SOURCES {% raw %}{{ cookiecutter.lib_slug }}{% endraw %}
    LIBRARIES {% raw %}{{ cookiecutter.lib_slug }}{% endraw %}
)
