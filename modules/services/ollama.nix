{ pkgs, lib, ... }:
let
  ollamaOverride = pkgs.ollama.overrideAttrs
    (oldAttrs: rec {
      COMMON_CMAKE_DEFS =
        "-DCMAKE_POSITION_INDEPENDENT_CODE=on -DLLAMA_NATIVE=on -DLLAMA_AVX=on -DLLAMA_AVX2=on -DLLAMA_AVX512=off -DLLAMA_FMA=on -DLLAMA_F16C=on";
      NIX_CFLAGS_COMPILE = "-O3 -march=znver3 -mtune=znver3";
    });
in
{
  systemd.services.ollama.serviceConfig.DynamicUser = lib.mkForce false;

  environment.systemPackages = with pkgs; [ ollamaOverride ];

  services.ollama = {
    enable = true;
    package = ollamaOverride;
    acceleration = "cuda";
    home = "/home/jimh/DATA2/ollama";
    models = "/home/jimh/DATA2/ollama/models";
  };
}
