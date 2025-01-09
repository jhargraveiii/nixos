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
        buildInputs = with pkgs; [
          gsettings-desktop-schemas
          gtk3
          kdePackages.kde-gtk-config
          webkitgtk
          xdg-desktop-portal-gtk
          xdg-user-dirs
          adwaita-icon-theme
          gobject-introspection
          cairo
          pango
          gdk-pixbuf
          atk
          shared-mime-info
          dbus
          glib
          glib-networking
          gnome-themes-extra
          hicolor-icon-theme
          swt
        ];

        shellHook = ''
          export GSETTINGS_SCHEMA_DIR="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas/"
          export XDG_DATA_DIRS="$GSETTINGS_SCHEMA_DIR:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/:$XDG_DATA_DIRS"
          export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${pkgs.webkitgtk}/lib:${pkgs.glib}/lib:${pkgs.glib-networking}/lib:${pkgs.swt}/lib:${pkgs.gtk3}/lib"
          export GI_TYPELIB_PATH="${pkgs.gobject-introspection}/lib/girepository-1.0"
          export XDG_DATA_DIRS="${pkgs.shared-mime-info}/share:${pkgs.hicolor-icon-theme}/share:$XDG_DATA_DIRS"
          export GTK_USE_PORTAL=1
          export GTK_THEME="Breeze"
          export GTK2_RC_FILES="${pkgs.kdePackages.breeze-gtk}/share/themes/Breeze/gtk-2.0/gtkrc"

          # Add SWT libraries to java.library.path
          export _JAVA_OPTIONS="$_JAVA_OPTIONS -Djava.library.path=${pkgs.swt}/lib"

          # Ensure SWT can find its native libraries
          export SWT_GTK3=1
          export SWT_LIBRARY_PATH="${pkgs.swt}/lib"
        '';
      };
    };
}
