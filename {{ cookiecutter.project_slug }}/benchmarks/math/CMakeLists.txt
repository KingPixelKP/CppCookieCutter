add_executable(math_benchmark math_benchmark.cpp)
target_link_libraries(math_benchmark PRIVATE math benchmark::benchmark benchmark::benchmark_main)
configure_target(math_benchmark)
