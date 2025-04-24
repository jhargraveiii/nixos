{
  description = "A flake for running an SWT GTK app with gsettings-desktop-schemas";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs
    , ...
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

          # Create directory for SWT symbolic links
          mkdir -p $HOME/.swt/lib/linux/x86_64

          # Discover what SWT libraries are available
          echo "Available SWT libraries in ${pkgs.swt}/lib/:"
          ls -la ${pkgs.swt}/lib/

          # First approach: directly link existing pi libraries with required names
          if [ -f ${pkgs.swt}/lib/libswt-pi4-gtk*.so ]; then
            ln -sf ${pkgs.swt}/lib/libswt-pi4-gtk*.so $HOME/.swt/lib/linux/x86_64/libswt-pi4-gtk-4966r5.so
            ln -sf ${pkgs.swt}/lib/libswt-pi4-gtk*.so $HOME/.swt/lib/linux/x86_64/libswt-pi4-gtk.so
          fi

          if [ -f ${pkgs.swt}/lib/libswt-pi4*.so ]; then
            ln -sf ${pkgs.swt}/lib/libswt-pi4*.so $HOME/.swt/lib/linux/x86_64/libswt-pi4.so
          fi

          # Second approach: if pi4 doesn't exist but pi3 does, use those
          if [ ! -f $HOME/.swt/lib/linux/x86_64/libswt-pi4.so ] && [ -f ${pkgs.swt}/lib/libswt-pi3*.so ]; then
            ln -sf ${pkgs.swt}/lib/libswt-pi3*.so $HOME/.swt/lib/linux/x86_64/libswt-pi4.so
          fi

          if [ ! -f $HOME/.swt/lib/linux/x86_64/libswt-pi4-gtk.so ] && [ -f ${pkgs.swt}/lib/libswt-pi3-gtk*.so ]; then
            ln -sf ${pkgs.swt}/lib/libswt-pi3-gtk*.so $HOME/.swt/lib/linux/x86_64/libswt-pi4-gtk.so
            ln -sf ${pkgs.swt}/lib/libswt-pi3-gtk*.so $HOME/.swt/lib/linux/x86_64/libswt-pi4-gtk-4966r5.so
          fi

          # Also link all other SWT libraries to the .swt directory
          for lib in ${pkgs.swt}/lib/libswt-*.so; do
            ln -sf $lib $HOME/.swt/lib/linux/x86_64/
          done

          # Print the results
          echo "Created symlinks in $HOME/.swt/lib/linux/x86_64/:"
          ls -la $HOME/.swt/lib/linux/x86_64/

          # Add the SWT directories to the Java library path explicitly
          export _JAVA_OPTIONS="$_JAVA_OPTIONS -Djava.library.path=${pkgs.swt}/lib:$HOME/.swt/lib/linux/x86_64:${pkgs.gtk3}/lib:${pkgs.cairo}/lib"

          # SWT environment variables
          export SWT_GTK3=1
          export SWT_LIBRARY_PATH="${pkgs.swt}/lib:$HOME/.swt/lib/linux/x86_64"
          
          # Additional debug info 
          export SWT_DEBUG=1
          export SWT_DEBUG_LOAD_LIBRARY=1
          
          # Print java.library.path to verify
          echo "Current java.library.path in _JAVA_OPTIONS: $_JAVA_OPTIONS"
        '';
      };
    };
}
