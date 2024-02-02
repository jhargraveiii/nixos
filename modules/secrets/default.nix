{config, lib, pkgs, ... }:

{
  home.file."pia-credentials".text =
    "$(op get item pia-credentials --fields password)";

  home.file."pia-ca-montreal".text = 
    "$(op get item pia-ca-montreal --fields password)";
}
