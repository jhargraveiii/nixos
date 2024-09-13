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
        ms-python.vscode-pylance
        #ms-python.python
        ms-toolsai.jupyter
        github.copilot
        github.copilot-chat
        redhat.vscode-xml
        redhat.vscode-yaml
        tamasfe.even-better-toml
        zxh404.vscode-proto3
        dotenv.dotenv-vscode
      ]
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "pixi-vscode";
          publisher = "jjjermiah";
          version = "1.0.1";
          sha256 = "sha256-+vHyjXT4Qiz/ZLtfd/3ZcgZfajzqfdOQC4pMkE+PSGU=";
        }
      ];
  };
}
