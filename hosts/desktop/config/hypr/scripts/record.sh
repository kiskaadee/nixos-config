#!/usr/bin/env bash

# 📹 Hyprland Screen Recording Utility
# Leverages 'wf-recorder' for GPU-accelerated video recording and pipewire audio routing.
# Supports capturing specific bounding boxes, active windows, virtual outputs, or full displays.
#
# Usage: 
#   record.sh [area | window | output | screen] [audio]

PID_FILE="/tmp/wf-recorder.pid"
TYPE_FILE="/tmp/wf-recorder.type"
OUTPUT_DIR="$HOME/Videos"

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

# Extract geometric regions based on requested target
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
        # Fetch the active window coordinates and dimensions using hyprctl JSON output
        GEOM=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
        if [ -z "$GEOM" ] || [ "$GEOM" = "null,null nullxnull" ]; then
            notify-send -t 2000 "Screen Recorder" "No active window found"
            exit 1
        fi
        TYPE_DESC="Window Recording"
        ;;
    output)
        # Query active monitors and match the geometry of the current cursor focus
        GEOM=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | "\(.x),\(.y) \(.width)x\(.height)"')
        TYPE_DESC="Monitor Recording"
        ;;
    screen)
        # Clear geometry: captures the full desktop layout spanning all connected monitors
        GEOM=""
        TYPE_DESC="Full Screen Recording"
        ;;
esac

# Resolve dynamic audio monitor node if the user specified "audio" as the second flag
if [ "$2" = "audio" ]; then
    # Parse status output of wireplumber to determine the currently active output Sink ID
    SINK_ID=$(wpctl status | sed -n '/Sinks:/,/Sources:/p' | grep '*' | awk '{print $3}' | tr -d '.')
    if [ -n "$SINK_ID" ]; then
        # Query wireplumber to resolve the dynamic node name of the identified sink (e.g. alsa_output.pci...)
        NODE_NAME=$(wpctl inspect "$SINK_ID" | grep 'node.name' | awk -F'"' '{print $2}')
        if [ -n "$NODE_NAME" ]; then
            # Append .monitor to route output system audio loopback to the recording device
            AUDIO_DEVICE="${NODE_NAME}.monitor"
        fi
    fi
    # Fallback to default system input/source if parsing failed
    if [ -z "$AUDIO_DEVICE" ]; then
        AUDIO_DEVICE="default"
    fi
    TYPE_DESC="${TYPE_DESC} (with Audio)"
fi

# Define output filename format (ISO-like timestamping)
FILENAME="recording_$(date +%Y-%m-%d_%H-%M-%S).mp4"
FILEPATH="$OUTPUT_DIR/$FILENAME"

# Trigger user-facing low-priority desktop notification
notify-send -t 2000 -u low "Screen Recorder" "Starting $TYPE_DESC..."

# Execute wf-recorder in the background with appropriate flags
if [ -n "$AUDIO_DEVICE" ]; then
    if [ -n "$GEOM" ]; then
        wf-recorder -a "$AUDIO_DEVICE" -g "$GEOM" -f "$FILEPATH" &
    else
        wf-recorder -a "$AUDIO_DEVICE" -f "$FILEPATH" &
    fi
else
    if [ -n "$GEOM" ]; then
        wf-recorder -g "$GEOM" -f "$FILEPATH" &
    else
        wf-recorder -f "$FILEPATH" &
    fi
fi

# Track PID and Type metadata in /tmp for future toggle invocation
PID=$!
echo "$PID" > "$PID_FILE"
echo "$TYPE_DESC" > "$TYPE_FILE"

