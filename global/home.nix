{ pkgs
, username
, gitUsername
, gitEmail
, flakeDir
, ...
}:
{
  nixpkgs.config = (import ../config/nixpkgs-config.nix { inherit pkgs; }) // {
    allowBroken = true;
    # Workaround for https://github.com/nix-community/home-manager/issues/2942
    allowUnfreePredicate = _: true;
  };

  # We are on unstable/master, so versions may differ
  home.enableNixpkgsReleaseCheck = false;
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";

  imports = [
    ../config/files.nix
    ../modules/programs/kitty.nix
    ../modules/programs/oxygen.nix
  ];

  home.packages = with pkgs; [
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
    gearlever
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

  xdg = {
    configFile."mimeapps.list".force = true;
    mimeApps.enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = true;
    };
  };

  dconf = {
    enable = true;
    settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    historyWidget.command = "";
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    package = pkgs.gitFull;
    signing.format = null; # no git signing configured
    settings.user = {
      name = "${gitUsername}";
      email = "${gitEmail}";
    };
  };

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
    plugins.mappings = {
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

  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    flags = [ "--disable-up-arrow" ];
    settings = { };
  };

  home.sessionPath = [ "$HOME/.local/bin" ];

  programs.bash = {
    enable = true;
    enableCompletion = true;
    profileExtra = ''
      if [ -f $HOME/.oxygen-xml-developer-profile ]; then
        source $HOME/.oxygen-xml-developer-profile
      fi
      export XDG_RUNTIME_DIR="/run/user/$(id -u)"
    '';
    bashrcExtra = ''
      export NNN_PLUG='p:preview-tui;l:lastdir'
      export NNN_OPENER="${pkgs.xdg-utils}/bin/xdg-open"
      export NNN_TRASH="1"
      export NNN_ARCHIVE="\\.(7z|a|ace|alz|arc|arj|bz|bz2|cab|cpio|deb|gz|jar|lha|lz|lzh|lzma|lzo|rar|rpm|rz|t7z|tar|tbz|tbz2|tgz|tlz|txz|tZ|tzo|war|xpi|xz|Z|zip)$"
    '';
    initExtra = ''
      set -h
      fastfetch
      if [ -f $HOME/.bashrc-personal ]; then
        source $HOME/.bashrc-personal
      fi
    '';
    shellAliases = {
      straker-vpn = "sudo openvpn --config /home/${username}/work/straker_vpn.ovpn";
      straker-office-vpn = "sudo openvpn --config /home/${username}/work/straker_office_vpn.ovpn";
      flake-check = "nix flake check --verbose --show-trace ${flakeDir}";
      flake-update = "sudo nix flake update --flake ${flakeDir}";
      gcCleanup = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
      less = "most";
      cat = "bat";
      ll = "ls -alF";
      lg = "lazygit";
    };
  };

  programs.home-manager.enable = true;
}
