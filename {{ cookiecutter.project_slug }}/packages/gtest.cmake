include(GoogleTest)

CPMAddPackage(
    NAME googletest
    GITHUB_REPOSITORY google/googletest
    GIT_TAG v1.17.0
    SYSTEM YES
    OPTIONS
    "BUILD_GMOCK OFF"
    "INSTALL_GTEST OFF"
)
