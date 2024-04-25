{ pkgs, lib, ... }: {
  systemd.services.ollama.serviceConfig.DynamicUser = lib.mkForce false;
  environment.systemPackages = with pkgs; [ ollama ];
  services.ollama = {
    environmentVariables = {
       COMMON_CMAKE_DEFS =
        "-DLLAMA_NATIVE=on -DLLAMA_AVX=on -DLLAMA_AVX2=on -DLLAMA_FMA=on";
    };
    enable = true;
    acceleration = "cuda";
    home = "/home/jimh/DATA2/ollama";
    models = "/home/jimh/DATA2/ollama/models";
  };
}
