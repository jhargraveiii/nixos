# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs
, username
, inputs
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

  networking.networkmanager.wifi.powersave = false;

  # Power Management - TLP
  services.power-profiles-daemon.enable = false;
  powerManagement.powertop.enable = false;
  powerManagement.enable = true;

  services.tlp = {
    enable = true;
    settings = {
      TLP_ENABLE = 1;
      TLP_DEFAULT_MODE = "BAT";
      TLP_PERSISTENT_DEFAULT = 0;

      # CPU — amd-pstate-epp only supports performance/powersave governors
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      # EPP hints for amd-pstate-epp (active mode)
      # "power" was too aggressive — CPU downclocking during WebRTC video
      # encoding caused bitrate tracker assertion failures across all browsers
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";

      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "balanced";

      # PCIe ASPM — avoid "powersave" which re-enables L1 on mt7921e
      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "default";

      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";

      USB_AUTOSUSPEND = 1;

      SOUND_POWER_SAVE_ON_AC = 0;
      SOUND_POWER_SAVE_ON_BAT = 1;
      SOUND_POWER_SAVE_CONTROLLER = "Y";

      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "off";

      # RADEON_* removed — only applies to legacy radeon driver, not amdgpu
      # DISK_APM_LEVEL_* / SATA_LINKPWR_* removed — no SATA drives (NVMe + MMC only)

      RUNTIME_PM_DRIVER_DENYLIST = "mt7921e";
      RUNTIME_PM_DENYLIST = "02:00.0";
    };
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };

  services.udev.extraRules = ''
    # Prevent runtime PM from suspending MT7921 WiFi (causes random disconnects)
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x14c3", ATTR{device}=="0x7961", ATTR{power/control}="on"
  '';

  hardware.bluetooth.powerOnBoot = false;

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

    # HSA_* ROCm overrides moved to ollama service only — global scope
    # caused SIGILL crashes in browsers/Electron apps during video calls
  };

  services.ollama = {
    package = pkgs.ollama-rocm;
    enable = true;
    user = "ollama-service";
    group = "ollama-service";
    # HawkPoint iGPU is gfx1103, map to supported gfx1100
    environmentVariables = {
      HSA_OVERRIDE_GFX_VERSION = "11.0.0";
      HSA_ENABLE_SDMA = "0";
      HSA_XNACK = "1";
    };
    rocmOverrideGfx = "11.0.0";
  };

  system.stateVersion = "24.05";
}
