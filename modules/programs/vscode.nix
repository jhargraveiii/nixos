{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    enableUpdateCheck = true;
    enableExtensionUpdateCheck = true;
    extensions =
      with pkgs.vscode-extensions;
      [
        yzhang.markdown-all-in-one
        jnoortheen.nix-ide
        github.copilot
        github.copilot-chat
        redhat.vscode-xml
        redhat.vscode-yaml
        ms-python.python
        bungcip.better-toml
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      ];
  };
}
