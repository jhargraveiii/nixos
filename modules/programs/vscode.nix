{ pkgs, ... }: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    enableUpdateCheck = true;
    enableExtensionUpdateCheck = true;
    extensions = with pkgs.vscode-extensions;
      [
        yzhang.markdown-all-in-one
        jnoortheen.nix-ide
        ms-pyright.pyright
        ms-python.python
        github.copilot
        github.copilot-chat
        redhat.vscode-xml
        redhat.vscode-yaml
        julialang.language-julia
        tamasfe.even-better-toml
        zxh404.vscode-proto3
        eamodio.gitlens
        arrterian.nix-env-selector
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [ ];
  };
}
