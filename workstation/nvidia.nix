{ config, pkgs, lib, inputs, user, ... }:
{

  #Nvidia
  #Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [ vaapiVdpau libvdpau-va-gl mesa.drivers];
  };

  # Load nvidia driver for Xorg and Wayland
  nixpkgs.config.nvidia.acceptLicense = true;
  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "";
    libinput.enable = true;
    videoDrivers = [ "nvidia" ];
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
   config = ''
      Section "Device"
          Identifier "nvidia"
          Driver "nvidia"
          BusID "PCI:10:0:0"
          Option "AllowEmptyInitialConfiguration"
      EndSection
    '';
    screenSection = ''
      Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
      Option         "AllowIndirectGLXProtocol" "off"
      Option         "TripleBuffer" "on"
    '';
    deviceSection = '' 
    '';
  };

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    powerManagement.enable = false;
    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    nvidiaPersistenced = true;

    forceFullCompositionPipeline = true;
    
    # Cuda?
    #services.xmr-stak.cudaSupport = true; 

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
 };

  # Nvidia in Docker
  virtualisation.docker = {
    enable = true;
    enableOnBoot= true;
    enableNvidia = true;
  }; 
  systemd.enableUnifiedCgroupHierarchy = false;
}