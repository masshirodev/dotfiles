killall mpvpaper

# Monitor 1 - LG
mpvpaper DP-1 ~/Documents/Backgrounds/samurai_cyber.jpg -o "no-audio --loop-file --panscan=1.0" &>/dev/null &

# Monitor 2 - LG Ultrawide
mpvpaper DP-2 ~/Documents/Backgrounds/oxocarbon-evangelion.jpg -o "no-audio --loop-file --vf=crop=iw-2:ih:2:0 --panscan=1.0" &>/dev/null &

# TV
if hyprctl monitors | grep -q "Monitor HDMI-A-1"; then
  mpvpaper HDMI-A-1 ~/Documents/Backgrounds/bg.mp4 -o "no-audio --loop-file --panscan=1.0" &>/dev/null &
fi
