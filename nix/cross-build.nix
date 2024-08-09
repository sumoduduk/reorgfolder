{
  inputs,
  system,
  crossSystem,
  rustTargetTriple,
  pathCwd,
  ...
}: let
  inherit (inputs) nixpkgs crane rust-overlay;

  common = import ./common.nix {};

  pkgs = import nixpkgs {
    inherit crossSystem system;
    overlays = [(import rust-overlay)];
  };

  craneLib = (crane.mkLib pkgs).overrideToolchain (pkgs:
    pkgs.rust-bin.stable.${common.rustVersion}.minimal.override {
      targets = [rustTargetTriple];
    });

  createExpression = {
    lib,
    stdenv,
  }: let
    reorgfolderCommon = common.reorgfolder {
      inherit lib craneLib pathCwd;
    };

    commonArgs = {
      pname = "default";
      version = "0.0.0";

      src = reorgfolderCommon.src;

      doCheck = true;
      strictDeps = true;

      nativeBuildInputs = [
        stdenv.cc
      ];

      buildInputs =
        [
          #pkgs.openssl
        ]
        ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
          pkgs.libiconv
        ];

      CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER = "${stdenv.cc.targetPrefix}cc";
      CARGO_TARGET_AARCH64_UNKNOWN_APPLE_LINKER = "${stdenv.cc.targetPrefix}cc";

      cargoExtraArgs = "--target ${rustTargetTriple}";

      HOST_CC = "${stdenv.cc.nativePrefix}cc";
      TARGET_CC = "${stdenv.cc.targetPrefix}cc";
    };

    cargoArtifacts = craneLib.buildDepsOnly commonArgs;
  in
    craneLib.buildPackage (commonArgs
      // {
        pname = "reorgfolder";
        version = reorgfolderCommon.crateInfo.version;

        inherit cargoArtifacts;

        cargoExtraArgs = "${commonArgs.cargoExtraArgs} --package reorgfolder";
      });
in
  pkgs.callPackage createExpression {}
