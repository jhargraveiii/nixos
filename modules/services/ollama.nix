{ pkgs, lib, ... }: {
  systemd.services.ollama.serviceConfig.DynamicUser = lib.mkForce false;
  environment.systemPackages = with pkgs; [ oterm ollama ];
  services.ollama = {
    enable = true;
    acceleration = "cuda";
    home = "/home/jimh/DATA2/ollama";
    models = "/home/jimh/DATA2/ollama/models";
  };
}
