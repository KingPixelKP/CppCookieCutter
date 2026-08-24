message(STATUS "Configuring \"Libs\"")
file(GLOB _lib_members CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/*/CMakeLists.txt"
)

if(_lib_members)
    workspace(DISCOVER .)
endif()
