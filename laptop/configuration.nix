# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs
, nixos-hardware
, username
, gitUsername
, theLocale
, theTimezone
, outputs
, theKBDLayout
, inputs
, system
, ...
}:
{
  imports = [
    #inputs.ucodenix.nixosModules.default
    ../global/configuration.nix
    ./hardware-configuration.nix
    ./amd.nix
    ./displaymanager.nix
  ];

  # # AMD microcode flake
  # services.ucodenix = {
  #   enable = true;
  #   # cpuid -1 -l 1 -r | sed -n 's/.*eax=0x\([0-9a-f]*\).*/\U\1/p'
  #   cpuModelId = "00A70F52";
  # };

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

  environment.sessionVariables = {
    CMAKE_ARGS = "-DGGML_BLAS=ON -DGGML_BLAS_VENDOR=FLAME -DGGML_CUDA=off";

    # Extend PATH
    PATH = [
    ];

    # Set library paths
    LD_LIBRARY_PATH = [
      "${pkgs.amd-blis}/lib"
      "${pkgs.amd-libflame}/lib"
    ];

    LIBRARY_PATH = [
      "${pkgs.amd-blis}/lib"
      "${pkgs.amd-libflame}/lib"
    ];

    CPATH = [
      "${pkgs.amd-blis}/include"
      "${pkgs.amd-libflame}/include"
    ];
  };

  system.stateVersion = "24.05";
}
