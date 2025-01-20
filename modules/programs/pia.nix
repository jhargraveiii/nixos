{ pkgs, ... }:

let
  version = "3.6.1-08339";
  pia-client = pkgs.stdenv.mkDerivation {
    pname = "private-internet-access";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://installers.privateinternetaccess.com/download/pia-linux-${version}.run";
      sha256 = "sha256-bxTGPHt/vF50guovtCOBr63m3IvPmBZjKBOt+hEsphM=";
    };

    nativeBuildInputs = with pkgs; [ 
      bash 
      coreutils 
      glibc
      stdenv.cc.cc.lib
      zlib
      libsecret
      gtk3
      nss
      nspr
      glib
      pango
      cairo
      atk
      gdk-pixbuf
      libnotify
      xorg.libX11
      xorg.libXext
      xorg.libXrender
      xorg.libXtst
      xorg.libXi
    ];

    unpackPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/pia-installer
      chmod +x $out/bin/pia-installer
    '';

    buildPhase = '''';

    installPhase = ''
      export PATH=$PATH:$out/bin
      export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath}:$LD_LIBRARY_PATH
      bash $out/bin/pia-installer --target $out/opt/pia
      mkdir -p $out/bin
      ln -s $out/opt/pia/pia-client $out/bin/pia-client
    '';

    meta = with pkgs.lib; {
      description = "Private Internet Access VPN client";
      homepage = "https://www.privateinternetaccess.com/";
      license = licenses.unfree;
      platforms = platforms.linux;
    };
  };
in
{
  home.packages = [ pia-client ];
}
