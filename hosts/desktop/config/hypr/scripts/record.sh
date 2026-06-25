#!/usr/bin/env bash

# Screen Recording script for Hyprland using wf-recorder
# Usage: record.sh [area|window|output|screen] [audio]

PID_FILE="/tmp/wf-recorder.pid"
TYPE_FILE="/tmp/wf-recorder.type"
OUTPUT_DIR="$HOME/Videos"
mkdir -p "$OUTPUT_DIR"

stop_recording() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if kill -0 "$PID" 2>/dev/null; then
            kill -INT "$PID"
            # Wait a moment for wf-recorder to finish writing the file
            sleep 0.5
        fi
        rm -f "$PID_FILE"
    fi
    
    # Also double check in case of orphaned wf-recorder instances
    if pgrep -x "wf-recorder" > /dev/null; then
        pkill -INT -x wf-recorder
        sleep 0.5
    fi
    
    TYPE="Recording"
    if [ -f "$TYPE_FILE" ]; then
        TYPE=$(cat "$TYPE_FILE")
        rm -f "$TYPE_FILE"
    fi
    
    notify-send -t 3000 -u normal "Screen Recorder" "$TYPE stopped and saved to $OUTPUT_DIR"
    exit 0
}

# If already running, stop recording (no matter what arguments are passed)
if pgrep -x "wf-recorder" > /dev/null; then
    stop_recording
fi

# Determine type
MODE="${1:-area}"
AUDIO_DEVICE=""
TYPE_DESC="Screen Recording"

# Get recording parameters
case "$MODE" in
    area)
        # Select area using slurp
        GEOM=$(slurp)
        if [ -z "$GEOM" ]; then
            notify-send -t 2000 "Screen Recorder" "Recording cancelled"
            exit 1
        fi
        TYPE_DESC="Area Recording"
        ;;
    window)
        # Get active window geometry
        GEOM=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
        if [ -z "$GEOM" ] || [ "$GEOM" = "null,null nullxnull" ]; then
            notify-send -t 2000 "Screen Recorder" "No active window found"
            exit 1
        fi
        TYPE_DESC="Window Recording"
        ;;
    output)
        # Get focused monitor geometry
        GEOM=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | "\(.x),\(.y) \(.width)x\(.height)"')
        TYPE_DESC="Monitor Recording"
        ;;
    screen)
        # All outputs (no geometry restriction)
        GEOM=""
        TYPE_DESC="Full Screen Recording"
        ;;
esac

# If the second argument is "audio", enable system audio recording
if [ "$2" = "audio" ]; then
    # Dynamically find the default output sink's monitor name from PipeWire/WirePlumber
    SINK_ID=$(wpctl status | sed -n '/Sinks:/,/Sources:/p' | grep '*' | awk '{print $3}' | tr -d '.')
    if [ -n "$SINK_ID" ]; then
        NODE_NAME=$(wpctl inspect "$SINK_ID" | grep 'node.name' | awk -F'"' '{print $2}')
        if [ -n "$NODE_NAME" ]; then
            AUDIO_DEVICE="${NODE_NAME}.monitor"
        fi
    fi
    # Fallback to default system source if we couldn't resolve the node name
    if [ -z "$AUDIO_DEVICE" ]; then
        AUDIO_DEVICE="default"
    fi
    TYPE_DESC="${TYPE_DESC} (with Audio)"
fi

FILENAME="recording_$(date +%Y-%m-%d_%H-%M-%S).mp4"
FILEPATH="$OUTPUT_DIR/$FILENAME"

# Start recording
notify-send -t 2000 -u low "Screen Recorder" "Starting $TYPE_DESC..."

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

PID=$!
echo "$PID" > "$PID_FILE"
echo "$TYPE_DESC" > "$TYPE_FILE"
