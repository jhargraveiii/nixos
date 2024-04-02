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
        redhat.vscode-xml
        redhat.vscode-yaml
        tamasfe.even-better-toml
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          publisher = "GitHub";
          name = "copilot-chat";
          version = "0.14.2024031301";
          sha256 = "sha256-tkeh3q8GP5ZYIOOwwotkRW7nNjFaucmxHI8IgoRPnMY=";
        }
        {
          publisher = "nimlang";
          name = "nimlang";
          version = "0.9.0";
          sha256 = "sha256-vaQ9YXSmVYDnAulv8ymxCyboLs+MK1p1mpk7f0Necr0=";
        }
      ];
  };
}
