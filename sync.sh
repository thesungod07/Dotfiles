#!/usr/bin/env bash

DOTFILES_DIR="$HOME/dotfiles"
CONFIG_SRC="$HOME/.config"
CONFIG_DST="$DOTFILES_DIR/config"

echo "=== Dotfiles Sync ==="
echo ""

cd "$DOTFILES_DIR" || exit 1

# Step 1: Sync directories that are already tracked in the repo
echo "Syncing already-tracked config directories..."
echo ""

if [ -d "$CONFIG_DST" ]; then
    for dir in "$CONFIG_DST"/*/; do
        name=$(basename "$dir")
        if [ -d "$CONFIG_SRC/$name" ]; then
            echo "  Syncing ~/.config/$name"
            rsync -a --delete "$CONFIG_SRC/$name/" "$CONFIG_DST/$name/"
        fi
    done
fi

# Step 2: Show git diff summary
echo ""
echo "=== Changes detected ==="
git status --short

# Step 3: Offer to add new config directories not yet in repo
echo ""
echo "=== Add new configs? ==="
echo "The following ~/.config directories are NOT yet in your repo:"
echo ""

NOT_TRACKED=()
for dir in "$CONFIG_SRC"/*/; do
    name=$(basename "$dir")
    # Skip backups, caches, and system dirs
    [[ "$name" == *"backup"* ]] && continue
    [[ "$name" == *"cache"* ]] && continue
    [[ "$name" == "mozilla" ]] && continue
    [[ "$name" == "google-chrome" ]] && continue
    [[ "$name" == "chromium" ]] && continue
    [[ "$name" == "Code - OSS" ]] && continue
    [[ "$name" == "discord" ]] && continue
    [[ "$name" == "dconf" ]] && continue
    [[ "$name" == "pulse" ]] && continue
    [[ "$name" == "pipewire" ]] && continue
    [[ "$name" == "systemd" ]] && continue
    [[ "$name" == "go" ]] && continue
    [[ "$name" == "yay" ]] && continue
    [[ "$name" == "github-copilot" ]] && continue

    if [ ! -d "$CONFIG_DST/$name" ]; then
        NOT_TRACKED+=("$name")
    fi
done

if [ ${#NOT_TRACKED[@]} -eq 0 ]; then
    echo "  None — everything is already tracked."
else
    for name in "${NOT_TRACKED[@]}"; do
        echo -n "  Add ~/.config/$name? [y/N] "
        read -r ans
        if [[ "$ans" == "y" || "$ans" == "Y" ]]; then
            mkdir -p "$CONFIG_DST/$name"
            rsync -a "$CONFIG_SRC/$name/" "$CONFIG_DST/$name/"
            echo "  Added ~/.config/$name"
        fi
    done
fi

# Step 4: Check if anything changed
echo ""
if git diff --quiet && git diff --cached --quiet; then
    echo "Nothing to commit — repo is already up to date."
    exit 0
fi

echo "=== Final changes ==="
git status --short
echo ""

# Step 5: Commit and push
read -rp "Commit message: " MSG

if [ -z "$MSG" ]; then
    echo "Aborted — commit message cannot be empty."
    exit 1
fi

git add -A
git commit -m "$MSG"
git push

echo ""
echo "Done. Changes pushed to GitHub."
