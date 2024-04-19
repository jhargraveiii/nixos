{ pkgs, ... }: {
  environment.systemPackages = with pkgs;
    [ (julia.withPackages [ "LanguageServer" ]) ];
}
