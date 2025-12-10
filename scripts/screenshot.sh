#!/usr/bin/env sh
# Restores the shader after screenshot has been taken
restore_shader() {
	if [ -n "$shader" ]; then
		hyprshade on "$shader"
	fi
}
# Saves the current shader and turns it off
save_shader() {
	shader=$(hyprshade current)
	hyprshade off
	trap restore_shader EXIT
}
save_shader # Saving the current shader

if [ -z "$XDG_PICTURES_DIR" ]; then
	XDG_PICTURES_DIR="$HOME/Pictures"
fi

scrDir=$(dirname "$(realpath "$0")")
source $scrDir/globalcontrol.sh
swpy_dir="${confDir}/swappy"
save_dir="${2:-$XDG_PICTURES_DIR/Screenshots}"

# Create monthly subdirectory
month_year=$(date +'%m-%y')
save_dir="$save_dir/$month_year"
mkdir -p "$save_dir"
mkdir -p "$swpy_dir"

# Get active window title for filename
active_window=$(hyprctl activewindow -j | jq -r '.class' | tr '[:upper:]' '[:lower:]' | sed 's/ /_/g')
[ -z "$active_window" ] && active_window="screenshot"

# Get timestamp with milliseconds
timestamp=$(date +'%d_%m_%y_%Hh%Mm%Ss')
milliseconds=$(date +'%3N')
save_file="${timestamp}${milliseconds}ms_${active_window}.png"
temp_screenshot="/tmp/screenshot.png"

echo -e "[Default]\nsave_dir=$save_dir\nsave_filename_format=$save_file" >$swpy_dir/config

function print_error
{
	cat <<"EOF"
    ./screenshot.sh <action>
    ...valid actions are...
        p  : print all screens
        s  : snip current screen
        sf : snip current screen (frozen)
        m  : print focused monitor
        q  : quick snip (frozen, no editor)
EOF
}

case $1 in
p) # print all outputs
	grimblast copysave screen $temp_screenshot && restore_shader && swappy -f $temp_screenshot ;;
s) # drag to manually snip an area / click on a window to print it
	grimblast copysave area $temp_screenshot && restore_shader && swappy -f $temp_screenshot ;;
sf) # frozen screen, drag to manually snip an area / click on a window to print it
	grimblast --freeze copysave area $temp_screenshot && restore_shader && swappy -f $temp_screenshot ;;
m) # print focused monitor
	grimblast copysave output $temp_screenshot && restore_shader && swappy -f $temp_screenshot ;;
q) # quick capture - frozen screen, no swappy editor
	grimblast --freeze save area "${save_dir}/${save_file}" && restore_shader ;;
*) # invalid option
	print_error ;;
esac

rm "$temp_screenshot" 2>/dev/null

if [ -f "${save_dir}/${save_file}" ]; then
	notify-send -a "t1" -i "${save_dir}/${save_file}" "saved in ${save_dir}"
fi
