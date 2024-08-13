{ lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    update-systemd-resolved
    networkmanager
    networkmanager-openvpn
  ];

  services.resolved = {
    enable = true;
  };

  networking.networkmanager = {
    enable = true;
  };
}
