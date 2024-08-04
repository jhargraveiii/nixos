{ pkgs }:
{
  services.ollama = {
    enable = true;
    environmentVariables = {
      LD_LIBRARY_PATH = "${pkgs.amd-blis}/lib:${pkgs.amd-libflame}/lib:${pkgs.cudaPackages.tensorrt}/lib:$LD_LIBRARY_PATH";
      LIBRARY_PATH = "${pkgs.amd-blis}/lib:${pkgs.amd-libflame}/lib:${pkgs.cudaPackages.tensorrt}/lib:$LIBRARY_PATH";
      CPATH = "${pkgs.amd-blis}/lib:${pkgs.amd-libflame}/lib:${pkgs.cudaPackages.tensorrt}/lib:$CPATH";
      OLLAMA_LLM_LIBRARY = "cuda_v12";
      OLLAMA_MAX_VRAM = "11796917760";
      OLLAMA_FLASH_ATTENTION = "1";
    };
    acceleration = "cuda";
  };
}
