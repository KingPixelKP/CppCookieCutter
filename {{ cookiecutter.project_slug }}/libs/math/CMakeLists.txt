
file(GLOB_RECURSE MATH_SRCS ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp)
add_library(math STATIC ${MATH_SRCS})
target_include_directories(math PUBLIC include)
configure_target(math)

include_test()