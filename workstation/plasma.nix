{...}:
{
  programs.plasma = {
    enable = true;
    shortcuts = { };
    configFile = {
      "kdeglobals"."General"."AllowKDEAppsToRememberWindowPositions" = true;
      "kdeglobals"."KDE"."SingleClick" = false;
      "kdeglobals"."WM"."activeBackground" = "227,229,231";
      "kdeglobals"."WM"."activeBlend" = "227,229,231";
      "kdeglobals"."WM"."activeForeground" = "35,38,41";
      "kdeglobals"."WM"."inactiveBackground" = "239,240,241";
      "kdeglobals"."WM"."inactiveBlend" = "239,240,241";
      "kdeglobals"."WM"."inactiveForeground" = "112,125,138";
      "plasma-localerc"."Formats"."LANG" = "en_US.UTF-8";
    };
  };
}
