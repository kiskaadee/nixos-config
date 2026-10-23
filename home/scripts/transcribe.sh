#!/usr/bin/env bash

# 🎙️ Whisper Audio Message Transcriber
# Fast, local, offline audio transcription using whisper-cpp and ffmpeg.
# Optimised for voice messages (.ogg, .opus, .m4a, .mp3, .wav).

set -euo pipefail

show_help() {
  cat << 'EOF'
Usage: transcribe [OPTIONS] <audio-file> [audio-file2 ...]

Transcribes audio recordings into plain text using local whisper.cpp.

Options:
  -c, --clip, --clipboard   Copy transcription result to Wayland clipboard (wl-copy)
  -s, --save                Save transcript alongside audio file as <filename>.txt
  -m, --model <name>        Whisper model size (default: small, ~488MB)
                            Options: tiny, base, small, medium, large-v3-turbo
  -l, --lang <code|auto>    Spoken language (e.g. en, es, auto; default: auto)
  -t, --threads <num>       Computation threads (default: CPU core count)
  -q, --quiet               Suppress informational messages to stderr
  -h, --help                Show this help message and exit

Examples:
  transcribe voice_note.ogg
  transcribe -c memo.m4a
  transcribe -s -l es recording.opus
EOF
}

MODEL="${TRANSCRIBE_MODEL:-small}"
LANG="${TRANSCRIBE_LANG:-auto}"
CLIP=0
SAVE=0
QUIET=0
THREADS="$(nproc 2>/dev/null || echo 4)"

# Parse CLI options
while [ $# -gt 0 ]; do
  case "$1" in
    -c|--clip|--clipboard)
      CLIP=1
      shift
      ;;
    -s|--save)
      SAVE=1
      shift
      ;;
    -m|--model)
      if [ $# -lt 2 ]; then
        echo "Error: --model requires an argument" >&2
        exit 1
      fi
      MODEL="$2"
      shift 2
      ;;
    -l|--lang|--language)
      if [ $# -lt 2 ]; then
        echo "Error: --language requires an argument" >&2
        exit 1
      fi
      LANG="$2"
      shift 2
      ;;
    -t|--threads)
      if [ $# -lt 2 ]; then
        echo "Error: --threads requires an argument" >&2
        exit 1
      fi
      THREADS="$2"
      shift 2
      ;;
    -q|--quiet)
      QUIET=1
      shift
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "Unknown option: $1" >&2
      show_help
      exit 1
      ;;
    *)
      break
      ;;
  esac
done

if [ $# -lt 1 ]; then
  echo "Error: No audio files provided." >&2
  show_help
  exit 1
fi

MODEL_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/whisper-cpp/models"
MODEL_FILE="$MODEL_DIR/ggml-${MODEL}.bin"

# Auto-download model on first run if missing
if [ ! -f "$MODEL_FILE" ]; then
  if [ "$QUIET" -eq 0 ]; then
    echo "Model 'ggml-${MODEL}.bin' not found in $MODEL_DIR." >&2
    echo "Downloading model '${MODEL}'..." >&2
  fi
  mkdir -p "$MODEL_DIR"
  whisper-cpp-download-ggml-model "$MODEL" "$MODEL_DIR"
fi

# Set up temporary working directory for 16kHz audio normalization
TEMP_DIR="$(mktemp -d -t transcribe-XXXXXX)"
cleanup() {
  rm -rf "$TEMP_DIR"
}
trap cleanup EXIT INT TERM

ALL_OUTPUT=""

for input_file in "$@"; do
  if [ ! -f "$input_file" ]; then
    echo "Warning: File '$input_file' not found, skipping." >&2
    continue
  fi

  TEMP_WAV="$TEMP_DIR/converted_$(basename "$input_file").wav"

  # Normalize audio to 16kHz mono 16-bit PCM WAV (Whisper specification)
  if ! ffmpeg -hide_banner -loglevel error -y -i "$input_file" -ar 16000 -ac 1 -c:a pcm_s16le "$TEMP_WAV"; then
    echo "Error: Failed to process audio file '$input_file' with ffmpeg." >&2
    continue
  fi

  # Run whisper-cli
  RAW_TRANSCRIPT="$(whisper-cli -m "$MODEL_FILE" -f "$TEMP_WAV" -l "$LANG" -t "$THREADS" -nt -np)"

  # Clean transcript: strip leading whitespace from segments
  CLEAN_TRANSCRIPT="$(echo "$RAW_TRANSCRIPT" | sed -e 's/^[[:space:]]*//' | sed -e '/^[[:space:]]*$/d')"

  # Print to stdout
  printf "%s\n" "$CLEAN_TRANSCRIPT"

  # Optional: Save next to original audio file
  if [ "$SAVE" -eq 1 ]; then
    OUT_TXT="${input_file%.*}.txt"
    printf "%s\n" "$CLEAN_TRANSCRIPT" > "$OUT_TXT"
    if [ "$QUIET" -eq 0 ]; then
      echo "Saved transcript to: $OUT_TXT" >&2
    fi
  fi

  if [ -n "$ALL_OUTPUT" ]; then
    ALL_OUTPUT="${ALL_OUTPUT}
${CLEAN_TRANSCRIPT}"
  else
    ALL_OUTPUT="$CLEAN_TRANSCRIPT"
  fi

  rm -f "$TEMP_WAV"
done

# Optional: Copy accumulated transcript to clipboard
if [ "$CLIP" -eq 1 ] && [ -n "$ALL_OUTPUT" ]; then
  if command -v wl-copy >/dev/null 2>&1; then
    printf "%s\n" "$ALL_OUTPUT" | wl-copy
    if [ "$QUIET" -eq 0 ]; then
      echo "Copied transcript to clipboard." >&2
    fi
  else
    echo "Warning: wl-copy not found, skipping clipboard copy." >&2
  fi
fi
