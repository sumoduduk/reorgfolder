{
  description = "Flake file for Reorgfolder App Package";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    crane,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};

      craneLib = crane.mkLib pkgs;

      commonArgs = {
        src = craneLib.cleanCargoSource ./.;
        strictDeps = true;

        buildInputs =
          [
            #pkgs.openssl
          ]
          ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
            pkgs.libiconv
          ];
        nativeBuildInputs = [
          # pkgs.pkg-config
        ];
      };

      reorgfolder = craneLib.buildPackage (commonArgs
        // {
          cargoArtifacts = craneLib.buildDepsOnly commonArgs;
          # Additional environment variables or build phases/hooks can be set
          # here *without* rebuilding all dependency crates
          # MY_CUSTOM_VAR = "some value";
        });
    in {
      checks = {
        inherit reorgfolder;
      };

      packages =
        {
          default = reorgfolder;
        }
        // (
          if system == "x86_64-linux"
          then {
            reorgfolder-bin-aur = pkgs.callPackage ./nix/pkgbuild.nix {
              reorgfolder = self.packages.x86_64-linux.reorgfolder;
            };
          }
          else {}
        );

      apps.default = flake-utils.lib.mkApp {
        drv = reorgfolder;
      };

      devShells.default = craneLib.devShell {
        checks = self.checks.${system};

        # Additional dev-shell environment variables can be set directly
        # MY_CUSTOM_DEVELOPMENT_VAR = "something else";
        shellHook = ''
          alias cls="clear"
        '';

        # Extra inputs can be added here; cargo and rustc are provided by default.
        packages = [
          # pkgs.ripgrep
        ];
      };
    });
}
