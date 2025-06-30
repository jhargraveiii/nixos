# This overlay fixes the hash for warp-terminal by overriding the source and version.
self: super: {
  warp-terminal = super.warp-terminal.overrideAttrs (oldAttrs: rec {
    pname = "warp-terminal";
    version = "0.2025.06.20.22.47.stable_05";

    src = super.fetchurl {
      url = "https://releases.warp.dev/stable/v${version}/warp-terminal-v${version}-1-x86_64.pkg.tar.zst";
      # This is the correct hash that Nix found.
      hash = "sha256-yrwS6rqSGkiWNjr17MVyH+ZQL2CTUqt6coi8qWfq0Gg=";
    };
  });
}
