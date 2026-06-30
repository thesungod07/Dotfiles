#!/usr/bin/env bash

BROWSER="firefox"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/rofi-apps.cache"

# ── Search flags ──────────────────────────────────────────────────────────────
# To add a new flag, just add a line here: FLAG|URL
# The URL will have the search term appended to it (URL encoded)
SEARCH_FLAGS="
!g|https://www.google.com/search?q=
!ddg|https://duckduckgo.com/?q=
!yt|https://www.youtube.com/search?search_query=
!gh|https://github.com/search?q=
!wiki|https://en.wikipedia.org/wiki/Special:Search?search=
!shodan|https://www.shodan.io/search?query=
"

rebuild_cache() {
    find /usr/share/applications ~/.local/share/applications 2>/dev/null \
        -name "*.desktop" | while read -r f; do
        name=$(grep -m1 "^Name=" "$f" | cut -d= -f2-)
        exec_cmd=$(grep -m1 "^Exec=" "$f" | cut -d= -f2- \
            | sed 's/ %[uUfFdDnNickvm]//g')
        icon=$(grep -m1 "^Icon=" "$f" | cut -d= -f2-)
        nodisplay=$(grep -m1 "^NoDisplay=" "$f" | cut -d= -f2-)
        [ -n "$name" ] && [ -n "$exec_cmd" ] && [ "$nodisplay" != "true" ] \
            && printf "%s\t%s\t%s\n" "$name" "$exec_cmd" "$icon"
    done | sort -t$'\t' -k1 -u > "$CACHE"
}

[ ! -f "$CACHE" ] && rebuild_cache
find /usr/share/applications ~/.local/share/applications 2>/dev/null \
    -name "*.desktop" -newer "$CACHE" -print -quit 2>/dev/null \
    | grep -q . && rebuild_cache

QUERY=$(awk -F'\t' '{ printf "%s\0icon\x1f%s\n", $1, $3 }' "$CACHE" \
    | rofi \
        -dmenu \
        -p "" \
        -theme "$HOME/.config/rofi/search.rasi" \
        -no-fixed-num-lines \
        -lines 0 \
        -i \
        -show-icons \
        -format "s")

[ -z "$QUERY" ] && exit 0

FLAG=$(echo "$QUERY" | awk '{print $1}')
TERM=$(echo "$QUERY" | cut -d' ' -f2-)

# !c — execute as shell command
if [[ "$FLAG" == "!c" ]]; then
    kitty -e bash -c "$TERM; echo; echo '--- Press Enter to close ---'; read" & disown
    exit 0
fi

# Search flags — look up flag in SEARCH_FLAGS
BASE_URL=$(echo "$SEARCH_FLAGS" | grep "^${FLAG}|" | cut -d'|' -f2)
if [ -n "$BASE_URL" ]; then
    $BROWSER "${BASE_URL}$(jq -rn --arg t "$TERM" '$t|@uri')" & disown
    exit 0
fi

# App launch
EXEC=$(awk -F'\t' -v q="$QUERY" \
    'tolower($1) == tolower(q) { print $2; exit }' "$CACHE")
if [ -z "$EXEC" ]; then
    EXEC=$(awk -F'\t' -v q="$QUERY" \
        'tolower($1) ~ tolower(q) { print $2; exit }' "$CACHE")
fi
if [ -n "$EXEC" ]; then
    eval "$EXEC" & disown
fi
