#!/usr/bin/env bash
#
# Ollama Correct - Clipboard Autocorrect
# 1. Reads text from clipboard
# 2. Sends to Ollama (Gemma 3) for grammar/spelling fix
# 3. Copies result BACK to clipboard
#

set -euo pipefail

# Configuration
MODEL="gemma3:latest"
API_URL="http://localhost:11434/api/generate"

SYSTEM_PROMPT="You are a dictation assistant. Your ONLY job is to fix grammar, spelling, punctuation, and capitalization. Rules:
- Return ONLY the corrected text
- Do NOT add explanations
- Do NOT change the meaning
- Preserve the original tone
- Combine multiple sentences into a single sentence if needed
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
for cmd in wl-copy wl-paste curl jq notify-send; do
    command -v "$cmd" &>/dev/null || error_exit "Missing: $cmd"
done

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
    '{model: $model, prompt: $prompt, system: $system, stream: false, keep_alive: "60m"}')

# Increase timeout to 120s to allow for initial model loading
RESPONSE=$(curl -s --max-time 120 "$API_URL" -d "$JSON_PAYLOAD" 2>/dev/null)
CORRECTED=$(echo "$RESPONSE" | jq -r '.response // empty' 2>/dev/null)

# Fallback
if [[ -z "$CORRECTED" ]]; then
    notify "⚠️ Correction failed, keeping original"
    exit 1
fi

# Clean up whitespace/quotes
CORRECTED=$(echo "$CORRECTED" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/^"//g' -e 's/"$//g')

# 3. Copy Result to Clipboard
echo -n "$CORRECTED" | wl-copy

notify "✅ Copied to clipboard!"
