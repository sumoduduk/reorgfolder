{
  runCommand,
  reorgfolder,
  pkgrel ? "1",
}: let
  sha256 = runCommand "reorgfolder-sha256" {} ''
    sha256sum ${reorgfolder}/bin/reorgfolder | awk '{print $1}'
  '';

  pkgdesc = "Blazingly fast and safe utility written in Rust for reorganizing folders by grouping files based on their extensions.";

  pkgbuild = ''
    pkgname=reorgfolder-bin
     pkgdesc="${pkgdesc}"
     pkgrel=${pkgrel}
     pkgver=${reorgfolder.version}
     url="https://github.com/sumoduduk/reorgfolder"
     license=("GPL-3.0")
     arch=("x86_64")
     provides=("reorgfolder")
     conflicts=("reorgfolder")
     source=("https://github.com/sumoduduk/reorgfolder/releases/download/v$pkgver/reorgfolder-$CARCH-linux")
     sha256sums=("%%SHA256SUM%%")

     package() {
        mv reorgfolder-x86_64-linux reorgfolder
        install -Dm755 reorgfolder -t "$pkgdir/usr/bin"
     }
  '';

  srcinfo = ''
    pkgbase = reorgfolder-bin
    	pkgdesc = ${pkgdesc}
    	pkgver = ${reorgfolder.version}
    	pkgrel = ${pkgrel}
    	url = https://github.com/sumoduduk/reorgfolder
    	arch = x86_64
    	license = GPL-3.0
    	provides = reorgfolder
    	conflicts = reorgfolder
    	source = https://github.com/sumoduduk/reorgfolder/releases/download/v${reorgfolder.version}/reorgfolder-x86_64-linux
    	sha256sums = %%SHA256SUM%%

    pkgname = reorgfolder-bin
  '';
in
  runCommand "reorgfolder-bin-aur" {inherit srcinfo pkgbuild;} ''
    sha256=$(sha256sum ${reorgfolder}/bin/reorgfolder | awk '{print $1}')

    mkdir -p $out

    echo "$srcinfo" | sed "s/%%SHA256SUM%%/$sha256/" > $out/.SRCINFO
    echo "$pkgbuild" | sed "s/%%SHA256SUM%%/$sha256/" > $out/PKGBUILD

  ''
