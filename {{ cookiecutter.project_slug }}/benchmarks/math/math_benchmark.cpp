#include "math/math.hpp"

#include <benchmark/benchmark.h>

static void BM_VectorAdd(benchmark::State &state) {
  const auto lhs = math::Vector(1, 2);
  const auto rhs = math::Vector(3, 4);

  for (auto _ : state) {
    auto sum = lhs.add(rhs);
    benchmark::DoNotOptimize(sum);
  }
}

BENCHMARK(BM_VectorAdd);