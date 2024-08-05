# This file defines overlays
{ inputs, ... }:
{

  cuda-override = final: prev: { cudaPackages = prev.cudaPackages_12_3; };

}
