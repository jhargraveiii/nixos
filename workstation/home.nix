{ pkgs
, inputs
, username
, gitUsername
, gitEmail
, flakeDir
, outputs
, wallpaperDir
, ...
}:

{
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

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    options = [
      "--cmd cd"
    ];
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };

  # Install & Configure Git
  programs.git = {
    enable = true;
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
    overlays = [
      # we want to use some packages from stable so need this overlay
      outputs.overlays.stable-packages
    ];
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
    slack
    (jetbrains.plugins.addPlugins jetbrains.idea-ultimate [ "github-copilot" ])
    git-cola
    _1password
    brave
    thunderbird
    libreoffice
    sddm
    pulseaudio
    libva
    blueman
    restic
    ant
    maven
    pavucontrol
    python3
    networkmanager
    networkmanagerapplet
    meld
    openjdk11
    openvpn
    hunspell
    hunspellDicts.en_US
    nil
    ollama
    klavaro
    gh
  ];

  home.file.".jdks/openjdk11".source = pkgs.openjdk11;
  home.file.".jdks/openjdk17".source = pkgs.openjdk17;
  home.file.".jdks/openjdk21".source = pkgs.openjdk21;

  # Theme QT -> GTK
  #qt = {
  #  enable = true;
  #  platformTheme = "gnome";
  #  style = {
  #    name = "adwaita-dark";
  #    package = pkgs.adwaita-qt;
  #  };
  #};

  # Theme GTK
  dconf = {
    enable = true;
    settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
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
    initExtra = ''
      neofetch
      if [ -f $HOME/.bashrc-personal ]; then
        source $HOME/.bashrc-personal
      fi
    '';

    sessionVariables = { };

    shellAliases = {
      conda-shell = "NIXPKGS_ALLOW_UNFREE=1 nix develop ${flakeDir}/modules/shells/conda --impure";
      flake-rebuild = "sudo nixos-rebuild switch --flake ${flakeDir}";
      flake-update = "sudo nix flake update ${flakeDir}";
      gcCleanup = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d";
      ls = "lsd";
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  home.sessionVariables = { };
  programs.home-manager.enable = true;
}
