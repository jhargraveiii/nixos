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
    ../global/configuration.nix
    ./hardware-configuration.nix
    ./amd.nix
    ./displaymanager.nix
    ../modules/services/tuxflow.nix
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
  powerManagement.enable = true;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };

  hardware.bluetooth.powerOnBoot = false;
  services.blueman.enable = false;

  environment.sessionVariables = {
    CMAKE_ARGS = "-DGGML_BLAS=ON -DGGML_BLAS_VENDOR=FLAME -DGGML_CUDA=off";

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

  services.ollama = {
    enable = true;
    user = "ollama-service";
    group = "ollama-service";
    acceleration = null;
  };

  services.tuxflow = {
    enable = true;
    model = "small";
    ai = {
      enable = true;
      model = "llama3.2";
    };
  };

  system.stateVersion = "24.05";
}
