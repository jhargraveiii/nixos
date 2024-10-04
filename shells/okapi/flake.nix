{
  description = "A flake for running an SWT GTK app with gsettings-desktop-schemas";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      formatter.${system} = pkgs.nixpkgs-fmt;

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          pkgs.gsettings-desktop-schemas
          pkgs.gtk3
          pkgs.kdePackages.kde-gtk-config
          pkgs.webkitgtk
          pkgs.xdg-desktop-portal-gtk
          pkgs.xdg-user-dirs
          pkgs.adwaita-icon-theme
          pkgs.gobject-introspection
          pkgs.cairo
          pkgs.pango
          pkgs.gdk-pixbuf
          pkgs.atk
          pkgs.shared-mime-info
          pkgs.dbus
          pkgs.glib
          pkgs.glib-networking
        ];

        shellHook = ''
           export GSETTINGS_SCHEMA_DIR="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas/"
          export XDG_DATA_DIRS=$GSETTINGS_SCHEMA_DIR:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/:$XDG_DATA_DIRS
          export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.webkitgtk}/lib:/home/jimh/.swt/lib/linux/x86_64/:${pkgs.glib}/lib
          export SWT_GTK3=1
          export GI_TYPELIB_PATH=${pkgs.gobject-introspection}/lib/girepository-1.0
          export XDG_DATA_DIRS=${pkgs.shared-mime-info}/share:$XDG_DATA_DIRS
        '';
      };
    };
}
