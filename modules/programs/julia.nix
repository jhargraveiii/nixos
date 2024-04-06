{ pkgs, ... }: {
  environment.systemPackages = with pkgs;
    [ (julia.withPackages [ "IJulia" "DataFrames" "CSV" "Plots" ]) ];
}
