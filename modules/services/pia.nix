{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.pia;

  version = "3.6.2-08398";

  commonPkgs = pkgs: with pkgs; [
    bashInteractive
    coreutils
    shadow
    stdenv.cc.cc.lib
    glibc
    qt6.qtbase
    qt6.qtdeclarative
    openssl
    cacert
    gnutls
    zlib
    glib
    libxkbcommon
    libnl
    libnsl
    iptables
    iproute2
    psmisc
    libcap_ng
    xterm
    libatomic_ops
    xorg.libX11
    xorg.libxcb
    fontconfig
    freetype
    gtk3
    pango
    cairo
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXtst
    xorg.libXScrnSaver
    mesa
    libGL
    libGLU
    alsa-lib
    pulseaudio
    curl
    libsodium
    networkmanager
    xdg-utils
    dbus
    ncurses
    libcap
    libxml2
    libxslt
    polkit
  ];

  # The actual PIA package (raw files)
  piaRawPkg = pkgs.stdenv.mkDerivation {
    pname = "pia-vpn-raw"; # Renamed to avoid potential conflict if pkgs.pia-vpn exists
    version = version;

    src = pkgs.fetchurl {
      url = "https://installers.privateinternetaccess.com/download/pia-linux-${version}.run";
      sha256 = "sha256-xRNyHkLnB6X+8DxEgKMB/VQlUco1e9UgUyOslCHfr/0=";
    };

    nativeBuildInputs = with pkgs; [ makeWrapper libcap ];
    unpackPhase = "true";
    installPhase = ''
            mkdir -p $out/opt/pia-vpn
            cp $src ./pia-linux-${version}.run
            chmod +x ./pia-linux-${version}.run
            ./pia-linux-${version}.run --target $out/opt/pia-vpn --noexec --accept --keep

            mkdir -p $out/bin
      
            # unwrapped-pia-client script
            cat > $out/bin/unwrapped-pia-client << EOF
      #!/bin/sh
      cd $out/opt/pia-vpn/piafiles/bin
      export XDG_SESSION_TYPE=X11 
      export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
      export QT_OPENSSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
      export SSL_CERT_DIR=${pkgs.cacert}/etc/ssl/certs
      export OPENSSL_CONF=${pkgs.openssl.out}/etc/ssl/openssl.cnf
      export LD_LIBRARY_PATH=${pkgs.openssl}/lib:${pkgs.glib}/lib:${pkgs.libxkbcommon}/lib:${pkgs.libnl}/lib:${pkgs.libnsl}/lib:${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.libcap}/lib:\$LD_LIBRARY_PATH:$out/opt/pia-vpn/piafiles/lib
      export QT_PLUGIN_PATH=${pkgs.qt6.qtbase}/lib/qt-6/plugins:$out/opt/pia-vpn/piafiles/plugins
      export QML2_IMPORT_PATH=$out/opt/pia-vpn/piafiles/qml:${pkgs.qt6.qtdeclarative}/lib/qt-6/qml
      exec ./pia-client "\$@"
      EOF
            chmod +x $out/bin/unwrapped-pia-client

            # unwrapped-pia-daemon script
            cat > $out/bin/unwrapped-pia-daemon << EOF
      #!/bin/sh
      cd $out/opt/pia-vpn/piafiles/bin
      # The piavpn group should be created by the NixOS module.
      export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
      export SSL_CERT_DIR=${pkgs.cacert}/etc/ssl/certs
      export OPENSSL_CONF=${pkgs.openssl.out}/etc/ssl/openssl.cnf
      export LD_LIBRARY_PATH=${pkgs.openssl}/lib:${pkgs.glib}/lib:${pkgs.libxkbcommon}/lib:${pkgs.libnl}/lib:${pkgs.libnsl}/lib:${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.libcap}/lib:\$LD_LIBRARY_PATH:$out/opt/pia-vpn/piafiles/lib
      export QT_PLUGIN_PATH=${pkgs.qt6.qtbase}/lib/qt-6/plugins:$out/opt/pia-vpn/piafiles/plugins
      exec ./pia-daemon "\$@"
      EOF
            chmod +x $out/bin/unwrapped-pia-daemon
      
            # unwrapped-pia-ctl script
            cat > $out/bin/unwrapped-pia-ctl << EOF
      #!/bin/sh
      cd $out/opt/pia-vpn/piafiles/bin
      export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
      export SSL_CERT_DIR=${pkgs.cacert}/etc/ssl/certs
      export OPENSSL_CONF=${pkgs.openssl.out}/etc/ssl/openssl.cnf
      export LD_LIBRARY_PATH=${pkgs.openssl}/lib:${pkgs.glib}/lib:${pkgs.libxkbcommon}/lib:${pkgs.libnl}/lib:${pkgs.libnsl}/lib:${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.libcap}/lib:\$LD_LIBRARY_PATH:$out/opt/pia-vpn/piafiles/lib
      exec ./piactl "\$@"
      EOF
            chmod +x $out/bin/unwrapped-pia-ctl

            mkdir -p $out/share/icons/hicolor/128x128/apps
            if [ -f "$out/opt/pia-vpn/installfiles/app-icon.png" ]; then
              cp "$out/opt/pia-vpn/installfiles/app-icon.png" "$out/share/icons/hicolor/128x128/apps/pia-vpn.png"
            else
              ICON_SEARCH=$(find $out/opt/pia-vpn -name "*.png" | grep -i pia | head -n 1)
              if [ -n "$ICON_SEARCH" ]; then
                cp "$ICON_SEARCH" "$out/share/icons/hicolor/128x128/apps/pia-vpn.png"
              fi
            fi
    '';
  };

  # FHS environment for PIA Daemon
  piaFhsDaemon = pkgs.buildFHSEnv {
    name = "piavpn-daemon"; # This name will be used for the command in PATH
    targetPkgs = commonPkgs;
    runScript = "${piaRawPkg}/bin/unwrapped-pia-daemon";
    extraOutputsToInstall = [ "lib" "out" ];
    profile = ''
      export LD_LIBRARY_PATH=/lib:/usr/lib:$LD_LIBRARY_PATH
    '';
  };

  # FHS environment for PIA Client
  piaFhsClient = pkgs.buildFHSEnv {
    name = "piavpn-client"; # This name will be used for the command in PATH
    targetPkgs = commonPkgs;
    runScript = "${piaRawPkg}/bin/unwrapped-pia-client";
    extraOutputsToInstall = [ "lib" "out" ];
    profile = ''
      export LD_LIBRARY_PATH=/lib:/usr/lib:$LD_LIBRARY_PATH
    '';
    extraInstallCommands = ''
      mkdir -p $out/share/applications
      cat > $out/share/applications/piavpn-client.desktop << EOF
      [Desktop Entry]
      Name=Private Internet Access VPN
      Comment=Private Internet Access VPN Client
      Exec=$out/bin/piavpn-client
      Icon=${piaRawPkg}/share/icons/hicolor/128x128/apps/pia-vpn.png
      Terminal=false
      Type=Application
      Categories=Network;VPN;
      StartupNotify=true
      EOF
    '';
  };

  # FHS environment for piactl
  piaFhsCtl = pkgs.buildFHSEnv {
    name = "piactl";
    targetPkgs = commonPkgs;
    runScript = "${piaRawPkg}/bin/unwrapped-pia-ctl";
    extraOutputsToInstall = [ "lib" "out" ];
    profile = ''
      export LD_LIBRARY_PATH=/lib:/usr/lib:$LD_LIBRARY_PATH
    '';
  };

in
{
  options.services.pia = {
    enable = mkEnableOption "Private Internet Access VPN client and daemon";
  };

  config = mkIf cfg.enable {
    # Create groups needed by PIA
    users.groups.piavpn = { };
    users.groups.piahnsd = { };

    # Prevent NetworkManager from managing WireGuard interfaces created by PIA
    environment.etc."NetworkManager/conf.d/wgpia.conf".text = ''
      [keyfile]
      unmanaged-devices=interface-name:wgpia*
    '';

    # Option 1: Use extraConfig for newer systemd features
    systemd.network.links."99-wgpia" = {
      matchConfig.OriginalName = "wgpia*";
      extraConfig = ''
        [Link]
        Property=ID_NET_MANAGED_BY=
      '';
    };

    security.wrappers.pia-unbound = {
      owner = "root";
      group = "root";
      capabilities = "cap_net_bind_service+ep";
      source = "${piaRawPkg}/opt/pia-vpn/piafiles/bin/pia-unbound";
    };

    environment.systemPackages = [
      piaFhsClient
      piaFhsCtl
    ];

    systemd.services.piavpn = {
      description = "Private Internet Access Daemon";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${piaFhsDaemon}/bin/piavpn-daemon";
        Restart = "on-failure";
        RestartSec = 1;
        Group = "piavpn";
      };
      wantedBy = [ "multi-user.target" ];
    };

    # Polkit policy for managing the PIA service
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id == "com.privateinternetaccess.vpn-daemon.manage" &&
            subject.isInGroup("wheel")) {
          return polkit.Result.YES;
        }
      });
    '';

  };
}
