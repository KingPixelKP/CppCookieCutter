{
  lib,
  stdenv,
  pkgs,
  cmake,
  ninja,
  cookie-cmake,
}:

let
  # deps.json is the single dependency manifest: its keys are nixpkgs attribute
  # paths (e.g. "fmt", "qt6.qtbase"), and Cookie-Cmake's dependencies() runs
  # find_package() for the same entries.
  deps = lib.importJSON ./deps.json;
  depsOfKind =
    kinds:
    map (name: lib.getAttrFromPath (lib.splitString "." name) pkgs) (
      builtins.filter (name: builtins.elem (deps.${name}.kind or "build") kinds) (builtins.attrNames deps)
    );
in
stdenv.mkDerivation {
  pname = "{{ cookiecutter.project_slug }}";
  version = "{{ cookiecutter.project_version }}";

  src = lib.cleanSource ./.;

  nativeBuildInputs = [
    cmake
    ninja
  ]; # build-time tools
  buildInputs = depsOfKind [
    "build"
    "test"
  ]; # libraries to link against

  cmakeFlags = [
    "-DCOOKIE_CMAKE_DIR=${cookie-cmake}"
    "-D{{ cookiecutter.upper_project_slug }}_BUILD_DOCS=OFF"
    "-D{{ cookiecutter.upper_project_slug }}_BUILD_BENCHMARKS=OFF"
    "-D{{ cookiecutter.upper_project_slug }}_INSTALL=ON" # populate $out
  ];

  doCheck = true; # runs ctest during `nix build`

  # Benchmark libraries are only needed in the dev shell.
  passthru.benchInputs = depsOfKind [ "bench" ];
}
