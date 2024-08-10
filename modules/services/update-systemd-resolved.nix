{ lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    update-systemd-resolved
    networkmanager
    networkmanager-openvpn
  ];

  services.resolved = {
    enable = true;
    fallbackDns = [
      "1.1.1.1"
      "8.8.8.8"
      "2001:4860:4860::8844"
    ];
  };

  networking.networkmanager = {
    enable = true;
  };
}
