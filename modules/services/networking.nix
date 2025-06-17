{ lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    networkmanager
    networkmanager-openvpn
    wireguard-tools
  ];

  systemd.services.systemd-resolved.environment = with lib; {
    LD_LIBRARY_PATH = "${getLib pkgs.libidn2}/lib:$LD_LIBRARY_PATH";
  };

  networking.wireguard.enable = true;

  networking = {
    firewall = {
      enable = true;
      checkReversePath = "loose";
      allowedTCPPorts = [
        80
        443
        53
      ];
      allowedUDPPorts = [
        53
        51820
      ];
      # Trust traffic from the PIA interface
      extraCommands = ''
        iptables -A INPUT -i wgpia+ -j ACCEPT
      '';
    };

    hostName = "datalore";
    domain = "local";
    networkmanager = {
      enable = true;
    };
    # Set the system's DNS resolver to our local unbound instance.
    nameservers = [ "192.168.50.1" ];
  };

  networking.timeServers = [ "pool.ntp.org" ];

}
