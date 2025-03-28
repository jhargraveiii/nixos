{ pkgs, lib, ... }:

let
  pia-client = pkgs.stdenv.mkDerivation rec {
    pname = "pia-client";
    version = "3.6.1-08339";
    src = pkgs.fetchurl {
      url = "https://installers.privateinternetaccess.com/download/pia-linux-${version}.run";
      sha256 = "sha256-bxTGPHt/vF50guovtCOBr63m3IvPmBZjKBOt+hEsphM=";
    };

    dontUnpack = true;
    dontPatchELF = true; # We'll handle this manually

    nativeBuildInputs = [
      pkgs.makeWrapper
      pkgs.binutils
      pkgs.patchelf
      pkgs.qt6.wrapQtAppsHook
    ];

    buildInputs = [
      pkgs.glibc
      pkgs.stdenv.cc.cc.lib # This provides libstdc++
      pkgs.glib
      pkgs.openssl
      # Qt6 components needed
      pkgs.qt6.qtbase
      pkgs.qt6.qtnetworkauth
      pkgs.qt6.qtsvg
      pkgs.qt6.qt3d
      pkgs.qt6.qtquick3d
      pkgs.qt6.qtquicktimeline
      pkgs.qt6.qtvirtualkeyboard
      pkgs.qt6.qtwayland
      pkgs.qt6.qtdeclarative
      pkgs.qt6.qtshadertools

      pkgs.gtk3
      pkgs.libsecret
      pkgs.libappindicator
      pkgs.nss
      pkgs.xorg.libXScrnSaver
      pkgs.xorg.libX11
      pkgs.xorg.libXext
      pkgs.xorg.libXrender
      pkgs.xorg.libXtst
      pkgs.xorg.libXau
      pkgs.xorg.libXdmcp
      pkgs.curl
      pkgs.dpkg
    ];

    installPhase = ''
            # Create a temporary working directory
            WORKDIR=$(mktemp -d)
            cd "$WORKDIR"

            # Copy installer to temporary location and make executable
            install -D -m755 "$src" "$WORKDIR/pia-installer.run"

            # Execute the makeself installer with required flags
            "$WORKDIR/pia-installer.run" \
              --noexec \
              --accept \
              --nox11 \
              --quiet \
              --target "$WORKDIR/pia-install"

            # Create output directories
            mkdir -p "$out/opt/pia"
            mkdir -p "$out/bin"

            # Move installed files to output directory
            cp -r "$WORKDIR/pia-install/"* "$out/opt/pia"

            # Find the actual main executable - likely in piafiles/bin
            MAIN_EXEC=$(find "$out/opt/pia" -name "pia-client" -type f -executable 2>/dev/null || echo "")
      
            # If pia-client doesn't exist, try other possible names
            if [ -z "$MAIN_EXEC" ]; then
              MAIN_EXEC=$(find "$out/opt/pia" -name "pia" -type f -executable 2>/dev/null || echo "")
            fi
      
            # If still not found, look for any plausible main executable
            if [ -z "$MAIN_EXEC" ]; then
              MAIN_EXEC=$(find "$out/opt/pia/piafiles/bin" -type f -executable -not -name "*.sh" | head -n 1)
            fi

            # Set up additional library paths
            LIB_PATHS="\
            ${pkgs.stdenv.cc.cc.lib}/lib:\
            ${pkgs.glib}/lib:\
            ${pkgs.openssl}/lib:\
            ${pkgs.gtk3}/lib:\
            ${pkgs.libsecret}/lib:\
            ${pkgs.libappindicator}/lib:\
            ${pkgs.nss}/lib:\
      
            ${pkgs.xorg.libXScrnSaver}/lib:\
            ${pkgs.xorg.libX11}/lib:\
            ${pkgs.xorg.libXext}/lib:\
            ${pkgs.xorg.libXrender}/lib:\
            ${pkgs.xorg.libXtst}/lib:\
            ${pkgs.xorg.libXau}/lib:\
            ${pkgs.xorg.libXdmcp}/lib:\
            ${pkgs.curl}/lib:\
            ${pkgs.qt6.qtbase}/lib:\
            ${pkgs.qt6.qtsvg}/lib:\
            ${pkgs.qt6.qt3d}/lib:\
            ${pkgs.qt6.qtquick3d}/lib:\
            ${pkgs.qt6.qtquicktimeline}/lib:\
            ${pkgs.qt6.qtvirtualkeyboard}/lib:\
            ${pkgs.qt6.qtwayland}/lib:\
            ${pkgs.qt6.qtdeclarative}/lib:\
            ${pkgs.qt6.qtshadertools}/lib:\
            $out/opt/pia/piafiles/lib:\
            $out/opt/pia/lib"

            # Remove existing symlinks
            rm -f "$out/opt/pia/piafiles/lib/libssl.so.3" "$out/opt/pia/piafiles/lib/libssl.so" || true
            rm -f "$out/opt/pia/piafiles/lib/libcrypto.so.3" "$out/opt/pia/piafiles/lib/libcrypto.so" || true

            # First find the correct OpenSSL library path
            OPENSSL_LIBS=$(find ${pkgs.openssl}/lib -name "libssl.so*" -type f -o -type l | head -n 1 || echo "")

            if [ -n "$OPENSSL_LIBS" ]; then
              OPENSSL_DIR=$(dirname "$OPENSSL_LIBS")
              echo "Found OpenSSL libraries at: $OPENSSL_DIR"
              
              # Create symlinks to the actual files
              ln -sf "$OPENSSL_DIR/libssl.so.3" "$out/opt/pia/piafiles/lib/libssl.so.3" || true
              ln -sf "$out/opt/pia/piafiles/lib/libssl.so.3" "$out/opt/pia/piafiles/lib/libssl.so" || true
              
              ln -sf "$OPENSSL_DIR/libcrypto.so.3" "$out/opt/pia/piafiles/lib/libcrypto.so.3" || true  
              ln -sf "$out/opt/pia/piafiles/lib/libcrypto.so.3" "$out/opt/pia/piafiles/lib/libcrypto.so" || true
            else
              echo "Warning: Could not find OpenSSL libraries"
            fi

            # Create a wrapper script
            if [ -n "$MAIN_EXEC" ]; then
              echo "Found main executable: $MAIN_EXEC"
              makeWrapper "$MAIN_EXEC" "$out/bin/pia" \
                --prefix LD_LIBRARY_PATH : "$LIB_PATHS" \
                --set QT_PLUGIN_PATH "$out/opt/pia/piafiles/plugins:${pkgs.qt6.qtbase}/lib/qt-6/plugins:${pkgs.qt6.qtwayland}/lib/qt-6/plugins" \
                --set QML2_IMPORT_PATH "$out/opt/pia/piafiles/qml:${pkgs.qt6.qtdeclarative}/lib/qt-6/qml" \
                --set QML_IMPORT_PATH "$out/opt/pia/piafiles/qml:${pkgs.qt6.qtdeclarative}/lib/qt-6/qml"
            else
              echo "Warning: couldn't find the main PIA executable"
              echo "Available files in opt/pia:"
              find "$out/opt/pia" -type f -executable | sort
            fi
      
            # Patch all ELF binaries with the interpreter and RPATH
            find "$out/opt/pia" -type f -executable -print0 | while IFS= read -r -d $'\0' file; do
              if [[ "$(file -b "$file")" == *ELF* ]]; then
                echo "Patching $file"
          
                # Set interpreter
                patchelf --set-interpreter "$(cat "$NIX_CC/nix-support/dynamic-linker")" "$file" || true
          
                # Force add all the library paths
                patchelf --force-rpath --set-rpath "$LIB_PATHS" "$file" || true
              fi
            done

            # Handle libraries separately
            find "$out/opt/pia" -name "*.so*" -print0 | while IFS= read -r -d $'\0' file; do
              if [[ "$(file -b "$file")" == *ELF* ]]; then
                echo "Patching library $file"
                patchelf --force-rpath --set-rpath "$LIB_PATHS" "$file" || true
              fi
            done

            # Create desktop entry
            mkdir -p "$out/share/applications"
            cat > "$out/share/applications/pia-client.desktop" <<EOF
            [Desktop Entry]
            Version=1.0
            Type=Application
            Name=Private Internet Access
            Exec=$out/bin/pia
            Icon=security-high
            Categories=Network;Security;
            EOF
    '';

    meta = {
      description = "Private Internet Access VPN Client";
      homepage = "https://www.privateinternetaccess.com";
      license = lib.licenses.unfree;
      platforms = [ "x86_64-linux" ];
    };
  };
in
{
  home.packages = [ pia-client ];
  home.sessionPath = [ "${pia-client}/bin" ];
}
