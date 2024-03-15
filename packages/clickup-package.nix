{ lib, stdenv, appimageTools, fetchurl, pkgs }:

let
  pname = "clickup-desktop";
  version = "3.3.79";
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";
  suffix = {
    x86_64-linux = "linux_x86_64.AppImage";
  }.${system} or throwSystem;
  src = fetchurl {
    url = "https://desktop.clickup.com/linux";
    hash = {
      x86_64-linux = "sha256-jAOYDX9j+ZTqWsSg0rEckKZnErgsIV6+CtUv3M3wNqM=";
    }.${system} or throwSystem;
  };
  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
  meta = with lib; {
    description = "Clickup Desktop";
    homepage = "https://clickup.com";
    license = licenses.unfree;
    maintainers = [ "whoever" ];
    platforms = [ "x86_64-linux" ];
  };
in
appimageTools.wrapType2 rec {
  inherit pname version src meta;
  extraPkgs = pkgs: with pkgs; [
    xorg.libxkbfile
    alsa-lib
    dbus-glib
    gtk3
    nss
    gnused
    libdbusmenu-gtk3
    # Add any additional dependencies here
  ];
  extraInstallCommands = ''
    mv $out/bin/{${pname}-${version},${pname}}
    install -Dm444 ${appimageContents}/desktop.desktop -t $out/share/applications
    install -Dm444 ${appimageContents}/desktop.png -t $out/share/pixmaps
    substituteInPlace $out/share/applications/desktop.desktop \
      --replace 'Exec=AppRun --no-sandbox %U' 'Exec=${pname}'
  '';
}
