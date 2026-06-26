{ pkgs
, pkgs-stable
, username
, gitUsername
, gitEmail
, ...
}:
{
  nixpkgs = {
    # Configure your nixpkgs instance
    config = {
      # Nvidia is used only for compute!!
      allowBroken = true;
      blasSupport = true;
      blasProvider = pkgs.amd-blis;
      lapackSupport = true;
      lapackProvider = pkgs.amd-libflame;
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };


  # You need to ensure your home-manager configuration also uses the overlay.
  # Add the nixpkgs.overlays line to your existing home-manager config.
  nixpkgs.overlays = [
  ];

  # Home Manager Settings
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";
  # We are on unstable/master, so versions may differ in name (e.g. 26.05 vs 25.11)
  # But we use inputs.nixpkgs.follows so they share the exact same pkgs.
  home.enableNixpkgsReleaseCheck = false;

  imports = [
    ../config/files.nix
    ../modules/programs/kitty.nix
    ../modules/programs/oxygen.nix
    ../modules/programs/vscode.nix
  ];

  home.packages = with pkgs; [
    clickup
    jetbrains.idea
    jetbrains.pycharm
    vscode-langservers-extracted
    thunderbird
    libreoffice
    bleachbit
    hunspell
    hunspellDicts.en_US
    meld
    vlc
    insync
    git-cola
    cheese
    chromium
    gearlever  # from stable; dwarfs broken on unstable with boost 1.89
  ];

  programs.firefox.profiles.default = {
    settings = {
      # --- Cookies & Sessions (keep logins) ---
      "network.cookie.cookieBehavior" = 5;
      "network.cookie.lifetimePolicy" = 0;
      "privacy.clearOnShutdown.cookies" = false;
      "privacy.clearOnShutdown.sessions" = false;
      "privacy.clearOnShutdown.offlineApps" = false;

      # --- Clear everything else on shutdown ---
      "privacy.sanitize.sanitizeOnShutdown" = true;
      "privacy.clearOnShutdown.cache" = true;
      "privacy.clearOnShutdown.formdata" = true;
      "privacy.clearOnShutdown.downloads" = true;
      "privacy.clearOnShutdown.history" = false;

      # --- Tracking & Fingerprinting ---
      "privacy.fingerprintingProtection" = true;
      "privacy.trackingprotection.enabled" = true;
      "privacy.trackingprotection.socialtracking.enabled" = true;
      "browser.contentblocking.category" = "strict";
      "privacy.donottrackheader.enabled" = true;
      "privacy.globalprivacycontrol.enabled" = true;

      # --- Network hardening ---
      "network.trr.mode" = 2;
      "dom.security.https_only_mode" = true;
      "network.prefetch-next" = false;
      "network.dns.disablePrefetch" = true;
      "network.http.speculative-parallel-limit" = 0;
      "media.peerconnection.ice.default_address_only" = true;

      # --- Disable telemetry & data collection ---
      "toolkit.telemetry.enabled" = false;
      "toolkit.telemetry.unified" = false;
      "datareporting.healthreport.uploadEnabled" = false;
      "app.shield.optoutstudies.enabled" = false;
      "browser.newtabpage.activity-stream.feeds.telemetry" = false;
      "browser.newtabpage.activity-stream.telemetry" = false;

      # --- Safe browsing ---
      "browser.safebrowsing.malware.enabled" = true;
      "browser.safebrowsing.phishing.enabled" = true;

      # --- Misc hardening ---
      "browser.formfill.enable" = false;
      "signon.autofillForms" = false;
      "extensions.formautofill.addresses.enabled" = false;
      "extensions.formautofill.creditCards.enabled" = false;
    };
  };

  home.file.".jdks/openjdk17".source = pkgs.jdk17;

  # Create XDG Dirs
  xdg = {
    configFile."mimeapps.list".force = true;
    mimeApps = {
      enable = true;
    };
    userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = true;
    };
  };

  # Theme GTK
  dconf = {
    enable = true;
    settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };

  # global home programs
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    # Enable fzf key bindings
  };

  # Install & Configure Git
  programs.git = {
    enable = true;
    lfs.enable = true;
    package = pkgs.gitFull;
    signing.format = null;
    settings = {
      user = {
        name = "${gitUsername}";
        email = "${gitEmail}";
      };
    };
  };

  # Starship Prompt
  programs.starship = {
    enable = true;
    package = pkgs.starship;
  };

  programs.nnn = {
    enable = true;
    package = pkgs.nnn.override { withNerdIcons = true; };
    extraPackages = with pkgs; [
      ffmpegthumbnailer
      mediainfo
      sxiv
      kdePackages.kdeplasma-addons
      kdePackages.okular
    ];
    bookmarks = {
      H = "/home/${username}";
    };
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

  home.sessionVariables = {
    EDITOR = "kate";
    BROWSER = "firefox";
    TERMINAL = "konsole";
    PATH = "$HOME/.local/bin:$PATH";
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      set -h  # Enable bash hashing
    '';
    enableCompletion = true;
    shellAliases = {
      straker-vpn = "sudo openvpn --config /home/jimh/work/straker_vpn.ovpn";
      straker-office-vpn = "sudo openvpn --config /home/jimh/work/straker_office_vpn.ovpn";
    };
  };
  programs.home-manager.enable = true;
}
