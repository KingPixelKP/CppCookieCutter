include(fmt)

CPMAddPackage(
    NAME spdlog
    GITHUB_REPOSITORY gabime/spdlog
    GIT_TAG v1.17.0
    SYSTEM YES
    OPTIONS
    "SPDLOG_FMT_EXTERNAL ON"
)
