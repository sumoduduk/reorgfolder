{
inpusts,
  hostSystem,
  crate,
  package,
  crossSystem,
  rustTargetTriple
}: 
let 
  inherit (inpusts) nixpkgs crane rust-overlay;

  common = import ./common.nix { };

  pkgs = import nixpkgs {
    inherit crossSystem hostSystem;
    overlays = [ (import rust-overlay) ];
  };


  craneLib = (crane.mkLib pkgs).overrideToolchain (pkgs: pkgs.rust-bin.stable.${common.rustVersion}.minimal.override {
    targets = [ rustTargetTriple ];
  });

  createExpression = 
  {
  lib,
  stdenv
  }: 
  let 
    # reorgfolder = common.
