{ pkgs, ... }:
{
  # Configure Kitty
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;
    font.name = "JetBrainsMono Nerd Font";
    font.size = 12;
    settings = {
      disable_ligatures = "never";
      scrollback_lines = 5000;
      allow_remote_control = false;
      wheel_scroll_min_lines = 5;
      window_padding_width = 0;
      confirm_os_window_close = 0;
      background_opacity = "0.85"; # Set opacity to 1.0 to disable transparency
      show_error_hints = true; # Make errors more readable
    };
  };
}
