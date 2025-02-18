#!/bin/bash

# Add fonts 
sudo wget -P /usr/local/share/fonts https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
sudo wget -P /usr/local/share/fonts https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
sudo wget -P /usr/local/share/fonts https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
sudo wget -P /usr/local/share/fonts https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf

# Install packages 
packages_script="./packages.sh"

if [ -f "$packages_script" ]; then
    echo "Executing $packages_script..."
    bash "$packages_script"  # Run the script
fi

echo "Creating tmux symlink.."
if [ -f ~/.tmux.conf ]; then
    rm -f ~/.tmux.conf
fi
ln -s $(pwd)/tmux/.tmux.conf ~/.tmux.conf

# Create aliases folder
echo "Creating aliases folder.."

# Define the folder path
folder="$HOME/.config/aliases"

# Check if the folder exists
if [ ! -d "$folder" ]; then
    echo "Folder $folder does not exist. Creating it..."
    mkdir -p "$folder"
else
    echo "Folder $folder already exists."
fi

# Create symlinks and append to ~/.bashrc
for file in $(pwd)/aliases/*; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        echo "Create symlink for $filename."
        ln -sf "$file" ~/.config/aliases/"$filename"  # Use -sf to overwrite existing symlink

        # Append the source line only if it's not already in .bashrc
        if ! grep -qxF "source $HOME/.config/aliases/$filename" ~/.bashrc; then
            echo "Appending $filename to ~/.bashrc."
            echo "source $HOME/.config/aliases/$filename" >> ~/.bashrc
        else
            echo "$filename is already in ~/.bashrc."
        fi
    fi
done
