{ lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    networkmanager
    networkmanager-openvpn
    wireguard-tools
    socat
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
        22 # SSH
        25 # SMTP
        53 # DNS
        80 # HTTP
        110 # POP3
        143 # IMAP
        443 # HTTPS
        465 # SMTPS
        587 # Submission
        631 # CUPS
        993 # IMAPS
        995 # POP3S
        1194 # OpenVPN
        3389 # RDP
        5900 # VNC
        8080 # Alt HTTP
        8443 # Alt HTTPS
        51820 # PIA client additional TCP port
      ];
      allowedUDPPorts = [
        53 # DNS
        110 # POP3 / OpenVPN
        123 # NTP
        631 # CUPS
        1194 # OpenVPN
        1317 # PIA client additional UDP port
        1318 # PIA client additional UDP port
        1900 # UPnP
        5353 # mDNS/Bonjour
        51820 # WireGuard
        8080 # Alt HTTP / OpenVPN
        502 # OpenVPN
      ];
      # Trust traffic from the PIA interface and allow DNS and PIA communication
      extraCommands = ''
        iptables -A INPUT -i wgpia+ -j ACCEPT
        iptables -A OUTPUT -o wgpia+ -p udp --dport 53 -j ACCEPT
        iptables -A OUTPUT -o wgpia+ -p tcp --dport 53 -j ACCEPT
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
    # Don't hardcode DNS - let NetworkManager and PIA manage it dynamically
    # extraConfig = ''
    #   DNS = 192.168.50.1
    # '';
    fallbackDns = [
      "1.1.1.1" # Cloudflare DNS
      "1.0.0.1" # Cloudflare DNS
    ];
  };

  networking.timeServers = [ "pool.ntp.org" ];
}
