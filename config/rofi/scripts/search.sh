#!/usr/bin/env bash

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

QUERY="$1"

# Empty or flag only — show nothing
[ -z "$QUERY" ] && exit 0
[[ "$QUERY" == "!g"* ]] && exit 0
[[ "$QUERY" == "!ddg"* ]] && exit 0

# Return filtered matches
awk -F'\t' -v q="$QUERY" \
    'tolower($1) ~ tolower(q) { printf "%s\0icon\x1f%s\n", $1, $3 }' "$CACHE"
