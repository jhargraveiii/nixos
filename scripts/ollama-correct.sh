#!/usr/bin/env bash

# Check if text was provided
if [ -z "$1" ]; then
    echo "Usage: $0 \"text to correct\""
    exit 1
fi

# Configuration
MODEL="gemma3:latest"
API_URL="http://localhost:11434/api/generate"

# Prompt engineering to ensure direct output
SYSTEM_PROMPT="You are a helpful text correction assistant. Fix the grammar, punctuation, and capitalization of the user's text. Do not change the meaning. Return ONLY the corrected text. Do not say 'Here is the corrected text'."

INPUT_TEXT="$1"

# Construct JSON payload safely using jq
# We use 'system' for instructions if the model supports it, or prepend to prompt
JSON_PAYLOAD=$(jq -n \
                  --arg model "$MODEL" \
                  --arg prompt "$INPUT_TEXT" \
                  --arg system "$SYSTEM_PROMPT" \
                  '{model: $model, prompt: $prompt, system: $system, stream: false}')

# Call Ollama API
RESPONSE=$(curl -s "$API_URL" -d "$JSON_PAYLOAD")

# Check for errors
if echo "$RESPONSE" | grep -q "\"error\""; then
    echo "Error calling Ollama:"
    echo "$RESPONSE" | jq -r '.error'
    exit 1
fi

# Output the response
echo "$RESPONSE" | jq -r '.response'
