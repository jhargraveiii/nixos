{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
    enableUpdateCheck = true;
    enableExtensionUpdateCheck = true;
    extensions =
      with pkgs.vscode-extensions;
      [
        yzhang.markdown-all-in-one
        jnoortheen.nix-ide
        ms-python.vscode-pylance

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
        {
          name = "python";
          publisher = "ms-python";
          version = "2024.15.2024091301";
          sha256 = "sha256-MB8Vq2rjO37yW3Zh+f8ek/yz0qT+ZYHn/JnF5ZA6CXQ=";
        }
      ];
  };
}
