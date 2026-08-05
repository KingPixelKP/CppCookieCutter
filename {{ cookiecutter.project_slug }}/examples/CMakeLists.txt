add_executable(vector_example vector_example.cpp)
target_link_libraries(vector_example PRIVATE math fmt::fmt)
configure_target(vector_example)
