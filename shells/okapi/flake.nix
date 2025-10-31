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
        
        # Create a wrapper with symlinks for SWT libraries
        # Note: RPATH patching doesn't work well with JNI libraries
        # We rely on LD_LIBRARY_PATH instead, set by the Maven wrapper
        swtLibs = pkgs.runCommand "swt-libs-wrapped" {} ''
          mkdir -p $out/lib
          
          # Copy all SWT libraries
          cp -L ${pkgs.swt}/lib/*.so $out/lib/
          
          # Create symlinks for different version naming patterns
          cd $out/lib
          for lib in libswt-*.so; do
            # Create generic symlinks without version suffix
            base=$(echo $lib | sed 's/-[0-9]*r[0-9]*\.so$//')
            ln -sf $lib $base.so
          done
          
          # Create symlinks for the specific version the tests expect
          for lib in libswt-*-4967r8.so; do
            newname=$(echo $lib | sed 's/4967r8/4969r18/')
            ln -sf $lib $newname
          done
        '';
        
        # Wrapper for maven that ensures LD_LIBRARY_PATH is set for forked processes
        # and configures Surefire to pass environment variables
        mavenWrapped = pkgs.writeShellScriptBin "mvn" ''
          export LD_LIBRARY_PATH="${swtLibs}/lib:${libraryPath}:''${LD_LIBRARY_PATH:-}"
          
          # Configure Surefire to pass LD_LIBRARY_PATH to forked JVMs
          # This is critical for SWT/GTK3 tests - both argLine AND environmentVariables
          export MAVEN_OPTS="''${MAVEN_OPTS:-} -Djava.library.path=${swtLibs}/lib:${pkgs.gtk3}/lib:${pkgs.cairo}/lib"
          
          # Surefire argLine for java.library.path
          SUREFIRE_ARG="-Djava.library.path=${swtLibs}/lib:${pkgs.gtk3}/lib:${pkgs.cairo}/lib"
          
          # Surefire environment variable configuration to pass LD_LIBRARY_PATH
          SUREFIRE_ENV_VAR="-DargLine=$SUREFIRE_ARG -Dsurefire.environmentVariables=LD_LIBRARY_PATH=${swtLibs}/lib:${libraryPath}"
          
          # Check if user provided custom configuration
          if [[ "$*" != *"-DargLine="* ]] && [[ "$*" != *"surefire.environmentVariables"* ]]; then
            # Add our configuration
            exec ${pkgs.maven}/bin/mvn $SUREFIRE_ENV_VAR "$@"
          else
            # User provided custom config, just run as-is
            exec ${pkgs.maven}/bin/mvn "$@"
          fi
        '';
        
        # Helper script for running tests with proper SWT/GTK3 configuration
        mvnTestScript = pkgs.writeShellScriptBin "mvn-test-swt" ''
          export LD_LIBRARY_PATH="${swtLibs}/lib:${libraryPath}:''${LD_LIBRARY_PATH:-}"
          export MAVEN_OPTS="-Djava.library.path=${swtLibs}/lib:${pkgs.gtk3}/lib:${pkgs.cairo}/lib"
          
          echo "Running Maven tests with SWT/GTK3 in headless mode (xvfb)..."
          exec ${pkgs.xvfb-run}/bin/xvfb-run -a ${pkgs.maven}/bin/mvn "$@" \
            -DargLine="-Djava.library.path=${swtLibs}/lib:${pkgs.gtk3}/lib:${pkgs.cairo}/lib" \
            -Dsurefire.environmentVariables=LD_LIBRARY_PATH="${swtLibs}/lib:${libraryPath}"
        '';
      in
      {
        formatter = pkgs.nixpkgs-fmt;

        devShells.default = pkgs.mkShell {
          buildInputs = (with pkgs; [
            # Build tools
            jdk17
            # maven - using wrapped version instead
            
            # GTK/UI runtime dependencies
            gtk3
            cairo
            webkitgtk_4_1
            swt
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
            # Wrapped maven with LD_LIBRARY_PATH set for forked processes
            mavenWrapped
            mvnTestScript
          ];

          shellHook = ''
            # Set up library paths for SWT native libraries (using wrapped SWT with symlinks)
            export LD_LIBRARY_PATH="${swtLibs}/lib:${libraryPath}:''${LD_LIBRARY_PATH:-}"
            
            # Java library path for SWT JNI (using wrapped SWT libs)
            export _JAVA_OPTIONS="-Djava.library.path=${swtLibs}/lib:${pkgs.gtk3}/lib:${pkgs.cairo}/lib"
            
            # Maven/Surefire needs to pass library path and LD_LIBRARY_PATH to forked JVMs
            export MAVEN_OPTS="-Djava.library.path=${swtLibs}/lib:${pkgs.gtk3}/lib:${pkgs.cairo}/lib"
            
            # Surefire argLine for forked test JVMs
            export MAVEN_ARGS="-DargLine=-Djava.library.path=${swtLibs}/lib:${pkgs.gtk3}/lib:${pkgs.cairo}/lib"
            
            # GTK configuration
            export GSETTINGS_SCHEMA_DIR="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas/"
            export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share:${pkgs.gtk3}/share:${pkgs.shared-mime-info}/share:${pkgs.hicolor-icon-theme}/share:''${XDG_DATA_DIRS:-}"
            
            # SWT configuration
            export SWT_GTK3=1
            
            # Ensure GTK can find its modules and libraries
            export GTK_PATH="${pkgs.gtk3}/lib/gtk-3.0"
            export GDK_PIXBUF_MODULE_FILE="${pkgs.librsvg}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache"
            
            echo "========================================="
            echo "Okapi Development Environment"
            echo "========================================="
            echo "Java: $(java -version 2>&1 | head -1)"
            echo "Maven: $(mvn -version | head -1)"
            echo ""
            echo "SWT/GTK3: ✓ Configured with library symlinks"
            echo ""
            echo "Commands:"
            echo "  mvn clean install -DskipTests"
            echo "    └─ Build without running tests (RECOMMENDED)"
            echo ""
            echo "  mvn clean install -Dmaven.test.skip=true"
            echo "    └─ Build, skip compilation & execution of tests"
            echo ""
            echo "Note: SWT/GTK3 GUI tests have known issues with"
            echo "Maven Surefire on NixOS due to forked JVM not"
            echo "inheriting LD_LIBRARY_PATH. Non-GUI tests work fine."
            echo ""
            echo "To fix GUI tests, add to module POM.xml:"
            echo '  <plugin><artifactId>maven-surefire-plugin</artifactId>'
            echo '    <configuration><forkMode>never</forkMode></configuration>'
            echo "  </plugin>"
            echo "========================================="
          '';
        };
      }
    );
}
