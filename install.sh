#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status

echo "🚀 Starting Dotfiles Installation..."

# 1. Sync system packages (Tailored for Arch/CachyOS)
echo "📦 Installing core system dependencies..."
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm hyprland waybar neovim kitty thunar gvfs udiskie nodejs npm

# 2. Create target configuration folders if they don't exist
mkdir -p ~/.config

# 3. Deploy configurations safely
echo "🔧 Deploying configuration files..."

# Loop through everything inside our repository's config folder
for dir in config/*; do
    dir_name=$(basename "$dir")
    
    # If a config already exists on the machine, back it up to prevent overwriting
    if [ -d "$HOME/.config/$dir_name" ]; then
        echo "⚠️  Found existing config for $dir_name, backing up to ${dir_name}.bak"
        mv "$HOME/.config/$dir_name" "$HOME/.config/${dir_name}.bak"
    fi
    
    # Symlink our repository configs directly into the system layout
    ln -sf "$HOME/dotfiles/config/$dir_name" "$HOME/.config/"
    echo "✅ Linked $dir_name -> ~/.config/$dir_name"
done

# 4. Deploy Git configurations
if [ -f "$HOME/dotfiles/.gitconfig" ]; then
    cp "$HOME/dotfiles/.gitconfig" "$HOME/.gitconfig"
    echo "✅ Copied .gitconfig successfully!"
fi

echo "🎉 Done! Your system environment is fully deployed."
