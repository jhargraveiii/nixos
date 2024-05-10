{ pkgs, lib, buildEnv, ... }:
let ollamaOptimized = pkgs.callPackage ../../packages/ollama/ollama.nix { };
in {
  environment.systemPackages = with pkgs; [ ollamaOptimized ];
  systemd.services.ollama.serviceConfig.DynamicUser = lib.mkForce false;

  services.ollama = {
    enable = true;
    package = ollamaOptimized;
    environmentVariables = {
      OLLAMA_LLM_LIBRARY = "cuda_v12";
      OLLAMA_NUM_THREADS = "24";
    };
    acceleration = "cuda";
    home = "/home/jimh/DATA2/ollama";
    models = "/home/jimh/DATA2/ollama/models";
  };
}
