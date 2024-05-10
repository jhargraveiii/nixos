{ pkgs, lib, buildEnv, ... }:
let ollamaOptimized = pkgs.callPackage ../../packages/ollama/ollama.nix { };
in {
  environment.systemPackages = with pkgs; [ ollamaOptimized ];

  services.ollama = {
    enable = true;
    package = ollamaOptimized;
    environmentVariables = {
      OLLAMA_LLM_LIBRARY = "cpu_avx2";
      OLLAMA_NUM_THREADS = "18";
    };
    acceleration = "cuda";
    home = "/home/jimh/DATA2/ollama";
    models = "/home/jimh/DATA2/ollama/models";
  };
}
