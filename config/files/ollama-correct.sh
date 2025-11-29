#!/usr/bin/env bash
#
# Ollama Correct - Clipboard Autocorrect
# 1. Reads text ALREADY in clipboard (you must copy it first!)
# 2. Sends to Ollama (Gemma 3) for grammar/spelling fix
# 3. Types corrected text via ydotool
#

set -euo pipefail

# Configuration
export YDOTOOL_SOCKET="${YDOTOOL_SOCKET:-/run/ydotoold/socket}"
MODEL="gemma3:latest"
API_URL="http://localhost:11434/api/generate"

SYSTEM_PROMPT="You are a dictation assistant. Your ONLY job is to fix grammar, spelling, punctuation, and capitalization. Rules:
- Return ONLY the corrected text
- Do NOT add explanations
- Do NOT change the meaning
- Preserve the original tone
- If the text looks fine, return it unchanged"

ICON="/home/jimh/.local/share/icons/ollama-correct.png"

notify() {
    notify-send -i "$ICON" "Ollama Correct" "$1" -t 2000
}

error_exit() {
    notify-send -i "dialog-error" "Correction Error" "$1" -t 5000
    exit 1
}

# Check dependencies
for cmd in ydotool wl-copy wl-paste curl jq notify-send; do
    command -v "$cmd" &>/dev/null || error_exit "Missing: $cmd"
done

# Check ydotool socket
[[ -S "$YDOTOOL_SOCKET" ]] || error_exit "ydotool daemon not running"

# Check Ollama
curl -s --connect-timeout 1 "http://localhost:11434/api/tags" &>/dev/null || error_exit "Ollama not running"

# 1. Get Text from Clipboard
SPEECH_TEXT=$(wl-paste --no-newline 2>/dev/null || true)

# Skip if empty
if [[ -z "${SPEECH_TEXT// /}" ]]; then
    error_exit "Clipboard is empty. Copy text first!"
fi

notify "✨ Correcting..."

# 2. Send to Ollama
JSON_PAYLOAD=$(jq -n \
    --arg model "$MODEL" \
    --arg prompt "$SPEECH_TEXT" \
    --arg system "$SYSTEM_PROMPT" \
    '{model: $model, prompt: $prompt, system: $system, stream: false}')

RESPONSE=$(curl -s --max-time 30 "$API_URL" -d "$JSON_PAYLOAD" 2>/dev/null)
CORRECTED=$(echo "$RESPONSE" | jq -r '.response // empty' 2>/dev/null)

# Fallback
if [[ -z "$CORRECTED" ]]; then
    notify "⚠️ Correction failed, using original"
    CORRECTED="$SPEECH_TEXT"
fi

# Clean up whitespace/quotes
CORRECTED=$(echo "$CORRECTED" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/^"//g' -e 's/"$//g')

notify "⌨️ Typing..."

# 3. Type Result
sleep 0.2
ydotool type -- "$CORRECTED "


