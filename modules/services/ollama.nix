{ pkgs, ... }: {
  services.ollama = {
    enable = true;
    acceleration = "cuda";
  };
  environment.systemPackages = [ pkgs.oterm ];
}
