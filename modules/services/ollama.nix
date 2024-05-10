{ pkgs, lib, buildEnv, ... }:
let ollamaOptimized = pkgs.callPackage ../../packages/ollama/ollama.nix { };
in {
  systemd.services.ollama.serviceConfig.DynamicUser = lib.mkForce false;

  environment.systemPackages = with pkgs; [ ollamaOptimized ];

  services.ollama = {
    enable = true;
    package = ollamaOptimized;
    acceleration = "cuda";
    home = "/home/jimh/DATA2/ollama";
    models = "/home/jimh/DATA2/ollama/models";
  };
}
