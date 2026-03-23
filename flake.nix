{
  description = "CrunchTime: The Export Simulator development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            gdscript-formatter
          ];

          shellHook = ''
            echo "CrunchTime: The Export Simulator Dev Environment"
            echo "GDScript Formatter version: $(gdscript-formatter --version)"
          '';
        };
      });
}
