#!/bin/bash

# Check if all arguments are provided
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <path_to_reorgfolderArm> <path_to_reorgfolderIntel> <version>"
  exit 1
fi

# Assign arguments to variables
reorgfolderArm="$1"
reorgfolderIntel="$2"
version="$3"

# Define rb_build content
rb_build=$(cat <<EOF
class Reorgfolder < Formula
  desc "Blazingly fast and safe utility written in Rust for reorganizing folders by grouping files based on their extensions."
  homepage "https://github.com/sumoduduk/reorgfolder"
  version "${version}"

  on_macos do
    on_intel do
      url "https://github.com/sumoduduk/reorgfolder/releases/download/v${version}/reorgfolder-v${version}-mac-intel.tar.gz"
      sha256 "$reorgfolderIntel"
    end

    on_arm do
      url "https://github.com/sumoduduk/reorgfolder/releases/download/v${version}/reorgfolder-v${version}-mac-arm.tar.gz"
      sha256 "$reorgfolderArm"
    end
  end

  def install
    bin.install "reorgfolder"
  end
end
EOF
)


# calculate the sha256sum for reorgfolderArm
# sha256_arm=$(sha256sum reorgfolder-arm.tar.gz | awk '{ print $1 }')

# calculate the sha256sum for reorgfolderIntel
# sha256_intel=$(sha256sum reorgfolder-intel.tar.gz | awk '{ print $1 }')

# sed the shasum in rb build and save to out
mkdir -p rb_build
echo "$rb_build" > rb_build/reorgfolder.rb
