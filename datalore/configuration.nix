{ pkgs
, username
, gitUsername
, theLocale
, theTimezone
, outputs
, theKBDLayout
, inputs
, system
, lib
, config
, ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./amd.nix
    ./hardware-configuration.nix
    ../global/configuration.nix
    ./nvidia.nix
    ./displaymanager.nix
  ];

  networking.hostName = "datalore";

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
  ];

  environment.systemPackages = with pkgs; [
  ];

  powerManagement = {
    cpuFreqGovernor = "ondemand";
    enable = true;
  };

  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/" "/home" ];
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };

  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  environment.sessionVariables = {
    # GPU preferences for applications
    AMD_VULKAN_ICD = "RADV";
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json";

    # Prevent NVIDIA from being used for display
    __GLX_VENDOR_LIBRARY_NAME = "amd";

    # Use AMD for OpenCL compute when available
    OPENCL_VENDOR_PATH = "/run/opengl-driver/etc/OpenCL/vendors";
  };

  system.stateVersion = "23.11";
}
