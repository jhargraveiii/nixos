{ pkgs, lib, ... }:
let
  ollamaOverride = pkgs.ollama.overrideAttrs (oldAttrs: rec {
    NIX_CFLAGS_COMPILE = "-O3 -march=native -mtune=native";
  });
in {
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
