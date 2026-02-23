#!/bin/bash
set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[I]${NC} $1"; }
log_success() { echo -e "${GREEN}[S]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[W]${NC} $1"; }
log_error() { echo -e "${RED}[E]${NC} $1"; }

# Git config
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.al 'add --all'
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual '!gitk'
log_info "Git aliases configured"

script_dir=$(dirname "$(realpath -s "$0")")
config_source=$(realpath -s "$script_dir/../home/config")
rc_source=$(realpath -s "$script_dir/../home/rc")

if [[ ! -d "$config_source" ]]; then
    log_error "Error: Configuration source directory not found: $config_source" >&2
    exit 1
fi

if [[ ! -d "$rc_source" ]]; then
	log_error "Error: RC source directory not found: $rc_source" >&2
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
        local backup_path="$HOME/.backup/$(date +%s)/${relative_path}"
        
        # Create parent directory for backup
        mkdir -p "$(dirname "$backup_path")"
        
        log_info "Backing up existing $itemname to $backup_path"
        
        cp -Lr "$target" "$backup_path" #2>/dev/null
    fi
    # Remove existing item before creating symlink
    rm -rf "$target"
    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$target")"
    # Create symbolic link
    if ln -sf "$source_item" "$target"; then
        log_success "$itemname linked successfully to $target"
    else
        log_error "Failed to link $itemname" >&2
        return 1
    fi
}


link_directory_contents() {
    local source_dir="$1"
    local target_base="$2"
    
    if [[ ! -d "$source_dir" ]]; then
        log_error "Source directory not found: $source_dir" >&2
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
		local target="$(realpath $target_base)/$itemname"
        
        link_item "$item" "$target"
    done
    # Restore original shopt settings if they existed
    eval "$old_shopt" 2>/dev/null || true
}

# Make scripts executable
chmod +x "$script_dir"/linked/*
if [[ -d "$HOME/.config/sway/scripts" ]]; then
    chmod +x "$HOME/.config/sway/scripts"/*
fi
# Setup zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
	log_info "Setting up oh-my-zsh"
	bash "$script_dir/zsh.sh" && \
		log_success "zsh setup complete"
fi
# Setup Spotifyd
if [[ ! "$(which spotifyd 2>/dev/null)" ]]; then
	bash "$script_dir/spotifyd.sh" && \
		log_success "Spotifyd installed"
fi
# Link files
link_directory_contents "$config_source" "$HOME/.config/"
link_directory_contents "$rc_source" "$HOME"
link_directory_contents "$script_dir/linked" "$HOME/.local/bin/"
# System configuration
systemctl --user enable spotifyd.service
systemctl --user enable espanso.service
log_info "Setting up Tailscale"
sudo systemctl enable --now tailscaled.service
sudo tailscale set --operator=$USER && \
	log_success "Tailscale setup complete"
sudo xhost +SI:localuser:root
sudo systemctl enable --now systemd-timesyncd.service
sudo cp "$script_dir/pol.traineddata" /usr/share/tesseract/tessdata/

sudo systemctl daemon-reload
systemctl --user daemon-reload
log_info "Setup completed successfully"

