{ config
, lib
, pkgs
, ...
}:
{
  boot = {
    extraModprobeConfig = ''
      blacklist nouveau
      # Apple Magic Trackpad with aggressive stabilization
      options bcm5974 debug=0
      options usbhid quirks=0x05ac:0x0265:0x00000010
      options usbhid mousepoll=8
      # NVMe thermal optimizations for Samsung SM963
      options nvme use_threaded_interrupts=1
      options nvme_core default_ps_max_latency_us=0
      options nvme_core force_apst=0
    '';
    blacklistedKernelModules = [
      "nouveau"
      "sp5100_tco"
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
    kernelModules = [
      "kvm-amd"
      "amdgpu"
      "wireguard"
      # Load NVIDIA modules after AMD
      "nvidia"
      "nvidia_uvm"
      # Remove problematic module temporarily
      # "ovpn-dco"
    ];
    kernelParams = [
      # Essential stability fixes
      "nowatchdog"
      "sp5100_tco.blacklist=1"
      "nmi_watchdog=0"
      "nvidia-drm.modeset=0"
      # NVMe thermal management for Samsung SM963
      "nvme_core.default_ps_max_latency_us=0"
    ];

    extraModulePackages = [
    ];
    tmp.cleanOnBoot = true;
  };

  # Focused memory management for Samsung SM963 thermal issues
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;
    # Reduce write pressure on root drive
    "vm.dirty_expire_centisecs" = 1000;
    "vm.dirty_writeback_centisecs" = 500;
  };



  fileSystems."/" = {
    device = "/dev/disk/by-uuid/48799b1c-64e9-4d05-abf7-bd0cfc5951c0";
    fsType = "ext4";
    options = [
      "noatime"
      "nodiratime"
      "discard"
      # NVMe thermal optimization
      "commit=120"
      "data=writeback"
      "barrier=0"
      "journal_async_commit"
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
      # NVMe thermal optimization
      "commit=120"
      "data=writeback"
      "barrier=0"
      "journal_async_commit"
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

  # Samsung SM963 ROOT drive thermal protection
  systemd.services.samsung-thermal-protection = {
    description = "Samsung SM963 Root Drive Thermal Protection";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 10;
    };
    script = ''
      while true; do
        # Monitor Samsung SM963 root drive (critical threshold 75°C)
        temp=$(cat /sys/devices/pci0000:00/0000:00:01.2/0000:02:00.0/0000:03:01.0/0000:04:00.0/nvme/nvme0/hwmon*/temp3_input 2>/dev/null | head -1 || echo 0)
        temp_c=$((temp / 1000))
        
        if [ "$temp_c" -gt 65 ]; then
          echo "$(date): Samsung ROOT drive critical: $temp_c°C - EMERGENCY THROTTLING" | systemd-cat -t samsung-thermal
          # Emergency measures for root drive
          echo 1 > /sys/class/nvme/nvme0/queue_count 2>/dev/null || true
          echo 16 > /sys/block/nvme0n1/queue/nr_requests 2>/dev/null || true
          sync && echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || true
        elif [ "$temp_c" -gt 60 ]; then
          echo "$(date): Samsung ROOT drive warm: $temp_c°C - Moderate throttling" | systemd-cat -t samsung-thermal
          echo 2 > /sys/class/nvme/nvme0/queue_count 2>/dev/null || true
          echo 32 > /sys/block/nvme0n1/queue/nr_requests 2>/dev/null || true
        elif [ "$temp_c" -lt 55 ] && [ "$temp_c" -gt 0 ]; then
          # Restore normal operation
          echo 4 > /sys/class/nvme/nvme0/queue_count 2>/dev/null || true
          echo 128 > /sys/block/nvme0n1/queue/nr_requests 2>/dev/null || true
        fi
        sleep 5
      done
    '';
  };

  # Disable global DHCP (preferred approach)
  networking.useDHCP = false;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.enableAllFirmware = lib.mkDefault true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault true;
  hardware.enableRedistributableFirmware = lib.mkDefault true;
}
