{ pkgs, config, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.unstable.vscodium;
    enableUpdateCheck = true;
    enableExtensionUpdateCheck = true;
    extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "copilot";
        publisher = "GitHub";
        version = "1.162.714";
        sha256 = "a8f74ace6997dd375babe430dae35f3c37331e0c1beac2f67854424f3ca83777";
      }
      {
        name = "jnoortheen.nix-ide";
        publisher = "Noortheen";
        version = "0.2.2";
        sha256 = "8f038cfba2e71f20a4be13935524d466f831efb8c083a845082a41a98f00c488";
      }
    ];
  };
}
