#!/bin/bash

# Add fonts 
# Directory where fonts should be installed
FONT_DIR="/usr/local/share/fonts"

# List of fonts to check and download if missing
FONTS=(
    "MesloLGS NF Regular.ttf"
    "MesloLGS NF Bold.ttf"
    "MesloLGS NF Italic.ttf"
    "MesloLGS NF Bold Italic.ttf"
)

# Base URL for downloading fonts
BASE_URL="https://github.com/romkatv/powerlevel10k-media/raw/master/"

# Loop through each font and check if it's installed
for FONT in "${FONTS[@]}"; do
    FONT_PATH="$FONT_DIR/$FONT"
    
    if [ ! -f "$FONT_PATH" ]; then
        echo "[-] Downloading $FONT..."
        sudo wget -P "$FONT_DIR" "${BASE_URL}${FONT// /%20}"
    else
        echo "[✔] $FONT is already installed, skipping."
    fi
done

# Refresh the font cache
fc-cache -fv

echo "[✔] All fonts are up to date."

# Install packages 
packages_script="./packages.sh"

if [ -f "$packages_script" ]; then
    echo "[-] Executing $packages_script..."
    bash "$packages_script"  # Run the script
fi

# Tmux 
echo "[-] Creating tmux symlink.."
if [ -f ~/.tmux.conf ]; then
    rm -f ~/.tmux.conf
    echo "[✔] Tmux old conf removed"
fi
ln -s $(pwd)/tmux/.tmux.conf ~/.tmux.conf
echo "[✔] Tmux symlink created"

# Define the Aliases folder path
folder="$HOME/.config/aliases"

# Check if the folder exists
if [ ! -d "$folder" ]; then
    echo "[-] Folder $folder does not exist. Creating it..."
    mkdir -p "$folder"
else
    echo "[✔] Folder $folder already exists."
fi

# Create symlinks and append to ~/.bashrc
for file in $(pwd)/aliases/*; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        echo "[-] Create symlink for $filename."
        ln -sf "$file" ~/.config/aliases/"$filename"  # Use -sf to overwrite existing symlink

        # Append the source line only if it's not already in .bashrc
        if ! grep -qxF "source $HOME/.config/aliases/$filename" ~/.bashrc; then
            echo "[-] Appending $filename to ~/.bashrc."
            echo "source $HOME/.config/aliases/$filename" >> ~/.bashrc
        else
            echo "[✔] $filename is already in ~/.bashrc."
        fi
    fi
done

# Define the NVIM directory and copy it.
NVIM_DIR="$HOME/.config/nvim"

if [ ! -d "$NVIM_DIR" ]; then
    echo "[-] Nvim folder does not exist. Copying it..."
    cp -r nvim/.config/nvim "$NVIM_DIR"
else
    echo "[-] Nvim folder already exists."
    echo "[-] Removing Nvim folder."
    rm -rf "$NVIM_DIR"
    echo "[-] Copying Nvim folder..."
    cp -r nvim/.config/nvim "$NVIM_DIR"
fi