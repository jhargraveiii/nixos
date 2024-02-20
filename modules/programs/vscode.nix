{ pkgs, config, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.unstable.vscodium;
    enableUpdateCheck = true;
    enableExtensionUpdateCheck = true;
    extensions = with pkgs.unstable.vscode-extensions; [
      jnoortheen.nix-ide
      github-copilot
      ms-python-python
    ];
  };
}
