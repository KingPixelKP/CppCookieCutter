CPMAddPackage(
    NAME benchmark
    GITHUB_REPOSITORY google/benchmark
    GIT_TAG v1.9.5
    SYSTEM YES
    OPTIONS
    "BENCHMARK_ENABLE_TESTING OFF"
)
