{ pkgs, ... }: {
  environment.systemPackages = with pkgs;
    [
      (python312.withPackages (python-pkgs:
        with python-pkgs; [
          virtualenv
        ]))
    ];
}
