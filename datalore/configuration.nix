{
  pkgs,
  username,
  gitUsername,
  theLocale,
  theTimezone,
  outputs,
  theKBDLayout,
  inputs,
  system,
  lib,
  config,
  ...
}:
{
  nixpkgs = {
    overlays = [
      outputs.overlays.cuda-override
    ];
  };

  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../global/configuration.nix
    ./amd.nix
    ./nvidia.nix
    ./displaymanager.nix
    ../modules/services/networking.nix
    ../modules/services/flatpak.nix
    ../modules/programs/distrobox.nix
  ];

  networking.hostName = "datalore";

  environment.plasma6.excludePackages =
    with pkgs.kdePackages;
    [
    ];

  environment.systemPackages = with pkgs; [
    nvtopPackages.full
    ollama-cuda
    llama-cpp
    cargo
  ];

  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  system.stateVersion = "23.11";
}
