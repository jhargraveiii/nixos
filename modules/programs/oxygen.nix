{ pkgs, ... }:

let
  oxygen-xml-developer = pkgs.stdenv.mkDerivation {
    pname = "oxygen-xml-developer";
    version = "24.1";

    src = pkgs.fetchurl {
      url = "https://archives.oxygenxml.com/Oxygen/Developer/InstData24.1/All/oxygenDeveloper.tar.gz?_gl=1*haxz4s*_ga*MjEzMTczOTU3MC4xNzA2ODE1NTc1*_ga_CKSFNYE9EY*MTcwNjgxNTU3NS4xLjEuMTcwNjgxNTYwMS4zNC4wLjA.*_ga_HEWSDXWJSN*MTcwNjgxNTU3NS4xLjEuMTcwNjgxNTYwMS4wLjAuMA..";
      sha256 = "78f6fe7dc6bf7d3205b6d711de9d976c14fcbbdf2bac0a6ec051be20d071ab83";
    };

    installPhase = ''
      mkdir -p $out/opt/oxygen-xml-developer
      tar xzvf $src -C $out/opt/oxygen-xml-developer --strip-components=1
    '';
  };
in
{
  home.packages = [ oxygen-xml-developer ];
  home.file.".oxygen-xml-developer-profile".text = ''
    export JAVA_HOME=/home/jimh/.jdks/openjdk21
    export OXYGEN_JAVA=/home/jimh/.jdks/openjdk21/bin/java
    export PATH=$PATH:${oxygen-xml-developer.out}/opt/oxygen-xml-developer
  '';
}
