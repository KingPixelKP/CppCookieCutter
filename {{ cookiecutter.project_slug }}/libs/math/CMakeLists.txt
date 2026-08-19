
file(GLOB_RECURSE MATH_SRCS CONFIGURE_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp)
add_library(math STATIC ${MATH_SRCS})
target_include_directories(math
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)
configure_target(math)
install_project_target(math)
install_project_headers(${CMAKE_CURRENT_SOURCE_DIR}/include)

include_test()
