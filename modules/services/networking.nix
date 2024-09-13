{ lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    update-systemd-resolved
    networkmanager
    networkmanager-openvpn
  ];

  systemd.services.systemd-resolved.environment = with lib; {
    LD_LIBRARY_PATH = "${getLib pkgs.libidn2}/lib";
  };

  services.resolved = {
    enable = true;
  };

  networking.networkmanager = {
    enable = true;
  };

  # Open ports in the firewall.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      631
      53
    ];
    allowedUDPPorts = [
      5353
      111
    ];
  };

  networking.timeServers = [ "pool.ntp.org" ];

}
