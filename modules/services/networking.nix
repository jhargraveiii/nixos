{ lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    networkmanager
    networkmanager-openvpn
    wireguard-tools
    update-systemd-resolved
  ];

  systemd.services.systemd-resolved.environment = with lib; {
    LD_LIBRARY_PATH = "${getLib pkgs.libidn2}/lib:$LD_LIBRARY_PATH";
  };

  networking = {
    firewall = {
      enable = true;
      checkReversePath = "loose";
      allowedTCPPorts = [
        80
        443
      ];
    };

    networkmanager = {
      enable = true;
    };
  };

  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = [ "~." ];
    fallbackDns = [
      "1.1.1.1"
      "1.0.0.1"
    ];
  };

  networking.timeServers = [ "pool.ntp.org" ];

}
