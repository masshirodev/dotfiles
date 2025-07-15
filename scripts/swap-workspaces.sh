#!/bin/bash

# Get the target workspace to swap with
TARGET_WORKSPACE=$1

# Get the current workspace
CURRENT_WORKSPACE=$(hyprctl activeworkspace | grep "workspace ID" | awk '{print $3}')

# Don't do anything if current and target are the same
if [ "$CURRENT_WORKSPACE" -eq "$TARGET_WORKSPACE" ]; then
    exit 0
fi

# Temporary workspace (use a high number to avoid conflicts)
TEMP_WORKSPACE=99

# Store window addresses from current workspace
CURRENT_WINDOWS=$(hyprctl clients -j | jq -r ".[] | select(.workspace.id == $CURRENT_WORKSPACE) | .address")

# Store window addresses from target workspace
TARGET_WINDOWS=$(hyprctl clients -j | jq -r ".[] | select(.workspace.id == $TARGET_WORKSPACE) | .address")

# Move all windows from current workspace to temp workspace
for window in $CURRENT_WINDOWS; do
    hyprctl dispatch movetoworkspacesilent $TEMP_WORKSPACE,address:$window
done

# Move all windows from target workspace to current workspace
for window in $TARGET_WINDOWS; do
    hyprctl dispatch movetoworkspacesilent $CURRENT_WORKSPACE,address:$window
done

# Move all windows from temp workspace to target workspace
TEMP_WINDOWS=$(hyprctl clients -j | jq -r ".[] | select(.workspace.id == $TEMP_WORKSPACE) | .address")
for window in $TEMP_WINDOWS; do
    hyprctl dispatch movetoworkspacesilent $TARGET_WORKSPACE,address:$window
done

# Focus back on the current workspace
hyprctl dispatch workspace $CURRENT_WORKSPACE
