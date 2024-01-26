{ pkgs, config, ... }:

{
  # Configure & Theme Waybar
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
    settings = [{
      layer = "top";
      position = "top";

      modules-left = [ "hyprland/window" ];
      modules-center = [ "temperature" "network" "bluetooth" "pulseaudio" "cpu" "hyprland/workspaces" "memory" "disk" "clock" ];
      modules-right = [ "custom/weather" "custom/notification" "tray" ];
      "hyprland/workspaces" = {
      	format = "{icon}";
      	format-icons = {
          active = " 󱎴";
          default = "󰍹";
      	};
				persistent-workspaces = {
              "1" = [];
              "2" = [];
              "3" = [];
              "4" = [];
              "5" = [];
              "6" = [];
              "7" = [];
              "8" = [];
              "9" = [];
        };
				on-click = "activate";
      	on-scroll-up = "hyprctl dispatch workspace e+1";
      	on-scroll-down = "hyprctl dispatch workspace e-1";
      };
      "clock" = {
        format = "{: %I:%M %p}";
				format-alt = "{: %A, %B %d, %Y (%I:%M %p)}";
        tooltip-format = "<tt><small>{calendar}</small></tt>";
				tooltip = true;
				calendar = {
                    mode =          "year";
                    mode-mon-col =   3;
                    weeks-pos    = "right";
                    on-scroll = 1;
                    on-click-right = "mode";
                    format = {
                              months =    "<span color='#ffead3'><b>{}</b></span>";
                              days   =    "<span color='#ecc6d9'><b>{}</b></span>";
                              weeks  =    "<span color='#99ffdd'><b>W{}</b></span>";
                              weekdays =  "<span color='#ffcc66'><b>{}</b></span>";
                              today    =  "<span color='#ff6699'><b><u>{}</u></b></span>";
                              };
                    };
				 actions = {
                    on-click-right = "mode";
                    on-click-forward = "tz_up";
                    on-click-backward = "tz_down";
                    on-scroll-up = "shift_up";
                    on-scroll-down = "shift_down";
                    };						
      };
      "hyprland/window" = {
      	max-length = 60;
      	separate-outputs = true;
      };
      "memory" = {
      	interval = 5;
      	format = " {used:0.1f}G/{total:0.1f}G";
        tooltip = true;
      };
      "cpu" = {
      	interval = 5;
      	format = " {usage:2}%";
        tooltip = true;
      };
      "disk" = {
        format = "  {free}";
        tooltip = true;
      };
			 "bluetooth" = {
            format = "{icon}";
            format-alt = "bluetooth: {status}";
            interval = 30;
            format-icons = {
              enabled = "";
              disabled = "󰂲";
            };
            tooltip-format = "{status}";
      };
      "network" = {
        format-icons = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
        format-ethernet = ": {bandwidthDownOctets} : {bandwidthUpOctets}";
        format-wifi = "{icon} {signalStrength}%";
        format-disconnected = "󰤮";
        tooltip = false;
      };
      "tray" = {
        spacing = 12;
      };
      "pulseaudio" = {
        format = "{icon} {volume}% {format_source}";
        format-bluetooth = "{volume}% {icon} {format_source}";
        format-bluetooth-muted = " {icon} {format_source}";
        format-muted = " {format_source}";
        format-source = " {volume}%";
        format-source-muted = "";
        format-icons = {
          headphone = "";
          hands-free = "";
          headset = "";
          portable = "";
          default = ["" "" ""];
        };
        on-click = "pavucontrol";
      };
			
			"temperature" = {
        thermal-zone = 1;
				hwmon-path = "/sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon2/temp1_input";
        format = " {temperatureC}°C";
				format-icons = ["" 
						""
						""
						""
						""
					];
				tooltip = false;
        critical-threshold = 60;
        format-critical = " {temperatureC}°C";
        on-click = "kitty --start-as=fullscreen --title btop sh -c 'btop'";
      };

			"custom/weather" = {
					exec = "nix-shell ~/.config/waybar/scripts/weather.py";
					restart-interval = 300;
					return-type = "json";
				};

      "custom/notification" = {
        tooltip = false;
        format = "{icon} {}";
        format-icons = {
          notification = "<span foreground='red'><sup></sup></span>";
          none = "";
          dnd-notification = "<span foreground='red'><sup></sup></span>";
          dnd-none = "";
          inhibited-notification = "<span foreground='red'><sup></sup></span>";
          inhibited-none = "";
          dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
          dnd-inhibited-none = "";
       	};
        return-type = "json";
        exec-if = "which swaync-client";
        exec = "swaync-client -swb";
        on-click = "task-waybar";
        escape = true;
      };
    }];
    style = ''
	* {
		font-size: 16px;
		font-family: JetBrainsMono Nerd Font, Font Awesome, sans-serif;
    		font-weight: bold;
	}
	window#waybar {
		    background-color: rgba(26,27,38,0);
    		border-bottom: 1px solid rgba(26,27,38,0);
    		border-radius: 0px;
				border: 0px;
		    color: #${config.colorScheme.colors.base0F};
    		padding: 0px 1px;
	}
	#workspaces {
		    background: linear-gradient(180deg, #${config.colorScheme.colors.base00}, #${config.colorScheme.colors.base01});
    		margin: 5px;
    		padding: 0px 1px;
    		border-radius: 15px;
    		border: 0px;
    		font-style: normal;
    		color: #${config.colorScheme.colors.base00};
	}
	#workspaces button {
    		padding: 0px 5px;
    		margin: 4px 3px;
    		border-radius: 15px;
    		border: 0px;
    		color: #${config.colorScheme.colors.base00};
    		background-color: #${config.colorScheme.colors.base00};
    		opacity: 1.0;
    		transition: all 0.3s ease-in-out;
	}
	#workspaces button.active {
    		color: #${config.colorScheme.colors.base00};
    		background: #${config.colorScheme.colors.base04};
    		border-radius: 15px;
    		min-width: 40px;
    		transition: all 0.3s ease-in-out;
    		opacity: 1.0;
	}
	#workspaces button:hover {
    		color: #${config.colorScheme.colors.base00};
    		background: #${config.colorScheme.colors.base04};
    		border-radius: 15px;
    		opacity: 1.0;
	}
	#tooltip {
  		background: #${config.colorScheme.colors.base00};
  		border: 1px solid #${config.colorScheme.colors.base04};
  		border-radius: 10px;
	}
	#tooltip label {
  		color: #${config.colorScheme.colors.base07};
	}
	#window {
    		color: #${config.colorScheme.colors.base05};
    		background: #${config.colorScheme.colors.base00};
    		border-radius: 0px 15px 50px 0px;
    		margin: 5px 5px 5px 0px;
    		padding: 2px 20px;
	}
	#memory {
    		color: #${config.colorScheme.colors.base0F};
    		background: #${config.colorScheme.colors.base00};
    		border-radius: 15px 50px 15px 50px;
    		margin: 5px;
    		padding: 2px 20px;
	}
	#clock {
    		color: #${config.colorScheme.colors.base0B};
    		background: #${config.colorScheme.colors.base00};
    		border-radius: 15px 50px 15px 50px;
    		margin: 5px;
    		padding: 2px 20px;
	}
	#cpu {
    		color: #${config.colorScheme.colors.base07};
    		background: #${config.colorScheme.colors.base00};
    		border-radius: 50px 15px 50px 15px;
    		margin: 5px;
    		padding: 2px 20px;
	}
	#disk {
    		color: #${config.colorScheme.colors.base03};
    		background: #${config.colorScheme.colors.base00};
    		border-radius: 15px 50px 15px 50px;
    		margin: 5px;
    		padding: 2px 20px;
	}
	#bluetooth {
    		color: #${config.colorScheme.colors.base07};
    		background: #${config.colorScheme.colors.base00};
    		border-radius: 50px 15px 50px 15px;
    		margin: 5px;
    		padding: 2px 20px;
	}
	#network {
    		color: #${config.colorScheme.colors.base09};
    		background: #${config.colorScheme.colors.base00};
    		border-radius: 50px 15px 50px 15px;
    		margin: 5px;
    		padding: 2px 20px;
	}
	tray {
    		color: #${config.colorScheme.colors.base05};
    		background: #${config.colorScheme.colors.base00};
    		border-radius: 15px 0px 0px 50px;
    		margin: 5px 0px 5px 5px;
    		padding: 2px 20px;
	}
	#pulseaudio {
    		color: #${config.colorScheme.colors.base0D};
    		background: #${config.colorScheme.colors.base00};
    		border-radius: 50px 15px 50px 15px;
    		margin: 5px;
    		padding: 2px 20px;
	}
	#temperature.critical {
    color: #e92d4d;
  }
	#temperature {
				color: #${config.colorScheme.colors.base0D};
				background: #${config.colorScheme.colors.base00};
				border-radius: 50px 15px 50px 15px;
				margin: 5px;
				padding: 2px 20px;
  }
	#custom-notification {
    		color: #${config.colorScheme.colors.base0C};
    		background: #${config.colorScheme.colors.base00};
    		border-radius: 15px 50px 15px 50px;
    		margin: 5px;
    		padding: 2px 20px;
	}
  #custom-weather,
	#custom-weather.severe,
	#custom-weather.sunnyDay,
	#custom-weather.clearNight,
	#custom-weather.cloudyFoggyDay,
	#custom-weather.cloudyFoggyNight,
	#custom-weather.rainyDay,
	#custom-weather.rainyNight,
	#custom-weather.showyIcyDay,
	#custom-weather.snowyIcyNight,
	#custom-weather.default {
		color: #e5e5e5;
		border-radius: 6px;
		padding: 2px 10px;
		background-color: #252733;
		border-radius: 8px;
		font-size: 16px;

		margin-left: 4px;
		margin-right: 4px;

		margin-top: 8.5px;
		margin-bottom: 8.5px;
	}	
	#custom-weather {
				font-family: Iosevka Nerd Font;
				font-size: 19px;
				color: #8a909e;
			}

			#custom-weather.severe {
				color: #eb937d;
			}

			#custom-weather.sunnyDay {
				color: #c2ca76;
			}

			#custom-weather.clearNight {
				color: #cad3f5;
			}

			#custom-weather.cloudyFoggyDay,
			#custom-weather.cloudyFoggyNight {
				color: #c2ddda;
			}

			#custom-weather.rainyDay,
			#custom-weather.rainyNight {
				color: #5aaca5;
			}

			#custom-weather.showyIcyDay,
			#custom-weather.snowyIcyNight {
				color: #d6e7e5;
			}

			#custom-weather.default {
				color: #dbd9d8;
			}
    '';
  };
}
