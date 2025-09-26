{ config
, pkgs
, lib
, username ? null
, ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption types mkDefault;

  cfg = config.services.tuxflow;

  nerdDirRel = ".local/share/tuxflow/nerd-dictation";

  # Wrapper scripts installed into PATH
  tuxflowStart = pkgs.writeShellScriptBin "tuxflow-start" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail
    export PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.libnotify pkgs.wl-clipboard pkgs.dotool pkgs.pipewire ]}
    # Ensure libstdc++.so.6 is available for Vosk's bundled libvosk.so
    export LD_LIBRARY_PATH=${lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib ]}:"$LD_LIBRARY_PATH"
    notify-send "Tux-Flow" "STT Started"
    state_dir="$HOME/.local/state/tuxflow"
    log_dir="$state_dir/logs"
    mkdir -p "$log_dir"
    run_dir="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/tuxflow"
    mkdir -p "$run_dir"
    dict_file="$run_dir/dictation.txt"
    rm -f "$dict_file"

    if [ "${builtins.toString cfg.dictation.safePasteOnEnd}" = "true" ]; then
      # Buffer output to a file; paste on end
      "$HOME/${nerdDirRel}/venv/bin/python" "$HOME/${nerdDirRel}/nerd-dictation" begin --input PW-CAT --output STDOUT --vosk-model-dir "$HOME/.config/nerd-dictation/model" >> "$dict_file" 2> "$log_dir/stt.log"
    else
      # Realtime typing into the focused app
      "$HOME/${nerdDirRel}/venv/bin/python" "$HOME/${nerdDirRel}/nerd-dictation" begin --input PW-CAT --simulate-input-tool DOTOOL --vosk-model-dir "$HOME/.config/nerd-dictation/model" > "$log_dir/stt.log" 2>&1
    fi
  '';

  tuxflowStop = pkgs.writeShellScriptBin "tuxflow-stop" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail
    export PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.libnotify ]}
    notify-send "Tux-Flow" "STT Stopped"
    "$HOME/${nerdDirRel}/venv/bin/python" "$HOME/${nerdDirRel}/nerd-dictation" end || true

    # Paste buffered text if safePasteOnEnd
    if [ "${builtins.toString cfg.dictation.safePasteOnEnd}" = "true" ]; then
      run_dir="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/tuxflow"
      dict_file="$run_dir/dictation.txt"
      if [ -s "$dict_file" ]; then
        TEXT=$(cat "$dict_file")
        if [ -n "$TEXT" ]; then
          ${pkgs.wl-clipboard}/bin/wl-copy --paste-once --trim-newline <<< "$TEXT"
          sleep 0.15
          ${pkgs.dotool}/bin/dotool <<< "key ctrl+v" || true
          sleep 0.12
          ${pkgs.dotool}/bin/dotool <<< "key shift+Insert" || true
        fi
      fi
      : > "$dict_file" || true
    fi
  '';

  aiEditSelected = pkgs.writeShellScriptBin "tuxflow-ai-edit-selected" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail
    export PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.wl-clipboard pkgs.jq pkgs.curl pkgs.dotool pkgs.libnotify pkgs.wtype ]}
    
    # Get current window info for refocusing later (Plasma 6 compatible)
    ACTIVE_WINDOW=""
    if command -v qdbus >/dev/null 2>&1; then
      # Plasma 6/KWin method
      ACTIVE_WINDOW=$(qdbus org.kde.KWin /KWin org.kde.KWin.activeWindow 2>/dev/null || echo "")
    elif command -v xdotool >/dev/null 2>&1; then
      # X11 fallback
      ACTIVE_WINDOW=$(xdotool getactivewindow 2>/dev/null || echo "")
    fi
    
    # Copy currently selected text
    echo "key ctrl+c" | dotool
    sleep 0.2
    
    # Retry to capture selection from clipboard
    SELECTED_TEXT=""
    for i in $(seq 1 10); do
      sleep 0.1
      SELECTED_TEXT=$(wl-paste 2>/dev/null || true)
      [ -n "$SELECTED_TEXT" ] && break
    done
    
    if [ -z "$SELECTED_TEXT" ]; then
      notify-send "AI Editor" "No text selected. Please select text first."
      exit 1
    fi
    
    state_dir="$HOME/.local/state/tuxflow"; log_dir="$state_dir/logs"; mkdir -p "$log_dir"
    echo "[$(date +%F\ %T)] selected $(printf %s "$SELECTED_TEXT" | wc -c) bytes" >> "$log_dir/ai-edit.log"

    # Show processing notification without stealing focus
    notify-send -u low "AI Editor" "Processing text..." &
    
    # Get AI-edited text
    EDITED_TEXT=$(jq -n --arg text "$SELECTED_TEXT" --arg model ${lib.escapeShellArg cfg.ai.model} '{
      "model": $model,
      "prompt": ("Fix grammar, spelling, and improve clarity of this text. Return only the corrected text without quotes or explanation:\n\n" + $text),
      "stream": false,
      "keep_alive": "15m",
      "options": {"temperature": 0.1, "top_p": 0.9}
    }' | curl --fail --max-time 30 -s http://localhost:11434/api/generate -d @- | tee -a "$log_dir/ai-edit.log" | jq -r '.response // (.message.content // empty) // empty')
    
    if [ -z "$EDITED_TEXT" ]; then
      notify-send "AI Editor" "AI service error or no response"
      exit 1
    fi
    
    # Refocus original window if possible (Plasma 6 compatible)
    if [ -n "$ACTIVE_WINDOW" ]; then
      if command -v qdbus >/dev/null 2>&1; then
        # Plasma 6/KWin method
        qdbus org.kde.KWin /KWin org.kde.KWin.activateWindow "$ACTIVE_WINDOW" 2>/dev/null || true
      elif command -v xdotool >/dev/null 2>&1; then
        # X11 fallback
        xdotool windowactivate "$ACTIVE_WINDOW" 2>/dev/null || true
      fi
      sleep 0.2
    fi
    
    # Replace selected text with edited version - multiple methods for reliability
    echo "$EDITED_TEXT" | wl-copy --trim-newline
    sleep 0.1
    
    # Method 1: Try ctrl+v
    echo "key ctrl+v" | dotool
    sleep 0.2
    
    # Method 2: Fallback to typing if paste might have failed
    # Check if we still have focus by trying to select what we just pasted
    echo "key ctrl+a" | dotool
    sleep 0.1
    echo "key ctrl+c" | dotool  
    sleep 0.1
    PASTED_TEXT=$(wl-paste 2>/dev/null || true)
    
    # If paste failed or text doesn't match, use wtype as fallback
    if [ "$PASTED_TEXT" != "$EDITED_TEXT" ]; then
      # First clear any selected text and position cursor
      echo "key ctrl+a" | dotool
      sleep 0.1
      # Type the text directly
      printf "%s" "$EDITED_TEXT" | wtype -
    fi
    
    notify-send -u low "AI Editor" "Text improved!"
  '';

  aiEditRecent = pkgs.writeShellScriptBin "tuxflow-ai-edit-recent" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail
    export PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.wl-clipboard pkgs.jq pkgs.curl pkgs.dotool pkgs.libnotify pkgs.wtype ]}
    
    # Get current window info for refocusing later (Plasma 6 compatible)
    ACTIVE_WINDOW=""
    if command -v qdbus >/dev/null 2>&1; then
      # Plasma 6/KWin method
      ACTIVE_WINDOW=$(qdbus org.kde.KWin /KWin org.kde.KWin.activeWindow 2>/dev/null || echo "")
    elif command -v xdotool >/dev/null 2>&1; then
      # X11 fallback
      ACTIVE_WINDOW=$(xdotool getactivewindow 2>/dev/null || echo "")
    fi
    
    # Try to select recent text using various methods
    # Method 1: Select paragraph (ctrl+Up, ctrl+shift+Down)
    echo "key ctrl+Up" | dotool; sleep 0.1
    echo "key ctrl+shift+Down" | dotool; sleep 0.1
    echo "key ctrl+c" | dotool; sleep 0.2
    
    SELECTED_TEXT=""
    for i in $(seq 1 10); do
      sleep 0.1
      SELECTED_TEXT=$(wl-paste 2>/dev/null || true)
      [ -n "$SELECTED_TEXT" ] && break
    done
    
    # Method 2: Select current line if paragraph selection failed
    if [ -z "$SELECTED_TEXT" ] || [ "$(printf %s "$SELECTED_TEXT" | wc -c)" -lt 5 ]; then
      echo "key Home" | dotool; sleep 0.1
      echo "key shift+End" | dotool; sleep 0.1
      echo "key ctrl+c" | dotool; sleep 0.2
      SELECTED_TEXT=$(wl-paste 2>/dev/null || true)
    fi
    
    # Method 3: Select all as last resort
    if [ -z "$SELECTED_TEXT" ] || [ "$(printf %s "$SELECTED_TEXT" | wc -c)" -lt 5 ]; then
      echo "key ctrl+a" | dotool; sleep 0.1
      echo "key ctrl+c" | dotool; sleep 0.1
      SELECTED_TEXT=$(wl-paste 2>/dev/null || true)
    fi
    
    if [ -z "$SELECTED_TEXT" ]; then
      notify-send "AI Editor" "No text found to edit"
      exit 1
    fi
    
    state_dir="$HOME/.local/state/tuxflow"; log_dir="$state_dir/logs"; mkdir -p "$log_dir"
    echo "[$(date +%F\ %T)] auto-selected $(printf %s "$SELECTED_TEXT" | wc -c) bytes" >> "$log_dir/ai-edit.log"

    # Show processing notification without stealing focus
    notify-send -u low "AI Editor" "Processing text..." &

    # Get AI-edited text
    EDITED_TEXT=$(jq -n --arg text "$SELECTED_TEXT" --arg model ${lib.escapeShellArg cfg.ai.model} '{
      "model": $model,
      "prompt": ("Fix grammar, spelling, and improve clarity of this text. Return only the corrected text without quotes or explanation:\n\n" + $text),
      "stream": false,
      "keep_alive": "15m",
      "options": {"temperature": 0.1, "top_p": 0.9}
    }' | curl --fail --max-time 30 -s http://localhost:11434/api/generate -d @- | tee -a "$log_dir/ai-edit.log" | jq -r '.response // (.message.content // empty) // empty')
    
    if [ -z "$EDITED_TEXT" ]; then
      notify-send "AI Editor" "AI service error"
      exit 1
    fi
    
    # Refocus original window if possible (Plasma 6 compatible)
    if [ -n "$ACTIVE_WINDOW" ]; then
      if command -v qdbus >/dev/null 2>&1; then
        # Plasma 6/KWin method
        qdbus org.kde.KWin /KWin org.kde.KWin.activateWindow "$ACTIVE_WINDOW" 2>/dev/null || true
      elif command -v xdotool >/dev/null 2>&1; then
        # X11 fallback
        xdotool windowactivate "$ACTIVE_WINDOW" 2>/dev/null || true
      fi
      sleep 0.2
    fi
    
    # Replace selected text with edited version - multiple methods for reliability
    echo "$EDITED_TEXT" | wl-copy --trim-newline
    sleep 0.1
    
    # Method 1: Try ctrl+v
    echo "key ctrl+v" | dotool
    sleep 0.2
    
    # Method 2: Fallback to typing if paste might have failed
    # Check if we still have focus by trying to select what we just pasted
    echo "key ctrl+a" | dotool
    sleep 0.1
    echo "key ctrl+c" | dotool  
    sleep 0.1
    PASTED_TEXT=$(wl-paste 2>/dev/null || true)
    
    # If paste failed or text doesn't match, use wtype as fallback
    if [ "$PASTED_TEXT" != "$EDITED_TEXT" ]; then
      # First clear any selected text and position cursor
      echo "key ctrl+a" | dotool
      sleep 0.1
      # Type the text directly
      printf "%s" "$EDITED_TEXT" | wtype -
    fi
    
    notify-send -u low "AI Editor" "Text improved!"
  '';

  

  endAndEdit = pkgs.writeShellScriptBin "tuxflow-end-and-edit" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail
    ${tuxflowStop}/bin/tuxflow-stop || true
    ${aiEditRecent}/bin/tuxflow-ai-edit-recent
  '';

  aiUnload = pkgs.writeShellScriptBin "tuxflow-ai-unload" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail
    ${pkgs.curl}/bin/curl -s http://localhost:11434/api/generate -d "$(jq -n --arg model ${lib.escapeShellArg cfg.ai.model} '{
      "model": $model,
      "keep_alive": 0
    }')" > /dev/null
    ${pkgs.libnotify}/bin/notify-send "AI System" "Model unloaded - RAM freed"
  '';

  aiLoad = pkgs.writeShellScriptBin "tuxflow-ai-load" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail
    ${pkgs.libnotify}/bin/notify-send "AI System" "Loading model '${cfg.ai.model}' …"
    ${pkgs.curl}/bin/curl -s http://localhost:11434/api/generate -d "$(jq -n --arg model ${lib.escapeShellArg cfg.ai.model} '{
      "model": $model,
      "prompt": "warmup",
      "stream": false,
      "keep_alive": "15m"
    }')" > /dev/null || true
    ${pkgs.libnotify}/bin/notify-send "AI System" "Model '${cfg.ai.model}' loaded (kept alive 15m)"
  '';

  modelInfo = {
    medium = {
      url = "https://alphacephei.com/vosk/models/vosk-model-en-us-0.22.zip";
      dir = "vosk-model-en-us-0.22";
    };
  };
