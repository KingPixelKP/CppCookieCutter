message(STATUS "Configuring Benchmark: \"{% raw %}{{ cookiecutter.bench_name }}{% endraw %}\" for \"{% raw %}{{ cookiecutter.lib_name }}{% endraw %}\" for \"{{ cookiecutter.project_name }}\"")

add_executable({% raw %}{{ cookiecutter.bench_slug }}{% endraw %} src/{% raw %}{{ cookiecutter.bench_slug }}{% endraw %}.cpp)
target_link_libraries({% raw %}{{ cookiecutter.bench_slug }}{% endraw %} PRIVATE
    {% raw %}{{ cookiecutter.lib_slug }}{% endraw %}
    benchmark::benchmark
    benchmark::benchmark_main
)

configure_target({% raw %}{{ cookiecutter.bench_slug }}{% endraw %})