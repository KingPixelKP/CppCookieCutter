#include "{% raw %}{{ cookiecutter.lib_slug }}{% endraw %}/{% raw %}{{ cookiecutter.lib_slug }}{% endraw %}.hpp"

#include <benchmark/benchmark.h>

static void BM_{% raw %}{{ cookiecutter.upper_lib_slug }}{% endraw %}(benchmark::State &state) {

}

BENCHMARK(BM_{% raw %}{{ cookiecutter.upper_lib_slug }}{% endraw %});