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
    buildInputs = [ pkgs.jetbrains.jdk-no-jcef-17 ];

    installPhase = ''
            # Create destination directory
            mkdir -p $out/opt/oxygen-xml-developer
      
            # Extract the tarball with verbose output and error checking
            echo "Extracting tarball..."
            tar xzvf $src -C $out/opt/oxygen-xml-developer --strip-components=1

            # Check if extraction succeeded
            if [ ! -f $out/opt/oxygen-xml-developer/oxygenDeveloper.sh ]; then
              echo "Error: Failed to extract oxygenDeveloper script"
              exit 1
            fi
      
            # Create a wrapper script that uses JDK 17
            mv $out/opt/oxygen-xml-developer/oxygenDeveloper.sh $out/opt/oxygen-xml-developer/oxygenDeveloper.sh.orig
      
            # Modify the original script to use 16GB heap instead of 1GB
            sed 's/-Xmx1g\\/-Xmx16g\\/g' $out/opt/oxygen-xml-developer/oxygenDeveloper.sh.orig > $out/opt/oxygen-xml-developer/oxygenDeveloper.sh.modified
            chmod +x $out/opt/oxygen-xml-developer/oxygenDeveloper.sh.modified
      
            cat > $out/opt/oxygen-xml-developer/oxygenDeveloper.sh << EOF
      #!/bin/sh
      # Wrapper script to ensure Oxygen uses JDK 17 with 16GB heap

      # Force use of JDK 17
      OXYGEN_JAVA="${pkgs.jetbrains.jdk-no-jcef-17}/bin/java"
      export JAVA_HOME="${pkgs.jetbrains.jdk-no-jcef-17}"

      # Call the modified original script with all arguments
      exec "\$0.modified" "\$@"
      EOF
            chmod +x $out/opt/oxygen-xml-developer/oxygenDeveloper.sh
      
            # Create icon directory
            mkdir -p $out/share/icons/hicolor/128x128/apps
      
            # Copy icon file if it exists
            if [ -f $out/opt/oxygen-xml-developer/Developer128.png ]; then
              cp $out/opt/oxygen-xml-developer/Developer128.png $out/share/icons/hicolor/128x128/apps/oxygen-xml-developer.png
            else
              echo "Warning: Developer128.png not found, looking for alternatives..."
              find $out/opt/oxygen-xml-developer -name "*.ico" -o -name "*.png" | head -n 1 | xargs -I{} cp {} $out/share/icons/hicolor/128x128/apps/oxygen-xml-developer.png
            fi
      
            # Create desktop entry directory
            mkdir -p $out/share/applications
            cat > $out/share/applications/oxygen-xml-developer.desktop << EOF
            [Desktop Entry]
            Name=Oxygen XML Developer
            Comment=XML Development Environment
            Exec=$out/opt/oxygen-xml-developer/oxygenDeveloper.sh
            Icon=$out/share/icons/hicolor/128x128/apps/oxygen-xml-developer.png
            Terminal=false
            Type=Application
            Categories=Development;IDE;XML;
            StartupNotify=true
            EOF
    '';
  };
in
{
  home.packages = [ oxygen-xml-developer ];
  home.file.".oxygen-xml-developer-profile".text = ''
    export PATH=$PATH:${oxygen-xml-developer.out}/opt/oxygen-xml-developer
  '';

  # Link desktop file to user applications directory
  home.file.".local/share/applications/oxygen-xml-developer.desktop".source =
    "${oxygen-xml-developer}/share/applications/oxygen-xml-developer.desktop";
}
