#!/usr/bin/env bash

# 📹 Wayland Screen Recording Utility (Niri & Hyprland compatible)
# Leverages 'wf-recorder' for GPU-accelerated video recording and pipewire audio routing.
# Supports capturing specific regions, active windows, focused monitors, or full displays.
#
# Usage: 
#   record [area | window | output | screen] [audio]

PID_FILE="/tmp/wf-recorder.pid"
TYPE_FILE="/tmp/wf-recorder.type"
OUTPUT_DIR="${XDG_VIDEOS_DIR:-$HOME/Videos}"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Stop any active recording session gracefully
stop_recording() {
    # Check if we have a saved process ID
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if kill -0 "$PID" 2>/dev/null; then
            # Send INT signal (Ctrl+C equivalent) so wf-recorder can flush the output container
            kill -INT "$PID"
            # Wait briefly to permit filesystem write finalization
            sleep 0.5
        fi
        rm -f "$PID_FILE"
    fi
    
    # Sweep for orphan instances of wf-recorder to prevent background process leaks
    if pgrep -x "wf-recorder" > /dev/null; then
        pkill -INT -x wf-recorder
        sleep 0.5
    fi
    
    # Read the recording type metadata for user notification
    TYPE="Recording"
    if [ -f "$TYPE_FILE" ]; then
        TYPE=$(cat "$TYPE_FILE")
        rm -f "$TYPE_FILE"
    fi
    
    notify-send -t 3000 -u normal "Screen Recorder" "$TYPE stopped and saved to $OUTPUT_DIR"
    exit 0
}

# If the script is invoked while a recording is already running, toggle it OFF
if pgrep -x "wf-recorder" > /dev/null; then
    stop_recording
fi

# Define operation modes
MODE="${1:-area}"
AUDIO_DEVICE=""
TYPE_DESC="Screen Recording"
GEOM=""
OUTPUT_TARGET=""

# Extract geometric regions or output target based on requested mode
case "$MODE" in
    area)
        # Interactive region selector using 'slurp'. User clicks and drags to select.
        GEOM=$(slurp)
        if [ -z "$GEOM" ]; then
            notify-send -t 2000 "Screen Recorder" "Recording cancelled"
            exit 1
        fi
        TYPE_DESC="Area Recording"
        ;;
    window)
        # Try querying Hyprland active window coordinates if on Hyprland
        if [ "$XDG_CURRENT_DESKTOP" = "Hyprland" ] && command -v hyprctl >/dev/null 2>&1; then
            GEOM=$(hyprctl activewindow -j 2>/dev/null | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
        fi
        # Fallback to interactive window / region selection via slurp
        if [ -z "$GEOM" ] || [ "$GEOM" = "null,null nullxnull" ]; then
            GEOM=$(slurp)
        fi
        if [ -z "$GEOM" ]; then
            notify-send -t 2000 "Screen Recorder" "Recording cancelled"
            exit 1
        fi
        TYPE_DESC="Window Recording"
        ;;
    output)
        # Query focused monitor on Niri or Hyprland
        if [ "$XDG_CURRENT_DESKTOP" = "niri" ] || command -v niri >/dev/null 2>&1; then
            OUTPUT_TARGET=$(niri msg -j focused-output 2>/dev/null | jq -r '.name // empty')
        fi
        if [ -z "$OUTPUT_TARGET" ] && command -v hyprctl >/dev/null 2>&1; then
            OUTPUT_TARGET=$(hyprctl monitors -j 2>/dev/null | jq -r '.[] | select(.focused == true) | .name // empty')
        fi
        TYPE_DESC="Monitor Recording"
        ;;
    screen)
        # Full desktop layout across monitors
        GEOM=""
        OUTPUT_TARGET=""
        TYPE_DESC="Full Screen Recording"
        ;;
esac

# Resolve dynamic audio monitor node if requested
if [ "$2" = "audio" ] || [ "$1" = "audio" ]; then
    # Parse status output of wireplumber to determine the currently active output Sink ID
    SINK_ID=$(wpctl status 2>/dev/null | sed -n '/Sinks:/,/Sources:/p' | grep '\*' | awk '{print $3}' | tr -d '.' | head -n 1)
    if [ -n "$SINK_ID" ]; then
        # Query wireplumber to resolve the dynamic node name of the identified sink
        NODE_NAME=$(wpctl inspect "$SINK_ID" 2>/dev/null | grep 'node.name' | awk -F'"' '{print $2}')
        if [ -n "$NODE_NAME" ]; then
            # Append .monitor to route output system audio loopback to the recording device
            AUDIO_DEVICE="${NODE_NAME}.monitor"
        fi
    fi
    # Fallback to default system source if parsing failed
    if [ -z "$AUDIO_DEVICE" ]; then
        AUDIO_DEVICE="default"
    fi
    TYPE_DESC="${TYPE_DESC} (with Audio)"
fi

# Define output filename format
FILENAME="recording_$(date +%Y-%m-%d_%H-%M-%S).mp4"
FILEPATH="$OUTPUT_DIR/$FILENAME"

# Desktop notification before starting
notify-send -t 2000 -u low "Screen Recorder" "Starting $TYPE_DESC..."

# Build wf-recorder arguments array
CMD=(wf-recorder)
if [ -n "$AUDIO_DEVICE" ]; then
    CMD+=(-a "$AUDIO_DEVICE")
fi
if [ -n "$GEOM" ]; then
    CMD+=(-g "$GEOM")
elif [ -n "$OUTPUT_TARGET" ]; then
    CMD+=(-o "$OUTPUT_TARGET")
fi
CMD+=(-f "$FILEPATH")

# Execute wf-recorder in background
"${CMD[@]}" &
PID=$!

# Track PID and Type metadata in /tmp for toggle invocation
echo "$PID" > "$PID_FILE"
echo "$TYPE_DESC" > "$TYPE_FILE"
