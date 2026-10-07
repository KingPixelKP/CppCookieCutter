CPMAddPackage(
    NAME cookie_cmake
    GITHUB_REPOSITORY KingPixelKP/Cookie-Cmake
    GIT_TAG "2a97a9f9ace938eeaf5b8ba6a1f1199db4d870eb"
    DOWNLOAD_ONLY YES
)
list(APPEND CMAKE_MODULE_PATH "${cookie_cmake_SOURCE_DIR}/cmake")
include(cookie)