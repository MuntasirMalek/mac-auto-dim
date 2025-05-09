#!/usr/bin/env bash

# Absolute paths (launchd's built-in PATH is only /usr/bin:/bin:/usr/sbin:/sbin)
IOREG="/usr/sbin/ioreg"
AWK="/usr/bin/awk"
BC="/usr/local/opt/bc/bin/bc"
BRIGHT_CMD="/usr/local/bin/brightness"

PREV_FILE="$HOME/.prev_brightness"
# Set idle time threshold in seconds (default: 60)
IDLE_THRESHOLD="${IDLE_THRESHOLD:-60}"

while true; do
    # 1) Read idle time (sec):
    idle=$($IOREG -c IOHIDSystem \
           | $AWK '/HIDIdleTime/ {printf "%.0f\n", $NF/1000000000; exit}')
    
    # 2) Read current brightness:
    curr=$($BRIGHT_CMD -l \
           | $AWK '/display 0:/ && /brightness/ {print $4; exit}')

    if (( $($BC <<< "$idle > $IDLE_THRESHOLD") )); then
        # Idle > threshold & not already off → save & dim
        if (( $(echo "$curr > 0" | bc -l) )); then
            echo "$curr" > "$PREV_FILE"
            $BRIGHT_CMD 0
        fi
    else
        # Activity resumed & was dimmed → restore
        if [[ -f "$PREV_FILE" ]] && (( $(echo "$curr == 0" | bc -l) )); then
            prev=$(cat "$PREV_FILE")
            $BRIGHT_CMD "$prev"
            rm "$PREV_FILE"
        fi
    fi

    sleep 5
done 