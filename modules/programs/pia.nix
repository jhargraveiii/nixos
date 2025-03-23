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
      pkgs.qt6.qtbase
      pkgs.qt6.qtnetworkauth
      pkgs.gtk3
      pkgs.libsecret
      pkgs.libappindicator
      pkgs.nss
      pkgs.xorg.libXScrnSaver
      pkgs.xorg.libX11
      pkgs.xorg.libXext
      pkgs.xorg.libXrender
      pkgs.xorg.libXtst
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

      # Create main executable symlink if we found something
      if [ -n "$MAIN_EXEC" ]; then
        echo "Found main executable: $MAIN_EXEC"
        ln -s "$MAIN_EXEC" "$out/bin/pia"
      else
        echo "Warning: couldn't find the main PIA executable"
        # Fall back to a known location (for debugging)
        echo "Available files in opt/pia:"
        find "$out/opt/pia" -type f -executable | sort
      fi

      # Manually patch executables to include the correct internal library paths
      find "$out/opt/pia" -type f -executable -print0 | while IFS= read -r -d $'\0' file; do
        if [[ "$(file -b "$file")" == *ELF* ]]; then
          echo "Patching $file"
          
          # Set interpreter
          patchelf --set-interpreter "$(cat "$NIX_CC/nix-support/dynamic-linker")" "$file" || true
          
          # Set RPATH to include the piafiles directory where the internal libraries are
          patchelf --set-rpath "$out/opt/pia/piafiles/lib:$out/opt/pia/piafiles:$out/opt/pia/lib:$out/opt/pia:$(patchelf --print-rpath "$file" 2>/dev/null || echo "")" "$file" || true
        fi
      done

      # Handle libraries separately - they don't need an interpreter but do need RPATH set
      find "$out/opt/pia" -name "*.so*" -print0 | while IFS= read -r -d $'\0' file; do
        if [[ "$(file -b "$file")" == *ELF* ]]; then
          echo "Patching library $file"
          
          # Set RPATH for libraries
          patchelf --set-rpath "$out/opt/pia/piafiles/lib:$out/opt/pia/piafiles:$out/opt/pia/lib:$out/opt/pia:$(patchelf --print-rpath "$file" 2>/dev/null || echo "")" "$file" || true
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