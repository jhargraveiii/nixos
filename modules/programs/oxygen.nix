{ pkgs, ... }:

let
  oxygen-xml-developer = pkgs.stdenv.mkDerivation {
    pname = "oxygen-xml-developer";
    version = "24.1";

    src = pkgs.fetchurl {
      url = "https://archives.oxygenxml.com/Oxygen/Developer/InstData24.1/All/oxygenDeveloper.tar.gz?_gl=1*haxz4s*_ga*MjEzMTczOTU3MC4xNzA2ODE1NTc1*_ga_CKSFNYE9EY*MTcwNjgxNTU3NS4xLjEuMTcwNjgxNTYwMS4zNC4wLjA.*_ga_HEWSDXWJSN*MTcwNjgxNTU3NS4xLjEuMTcwNjgxNTYwMS4wLjAuMA..";
      sha256 = "78f6fe7dc6bf7d3205b6d711de9d976c14fcbbdf2bac0a6ec051be20d071ab83";
    };

    nativeBuildInputs = [ pkgs.makeWrapper ];
    buildInputs = [ pkgs.temurin-jre-bin-17 ];

    installPhase = ''
      runHook preInstall

      # Create destination directory
      mkdir -p $out/opt/oxygen-xml-developer
      mkdir -p $out/bin

      # Extract the tarball
      echo "Extracting tarball..."
      tar xzf $src -C $out/opt/oxygen-xml-developer --strip-components=1

      # Check if extraction succeeded
      if [ ! -f $out/opt/oxygen-xml-developer/oxygenDeveloper.sh ]; then
        echo "Error: Failed to extract oxygenDeveloper script"
        exit 1
      fi

      # Modify the original script to use 16GB heap instead of 1GB
      sed -i 's/-Xmx1g/-Xmx16g/g' $out/opt/oxygen-xml-developer/oxygenDeveloper.sh
      chmod +x $out/opt/oxygen-xml-developer/oxygenDeveloper.sh

      # Create wrapper script using makeWrapper (handles permissions properly)
      makeWrapper $out/opt/oxygen-xml-developer/oxygenDeveloper.sh $out/bin/oxygen-xml-developer \
        --set JAVA_HOME "${pkgs.temurin-jre-bin-17}" \
        --prefix PATH : "${pkgs.temurin-jre-bin-17}/bin"

      # Create icon directory and copy icon
      mkdir -p $out/share/icons/hicolor/128x128/apps
      if [ -f $out/opt/oxygen-xml-developer/Developer128.png ]; then
        cp $out/opt/oxygen-xml-developer/Developer128.png $out/share/icons/hicolor/128x128/apps/oxygen-xml-developer.png
      else
        echo "Warning: Developer128.png not found, looking for alternatives..."
        find $out/opt/oxygen-xml-developer -name "*.png" -type f | head -n 1 | xargs -I{} cp {} $out/share/icons/hicolor/128x128/apps/oxygen-xml-developer.png || true
      fi

      runHook postInstall
    '';
  };
in
{
  home.packages = [ oxygen-xml-developer ];
  home.file.".oxygen-xml-developer-profile".text = ''
    export PATH=$PATH:${oxygen-xml-developer}/bin
  '';

  # Copy icon to local icons directory so KDE can find it
  home.file.".local/share/icons/hicolor/128x128/apps/oxygen-xml-developer.png".source =
    "${oxygen-xml-developer}/share/icons/hicolor/128x128/apps/oxygen-xml-developer.png";

  # Write desktop file directly (symlinks can cause issues with some desktop environments)
  home.file.".local/share/applications/oxygen-xml-developer.desktop" = {
    text = ''
      [Desktop Entry]
      Name=Oxygen XML Developer
      Comment=XML Development Environment
      Exec=${oxygen-xml-developer}/bin/oxygen-xml-developer
      Icon=oxygen-xml-developer
      Terminal=false
      Type=Application
      Categories=Development;IDE;XML;
      StartupNotify=true
    '';
    executable = true;
  };
}
