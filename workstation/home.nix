{ pkgs, inputs, username, gitUsername, gitEmail, flakeDir, outputs, ... }: {
  # Home Manager Settings
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "23.11";

  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ../config/files.nix
    ../modules/programs/kitty.nix
    ../modules/programs/neofetch.nix
    ../modules/programs/oxygen.nix
    ../modules/programs/neovim.nix
    ../modules/programs/vscode.nix
  ];

  # Create XDG Dirs
  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    # Enable fzf key bindings
  };

  # Install & Configure Git
  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "${gitUsername}";
    userEmail = "${gitEmail}";
    package = pkgs.gitFull;
  };

  # Starship Prompt
  programs.starship = {
    enable = true;
    package = pkgs.starship;
  };

  nixpkgs = {
    overlays = [ outputs.overlays.stable-packages ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  # Install Packages For The User
  home.packages = with pkgs; [
    sddm
    slack
    (jetbrains.plugins.addPlugins jetbrains.idea-ultimate [ "github-copilot" ])
    jetbrains.dataspell
    _1password
    brave
    firefox
    thunderbird
    libreoffice
    hunspell
    hunspellDicts.en_US
    klavaro
    kdePackages.kompare
    kdePackages.kcharselect
    okteta
    gittyup
    git-cola
    vlc
  ];

  home.file.".jdks/openjdk11".source = pkgs.openjdk11;
  home.file.".jdks/openjdk17".source = pkgs.openjdk17;
  home.file.".jdks/openjdk21".source = pkgs.openjdk21;

  # Theme GTK
  dconf = {
    enable = true;
    settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };

  programs.nnn = {
    enable = true;
    package = pkgs.nnn.override { withNerdIcons = true; };
    extraPackages = with pkgs; [
      ffmpegthumbnailer
      mediainfo
      sxiv
      kdeplasma-addons
      okular
    ];
    bookmarks = { H = "/home/${username}"; };
    plugins = {
      mappings = {
        c = "fzcd";
        f = "finder";
        v = "imgview";
        o = "xdg-open";
        t = "trash";
        d = "diffs";
        x = "!chmod +x $nnn";
        q = "preview";
      };
    };
  };

  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    flags = [ "--disable-up-arrow" ];
    settings = { };
  };

  # Configure Bash
  programs.bash = {
    enable = true;
    enableCompletion = true;
    profileExtra = ''
      if [ -f $HOME/.oxygen-xml-developer-profile ]; then
         source $HOME/.oxygen-xml-developer-profile
      fi
    '';
    bashrcExtra = ''
      # Configure nnn
       export NNN_PLUG='p:preview-tui;l:lastdir'
       export NNN_OPENER="${pkgs.xdg-utils}/bin/xdg-open"
       export NNN_TRASH="1"
       export NNN_ARCHIVE="\\.(7z|a|ace|alz|arc|arj|bz|bz2|cab|cpio|deb|gz|jar|lha|lz|lzh|lzma|lzo|rar|rpm|rz|t7z|tar|tbz|tbz2|tgz|tlz|txz|tZ|tzo|war|xpi|xz|Z|zip)$"
    '';
    initExtra = ''
      neofetch
      if [ -f $HOME/.bashrc-personal ]; then
        source $HOME/.bashrc-personal
      fi
    '';

    shellAliases = {
      flake-rebuild = "sudo nixos-rebuild switch --flake ${flakeDir}";
      flake-update = "sudo nix flake update ${flakeDir}";
      gcCleanup =
        "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d";
      less = "most";
      cat = "bat";
      ll = "ls -alF";
      lg = "lazygit";
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "kitty";
  };
  programs.home-manager.enable = true;
}
