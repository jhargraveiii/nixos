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
  ];

  networking.hostName = "datalore-laptop";

  environment.systemPackages = with pkgs; [
    kdePackages.wacomtablet
    iio-sensor-proxy
    onboard # On-screen keyboard
  ];

  # Start fingerprint service
  services.fprintd.enable = true;

  networking.networkmanager.wifi.powersave = true;

  # Power Management - TLP (Best practices for Nov 2025)
  services.power-profiles-daemon.enable = false; # Disable conflicting service
  powerManagement.powertop.enable = false; # TLP handles this
  powerManagement.enable = true;

  services.tlp = {
    enable = true;
    settings = {
      # General Settings
      TLP_ENABLE = 1;
      TLP_DEFAULT_MODE = "BAT";
      TLP_PERSISTENT_DEFAULT = 0;

      # CPU Scaling (acpi-cpufreq via kernel params)
      CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
      CPU_SCALING_GOVERNOR_ON_BAT = "schedutil"; # schedutil is usually better than powersave for modern kernels

      # CPU Energy Performance (Intel/AMD P-state, though p-state is disabled in hw-config)
      # These might not apply if amd_pstate is disabled, but good to have if user enables it later
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      # Platform Profiles (if supported by firmware)
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      # AMD GPU
      RADEON_DPM_PERF_LEVEL_ON_AC = "auto";
      RADEON_DPM_PERF_LEVEL_ON_BAT = "auto";
      RADEON_POWER_PROFILE_ON_AC = "default";
      RADEON_POWER_PROFILE_ON_BAT = "low";

      # PCIe ASPM
      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "powersave";

      # Runtime Power Management for PCI devices
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";

      # USB Autosuspend
      USB_AUTOSUSPEND = 1;
      # Exclude input devices (mouse, keyboard) if needed, but TLP usually handles this well
      # USB_BLACKLIST_BTUSB=1 # Bluetooth autosuspend is handled by btusb module options in hw-config

      # Audio
      SOUND_POWER_SAVE_ON_AC = 0;
      SOUND_POWER_SAVE_ON_BAT = 1;
      SOUND_POWER_SAVE_CONTROLLER = "Y";

      # Battery Care (if supported by Lenovo driver)
      # START_CHARGE_THRESH_BAT0 = 75;
      # STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

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
    package = pkgs.ollama-rocm;
    enable = true;
    user = "ollama-service";
    group = "ollama-service";
    acceleration = "rocm";
    # HawkPoint iGPU is gfx1103, map to supported gfx1100
    environmentVariables = {
      # Critical for HawkPoint (gfx1103) -> gfx1100
      HSA_OVERRIDE_GFX_VERSION = "11.0.0";
    };
    rocmOverrideGfx = "11.0.0";
  };

  system.stateVersion = "24.05";
}
