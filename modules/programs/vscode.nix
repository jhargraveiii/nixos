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
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "copilot";
          publisher = "GitHub";
          version = "1.162.714";
          sha256 = "sha256-qPdKzmmX3Tdbq+Qw2uNfPDczHgwb6sL2eFRCTzyoN3c=";
        }
        {
          name = "jnoortheen.nix-ide";
          publisher = "Noortheen";
          version = "0.2.2";
          sha256 = "8f038cfba2e71f20a4be13935524d466f831efb8c083a845082a41a98f00c488";
        }
        {
          name = "toml";
          publisher = "be5invis";
          version = "0.6.0";
          sha256 = "yk7buEyQIw6aiUizAm+sgalWxUibIuP9crhyBaOjC2E=";
        }
      ];
  };
}
