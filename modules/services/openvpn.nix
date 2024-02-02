{ config, pkgs, ... }:

{
  services.openvpn.servers = {
    pia-ca-montreal = {
      autoStart = false;
      config = ''
        config ${config.age.secrets.pia-ca-montreal.path}
        auth-user-pass ${config.home.homeDirectory}/.openvpn/secrets/pia-credentials
      '';
    };
    pia-guatemala = {
      autoStart = false;
      config = ''
        config ${config.age.secrets.pia-guatemala.path}
        auth-user-pass ${config.home.homeDirectory}/.openvpn/secrets/pia-credentials
      '';
    };
    pia-us-dc = {
      autoStart = false;
      config = ''
        config ${config.age.secrets.pia-us-dc.path}
        auth-user-pass ${config.home.homeDirectory}/.openvpn/secrets/pia-credentials
      '';
    };
    pia-us-virginia = {
      autoStart = false;
      config = ''
        config ${config.age.secrets.pia-us-virginia.path}
        auth-user-pass ${config.home.homeDirectory}/.openvpn/secrets/pia-credentials
      '';
    };
  };

  # Fetch and store 1Password credentials
  environment.systemPackages = with pkgs; [
    op
  ];

  systemd.services.fetch-openvpn-credentials = {
    wantedBy = [ "multi-user.target" ];
    script = ''
      op get item 'pia-credentials' | jq -r '.details.fields[] | "echo \(.t) > /etc/nixos/secrets/pia-credentials-\(.k)"' | sh
    '';
  };
}
