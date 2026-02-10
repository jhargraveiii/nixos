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
        
        # Core GTK runtime libraries needed by SWT native libraries
        runtimeLibs = with pkgs; [
          gtk3
          cairo
          pango
          glib
          gdk-pixbuf
          atk
          webkitgtk_4_1
        ];
        
        # Build library path from runtime libs
        libraryPath = pkgs.lib.makeLibraryPath runtimeLibs;
        
        # Wrapper for maven that ensures paths are set for forked JVMs
        mavenWrapped = pkgs.writeShellScriptBin "mvn" ''
          export LD_LIBRARY_PATH="${libraryPath}:''${LD_LIBRARY_PATH:-}"
          
          # SWT extracts native libraries to ~/.swt/lib/linux/x86_64/ automatically
          # We just need to ensure this directory exists and is in java.library.path
          SWT_EXTRACT_DIR="$HOME/.swt/lib/linux/x86_64"
          mkdir -p "$SWT_EXTRACT_DIR"
          
          # Remove broken symlinks (from old nixpkgs SWT package) so Maven can extract fresh libs
          find "$SWT_EXTRACT_DIR" -type l ! -exec test -e {} \; -delete 2>/dev/null || true
          
          # Build java.library.path: SWT extraction dir + GTK libs
          JAVA_LIB_PATH="$SWT_EXTRACT_DIR:${pkgs.gtk3}/lib:${pkgs.cairo}/lib"
          
          # Build LD_LIBRARY_PATH for environment variable
          LD_LIB_PATH="${libraryPath}"
          
          # Surefire argLine for java.library.path
          SUREFIRE_ARG="-Djava.library.path=$JAVA_LIB_PATH"
          
          # Surefire environment variable configuration
          SUREFIRE_ENV="LD_LIBRARY_PATH=$LD_LIB_PATH"
          
          # Check if user provided custom configuration
          if [[ "$*" != *"-DargLine="* ]] && [[ "$*" != *"surefire.environmentVariables"* ]]; then
            exec ${pkgs.maven}/bin/mvn \
              -DargLine="$SUREFIRE_ARG" \
              -Dsurefire.environmentVariables="$SUREFIRE_ENV" \
              "$@"
          else
            exec ${pkgs.maven}/bin/mvn "$@"
          fi
        '';
      in
      {
        formatter = pkgs.nixpkgs-fmt;

        devShells.default = pkgs.mkShell {
          buildInputs = (with pkgs; [
            # Build tools
            jdk17
            
            # GTK/UI runtime dependencies (SWT JAR comes from Maven)
            gtk3
            cairo
            webkitgtk_4_1
            gdk-pixbuf
            librsvg
            
            # Theme and icon support
            gsettings-desktop-schemas
            adwaita-icon-theme
            hicolor-icon-theme
            shared-mime-info
            
            # Desktop integration
            xdg-user-dirs
            
            # For running GUI tests in headless mode
            xvfb-run
            xorg.xorgserver
          ]) ++ [
            # Wrapped maven with path setup
            mavenWrapped
          ];

          shellHook = ''
            # Set up library paths - GTK libs for SWT native libraries to link against
            export LD_LIBRARY_PATH="${libraryPath}:''${LD_LIBRARY_PATH:-}"
            
            # SWT extracts native libraries to ~/.swt/lib/linux/x86_64/ automatically
            SWT_EXTRACT_DIR="$HOME/.swt/lib/linux/x86_64"
            mkdir -p "$SWT_EXTRACT_DIR"
            
            # Remove broken symlinks (from old nixpkgs SWT package) so Maven can extract fresh libs
            find "$SWT_EXTRACT_DIR" -type l ! -exec test -e {} \; -delete 2>/dev/null || true
            
            # Java library path - SWT will extract libs here, they need GTK via LD_LIBRARY_PATH
            JAVA_LIB_PATH="$SWT_EXTRACT_DIR:${pkgs.gtk3}/lib:${pkgs.cairo}/lib"
            export _JAVA_OPTIONS="-Djava.library.path=$JAVA_LIB_PATH"
            export MAVEN_OPTS="-Djava.library.path=$JAVA_LIB_PATH"
            
            # GTK configuration
            export GSETTINGS_SCHEMA_DIR="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas/"
            export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share:${pkgs.gtk3}/share:${pkgs.shared-mime-info}/share:${pkgs.hicolor-icon-theme}/share:''${XDG_DATA_DIRS:-}"
            export SWT_GTK3=1
            export GTK_PATH="${pkgs.gtk3}/lib/gtk-3.0"
            export GDK_PIXBUF_MODULE_FILE="${pkgs.librsvg}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache"
            
            echo "========================================="
            echo "Okapi Development Environment"
            echo "========================================="
            echo "Java: $(java -version 2>&1 | head -1)"
            echo "Maven: $(mvn -version | head -1)"
            echo "SWT: ✓ Maven will extract libraries to ~/.swt/lib/linux/x86_64/"
            echo "========================================="
          '';
        };
      }
    );
}
