{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    profiles.default.enableUpdateCheck = true;
    profiles.default.enableExtensionUpdateCheck = true;

    profiles.default.extensions =
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
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      ];
  };
}
