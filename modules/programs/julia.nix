{ pkgs, ... }: {
  environment.systemPackages = with pkgs;
    [
      (julia.withPackages [
        "Lux"
        "SciMLBase"
        "SciMLNLSolve"
        "DataFrames"
        "CSV"
        "Plots"
        "Pluto"
        "LanguageServer"
        "Zygote"
        "Distributions"
        "PythonCall"
        "Transformers"
        "Gadfly"
        "Chain"
      ])
    ];
}
