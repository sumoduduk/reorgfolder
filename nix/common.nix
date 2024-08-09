{}: {
  rustVersion = "1.79.0";

  reorgfolder = {
    lib,
    craneLib,
    reorgfolder,
  }: let
    nonCargoBuildFiles = path: _type: builtins.match ".*(sql|md)$" path != null;
    includeFilesFilter = path: type:
      (craneLib.filterCargoSources path type) || (nonCargoBuildFiles path type);
  in {
    crateInfo = craneLib.crateNameFromCargoToml {cargoToml = reorgfolder + "/Cargo.toml";};

    src = lib.cleanSourceWith {
      src = reorgfolder;
      filter = includeFilesFilter;
    };
  };
}
