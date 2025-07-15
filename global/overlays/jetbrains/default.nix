self: super: let
  inherit (super.lib) overrideDerivation;

  jdk17 = super.jdk17;
  jdk21 = super.jdk21;

in {
  jetbrains = super.jetbrains // {
    jdk = overrideDerivation super.jetbrains.jdk (old: {
      buildInputs = (old.buildInputs or []) ++ [jdk21];
      outputs = [ "out" ];
      patchPhase = ''
        runHook prePatch
        echo "export BOOT_JDK=${jdk21}; configureFlags=" | cat - jb/project/tools/linux/scripts/mkimages_x64.sh > temp && mv temp jb/project/tools/linux/scripts/mkimages_x64.sh
        chmod +x jb/project/tools/linux/scripts/mkimages_x64.sh
        ${old.patchPhase or ""}
        runHook postPatch
      '';
    });

    "jdk-no-jcef-17" = overrideDerivation super.jetbrains."jdk-no-jcef-17" (old: {
      buildInputs = (old.buildInputs or []) ++ [jdk17];
      outputs = [ "out" ];
      patchPhase = ''
        runHook prePatch
        echo "export BOOT_JDK=${jdk17}; configureFlags=" | cat - jb/project/tools/linux/scripts/mkimages_x64.sh > temp && mv temp jb/project/tools/linux/scripts/mkimages_x64.sh
        chmod +x jb/project/tools/linux/scripts/mkimages_x64.sh
        ${old.patchPhase or ""}
        runHook postPatch
      '';
    });

    jdk-jcef = overrideDerivation super.jetbrains.jdk-jcef (old: {
      buildInputs = (old.buildInputs or []) ++ [jdk21];
      outputs = [ "out" ];
      patchPhase = ''
        runHook prePatch
        echo "export BOOT_JDK=${jdk21}; configureFlags=" | cat - jb/project/tools/linux/scripts/mkimages_x64.sh > temp && mv temp jb/project/tools/linux/scripts/mkimages_x64.sh
        chmod +x jb/project/tools/linux/scripts/mkimages_x64.sh
        ${old.patchPhase or ""}
        runHook postPatch
      '';
    });
  };
}
