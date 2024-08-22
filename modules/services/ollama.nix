{ pkgs, lib, ... }:
{
  systemd.services.ollama.serviceConfig = {
    DynamicUser = lib.mkForce false;
    WorkingDirectory = "/home/jimh/DATA2/ollama";
  };

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
    };
    acceleration = "cuda";
    user = "ollama";
    group = "ollama";
    home = "/home/jimh/DATA2/ollama";
    models = "/home/jimh/DATA2/ollama/models";
  };
}
