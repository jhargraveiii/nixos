{ pkgs, lib, ... }:
{
  systemd.services.ollama.serviceConfig.DynamicUser = lib.mkForce false;

  users.users.ollama = {
    isSystemUser = true;
    home = lib.mkDefault "/home/jimh/DATA2/ollama";
    description = "Ollama Service User";
    group = "ollama";
    extraGroups = [ ];
  };
  users.groups.ollama = { };

  services.ollama = {
    enable = true;
    environmentVariables = {
      LD_LIBRARY_PATH = "${pkgs.cudaPackages.cudatoolkit}/lib:${pkgs.cudaPackages.cudatoolkit}/lib64:${pkgs.amd-blis}/lib:${pkgs.amd-libflame}/lib:$LD_LIBRARY_PATH";
      LIBRARY_PATH = "${pkgs.cudaPackages.cudatoolkit}/lib:${pkgs.cudaPackages.cudatoolkit}/lib64:${pkgs.amd-blis}/lib:${pkgs.amd-libflame}/lib:$LIBRARY_PATH";
      CPATH = "${pkgs.amd-blis}/lib:${pkgs.amd-libflame}/lib:$CPATH";
      OLLAMA_LLM_LIBRARY = "cuda_v12";
      OLLAMA_MAX_VRAM = "11994000000";
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_NUM_PARALLEL = "2";
    };
    acceleration = "cuda";
    user = "ollama";
    group = "ollama";
    home = "/home/jimh/DATA2/ollama";
    models = "/home/jimh/DATA2/ollama/models";
  };
}
