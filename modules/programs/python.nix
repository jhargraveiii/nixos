{ pkgs, ... }: {
  environment.systemPackages = with pkgs;
    [ (python312.withPackages (ps: with ps; [ numpy matplotlib pandas ])) ];
}
