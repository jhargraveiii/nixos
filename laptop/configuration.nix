# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  pkgs,
  nixos-hardware,
  username,
  gitUsername,
  theLocale,
  theTimezone,
  outputs,
  theKBDLayout,
  inputs,
  system,
  ...
}:
{
  imports = [
    ../global/configuration.nix
    ./hardware-configuration.nix
    ./amd.nix
    ./displaymanager.nix
    ../modules/services/networking.nix
    ../modules/services/flatpak.nix
    ../modules/programs/distrobox.nix
  ];

  networking.hostName = "datalore_laptop";

  environment.systemPackages = with pkgs; [
    kdePackages.wacomtablet
    iio-sensor-proxy
    onboard # On-screen keyboard
  ];

  # Start fingerprint service
  services.fprintd.enable = true;

  networking.networkmanager.wifi.powersave = true;

  services.power-profiles-daemon.enable = true;
  powerManagement.powertop.enable = true;
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
  };

  hardware.bluetooth.powerOnBoot = false;
  services.blueman.enable = false;

  system.stateVersion = "24.05";
}
