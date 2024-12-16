# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    extraModprobeConfig = ''
      blacklist nouveau
    '';
    blacklistedKernelModules = [
      "nouveau"
      "nvidia_drm"
      "nvidia_modeset"
    ];
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
    kernelPackages = pkgs.linuxPackages_6_12;
    initrd.availableKernelModules = [
      "thunderbolt"
      "nvme"
      "xhci_pci"
      "ahci"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
    initrd.kernelModules = [ ];
    kernel.sysctl = {
      "vm.max_map_count" = 2147483642;
    };
    kernelModules = [
      "kvm-amd"
      "amdgpu"
      "amd-pstate"
    ];
    kernelParams = [
      "amd_pstate=active"
      "amdgpu.ppfeaturemask=0xffffffff"
    ];
    extraModulePackages =
      [
      ];
    tmp.cleanOnBoot = true;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/48799b1c-64e9-4d05-abf7-bd0cfc5951c0";
    fsType = "ext4";
    options = [
      "noatime"
      "nodiratime"
      "discard"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/11D8-3071";
    fsType = "vfat";
    options = [
      "noatime"
      "nodiratime"
      "discard"
    ];
  };

  swapDevices = [
    {
      device = "/dev/disk/by-uuid/20e10911-18b1-47b0-974b-94acfc7fcff5";
      options = [
        "noatime"
        "nodiratime"
        "discard"
      ];
    }
  ];

  fileSystems."/home/jimh/BACKUP" = {
    device = "/dev/disk/by-uuid/76ce4fc4-ccdf-4ca6-8f2c-f10f4aeb5877";
    fsType = "ext4";
  };

  fileSystems."/home/jimh/DATA" = {
    device = "/dev/disk/by-uuid/8dd490ff-497c-4243-921a-cabfe0e20995";
    fsType = "ext4";
    options = [
      "noatime"
      "nodiratime"
      "discard"
    ];
  };

  fileSystems."/home/jimh/DATA2" = {
    device = "/dev/disk/by-uuid/edaf32c9-07c4-4c25-86e5-9f095dc6fcef";
    fsType = "ext4";
    options = [
      "noatime"
      "nodiratime"
      "discard"
    ];
  };

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.enableAllFirmware = lib.mkDefault true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault true;
  hardware.enableRedistributableFirmware = lib.mkDefault true;
  hardware.nvidia-container-toolkit.enable = true;
}
