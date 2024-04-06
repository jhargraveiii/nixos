{ pkgs, ... }: {
  environment.systemPackages = with pkgs;
    [
      (julia.withPackages [
        "Lux"
        "SciMLBase"
        "SciMLNLSolve"
        "IJulia"
        "DataFrames"
        "CSV"
        "Plots"
        "Pluto"
      ])
    ];
}
