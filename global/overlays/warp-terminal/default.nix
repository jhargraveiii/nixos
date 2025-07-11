# This overlay fixes the hash for warp-terminal by overriding the source and version.
self: super: {
  warp-terminal = super.warp-terminal.overrideAttrs (oldAttrs: rec {
    pname = "warp-terminal";
    version = "0.2025.07.09.08.11.stable_01";

    src = super.fetchurl {
      # https://releases.warp.dev/stable/v0.2025.06.25.08.12.stable_01/warp-terminal-v0.2025.06.25.08.12.stable_01-1-x86_64.pkg.tar.zst
      url = "https://releases.warp.dev/stable/v${version}/warp-terminal-v${version}-1-x86_64.pkg.tar.zst";
      # This is the correct hash that Nix found.
      hash = "sha256-zk3yHo3aimdmgA9bxbQrrZXXWYzNjJRB619PB/MRIG4=";
    };
  });
}
