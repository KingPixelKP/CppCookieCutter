{
  description = "CppCookieCutter: generate a Nix-built C++ CMake project";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      # `nix run github:KingPixelKP/CppCookieCutter` generates a project from this template.
      # Extra arguments go to cookiecutter, e.g. `nix run . -- --no-input project_name=demo`.
      packages = forAllSystems (pkgs: {
        default = pkgs.writeShellApplication {
          name = "cppcookiecutter";
          runtimeInputs = [
            pkgs.cookiecutter
            pkgs.git
          ];
          text = ''exec cookiecutter ${self} "$@"'';
        };
      });
    };
}
