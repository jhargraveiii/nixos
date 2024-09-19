{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    enableUpdateCheck = true;
    enableExtensionUpdateCheck = true;
    extensions =
      with pkgs.vscode-extensions;
      [
        github.copilot
        github.copilot-chat
        ms-python.vscode-pylance
        ms-python.python
        yzhang.markdown-all-in-one
        jnoortheen.nix-ide
        ms-toolsai.jupyter
        redhat.vscode-xml
        redhat.vscode-yaml
        tamasfe.even-better-toml
        zxh404.vscode-proto3
        dotenv.dotenv-vscode
      ]
      ++
        pkgs.vscode-utils.extensionsFromVscodeMarketplace
          [
          ];
  };
}
