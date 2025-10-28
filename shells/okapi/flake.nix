{
  description = "Development environment for Okapi Framework (Java/Maven SWT project)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        
        # Core GTK and SWT runtime libraries
        runtimeLibs = with pkgs; [
          gtk3
          cairo
          pango
          glib
          gdk-pixbuf
          atk
          webkitgtk_4_1
          swt
        ];
        
        # Build library path from runtime libs
        libraryPath = pkgs.lib.makeLibraryPath runtimeLibs;
      in
      {
        formatter = pkgs.nixpkgs-fmt;

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Build tools
            jdk17
            maven
            
            # GTK/UI runtime dependencies
            gtk3
            cairo
            webkitgtk_4_1
            swt
            
            # Theme and icon support
            gsettings-desktop-schemas
            adwaita-icon-theme
            hicolor-icon-theme
            shared-mime-info
            
            # Desktop integration
            xdg-user-dirs
          ];

          shellHook = ''
            # Set up library paths for SWT native libraries
            export LD_LIBRARY_PATH="${libraryPath}:''${LD_LIBRARY_PATH:-}"
            
            # Java library path for SWT JNI
            export _JAVA_OPTIONS="-Djava.library.path=${pkgs.swt}/lib:${pkgs.gtk3}/lib:${pkgs.cairo}/lib"
            
            # GTK configuration
            export GSETTINGS_SCHEMA_DIR="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas/"
            export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share:${pkgs.gtk3}/share:${pkgs.shared-mime-info}/share:${pkgs.hicolor-icon-theme}/share:''${XDG_DATA_DIRS:-}"
            
            # SWT configuration
            export SWT_GTK3=1
            
            echo "Okapi development environment loaded"
            echo "Java: $(java -version 2>&1 | head -1)"
            echo "Maven: $(mvn -version | head -1)"
          '';
        };
      }
    );
}
