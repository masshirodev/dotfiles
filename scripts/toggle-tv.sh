#!/bin/bash
# Replace with your actual TV monitor name (find it with: hyprctl monitors)
TV_MONITOR="HDMI-A-1"
TV_AUDIO="alsa_output.pci-0000_07_00.1.hdmi-stereo-extra2"
HEADSET_AUDIO="alsa_output.usb-Razer_Razer_USB_Audio_Controller_000000000000000000000000-00.stereo-game"

# Check if TV is currently enabled (will appear in monitors list if enabled)
if hyprctl monitors | grep -q "Monitor $TV_MONITOR"; then
    # TV is enabled, disable it
    hyprctl keyword monitor "$TV_MONITOR,disable"
    
    # Switch audio back to headset
    pactl set-card-profile alsa_card.pci-0000_07_00.1 output:hdmi-stereo
    pactl set-default-sink "$HEADSET_AUDIO"
    
    # Move all existing audio streams to headset
    pactl list short sink-inputs | cut -f1 | while read stream; do
        pactl move-sink-input "$stream" "$HEADSET_AUDIO" 2>/dev/null
    done
    
    notify-send "TV Output" "TV disabled - Audio: Headset" -t 2000
    echo "TV disabled - Audio switched to Headset"
    
    # Reset wallpaper after disabling TV
    . ~/.config/myconf/scripts/restart-wallpaper.sh
else
    # TV is disabled, enable it
    hyprctl keyword monitor "$TV_MONITOR,3840x2160,auto-left,1"
    
    # Switch to HDMI 3 profile for TV audio
    pactl set-card-profile alsa_card.pci-0000_07_00.1 output:hdmi-stereo-extra2
    pactl set-default-sink "$TV_AUDIO"
    
    # Move all existing audio streams to TV
    pactl list short sink-inputs | cut -f1 | while read stream; do
        pactl move-sink-input "$stream" "$TV_AUDIO" 2>/dev/null
    done
    
    notify-send "TV Output" "TV enabled - Audio: TV" -t 2000
    echo "TV enabled - Audio switched to TV"

    # Reset wallpaper after enabling TV
    . ~/.config/myconf/scripts/restart-wallpaper.sh
fi
