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

  networking = {
    wireguard.enable = true;
    
    firewall = {
      enable = true;
      checkReversePath = false;
      allowedTCPPorts = [
        80
        443
        53
      ];
      allowedUDPPorts = [
        53
        51820
        1317 # PIA client additional UDP port
      ];
      # Trust traffic from the PIA interface and allow DNS and PIA communication
      extraCommands = ''
        iptables -A INPUT -i wgpia+ -j ACCEPT
        iptables -A OUTPUT -o wgpia+ -p udp --dport 53 -j ACCEPT
        iptables -A OUTPUT -o wgpia+ -p udp --dport 1317 -j ACCEPT
      '';
    };

    networkmanager = {
      enable = true;
      dns = "systemd-resolved"; # Let NetworkManager manage DNS dynamically
    };
  };

  services.resolved = {
    enable = true;
    dnssec = "allow-downgrade"; # Compatible with PIA's DNS
    fallbackDns = [
      "192.168.50.1" # Router DNS
      "1.1.1.1"      # Cloudflare DNS
      "1.0.0.1"      # Cloudflare DNS
    ];
  };

  networking.timeServers = [ "pool.ntp.org" ];
}
