{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    update-systemd-resolved
  ];
  services.resolved.enable = true;

  networking.networkmanager.dispatcherScripts = [
  {
    source = "${pkgs.update-systemd-resolved}/libexec/nm-openvpn-service-resolved-update";
    type = "basic";
  }
];
}
