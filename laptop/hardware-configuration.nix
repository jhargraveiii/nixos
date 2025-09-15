{ config
, lib
, pkgs
, ...
}:

{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
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
    "lsm=landlock,yama,bpf"
    "msr.allow_writes=on"
    "nmi_watchdog=0"
    # BIOS disables CPPC; avoid amd_pstate errors
    "amd_pstate=disable"
    # Prefer SATA link power mgmt when applicable
    "ahci.mobile_lpm_policy=3"
    # Enable PCIe ASPM powersave globally
    "pcie_aspm.policy=powersave"
    # Modern amdgpu defaults are good; do not override full ppfeaturemask
    "amdgpu.runpm=1"
    "amdgpu.dpm=1"
    # Use deep mem sleep for better standby
    "mem_sleep_default=deep"
    # Reasonable NVMe latency for Phoenix platforms
    "nvme_core.default_ps_max_latency_us=5500"
    "mitigations=auto"
    "quiet"
    "loglevel=4"
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
    options snd_hda_intel power_save=1 power_save_controller=Y
    options mt7921e disable_aspm=0
    options mt76 disable_usb_sg=0
    options usbcore autosuspend=2
    options ideapad_laptop force=1
    options btusb enable_autosuspend=1
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
  # thermald is Intel-only; remove to avoid confusion
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.enableAllFirmware = lib.mkDefault true;
  hardware.enableRedistributableFirmware = lib.mkDefault true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault true;
}
