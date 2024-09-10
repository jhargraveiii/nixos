{
  config,
  pkgs,
  lib,
  ...
}:
{

  # Nvidia card is used only for compute, not display!!
  nixpkgs.config = {
    cudaSupport = true;
    cudaVersion = "12.4";
    cudaCapabilities = [ "8.9" ];
    nvidia.acceptLicense = true;
  };

  environment.systemPackages = with pkgs; [
    # CUDA Toolkit and related packages
    cudaPackages.cuda_cudart
    cudaPackages.cuda_cupti
    cudaPackages.cuda_cccl
    cudaPackages.cuda_nvcc
    cudaPackages.cuda_nvtx
    cudaPackages.cuda_sanitizer_api
    cudaPackages.cuda_profiler_api
    cudaPackages.cudatoolkit
    cudaPackages.cuda_gdb
    cudaPackages.cuda_nsight

    # CUDA libraries
    cudaPackages.libcublas
    cudaPackages.libcufft
    cudaPackages.libcurand
    cudaPackages.libcusolver
    cudaPackages.libcusparse
    cudaPackages.libcufile
    cudaPackages.libnpp
    cudaPackages.libnvjpeg
    cudaPackages.libnvjitlink
    cudaPackages.cutensor
    cudaPackages.cudnn
    cudaPackages.nccl
    cudaPackages.tensorrt
  ];

  #hardware.nvidia-container-toolkit.enable = true;

  systemd.services.nvidia-persistenced = {
    description = "NVIDIA Persistence Daemon";
    wantedBy = [ "multi-user.target" ];
    after = [
      "syslog.target"
      "systemd-modules-load.service"
    ];
    requires = [
      "syslog.target"
      "systemd-modules-load.service"
    ];
    serviceConfig = {
      Type = "forking";
      Restart = "always";
      RestartSec = "1s";
      ExecStart = "${config.hardware.nvidia.package}/bin/nvidia-persistenced --verbose";
      ExecStopPost = "${pkgs.coreutils}/bin/rm -rf /var/run/nvidia-persistenced";
      User = "root";
      Group = "root";
      TimeoutStartSec = "10s";
      TimeoutStopSec = "10s";
      RuntimeDirectory = "nvidia-persistenced";
      RuntimeDirectoryMode = "0755";
      PIDFile = "/var/run/nvidia-persistenced/nvidia-persistenced.pid";
    };
  };

  # Enable the NVIDIA driver - but not sure why it is needed for compute only??
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = false;
    forceFullCompositionPipeline = false;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidia_x11_production;
  };
}
