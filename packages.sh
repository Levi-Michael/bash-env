#!/bin/bash

# Define the required dependencies for the script to work
REQUIRED_PACKAGES=("gnupg" "software-properties-common" "apt-transport-https" "ca-certificates" "curl")

# Define the main list of packages to install
MAIN_PACKAGES=("terraform" "git-all" "google-cloud-cli" "google-cloud-cli-gke-gcloud-auth-plugin"
               "kubectl" "helm" "docker-ce" "docker-ce-cli" "containerd.io"
               "docker-buildx-plugin" "docker-compose-plugin" "jq" "yq" "fzf" "bat" "tmux" "make")

# Function to check if a package is installed
is_installed() {
    dpkg -l | grep -qw "$1"
}

# Function to check if a package needs an update
needs_update() {
    apt list --upgradable 2>/dev/null | grep -q "^$1/"
}

# Function to install or update packages (Reusable for any package list)
install_or_update_packages() {
    local PACKAGES=("$@")  # Accepts a list of packages
    local MISSING_PACKAGES=()
    local UPGRADE_PACKAGES=()

    for PACKAGE in "${PACKAGES[@]}"; do
        if is_installed "$PACKAGE"; then
            if needs_update "$PACKAGE"; then
                echo "[!] $PACKAGE is outdated. Marking for upgrade."
                UPGRADE_PACKAGES+=("$PACKAGE")
            else
                echo "[✔] $PACKAGE is already installed and up-to-date."
            fi
        else
            echo "[!] $PACKAGE is missing. Marking for installation."
            MISSING_PACKAGES+=("$PACKAGE")
        fi
    done

    # Install missing packages
    if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
        echo "[-] Installing missing packages: ${MISSING_PACKAGES[*]}"
        if ! sudo apt-get install -y "${MISSING_PACKAGES[@]}"; then
            echo "[✘] Failed to install some packages."
        else
            echo "[✔] Missing packages installed successfully."
        fi
    else
        echo "[✔] No missing packages to install."
    fi

    # Upgrade outdated packages
    if [ ${#UPGRADE_PACKAGES[@]} -gt 0 ]; then
        echo "[-] Upgrading outdated packages: ${UPGRADE_PACKAGES[*]}"
        if ! sudo apt-get install --only-upgrade -y "${UPGRADE_PACKAGES[@]}"; then
            echo "[✘] Failed to upgrade some packages."
        else
            echo "[✔] Outdated packages updated successfully."
        fi
    else
        echo "[✔] No outdated packages to upgrade."
    fi
}

# Function to install or update Lazygit
install_or_update_lazygit() {
    # Get the installed Lazygit version (extracting only the first match)
    INSTALLED_LG_VERSION=$(lazygit --version 2>/dev/null | grep -oP 'version=\K[\d.]+' | head -n 1)

    # Fetch the latest available Lazygit version from GitHub
    LATEST_LG_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*')

    # Check if Lazygit is installed and whether an update is needed
    if [ -z "$INSTALLED_LG_VERSION" ]; then
        echo "[!] Lazygit is not installed. Installing v${LATEST_LG_VERSION}..."
    elif [ "$INSTALLED_LG_VERSION" != "$LATEST_LG_VERSION" ]; then
        echo "[!] Lazygit is outdated (Installed: v${INSTALLED_LG_VERSION}, Latest: v${LATEST_LG_VERSION}). Updating..."
    else
        echo "[✔] Lazygit is up-to-date (v${INSTALLED_LG_VERSION}). No update needed."
        return  # Use return instead of exit if inside a function
    fi

    # Download and install the latest Lazygit version
    if [ -n "$LATEST_LG_VERSION" ]; then
        echo "[-] Downloading Lazygit v${LATEST_LG_VERSION}..."
        
        # File name for the downloaded archive
        LG_ARCHIVE="lazygit.tar.gz"
        
        # Download Lazygit tarball
        curl -Lo "$LG_ARCHIVE" "https://github.com/jesseduffield/lazygit/releases/download/v${LATEST_LG_VERSION}/lazygit_${LATEST_LG_VERSION}_Linux_x86_64.tar.gz"
        
        # Extract the binary from the archive
        tar xf "$LG_ARCHIVE" lazygit
        
        # Install Lazygit to /usr/local/bin/
        sudo install lazygit -D -t /usr/local/bin/
        
        # Clean up temporary files
        rm -f "$LG_ARCHIVE" lazygit
        
        echo "[✔] Lazygit v${LATEST_LG_VERSION} installed successfully."
    else
        echo "[✘] Failed to fetch Lazygit version."
    fi
}

# Function to install or update Neovim
install_or_update_neovim() {
    NEOVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
    INSTALL_DIR="/opt/nvim"
    ARCHIVE="nvim-linux-x86_64.tar.gz"

    # Get the latest Neovim version from GitHub
    LATEST_VERSION=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep -Po '"tag_name": "v\K[^"]*')

    # Check installed version
    if command -v nvim >/dev/null 2>&1; then
        INSTALLED_VERSION=$(nvim --version | awk 'NR==1{print $2}')
        if [ "$INSTALLED_VERSION" == "v$LATEST_VERSION" ]; then
            echo "[✔] Neovim is already up-to-date ($INSTALLED_VERSION)."
            return  # Do not exit the script, just return from function
        else
            echo "[-] Updating Neovim ($INSTALLED_VERSION → v$LATEST_VERSION)..."
        fi
    else
        echo "[-] Installing Neovim v$LATEST_VERSION..."
    fi

    # Download and install Neovim
    echo "[-] Downloading Neovim..."
    if ! curl -LO "$NEOVIM_URL"; then
        echo "[✘] Download failed!"
        return 1
    fi

    echo "[-] Removing old Neovim..."
    sudo rm -rf "$INSTALL_DIR"

    echo "[-] Extracting Neovim..."
    if sudo tar -C /opt -xzf "$ARCHIVE"; then
        rm -f "$ARCHIVE"
        echo "[✔] Neovim v$LATEST_VERSION installed! Run 'nvim' to start."
    else
        echo "[✘] Extraction failed!"
        return 1
    fi
}

# Update package lists
echo "[+] Updating package lists..."
if ! sudo apt-get update -y; then
    echo "[✘] Failed to update package lists. Check your internet connection or sources list."
    exit 1
fi

# Install/update required dependencies for the script itself
install_or_update_packages "${REQUIRED_PACKAGES[@]}"

# KeyRings
# Function to download and check keyrings
add_keyring() {
    local url="$1"
    local output="$2"

    if [ ! -f "$output" ]; then
        echo "[!] Adding keyring: $output"
        curl -fsSL "$url" | sudo gpg --dearmor -o "$output"
        sudo chmod 644 "$output"
    else
        echo "[✔] Keyring already exists: $output"
    fi
}

# Function to add a repository if not exists
add_repository() {
    local repo_string="$1"
    local repo_file="$2"

    if [ ! -f "$repo_file" ]; then
        echo "[!] Adding repository: $repo_file"
        echo "$repo_string" | sudo tee "$repo_file" > /dev/null
    else
        echo "[✔] Repository already exists: $repo_file"
    fi
}

echo "[-] Installing Keyrings & Repositories "

# Terraform Keyring & Repo
add_keyring "https://apt.releases.hashicorp.com/gpg" "/usr/share/keyrings/hashicorp-archive-keyring.gpg"
add_repository "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" "/etc/apt/sources.list.d/hashicorp.list"

# Google Cloud SDK Keyring & Repo
add_keyring "https://packages.cloud.google.com/apt/doc/apt-key.gpg" "/usr/share/keyrings/cloud.google.gpg"
add_repository "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" "/etc/apt/sources.list.d/google-cloud-sdk.list"

# Kubernetes Keyring & Repo
sudo mkdir -p /etc/apt/keyrings
add_keyring "https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key" "/etc/apt/keyrings/kubernetes-apt-keyring.gpg"
add_repository "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /" "/etc/apt/sources.list.d/kubernetes.list"

# Helm Keyring & Repo
add_keyring "https://baltocdn.com/helm/signing.asc" "/usr/share/keyrings/helm.gpg"
add_repository "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" "/etc/apt/sources.list.d/helm-stable-debian.list"

# Docker Keyring & Repo
sudo mkdir -p /etc/apt/keyrings
add_keyring "https://download.docker.com/linux/ubuntu/gpg" "/etc/apt/keyrings/docker.asc"
add_repository "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo \"${UBUNTU_CODENAME:-$VERSION_CODENAME}\") stable" "/etc/apt/sources.list.d/docker.list"

# Update package lists
echo "[+] Updating package lists..."
if ! sudo apt-get update -y; then
    echo "[✘] Failed to update package lists. Check your internet connection or sources list."
    exit 1
fi

# Call the function to install/update Lazygit
install_or_update_lazygit

# Call the function to install/update Neovim
install_or_update_neovim

# Install/update main packages
install_or_update_packages "${MAIN_PACKAGES[@]}"

echo "[✔] All required dependencies and main packages are installed and updated."