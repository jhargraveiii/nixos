{ pkgs, ... }: {
  environment.systemPackages = with pkgs;
    [
      (julia.withPackages [
        "DataFrames"
        "Plots"
        "LanguageServer"  
      ])
    ];
}
