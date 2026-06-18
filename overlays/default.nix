final: prev: {
  # Pin aocl-utils to 5.2.2 — AMD released 5.3.0 binaries but hasn't pushed
  # the tag to GitHub yet, so nixpkgs' fetchFromGitHub 404s.
  aocl-utils = prev.aocl-utils.overrideAttrs (old: rec {
    version = "5.2.2";
    src = prev.fetchFromGitHub {
      owner = "amd";
      repo = "aocl-utils";
      tag = version;
      hash = "sha256-grEuYM+Ss4pQQ12S5uOV27ocVHzYuLK+e70Jm5u8fuI=";
    };
  });
}
