{
  runCommand,
  reorgfolder,
  architecture,
  ...
}: let
  version = reorgfolder.version;
in
  runCommand "tar-the-file" {inherit version;} ''
    mkdir -p $out
    tar -czvf $out/reorgfolder-v$version-mac-${architecture}.tar.gz -C ${reorgfolder}/bin reorgfolder
  ''
