#!/usr/bin/env bash

# Smart Dictation Wrapper
# 1. Triggers Speech Note to listen and copy to clipboard.
# 2. Monitor clipboard for new text.
# 3. Sends text to Ollama for correction.
# 4. Types corrected text via ydotool.

# Configuration
export YDOTOOL_SOCKET=/run/ydotoold/socket
MODEL="gemma3:latest"
API_URL="http://localhost:11434/api/generate"
SYSTEM_PROMPT="You are a dictation assistant. Fix grammar, punctuation, and capitalization of the user's spoken text. Do not change the meaning. Return ONLY the corrected text."

# Dependencies check
if ! command -v ydotool &> /dev/null; then
    notify-send "Smart Dictation" "Error: ydotool is not installed"
    exit 1
fi

# 1. Prepare Clipboard
# Clear clipboard to ensure we don't pick up old text
wl-copy --clear
notify-send "Smart Dictation" "Listening... Speak now."

# 2. Start Speech Note Listening Mode
# This returns immediately, so Speech Note runs in background
flatpak run net.mkiol.SpeechNote --action start-listening-clipboard &

# 3. Wait for User Input
# We wait for the clipboard to have content. 
# Speech Note updates clipboard when it detects a "final" sentence or when stopped.
# We'll wait up to 30 seconds for input.
TIMEOUT=30
START_TIME=$(date +%s)

while true; do
    CURRENT_TEXT=$(wl-paste --no-newline 2>/dev/null)
    
    if [ -n "$CURRENT_TEXT" ]; then
        break
    fi

    CURRENT_TIME=$(date +%s)
    ELAPSED=$((CURRENT_TIME - START_TIME))
    
    if [ "$ELAPSED" -ge "$TIMEOUT" ]; then
        notify-send "Smart Dictation" "Timed out waiting for speech."
        # Try to stop speech note
        flatpak run net.mkiol.SpeechNote --action cancel
        exit 1
    fi
    
    sleep 0.5
done

# Stop listening explicitly (optional, but good to be sure)
flatpak run net.mkiol.SpeechNote --action cancel

# 4. Correct with Ollama
notify-send "Smart Dictation" "Processing text..."

JSON_PAYLOAD=$(jq -n \
                  --arg model "$MODEL" \
                  --arg prompt "$CURRENT_TEXT" \
                  --arg system "$SYSTEM_PROMPT" \
                  '{model: $model, prompt: $prompt, system: $system, stream: false}')

RESPONSE=$(curl -s "$API_URL" -d "$JSON_PAYLOAD")
CORRECTED_TEXT=$(echo "$RESPONSE" | jq -r '.response')

if [ -z "$CORRECTED_TEXT" ] || [ "$CORRECTED_TEXT" = "null" ]; then
    notify-send "Smart Dictation" "Ollama failed. Typing original text."
    CORRECTED_TEXT="$CURRENT_TEXT"
else
    notify-send "Smart Dictation" "Typing..."
fi

# 5. Type Result
# Using ydotool to type. We add a small delay to ensure focus is correct.
sleep 0.5
ydotool type "$CORRECTED_TEXT "
