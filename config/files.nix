{ ... }:

{
  # Place Files Inside Home Directory
  home.file.".face".source = ./files/face.jpg;
  home.file.".config/starship.toml".source = ./files/starship.toml;
  home.file.".local/share/fonts" = {
    source = ./files/fonts;
    recursive = true;
  };
}
