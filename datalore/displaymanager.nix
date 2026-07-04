{ ... }:
{
  imports = [ ../modules/services/displaymanager.nix ];

  # Load AMD first, then NVIDIA
  services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];
}
