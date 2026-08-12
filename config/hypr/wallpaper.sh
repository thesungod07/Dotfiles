#!/bin/bash

WALLPAPER_DIR="$HOME/wallpapers/walls"

menu() {
    find "${WALLPAPER_DIR}" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) \
        | awk '{print "img:"$0}'
}

main() {
    choice=$(menu | wofi -c ~/.config/wofi/wallpaper \
        -s ~/.config/wofi/style-wallpaper.css \
        --show dmenu --prompt "Select Wallpaper:" -n)

    [ -z "$choice" ] && exit 0

    selected_wallpaper=$(echo "$choice" | sed 's/^img://')

    # Set wallpaper via swww (handles both GIF and static)
    awww img "$selected_wallpaper" \
        --transition-type any \
        --transition-fps 60 \
        --transition-duration .5

    # Save last wallpaper for swww restore on login
    echo "$selected_wallpaper" > ~/.cache/swww/last_wallpaper

    # GIF — skip wal theming (wal can't read GIFs properly)
    if [[ "${selected_wallpaper,,}" == *.gif ]]; then
        echo "GIF wallpaper set — skipping wal theming."
        # Reload services that don't need wal
        pkill swayosd-server; swayosd-server &
        swaync-client --reload-css
        exit 0
    fi

    # Static image — full wal theming pipeline
    wal -i "$selected_wallpaper" -n --cols16

    pkill swayosd-server
    swayosd-server &
    swaync-client --reload-css

    cat ~/.cache/wal/colors-kitty.conf > ~/.config/kitty/current-theme.conf
    pywalfox update

    color1=$(awk 'match($0, /color2=\47(.*)\47/,a) { print a[1] }' ~/.cache/wal/colors.sh)
    color2=$(awk 'match($0, /color3=\47(.*)\47/,a) { print a[1] }' ~/.cache/wal/colors.sh)

    cava_config="$HOME/.config/cava/config"
    sed -i "s/^gradient_color_1 = .*/gradient_color_1 = '$color1'/" "$cava_config"
    sed -i "s/^gradient_color_2 = .*/gradient_color_2 = '$color2'/" "$cava_config"
    pkill -USR2 cava 2>/dev/null

    cp "$selected_wallpaper" ~/wallpapers/pywallpaper.jpg
}

main
