{ config, lib, theKBDLayout, ... }:

let
  theme = config.colorScheme.palette;
in
with lib; {
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;
    plugins = [
    ];
    extraConfig =
      let
        modifier = "SUPER";
      in
      concatStrings [
        ''
          monitor=DP-1,3440x1440@100,auto,1
          env = WLR_NO_HARDWARE_CURSORS,1
          env = WLR_DRM_NO_ATOMIC,1 
          env = LIBVA_DRIVER_NAME,nvidia
          env = XDG_SESSION_TYPE,wayland
          env = XDG_CURRENT_DESKTOP,Hyprland
          env = XDG_SESSION_DESKTOP,Hyprland
          env = GBM_BACKEND,nvidia-drm
          env = QT_QPA_PLATFORM,wayland;xcb
          env = GDK_BACKEND,wayland,x11
          env = __GLX_VENDOR_LIBRARY_NAME,nvidia
          env = QT_WAYLAND_DISABLE_WINDOWDECORATION, 1
          env = QT_QPA_PLATFORMTHEME,qt5ct
          env = QT_AUTO_SCREEN_SCALE_FACTOR, 1
          env = CLUTTER_BACKEND, wayland
          env = SDL_VIDEODRIVER, wayland
          env = NIXPKGS_ALLOW_UNFREE, 1
          env = MOZ_ENABLE_WAYLAND, 1
          env = NIXOS_OZONE_WL,1
          env = _JAVA_AWT_WM_NONREPARENTING,1
          env = WLR_RENDERER_ALLOW_SOFTWARE,1
          env = __GL_VRR_ALLOWED,0
          env = __GL_GSYNC_ALLOWED,0
          env = ELECTRON_OZONE_PLATFORM_HINT,wayland

          input {
              kb_layout = ${theKBDLayout}
              follow_mouse = 1
              #kb_options = grp:alt_shift_toggle
              #kb_options=caps:super

              touchpad {
                  natural_scroll = false
              }
              sensitivity = 5
              repeat_rate = 25
              repeat_delay = 600
          }

          gestures {
              workspace_swipe = true
          }

          # Ensure Mouse or Keyboard Inputs Turn On Displays
          misc {
              disable_hyprland_logo = true
              disable_splash_rendering=true
              mouse_move_enables_dpms = true
              key_press_enables_dpms = true
              vrr = 0
              vfr = true
          } 

          animations {
              enabled = yes
              bezier = wind, 0.05, 0.9, 0.1, 1.05
              bezier = winIn, 0.1, 1.1, 0.1, 1.1
              bezier = winOut, 0.3, -0.3, 0, 1
              bezier = liner, 1, 1, 1, 1
              animation = border, 1, 1, liner
              animation = windows, 1, 6, wind, slide
              animation = windowsIn, 1, 6, winIn, slide
              animation = windowsOut, 1, 5, winOut, slide
              animation = windowsMove, 1, 5, wind, slide
              animation = fade, 1, 10, default
              animation = workspaces, 1, 5, wind
          }

          dwindle {
              pseudotile = true # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
              preserve_split = true # you probably want this
          }

          master {
              new_is_master = true
          }

          xwayland {
              force_zero_scaling = true
          }

          general {
              gaps_in = 1
              gaps_out = 1
              border_size = 1
              col.active_border = rgba(${theme.base0C}ff) rgba(${theme.base0D}ff) rgba(${theme.base0B}ff) rgba(${theme.base0E}ff) 45deg
              col.inactive_border = rgba(${theme.base00}cc) rgba(${theme.base01}cc) 45deg
              layout = dwindle
              resize_on_border = true
          }

          decoration {
              rounding = 10
              drop_shadow = false
              blur {
                  enabled = true
                  size = 5
                  passes = 3  
                  new_optimizations = true
                  ignore_opacity = true
              }
          }

          # Blur for waybar 
          blurls=waybar
          blurls=lockscreen

          exec-once = dbus-update-activation-environment --systemd --all
          exec-once = systemctl --user import-environment QT_QPA_PLATFORMTHEME WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
          exec-once=  blueman-applet # Make sure you have installed blueman
          exec-once = waybar
          exec-once = swaync
          exec-once = swww init
          exec-once = wallsetter
          exec-once = nm-applet --indicator
          exec-once = hyprctl setcursor Bibata-Modern-Ice 24
          exec-once = wl-paste --watch cliphist store
          exec-once = wlsunset -S 7:00 -s 18:00;notify-send "Brightness value changed: $(wlsunset -l)"
          exec-once = swayidle -w timeout 600 'swaylock -f' timeout 900 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on' before-sleep 'swaylock -f -c 000000'

          exec-once=[workspace 1 silent] slack --disable-gpu 
          exec-once=[workspace 1 silent] thunderbird
          exec-once=[workspace 2 silent] brave --disable-gpu

          # System Application Keybinds
          bind = ${modifier},		Return,	exec, kitty
          bind = ${modifier},		K,	  exec, klavaro
          bind = ${modifier},		G,	  exec, git-cola
          bind = ${modifier},	  A,	  exec, rofi -show drun
          bind = ${modifier},		W,		exec, brave --disable-gpu
          bind = ${modifier},		E,		exec, thunderbird
          bind = ${modifier},		J,		exec, idea-ultimate
          bind = ${modifier},		T,		exec, thunar
          bind = ${modifier},		C,		exec, code --disable-gpu
          bind = ${modifier},		V,		exec, VirtualBoxVM --comment "Windows" --startvm "{9b1ee206-252e-44c1-b8e9-098039c50d35}"
          bind = ${modifier},		S,		exec, slack --disable-gpu
          bind = ${modifier},		O,		exec, JAVA_HOME=/home/jimh/.jdks/openjdk21/bin oxygenDeveloper.sh
          bind = ${modifier},		M,		exec, flatpak run com.microsoft.Edge --disable-gpu
          bind = ${modifier} SHIFT,	E,	exec, emopicker9000
          bind = ${modifier} SHIFT,	S,	exec, grim -g "$(slurp)" - | swappy -f -
          bind = ${modifier} SHIFT,	C,  exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy

          # Hyprland Keybinds
          bind = ${modifier},Q,killactive,
          bind = ${modifier},P,pseudo,
          bind = ${modifier}SHIFT,I,togglesplit,
          bind = ${modifier},F,fullscreen,
          bind = ${modifier}SHIFT,F,togglefloating,
          bind = ${modifier}SHIFT,left,movewindow,l
          bind = ${modifier}SHIFT,right,movewindow,r
          bind = ${modifier}SHIFT,up,movewindow,u
          bind = ${modifier}SHIFT,down,movewindow,d
          bind = ${modifier}SHIFT,h,movewindow,l
          bind = ${modifier}SHIFT,l,movewindow,r
          bind = ${modifier}SHIFT,k,movewindow,u
          bind = ${modifier}SHIFT,j,movewindow,d
          bind = ${modifier},left,movefocus,l
          bind = ${modifier},right,movefocus,r
          bind = ${modifier},up,movefocus,u
          bind = ${modifier},down,movefocus,d
          bind = ${modifier},h,movefocus,l
          bind = ${modifier},l,movefocus,r
          bind = ${modifier},k,movefocus,u
          bind = ${modifier},j,movefocus,d
          bind = ${modifier},1,workspace,1
          bind = ${modifier},2,workspace,2
          bind = ${modifier},3,workspace,3
          bind = ${modifier},4,workspace,4
          bind = ${modifier},5,workspace,5
          bind = ${modifier},6,workspace,6
          bind = ${modifier},7,workspace,7
          bind = ${modifier},8,workspace,8
          bind = ${modifier},9,workspace,9
          bind = ${modifier},0,workspace,10
          bind = ${modifier}SHIFT,SPACE,movetoworkspace,special
          bind = ${modifier},SPACE,togglespecialworkspace
          bind = ${modifier}SHIFT,1,movetoworkspace,1
          bind = ${modifier}SHIFT,2,movetoworkspace,2
          bind = ${modifier}SHIFT,3,movetoworkspace,3
          bind = ${modifier}SHIFT,4,movetoworkspace,4
          bind = ${modifier}SHIFT,5,movetoworkspace,5
          bind = ${modifier}SHIFT,6,movetoworkspace,6
          bind = ${modifier}SHIFT,7,movetoworkspace,7
          bind = ${modifier}SHIFT,8,movetoworkspace,8
          bind = ${modifier}SHIFT,9,movetoworkspace,9
          bind = ${modifier}SHIFT,0,movetoworkspace,10
          bind = ${modifier}CONTROL,right,workspace,e+1
          bind = ${modifier}CONTROL,left,workspace,e-1
          bind = ${modifier},mouse_down,workspace, e+1
          bind = ${modifier},mouse_up,workspace, e-1
          bindm = ${modifier},mouse:272,movewindow
          bindm = ${modifier},mouse:273,resizewindow
          bind = ALT,Tab,cyclenext
          bind = ALT,Tab,bringactivetotop
        ''
      ];
  };
}
