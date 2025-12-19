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
    "lenovo_wmi_gamezone" # Probing fails on this model
  ];

  boot.initrd.kernelModules = [ ];
  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642;
    "vm.swappiness" = 20;
    # Reduce disk writes - delay flushing dirty pages (60 seconds)
    "vm.dirty_writeback_centisecs" = 6000;
    # Enable laptop mode for aggressive write caching on battery
    "vm.laptop_mode" = 5;
    # Increase dirty ratio thresholds (more RAM caching before disk writes)
    "vm.dirty_ratio" = 40;
    "vm.dirty_background_ratio" = 10;
  };
  boot.kernelParams = [
    "lsm=landlock,yama,bpf"
    "msr.allow_writes=on"
    "nmi_watchdog=0"
    # TSC clock stability fix for CPU timing
    "tsc=reliable"
    # Model 83DR (IdeaPad Slim 5) supports amd_pstate if BIOS is updated to enable CPPC.
    # We enable 'active' mode to use EPP hints via TLP.
    # If BIOS lacks CPPC, this will fail safely and fallback to acpi-cpufreq.
    "amd_pstate=active"
    # Prefer SATA link power mgmt when applicable
    "ahci.mobile_lpm_policy=3"
    # Enable PCIe ASPM powersave globally
    "pcie_aspm.policy=powersave"
    # Use deep mem sleep for better standby
    "mem_sleep_default=deep"
    # NVMe power saving: APST enabled by default (removed latency fix)
    # "nvme_core.default_ps_max_latency_us=0"
    "mitigations=auto"
    "quiet"
    "loglevel=4"
    "i8042.nopnp" # Fix PS/2 AUX port disabled warning
  ];
  boot.kernelModules = [
    "amdgpu"
    "acpi_call"
    "ideapad_laptop"
    "wireguard"
    "kvm-amd"
    # "ovpn-dco" # OpenVPN DCO module not available in current kernel
  ];
  boot.extraModulePackages = [ config.boot.kernelPackages.acpi_call ];
  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=1 power_save_controller=Y
    options mt7921e disable_aspm=0
    options usbcore autosuspend=2
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
      "nofail"        # Don't fail boot if SD card is missing
      "x-systemd.device-timeout=5s"  # Short timeout for faster boot without card
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

  # ============================================
  # IdeaPad Slim 5 Specific Hardware Settings
  # ============================================

  # IdeaPad conservation mode - limits charging to ~60% for battery longevity
  # Uncomment to enable (recommended if laptop is often plugged in)
  # systemd.services.ideapad-conservation = {
  #   description = "Enable IdeaPad battery conservation mode";
  #   wantedBy = [ "multi-user.target" ];
  #   script = ''
  #     echo 1 > /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode
  #   '';
  #   serviceConfig = {
  #     Type = "oneshot";
  #     RemainAfterExit = true;
  #   };
  # };
}
