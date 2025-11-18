#!/bin/bash

discord_addr=$(hyprctl clients -j | jq -r '.[] | select(.class == "discord") | .address' | head -1)

if [ -n "$discord_addr" ]; then
    hyprctl dispatch sendshortcut CTRL SHIFT, M, address:$discord_addr
else
    notify-send "Discord not found" "Discord window is not open"
fi
