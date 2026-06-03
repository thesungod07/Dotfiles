#!/usr/bin/env bash

BROWSER="firefox"
GOOGLE="https://www.google.com/search?q="
DDG="https://duckduckgo.com/?q="
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/rofi-apps.cache"

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

# Feed rofi with -lines 0 initially so nothing shows until typed
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

if [[ "$QUERY" == "!g "* ]]; then
    TERM="${QUERY#!g }"
    $BROWSER "${GOOGLE}$(jq -rn --arg t "$TERM" '$t|@uri')" & disown
    exit 0
fi

if [[ "$QUERY" == "!ddg "* ]]; then
    TERM="${QUERY#!ddg }"
    $BROWSER "${DDG}$(jq -rn --arg t "$TERM" '$t|@uri')" & disown
    exit 0
fi

EXEC=$(awk -F'\t' -v q="$QUERY" \
    'tolower($1) == tolower(q) { print $2; exit }' "$CACHE")

if [ -z "$EXEC" ]; then
    EXEC=$(awk -F'\t' -v q="$QUERY" \
        'tolower($1) ~ tolower(q) { print $2; exit }' "$CACHE")
fi

if [ -n "$EXEC" ]; then
    eval "$EXEC" & disown
fi
