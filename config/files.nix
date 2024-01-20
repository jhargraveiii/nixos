{ pkgs, config, ... }:

{
  # Place Files Inside Home Directory
  home.file.".emoji".source = ./files/emoji;
  home.file.".face".source = ./files/face.jpg;
  home.file."Pictures/Wallpapers" = {
    source = ./files/media/Wallpapers;
    recursive = true;
  };
  home.file.".local/share/fonts" = {
    source = ./files/fonts;
    recursive = true;
  };
}
