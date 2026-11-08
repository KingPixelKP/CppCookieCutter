{ lib, stdenv, cmake, ninja, fmt, gtest, cookie-cmake }:

stdenv.mkDerivation {
  pname = "{{ cookiecutter.project_slug }}";
  version = "{{ cookiecutter.project_version }}";

  src = lib.cleanSource ./.;

  nativeBuildInputs = [ cmake ninja ];   # build-time tools
  buildInputs = [ fmt gtest ];           # libraries to link against

  cmakeFlags = [
    "-DCOOKIE_CMAKE_DIR=${cookie-cmake}"
    "-D{{ cookiecutter.upper_project_slug }}_BUILD_DOCS=OFF"
    "-D{{ cookiecutter.upper_project_slug }}_BUILD_BENCHMARKS=OFF"
    "-D{{ cookiecutter.upper_project_slug }}_INSTALL=ON"   # populate $out
  ];

  doCheck = true;                        # runs ctest during `nix build`
}
