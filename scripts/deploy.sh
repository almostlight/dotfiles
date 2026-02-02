#!/bin/bash
set -e  # Exit on any error

git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.al 'add --all'
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual '!gitk'
echo "Git aliases configured"

script_dir=$(dirname "$(realpath -s "$0")")
config_source=$(realpath -s "$script_dir/../home/.config")
rc_source=$(realpath -s "$script_dir/../home/rc")

if [[ ! -d "$config_source" ]]; then
    echo "Error: Configuration source directory not found: $config_source" >&2
    exit 1
fi

if [[ ! -d "$rc_source" ]]; then
    echo "Error: RC source directory not found: $rc_source" >&2
    exit 1
fi


link_item() {
    local source_item="$1"
    local target="$2"
    local itemname=$(basename "$source_item")
    # Backup existing file/directory
    if [[ -e "$target" || -L "$target" ]]; then
        # Create backup path that includes the item name
        local relative_path="${target#$HOME/}"
        local backup_path="$HOME/.backup/${relative_path}.bk.$(date +%s)"
        
        # Create parent directory for backup
        mkdir -p "$(dirname "$backup_path")"
        
        echo "Backing up existing $itemname to $backup_path"
        
        cp -Lr "$target" "$backup_path" 2>/dev/null
    fi
    # Remove existing item before creating symlink
    rm -rf "$target"
    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$target")"
    # Create symbolic link
    if ln -sf "$source_item" "$target"; then
        echo "$itemname linked successfully to $target"
    else
        echo "Failed to link $itemname" >&2
        return 1
    fi
}


link_directory_contents() {
    local source_dir="$1"
    local target_base="$2"
    
    if [[ ! -d "$source_dir" ]]; then
        echo "Source directory not found: $source_dir" >&2
        return 1
    fi
    # Enable dotglob to include dotfiles
    local old_shopt=$(shopt -p dotglob nullglob 2>/dev/null)
    shopt -s dotglob nullglob
    # Ensure target base directory exists
    mkdir -p "$target_base"
    # Ensure backup directory exists
    mkdir -p "$HOME/.backup"
    
    for item in "$source_dir"/*; do
        [[ -e "$item" ]] || continue
        
        local itemname=$(basename "$item")
        local target="$target_base/$itemname"
        
        link_item "$item" "$target"
    done
    # Restore original shopt settings if they existed
    eval "$old_shopt" 2>/dev/null || true
}

# Link files
link_directory_contents "$config_source" "$HOME/.config"
link_directory_contents "$rc_source" "$HOME"
# Make scripts executable
chmod +x "$script_dir"/*
if [[ -d "$HOME/.config/sway/scripts" ]]; then
    chmod +x "$HOME/.config/sway/scripts"/*
fi
# System configuration
sudo systemctl enable --now tailscaled.service
sudo tailscale set --operator=$USER
sudo xhost +SI:localuser:root
sudo systemctl enable --now systemd-timesyncd.service

echo "Setup completed successfully"

