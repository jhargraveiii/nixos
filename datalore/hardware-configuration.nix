{ config
, lib
, pkgs
, ...
}:
{
  boot = {
    extraModprobeConfig = ''
      blacklist nouveau
      options usbhid quirks=0x05ac:0x0265:0x00000010
      options usbhid mousepoll=8
      # Intel WiFi — disable power save for reliable connectivity
      options iwlwifi power_save=0
      options iwlmvm power_scheme=1
      options cfg80211 ieee80211_regdom=US
      # NVMe thermal optimizations
      options nvme use_threaded_interrupts=1
      options nvme_core default_ps_max_latency_us=5500
    '';
    blacklistedKernelModules = [
      "nouveau"
      "sp5100_tco"
    ];
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
    kernelPackages = pkgs.linuxPackages;
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
    kernelModules = [
      "kvm-amd"
      "amdgpu"
      "iwlwifi"
      "wireguard"
      "nvidia"
      "nvidia_uvm"
    ];
    kernelParams = [
      # Essential stability fixes
      "nowatchdog"
      "sp5100_tco.blacklist=1"
      "nmi_watchdog=0"
      "nvidia-drm.modeset=0"
      # NVMe thermal management for Samsung SM963
      "nvme_core.default_ps_max_latency_us=5500"
    ];

    extraModulePackages = [
    ];
    tmp.cleanOnBoot = true;
    supportedFilesystems = [ "btrfs" "ext4" ];
  };

  # Focused memory management for Samsung SM963 thermal issues
  boot.kernel.sysctl = {
    "vm.swappiness" = 20;
    "vm.dirty_writeback_centisecs" = 6000;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/2faa8ab4-b54d-4b70-8e2b-873c56d650e1";
    fsType = "btrfs";
    options = [ "subvol=@" "compress=zstd:3" "noatime" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/2faa8ab4-b54d-4b70-8e2b-873c56d650e1";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress=zstd:3" "noatime" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/683A-1A12";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [ ];


  fileSystems."/home/jimh/BACKUP" = {
    device = "/dev/disk/by-uuid/76ce4fc4-ccdf-4ca6-8f2c-f10f4aeb5877";
    fsType = "ext4";
    options = [
      "noatime"
      "lazytime"
      "commit=120"
    ];
  };

  fileSystems."/home/jimh/DATA" = {
    device = "/dev/disk/by-uuid/6c0f6c67-982e-468c-9582-5f042a54d7a2";
    fsType = "ext4";
    options = [
      "noatime"
      "lazytime"
      "commit=120"
    ];
  };

  fileSystems."/home/jimh/DATA2" = {
    device = "/dev/disk/by-uuid/edaf32c9-07c4-4c25-86e5-9f095dc6fcef";
    fsType = "ext4";
    options = [
      "noatime"
      "lazytime"
      "commit=120"
    ];
  };

  # Disable global DHCP (preferred approach)
  networking.useDHCP = false;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.enableAllFirmware = lib.mkDefault true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault true;
  hardware.enableRedistributableFirmware = lib.mkDefault true;
}
