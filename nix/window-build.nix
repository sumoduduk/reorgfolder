{
  inputs,
  hostSystem,
}: let
  inherit (inputs) nixpkgs crane fenix;
  common = import ./common.nix {};

  pkgs = nixpkgs.legacyPackages.${hostSystem};

  toolchain = with fenix.packages.${hostSystem};
    combine [
      minimal.rustc
      minimal.cargo
      targets.x86_64-pc-windows-gnu.latest.rust-std
    ];

  craneLib = (crane.mkLib pkgs).overrideToolchain toolchain;

  reorgfolderCommon = common.reorgfolder {
    inherit craneLib;
    lib = pkgs.lib;
    reorgfolder = inputs.reorgfolder;
  };

  commonArgs = {
    pname = "default";
    version = "0.0.0";

    src = reorgfolderCommon.src;

    strictDeps = true;
    doCheck = false;

    CARGO_BUILD_TARGET = "x86_64-pc-windows-gnu";

    TARGET_CC = "${pkgs.pkgsCross.mingwW64.stdenv.cc}/bin/${pkgs.pkgsCross.mingwW64.stdenv.cc.targetPrefix}cc";

    RUSTC_LINKER = "${pkgs.pkgsCross.mingwW64.stdenv.cc}/bin/${pkgs.pkgsCross.mingwW64.stdenv.cc.targetPrefix}cc";

    depsBuildBuild = with pkgs; [
      pkgsCross.mingwW64.stdenv.cc
      pkgsCross.mingwW64.windows.pthreads
    ];
  };

  cargoArtifacts = craneLib.buildDepsOnly commonArgs;
in
  craneLib.buildPackage (commonArgs
    // {
      pname = "reorgfolder";
      version = reorgfolderCommon.crateInfo.version;

      inherit cargoArtifacts;

      cargoExtraArgs = "--package reorgfolder";
    })
