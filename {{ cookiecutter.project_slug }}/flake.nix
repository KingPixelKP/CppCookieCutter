{
  description = "{{ cookiecutter.project_name }}: C++{{ cookiecutter.cpp_standard }} + CMake project with a shared dev build and a static release build";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # CMake helpers providing package(), workspace() and the tooling targets.
    cookie-cmake = {
      url = "github:KingPixelKP/Cookie-Cmake/2a97a9f9ace938eeaf5b8ba6a1f1199db4d870eb";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, cookie-cmake }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in {
      packages = forAllSystems (pkgs: {
        default = pkgs.callPackage ./package.nix { inherit cookie-cmake; };            # shared, for devs
        static  = pkgs.pkgsStatic.callPackage ./package.nix { inherit cookie-cmake; }; # fully static (musl), for release
      });

      # `nix flake check` builds (and tests) every package.
      checks = forAllSystems (pkgs: self.packages.${pkgs.stdenv.hostPlatform.system});

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          inputsFrom = [ self.packages.${pkgs.stdenv.hostPlatform.system}.default ]; # same deps as the build

          # dev-only extras
          packages = [
            pkgs.clang-tools
            pkgs.gdb
            pkgs.gcovr
            pkgs.gbenchmark
{%- if cookiecutter.include_docs == "y" %}
            pkgs.doxygen
{%- endif %}
            # Cookie-Cmake links with lld when it finds one; provide Nix's
            # wrapped lld so a host /usr/bin/ld.lld isn't used, which would
            # skip the store-path RPATHs (gtest, fmt, libstdc++).
            pkgs.llvmPackages.bintools
          ];

          COOKIE_CMAKE_DIR = "${cookie-cmake}";
        };
      });
    };
}
