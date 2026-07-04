{ pkgs }: {
  allowUnfree = true;
  blasSupport = true;
  blasProvider = pkgs.amd-blis;
  lapackSupport = true;
  lapackProvider = pkgs.amd-libflame;
}
