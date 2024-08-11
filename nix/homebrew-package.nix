{
  runCommand,
  reorgfolderArm,
  reorgfolderIntel,
}: let
  version = reorgfolderArm.version;

  rb_build = ''
    class Reorgfolder < Formula
      desc "Blazingly fast and safe utility written in Rust for reorganizing folders by grouping files based on their extensions."
      homepage "https://github.com/sumoduduk/reorgfolder"
      version "${version}"

      on_macos do
        on_intel do
          url "https://github.com/sumoduduk/reorgfolder/releases/download/v${version}/reorgfolder-v${version}-mac-intel.tar.gz"
          sha256 "%%SHA256SUMINTEL%%"
        end

        on_arm do
          url "https://github.com/sumoduduk/reorgfolder/releases/download/v${version}/reorgfolder-v${version}-mac-arm.tar.gz"
          sha256 "%%SHA256SUMARM%%"
        end
      end

      def install
        bin.install "reorgfolder"
      end
    end
  '';
in
  runCommand "package-homebrew" {inherit rb_build;} ''
    # tar the reorgfolderArm
    tar -czvf reorgfolder-arm.tar.gz -C ${reorgfolderArm}/bin reorgfolder

    # tar the reorgfolderIntel
    tar -czvf reorgfolder-intel.tar.gz -C ${reorgfolderIntel}/bin reorgfolder

    # calculate the sha256sum for reorgfolderArm
    sha256_arm=$(sha256sum reorgfolder-arm.tar.gz | awk '{ print $1 }')

    # calculate the sha256sum for reorgfolderIntel
    sha256_intel=$(sha256sum reorgfolder-intel.tar.gz | awk '{ print $1 }')

    # sed the shasum in rb build and save to out
    mkdir -p $out
    echo "$rb_build" | sed "s/%%SHA256SUMARM%%/$sha256_arm/" | sed "s/%%SHA256SUMINTEL%%/$sha256_intel/" > $out/reorgfolder.rb
  ''
