{ pkgs, lib, buildEnv, ... }:
let ollamaOptimized = pkgs.callPackage ../../packages/ollama/ollama.nix { };
in {
  environment.systemPackages = with pkgs; [ ollamaOptimized ];
  systemd.services.ollama.serviceConfig.DynamicUser = lib.mkForce false;

  services.ollama = {
    enable = true;
    package = ollamaOptimized;
    environmentVariables = {
      LLAMA_BLAS_VENDOR="FLAME";
      BLAS_LIBRARIES="${pkgs.amd-blis}/lib/libblis-mt.so";
      BLAS_INCLUDE_DIRS="${pkgs.amd-blis}/include/blis";
      LD_LIBRARY_PATH ="${pkgs.amd-blis}/lib:${pkgs.amd-libflame}/lib:${pkgs.cudaPackages.tensorrt}/lib:$LD_LIBRARY_PATH";
      #OLLAMA_LLM_LIBRARY = "cpu";
      OLLAMA_LLM_LIBRARY = "cuda_v12";
      OLLAMA_MAX_VRAM = "11796917760";
    };
    acceleration = "cuda";
    home = "/home/jimh/DATA2/ollama";
    models = "/home/jimh/DATA2/ollama/models";
  };
}
