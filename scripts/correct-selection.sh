#!/usr/bin/env bash

# Dependencies: wl-clipboard, curl, jq, libnotify

MODEL="gemma3:latest"
API_URL="http://localhost:11434/api/generate"
SYSTEM_PROMPT="You are a text correction assistant. Fix grammar, punctuation, and capitalization. Maintain the original meaning. Output ONLY the corrected text."

# 1. Get text from clipboard (primary selection or clipboard)
# Try primary first (highlighted text), fallback to clipboard
INPUT_TEXT=$(wl-paste --primary 2>/dev/null || wl-paste)

if [ -z "$INPUT_TEXT" ]; then
    notify-send "Ollama Auto-Correct" "Clipboard is empty!"
    exit 1
fi

notify-send "Ollama Auto-Correct" "Correcting text..."

# 2. Escape and prepare JSON
JSON_PAYLOAD=$(jq -n \
                  --arg model "$MODEL" \
                  --arg prompt "$INPUT_TEXT" \
                  --arg system "$SYSTEM_PROMPT" \
                  '{model: $model, prompt: $prompt, system: $system, stream: false}')

# 3. Call Ollama
RESPONSE=$(curl -s "$API_URL" -d "$JSON_PAYLOAD")

# 4. Extract Result
CORRECTED_TEXT=$(echo "$RESPONSE" | jq -r '.response')

if [ -z "$CORRECTED_TEXT" ] || [ "$CORRECTED_TEXT" = "null" ]; then
    notify-send "Ollama Auto-Correct" "Failed to get response."
    exit 1
fi

# 5. Update Clipboard
echo -n "$CORRECTED_TEXT" | wl-copy

# 6. Notify
notify-send "Ollama Auto-Correct" "Text corrected and copied to clipboard!"
