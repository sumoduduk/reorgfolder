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
    flake-utils.lib.eachDefaultSystem (localSystem: {
      packages = let
        pkgs = nixpkgs.legacyPackages.${localSystem};

        defineReorgfolderPkgs = {}:
          {
            reorgfolder_aarch64-linux = import ./nix/cross-build.nix {
              inherit localSystem inputs;
              pathCwd = ./.;
              crossSystem = "aarch64-linux";
              rustTargetTriple = "aarch64-unknown-linux-gnu";
            };

            reorgfolder_x86_64-linux = import ./nix/cross-build.nix {
              inherit localSystem inputs;
              pathCwd = ./.;
              crossSystem = "x86_64-linux";
              rustTargetTriple = "x86_64-unknown-linux-gnu";
            };

            reorgfolder_x86_64-windows = import ./nix/window-build.nix {
              inherit localSystem inputs;
              pathCwd = ./.;
            };

            build-rb-homebrew = pkgs.callPackage ./nix/homebrew-package.nix {
              reorgfolderArm = self.packages.${localSystem}.reorgfolder_x86_64-linux;
              reorgfolderIntel = self.packages.${localSystem}.reorgfolder_aarch64-linux;
            };
          }
          // (
            if localSystem == "aarch64-darwin"
            then {
              reorgfolder_aarch64-apple = import ./nix/cross-build.nix {
                inherit localSystem inputs;
                pathCwd = ./.;
                crossSystem = "aarch64-darwin";
                rustTargetTriple = "aarch64-apple-darwin";
              };

              tar-darwin-arm = pkgs.callPackage ./nix/tar-package.nix {
                reorgfolder = self.packages.${localSystem}.reorgfolder_aarch64-apple;
                architecture = "arm";
              };

              reorgfolder_x86_64-apple = import ./nix/cross-build.nix {
                inherit localSystem inputs;
                pathCwd = ./.;
                crossSystem = "x86_64-darwin";
                rustTargetTriple = "x86_64-apple-darwin";
              };

              tar-darwin-x86_64 = pkgs.callPackage ./nix/tar-package.nix {
                reorgfolder = self.packages.${localSystem}.reorgfolder_x86_64-apple;
                architecture = "intel";
              };
            }
            else if localSystem == "x86_64-darwin"
            then {
              reorgfolder_x86_64-apple = import ./nix/cross-build.nix {
                inherit localSystem inputs;
                pathCwd = ./.;
                crossSystem = "x86_64-darwin";
                rustTargetTriple = "x86_64-apple-darwin";
              };
            }
            else {}
          );
      in
        defineReorgfolderPkgs {};

      apps.default = flake-utils.lib.mkApp {
        drv = nixpkgs.lib.getAttr "reorgfolder_${localSystem}" self.packages.${localSystem};
      };

      devShells.default = let
        pkgs = nixpkgs.legacyPackages.${localSystem};
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
