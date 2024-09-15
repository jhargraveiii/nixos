{ lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    networkmanager
    networkmanager-openvpn
    update-systemd-resolved
  ];

  systemd.services.systemd-resolved.environment = with lib; {
    LD_LIBRARY_PATH = "${getLib pkgs.libidn2}/lib:$LD_LIBRARY_PATH";
  };

  services.openvpn.servers = {
    straker_vpn = {
      config = ''
        config /home/jimh/work/straker_vpn.ovpn
        auth-user-pass /home/jimh/work/auth.txt
        auth-nocache
        script-security 2
        up ${pkgs.update-systemd-resolved}/libexec/openvpn/update-systemd-resolved
        up-restart
        down ${pkgs.update-systemd-resolved}/libexec/openvpn/update-systemd-resolved
        down-pre
      '';
      autoStart = false;
    };
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
