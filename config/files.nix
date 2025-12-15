{ ... }:

{
  # Place Files Inside Home Directory
  home.file.".face".source = ./files/face.jpg;
  home.file.".config/starship.toml".source = ./files/starship.toml;
  home.file.".config/fastfetch/config.jsonc".source = ./files/config.jsonc;
  home.file.".local/share/fonts" = {
    source = ./files/fonts;
    recursive = true;
  };

  # Ollama Correct - Select All & Fix Grammar
  home.file.".local/share/icons/ollama-correct.png".source = ./files/ollama-icon.png;
  home.file.".local/bin/ollama-correct" = {
    source = ./files/ollama-correct.sh;
    executable = true;
  };
  home.file.".local/share/applications/ollama-correct.desktop".source = ./files/ollama-correct.desktop;
}
