{
  runCommand,
  reorgfolder,
}: let
  version = reorgfolder.version;
in
  runCommand "tar-the-file" {inherit version;} ''
    mkdir -p $out
    tar -czvf reorgfolder-v$version-linux.tar.gz -C $reorgfolder/bin/reorgfolder
  ''