in
{
  options.services.tuxflow = {
    enable = mkEnableOption "Tux-Flow (nerd-dictation + dotool + Ollama helpers)";

    model = mkOption {
      type = types.enum [ "medium" ];
      default = "medium";
      description = "VOSK model to auto-install (best quality).";
    };

    # key bindings removed per user request

    autoUpdate = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Periodically check and update the VOSK model if the upstream zip changed (ETag/Last-Modified).";
      };
      schedule = mkOption {
        type = types.str;
        default = "weekly";
        description = "systemd OnCalendar for model checks (e.g., 'daily', 'weekly', 'monthly', 'Sun *-*-* 03:00:00').";
      };
    };

    ai = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable AI editing helpers using Ollama.";
      };
      model = mkOption {
        type = types.str;
        default = "gemma3:latest";
        description = "Ollama model name for editing.";
      };
    };

    dictation = {
      safePasteOnEnd = mkOption {
        type = types.bool;
        default = true;
        description = "Buffer dictation to a file and paste once on end to avoid random keystrokes during dictation.";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      { assertion = username != null; message = "services.tuxflow requires 'username' specialArg in flake to configure Home Manager."; }
    ];

    # dotool access
    services.udev.extraRules = ''
      KERNEL=="uinput", GROUP="input", MODE="0664", OPTIONS+="static_node=uinput"
    '';

    users.users.${username}.extraGroups = [ "input" ];

    environment.systemPackages = [ pkgs.dotool pkgs.wtype ];

    # Home Manager content for the user
    home-manager.users.${username} = { lib, pkgs, config, ... }: {
      home.packages = [ tuxflowStart tuxflowStop ]
        ++ lib.optionals cfg.ai.enable [ aiEditSelected aiEditRecent endAndEdit aiUnload aiLoad ];

      # Desktop entries to bind shortcuts in Plasma settings
      xdg.desktopEntries = {
        "tuxflow-start" = {
          name = "Tuxflow: Start Dictation";
          exec = "tuxflow-start";
          icon = "microphone-sensitivity-high";
          terminal = false;
          categories = [ "Utility" ];
        };
        "tuxflow-stop" = {
          name = "Tuxflow: Stop Dictation";
          exec = "tuxflow-stop";
          icon = "media-playback-stop";
          terminal = false;
          categories = [ "Utility" ];
        };
      } // lib.optionalAttrs cfg.ai.enable {
        "tuxflow-end-and-edit" = {
          name = "Tuxflow: End Dictation + AI Edit";
          exec = "tuxflow-end-and-edit";
          icon = "tools-wizard";
          terminal = false;
          categories = [ "Utility" ];
        };
        "tuxflow-ai-edit-selected" = {
          name = "Tuxflow: AI Edit Selected";
          exec = "tuxflow-ai-edit-selected";
          icon = "tools-check-spelling";
          terminal = false;
          categories = [ "Utility" ];
        };
        "tuxflow-ai-unload" = {
          name = "Tuxflow: Unload AI Model";
          exec = "tuxflow-ai-unload";
          icon = "media-eject";
          terminal = false;
          categories = [ "Utility" ];
        };
        
      };

      # Systemd user service to download and install the VOSK model once
      systemd.user.services.tuxflow-install-model = {
        Unit = {
          Description = "Install VOSK model for nerd-dictation (first-run)";
          ConditionPathExists = "!%h/.config/nerd-dictation/model";
          After = [ "plasma-workspace.target" "graphical-session.target" ];
        };
        Service = {
          Type = "oneshot";
          TimeoutSec = "1h";
          ExecStart = pkgs.writeShellScript "tuxflow-install-model.sh" ''
            set -euo pipefail
            set -o pipefail
            mkdir -p "$HOME/.config/nerd-dictation"
            state_dir="$HOME/.local/state/tuxflow"
            log_dir="$state_dir/logs"
            mkdir -p "$log_dir"
            log_file="$log_dir/install.log"
            ${pkgs.libnotify}/bin/notify-send "Tux-Flow" "Downloading VOSK model (${cfg.model})…"
            tmpzip=$(mktemp /tmp/vosk-XXXX.zip)
            # Download with progress and log output
            ${pkgs.curl}/bin/curl --fail -L --progress-bar "${modelInfo.${cfg.model}.url}" -o "$tmpzip" 2>&1 | tee -a "$log_file"
            tmpdir=$(mktemp -d)
            ${pkgs.unzip}/bin/unzip -o "$tmpzip" -d "$tmpdir" 2>&1 | tee -a "$log_file"
            rm -f "$tmpzip"
            mv "$tmpdir/${modelInfo.${cfg.model}.dir}" "$HOME/.config/nerd-dictation/model"
            ${pkgs.libnotify}/bin/notify-send "Tux-Flow" "VOSK model installed (${cfg.model})"
          '';
          Restart = "no";
        };
      };

      # Trigger the first-run installer asynchronously shortly after login
      systemd.user.timers.tuxflow-install-model = {
        Unit.Description = "Tuxflow: Trigger first-run VOSK model install";
        Timer = {
          OnActiveSec = "15s";
          Persistent = true;
          Unit = "tuxflow-install-model.service";
        };
        Install.WantedBy = [ "default.target" ];
      };
      # Bootstrap nerd-dictation into a per-user venv if missing
      home.activation.tuxflowBootstrap = config.lib.dag.entryAfter [ "writeBoundary" ] ''
        set -euo pipefail
        ND_DIR="$HOME/${nerdDirRel}"
        if [ ! -x "$ND_DIR/venv/bin/python" ] || [ ! -f "$ND_DIR/nerd-dictation" ]; then
          mkdir -p "$ND_DIR"
          if [ ! -d "$ND_DIR/.git" ]; then
            ${pkgs.git}/bin/git clone --depth 1 https://github.com/ideasman42/nerd-dictation "$ND_DIR"
          fi
          ${pkgs.python3}/bin/python3 -m venv "$ND_DIR/venv"
          "$ND_DIR/venv/bin/pip" install --upgrade pip
          "$ND_DIR/venv/bin/pip" install vosk
        fi
      '';

      # Optional auto-update service and timer
      systemd.user.services.tuxflow-model-update = lib.mkIf cfg.autoUpdate.enable {
        Unit.Description = "Tuxflow: Check and update VOSK model";
        Service = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "tuxflow-model-update.sh" ''
            set -euo pipefail
            set -o pipefail
            model_dir="$HOME/.config/nerd-dictation/model"
            state_dir="$HOME/.local/state/tuxflow"
            log_dir="$state_dir/logs"
            mkdir -p "$log_dir"
            log_file="$log_dir/update.log"
            mkdir -p "$state_dir"
            etag_file="$state_dir/vosk-${cfg.model}.etag"
            lm_file="$state_dir/vosk-${cfg.model}.lastmod"

            url="${modelInfo.${cfg.model}.url}"
            headers=$(mktemp)
            body=$(mktemp)
            trap 'rm -f "$headers" "$body"' EXIT

            # Send conditional request
            etag_hdr=""
            lm_hdr=""
            [ -f "$etag_file" ] && etag_hdr="-H If-None-Match: $(cat "$etag_file")"
            [ -f "$lm_file" ] && lm_hdr="-H If-Modified-Since: $(cat "$lm_file")"

            ${pkgs.libnotify}/bin/notify-send "Tux-Flow" "Checking for VOSK model updates (${cfg.model})…"
            status=$(${pkgs.curl}/bin/curl --progress-bar -L -D "$headers" $etag_hdr $lm_hdr -o "$body" "$url" -w '%{http_code}' 2>&1 | tee -a "$log_file" | tail -n1)
            if [ "$status" = "304" ]; then
              exit 0
            fi
            if [ "$status" != "200" ]; then
              echo "Update HTTP status: $status" >> "$log_file"
              exit 0
            fi

            # Extract headers
            new_etag=$(grep -i '^etag:' "$headers" | sed 's/^etag:\s*//I' | tr -d '\r')
            new_lm=$(grep -i '^last-modified:' "$headers" | sed 's/^last-modified:\s*//I' | tr -d '\r')

            tmpdir=$(mktemp -d)
            unzip_dir=$(mktemp -d)
            cp "$body" "$tmpdir/model.zip"
            ${pkgs.unzip}/bin/unzip -o "$tmpdir/model.zip" -d "$unzip_dir" 2>&1 | tee -a "$log_file"
            # Take the first directory inside
            new_model_dir=$(find "$unzip_dir" -mindepth 1 -maxdepth 1 -type d | head -n1)
            if [ -z "$new_model_dir" ]; then
              exit 1
            fi
            # Replace atomically
            dest_parent="$HOME/.config/nerd-dictation"
            mkdir -p "$dest_parent"
            rm -rf "$model_dir.new"
            cp -a "$new_model_dir" "$model_dir.new"
            rm -rf "$model_dir"
            mv "$model_dir.new" "$model_dir"

            [ -n "$new_etag" ] && echo "$new_etag" > "$etag_file"
            [ -n "$new_lm" ] && echo "$new_lm" > "$lm_file"
            ${pkgs.libnotify}/bin/notify-send "Tux-Flow" "VOSK model updated (${cfg.model})"
          '';
        };
      };

      systemd.user.timers.tuxflow-model-update = lib.mkIf cfg.autoUpdate.enable {
        Unit.Description = "Tuxflow: Scheduled model update";
        Timer = {
          OnCalendar = cfg.autoUpdate.schedule;
          Persistent = true;
        };
        Install.WantedBy = [ "timers.target" ];
      };

      # Global shortcuts intentionally not managed by module

      # Basic troubleshooting hints: input group & /dev/uinput presence
      home.activation.tuxflowSanity = config.lib.dag.entryAfter [ "writeBoundary" ] ''
        if ! id -nG "$USER" | grep -qE '(^|\s)input(\s|$)'; then
          ${pkgs.libnotify}/bin/notify-send "Tux-Flow" "User not in 'input' group. Re-login required after activation."
        fi
        if [ ! -e /dev/uinput ]; then
          ${pkgs.libnotify}/bin/notify-send "Tux-Flow" "/dev/uinput missing. Reboot or check udev rule."
        fi
      '';
    };
  };
}


