{ config
, lib
, pkgs
, ...
}:
{
  boot = {
    extraModprobeConfig = ''
      blacklist nouveau
    '';
    blacklistedKernelModules = [
      "nouveau"
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
      "nvidia"
      "nvidia_uvm"
      "ovpn-dco"
    ];
    kernelParams = [
      "pcie_aspm=off"
    ];

    extraModulePackages = [
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

  # Disable global DHCP (preferred approach)
  networking.useDHCP = false;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.enableAllFirmware = lib.mkDefault true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault true;
  hardware.enableRedistributableFirmware = lib.mkDefault true;
}
