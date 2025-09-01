{ config
, lib
, pkgs
, ...
}:

{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_6_12;
  environment.systemPackages = [
  ];
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "usb_storage"
    "sd_mod"
    "rtsx_pci_sdmmc"
  ];

  boot.blacklistedKernelModules = [
  ];

  boot.initrd.kernelModules = [ ];
  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642;
    "vm.dirty_writeback_centisecs" = 6000;
    "vm.laptop_mode" = 5;
    "vm.swappiness" = 20;
  };
  boot.kernelParams = [
    "msr.allow_writes=on"
    "nmi_watchdog=0"
    "amd_pstate=guided"
    "ahci.mobile_lpm_policy=3"
    "pcie_aspm.policy=powersave"
    "amdgpu.ppfeaturemask=0xffffffff"
    "amdgpu.runpm=1"
    "amdgpu.audio=0"
    "amdgpu.dpm=1"
    "mem_sleep_default=deep"
    "nvme_core.default_ps_max_latency_us=5500"
    "mitigations=auto"
    "quiet"
  ];
  boot.kernelModules = [
    "amdgpu"
    "acpi_call"
    "ideapad_laptop"
    "wireguard"
    "kvm-amd"
    "ovpn-dco"
  ];
  boot.extraModulePackages = [ config.boot.kernelPackages.acpi_call ];
  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=1
    options mt7921e power_save=1
    options usbcore autosuspend=1
    options ideapad_laptop force=1
    options btusb enable_autosuspend=1
    options iwlmvm power_scheme=3
    options iwlwifi power_save=1
    options cfg80211 ieee80211_regdom=US
  '';

  boot.tmp.cleanOnBoot = true;
  boot.supportedFilesystems = [ "ext4" ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/892e4229-5260-4957-be9e-df50894ebed2";
    fsType = "ext4";
    options = [
      "noatime"
      "lazytime"
      "commit=60"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/7B6D-9DFF";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
      "noatime"
      "flush"
    ];
  };

  fileSystems."/home/jimh/BACKUP" = {
    device = "/dev/mmcblk0p1";
    fsType = "ext4";
    options = [
      "noatime"
      "lazytime"
      "commit=60"
    ];
  };

  swapDevices = [{ device = "/dev/disk/by-uuid/1e8f15a3-88e4-4389-9993-bb3ff7b92bac"; }];

  # Disable hdapsd (ThinkPad-specific)
  services.hdapsd.enable = lib.mkDefault false;
  hardware.amdgpu.initrd.enable = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.enableAllFirmware = lib.mkDefault true;
  hardware.enableRedistributableFirmware = lib.mkDefault true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault true;
}
