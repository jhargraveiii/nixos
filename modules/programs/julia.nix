{ pkgs, ... }: {
  environment.systemPackages = with pkgs;
    [
      (julia.withPackages [
        "DataFrames"
        "CSV"
        "Plots"
        "Pluto"
        "LanguageServer"
        "Gadfly"
        "Chain"
      ])
    ];
}
