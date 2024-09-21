# This file defines overlays
{ inputs, ... }:
{
  overlays = [
    (final: prev: {
      nvidia_driver = prev.linuxPackages_6_11.nvidia_x11_production;
    })
  ];
}
