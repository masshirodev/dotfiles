#!/bin/bash
# ~/.config/myconf/scripts/rusty-retirement-watcher.sh

GAME_TITLE="Rusty's Retirement"
WAYBAR_HEIGHT=30
GAME_HEIGHT=300
TOTAL_HEIGHT=$((GAME_HEIGHT + WAYBAR_HEIGHT))

# Get the correct Hyprland instance directory (not files)
HYPR_SIGNATURE=$(ls -t /tmp/hypr/ | while read -r entry; do
    if [ -d "/tmp/hypr/$entry" ]; then
        echo "$entry"
        break
    fi
done)
SOCKET_PATH="/tmp/hypr/${HYPR_SIGNATURE}/.socket2.sock"

handle() {
    case $1 in
        openwindow*|closewindow*)
            # Check if Rusty's Retirement is running
            if hyprctl clients | grep -q "$GAME_TITLE"; then
                # Game is open - reserve space
                hyprctl keyword monitor DP-2,preferred,auto,1,reserved=0 0 $TOTAL_HEIGHT 0
            else
                # Game is closed - only reserve waybar
                hyprctl keyword monitor DP-2,preferred,auto,1,reserved=0 0 $WAYBAR_HEIGHT 0
            fi
            ;;
    esac
}

# Listen to Hyprland events
socat -U - "UNIX-CONNECT:${SOCKET_PATH}" | while read -r line; do handle "$line"; done
