#!/usr/bin/env bash
set -euo pipefail

# Usage: stt-whisper [duration_seconds] [model_name] [sample_rate] [output_prefix]
# Defaults: 30 base.en 16000 transcript

DURATION=${1:-30}
MODEL_NAME=${2:-base.en}
RATE=${3:-16000}
OUT_PREFIX=${4:-transcript}

MODELS_DIR="$HOME/.local/share/whisper.cpp/models"
mkdir -p "$MODELS_DIR"

MODEL_FILE="ggml-${MODEL_NAME}.bin"
MODEL_PATH="${MODELS_DIR}/${MODEL_FILE}"

if [ ! -f "$MODEL_PATH" ]; then
  echo "Downloading model $MODEL_FILE ..." >&2
  URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/${MODEL_FILE}"
  curl -L "$URL" -o "$MODEL_PATH"
fi

TMP_WAV=$(mktemp --suffix=.wav)
echo "Recording ${DURATION}s from PipeWire to ${TMP_WAV} ..." >&2
# pw-record doesn't support --duration universally; use timeout to limit length
timeout "${DURATION}s" pw-record --channels 1 --format s16 --rate "$RATE" "$TMP_WAV" || true

THREADS=$(nproc)
echo "Transcribing with whisper-cpp (threads=${THREADS}) ..." >&2

if [ "${VAD:-1}" = "1" ]; then
  VAD_FILE="ggml-silero-v5.1.2.bin"
  VAD_PATH="${MODELS_DIR}/${VAD_FILE}"
  if [ ! -f "$VAD_PATH" ]; then
    echo "Downloading VAD model $VAD_FILE ..." >&2
    VAD_URL="https://huggingface.co/ggml-org/whisper-vad/resolve/main/${VAD_FILE}"
    curl -L "$VAD_URL" -o "$VAD_PATH"
  fi
  whisper-cli \
    -m "$MODEL_PATH" \
    -f "$TMP_WAV" \
    -t "$THREADS" \
    --vad -vm "$VAD_PATH" \
    -otxt -osrt -ovtt \
    -of "$OUT_PREFIX" \
    -l auto
else
  whisper-cli \
    -m "$MODEL_PATH" \
    -f "$TMP_WAV" \
    -t "$THREADS" \
    -otxt -osrt -ovtt \
    -of "$OUT_PREFIX" \
    -l auto
fi

echo "Outputs: ${OUT_PREFIX}.txt ${OUT_PREFIX}.srt ${OUT_PREFIX}.vtt" >&2
rm -f "$TMP_WAV"


