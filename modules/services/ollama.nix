{ pkgs, lib, ... }: {
  systemd.services.ollama.serviceConfig.DynamicUser = lib.mkForce false;
  environment.systemPackages = with pkgs; [ oterm ollama ];
  services.ollama = {
    enable = true;
    environmentVariables = {
      COMMON_CMAKE_DEFS =
        "-DCMAKE_POSITION_INDEPENDENT_CODE=on -DLLAMA_NATIVE=off -DLLAMA_AVX=on -DLLAMA_AVX2=on -DLLAMA_AVX512=off -DLLAMA_FMA=on -DLLAMA_F16C=on";
    };
    acceleration = "cuda";
    home = "/home/jimh/DATA2/ollama";
    models = "/home/jimh/DATA2/ollama/models";
  };
}
