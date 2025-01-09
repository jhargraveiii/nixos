{
  pkgs,
  inputs,
  username,
  gitUsername,
  gitEmail,
  flakeDir,
  outputs,
  config,
  ...
}:
{
  nixpkgs = {
    overlays = [ ];
  };

  home.stateVersion = "23.11";
  imports = [
    ../global/home.nix
  ];

  # Install Packages For The User
  home.packages = with pkgs; [
  ];

  # Configure Bash
  programs.bash = {
    profileExtra = ''
      if [ -f $HOME/.oxygen-xml-developer-profile ]; then
         source $HOME/.oxygen-xml-developer-profile
      fi
      export XDG_RUNTIME_DIR="/run/user/$(id -u)"

    '';
    bashrcExtra = ''
      # Configure nnn
       export NNN_PLUG='p:preview-tui;l:lastdir'
       export NNN_OPENER="${pkgs.xdg-utils}/bin/xdg-open"
       export NNN_TRASH="1"
       export NNN_ARCHIVE="\\.(7z|a|ace|alz|arc|arj|bz|bz2|cab|cpio|deb|gz|jar|lha|lz|lzh|lzma|lzo|rar|rpm|rz|t7z|tar|tbz|tbz2|tgz|tlz|txz|tZ|tzo|war|xpi|xz|Z|zip)$"
    '';
    initExtra = ''
      fastfetch
      if [ -f $HOME/.bashrc-personal ]; then
        source $HOME/.bashrc-personal
      fi
    '';

    shellAliases = {
      flake-check = "nix flake check --verbose --show-trace ${flakeDir}";
      flake-rebuild = "sudo nixos-rebuild switch --keep-going --flake ${flakeDir}#datalore";
      flake-update = "sudo nix flake update --flake ${flakeDir}";
      gcCleanup = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
      less = "most";
      cat = "bat";
      ll = "ls -alF";
      lg = "lazygit";
    };
  };
}
