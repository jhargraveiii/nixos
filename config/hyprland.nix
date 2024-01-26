{ lib, inputs, pkgs, config, ... }:

{
wayland.windowManager.hyprland.enable = true;
wayland.windowManager.hyprland.extraConfig = 
''
# monitor=[monitor-name],[resolution@framerate],[pos-x,y],[scale factor],transform,[rotation]
# Rotation Degrees Shorthand
# normal (no transforms) -> 0
# 90 degrees -> 1
# 180 degrees -> 2
# 270 degrees -> 3
# flipped -> 4
# flipped + 90 degrees -> 5
# flipped + 180 degrees -> 6
# flipped + 270 degrees -> 7
monitor=,3440x1440@99.98,auto,1          # Automatic Configuration

# Example windowrule v1
# windowrule = float, ^(kitty)$
# Example windowrule v2
# windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
# See https://wiki.hyprland.org/Configuring/Window-Rules/ for more

input {
    kb_layout = us
    follow_mouse = 1
    touchpad {
        natural_scroll = false
    }

    sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
}

gestures {
    workspace_swipe = false
}

# Ensure Mouse or Keyboard Inputs Turn On Displays
misc {
    disable_hyprland_logo = true
    disable_splash_rendering=true
    mouse_move_enables_dpms = true
    key_press_enables_dpms = true
    #vfr = true
} 

animations {
    enabled = yes
    # Define Settings For Animation Bezier Curve
    bezier = wind, 0.05, 0.9, 0.1, 1.05
    bezier = winIn, 0.1, 1.1, 0.1, 1.1
    bezier = winOut, 0.3, -0.3, 0, 1
    bezier = liner, 1, 1, 1, 1

    animation = windows, 1, 6, wind, slide
    animation = windowsIn, 1, 6, winIn, slide
    animation = windowsOut, 1, 5, winOut, slide
    animation = windowsMove, 1, 5, wind, slide
    animation = border, 1, 1, liner
    animation = borderangle, 1, 30, liner, loop
    animation = fade, 1, 10, default
    animation = workspaces, 1, 5, wind
}

exec-once = dbus-update-activation-environment --systemd --all
exec-once = systemctl --user import-environment QT_QPA_PLATFORMTHEME WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
#exec-once= hyprpaper
exec-once=  blueman-applet # Make sure you have installed blueman + blueman-utils
exec-once = waybar
exec-once = swaync
exec-once = nm-applet --indicator
exec-once = wallsetter
exec-once = hyprctl setcursor Bibata-Modern-Ice 24
exec-once = wl-paste --watch cliphist store
exec-once = wlsunset -S 7:00 -s 18:00;notify-send "Brightness value changed: $(wlsunset -l)"
exec-once = swayidle timeout 900 'swaylock -f -c 000000'
env = WLR_NO_HARDWARE_CURSORS,1
env = LIBVA_DRIVER_NAME,nvidia
env = XDG_SESSION_TYPE,wayland
env = XDG_CURRENT_DESKTOP,Hyprland
env = XDG_SESSION_DESKTO,Hyprland
env = GBM_BACKEND,nvidia-drm
env = QT_QPA_PLATFORM,wayland
env = GDK_BACKEND,wayland
env = __GLX_VENDOR_LIBRARY_NAME,nvidia

$mainMod = SUPER
# System Application Keybinds
bind = $mainMod,		Return,	exec, kitty
bind = $mainMod,		G,	    exec, git-cola
bind = $mainMod,	    A,	    exec, rofi -show drun
bind = $mainMod,		W,		exec, chromium
bind = $mainMod,		E,		exec, thunderbird
bind = $mainMod,		J,		exec, idea-ultimate
bind = $mainMod,		T,		exec, thunar
bind = $mainMod,		C,		exec, codium
bind = $mainMod,		V,		exec, VirtualBox
bind = $mainMod,		S,		exec, slack
bind = $mainMod,		O,		exec, sh ~/oxygenDeveloper/oxygenDeveloper.sh
bind = $mainMod SHIFT,	E,		exec, emopicker9000
bind = $mainMod SHIFT,	S,		exec, grim -g "$(slurp)"
bind = $mainMod SHIFT,	C,      exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy

# Hyprland Keybinds
bind = $mainMod,		Q,		killactive,
bind = $mainMod,		P,		pseudo, # dwindle
bind = $mainMod SHIFT,		I,		togglesplit, # dwindle
bind = $mainMod,	    	F,		fullscreen,
bind = $mainMod SHIFT,		F,		togglefloating,
# Move window with mainMod + shift + arrow keys
bind = $mainMod SHIFT,	left,			movewindow, l
bind = $mainMod SHIFT,	right,			movewindow, r
bind = $mainMod SHIFT,	up,			movewindow, u
bind = $mainMod SHIFT,	down,			movewindow, d
bind = $mainMod SHIFT,	h,			movewindow, l
bind = $mainMod SHIFT,	l,			movewindow, r
bind = $mainMod SHIFT,	k,			movewindow, u
bind = $mainMod SHIFT,	j,			movewindow, d
# Move focus with mainMod + arrow keys
bind = $mainMod,		left,		movefocus, l
bind = $mainMod,		right,		movefocus, r
bind = $mainMod,		up,		movefocus, u
bind = $mainMod,		down,		movefocus, d
bind = $mainMod,		h,		movefocus, l
bind = $mainMod,		l,		movefocus, r
bind = $mainMod,		k,		movefocus, u
bind = $mainMod,		j,		movefocus, d
# Switch workspaces with mainMod + [0-6]
bind = $mainMod,		1,		workspace, 1
bind = $mainMod,		2,		workspace, 2
bind = $mainMod,		3,		workspace, 3
bind = $mainMod,		4,		workspace, 4
bind = $mainMod,		5,		workspace, 5
bind = $mainMod,		6,		workspace, 6
bind = $mainMod,		7,		workspace, 7
bind = $mainMod,		8,		workspace, 8
bind = $mainMod,		9,		workspace, 9
bind = $mainMod,		0,		workspace, 10
# Move active window to a workspace with mainMod + SHIFT + [0-6]
bind = $mainMod SHIFT,	1,		movetoworkspace, 1
bind = $mainMod SHIFT,	2,		movetoworkspace, 2
bind = $mainMod SHIFT,	3,		movetoworkspace, 3
bind = $mainMod SHIFT,	4,		movetoworkspace, 4
bind = $mainMod SHIFT,	5,		movetoworkspace, 5
bind = $mainMod SHIFT,	6,		movetoworkspace, 6
bind = $mainMod SHIFT,	7,		movetoworkspace, 7
bind = $mainMod SHIFT,	8,		movetoworkspace, 8
bind = $mainMod SHIFT,	9,		movetoworkspace, 9
bind = $mainMod SHIFT,	0,		movetoworkspace, 0

# Scroll through existing workspaces with mainMod + scroll
bind = $mainMod,		mouse_down, workspace, e+1
bind = $mainMod,		mouse_up,	workspace, e-1
# Move/resize windows with mainMod + LMB/RMB and dragging
bindm = $mainMod,		mouse:272,	movewindow
bindm = $mainMod,		mouse:273,	resizewindow

dwindle {
    pseudotile = true # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
    preserve_split = true # you probably want this
}

master {
    new_is_master = true
    new_on_top = true
    no_gaps_when_only = true
}

general {
    gaps_in = 2
    gaps_out = 4
    border_size = 1
    col.active_border = rgba(${config.colorScheme.colors.base0C}ff) rgba(${config.colorScheme.colors.base0D}ff) 45deg
    col.inactive_border = rgba(${config.colorScheme.colors.base00}cc) rgba(${config.colorScheme.colors.base01}cc) 45deg
    layout = dwindle
    resize_on_border = true
}

decoration {
    rounding=18
    blur {
        enabled=1
        size=6.8 # minimum 1
        passes=2 # minimum 1, more passes = more resource intensive.
        new_optimizations = true   

        # Your blur "amount" is size * passes, but high size (over around 5-ish)
        # will produce artifacts.
        # if you want heavy blur, you need to up the passes.
        # the more passes, the more you can up the size without noticing artifacts.
    }
    drop_shadow=true
    shadow_range=15
    col.shadow=0xffa7caff
    col.shadow_inactive=0x50000000
}

# Blur for waybar 
blurls=waybar
blurls=lockscreen
'';
}
