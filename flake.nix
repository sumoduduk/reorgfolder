{
  description = "Flake file for Reorgfolder App Package";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    crane,
    flake-utils,
    rust-overlay,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (hostSystem: {
      packages = let
        defineReorgfolderPkgs = {}:
          {
            reorgfolder_aarch64-linux = import ./nix/cross-build.nix {
              inherit hostSystem inputs;
              crossSystem = "aarch64-linux";
              rustTargetTriple = "aarch64-unknown-linux-gnu";
            };

            reorgfolder_x86_64-linux = import ./nix/cross-build.nix {
              inherit hostSystem inputs;
              crossSystem = "x86_64-linux";
              rustTargetTriple = "x86_64-unknown-linux-gnu";
            };

            reorgfolder_x86_64-windows = import ./nix/window-build.nix {
              inherit hostSystem inputs;
            };
          }
          // (
            if hostSystem == "aarch64-darwin"
            then {
              reorgfolder_aarch64-apple = import ./nix/cross-build.nix {
                inherit hostSystem inputs;
                crossSystem = "aarch64-darwin";
                rustTargetTriple = "aarch64-apple-darwin";
              };
            }
            else if hostSystem == "x86_64-darwin"
            then {
              reorgfolder_x86_64-apple = import ./nix/cross-build.nix {
                inherit hostSystem inputs;
                crossSystem = "x86_64-darwin";
                rustTargetTriple = "x86_64-apple-darwin";
              };
            }
            else {}
          );
      in
        defineReorgfolderPkgs {};

      apps.default = flake-utils.lib.mkApp {
        drv = self.packages.${hostSystem}.reorgfolder_ "${hostSystem}";
      };

      devShells.default = let
        pkgs = nixpkgs.legacyPackages.${hostSystem};
      in
        pkgs.mkShell {
          packages = with pkgs; [
            patchelf
          ];
        };
    })
    // {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    };
}
