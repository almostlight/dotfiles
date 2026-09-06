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

repo_root="$(dirname "$(realpath -s "$0")")/.."
script_dir=$(dirname "$(realpath -s "$0")")
theme_dir="$repo_root/themes"
headless_config_source="$repo_root/home/headless/config"
graphical_config_source="$repo_root/home/graphical/config"
headless_rc_source="$repo_root/home/headless/rc"
graphical_rc_source="$repo_root/home/graphical/rc"
headless_bin_source="$repo_root/home/headless/bin"
graphical_bin_source="$repo_root/home/graphical/bin"
today=$(date -I)

for source_dir in "$headless_config_source" "$graphical_config_source" \
    "$headless_rc_source" "$graphical_rc_source" \
    "$headless_bin_source" "$graphical_bin_source"; do
    if [[ ! -d "$source_dir" ]]; then
        log_error "Error: Source directory not found: $source_dir" >&2
        exit 1
    fi
done


link_item() {
    local source_item="$1"
    local target="$2"
    local itemname=$(basename "$source_item")
    # Backup existing file/directory
    if [[ -e "$target" || -L "$target" ]]; then
			if [[ -e "$(readlink $target)" ]]; then
        	# Create backup path that includes the item name
        	local relative_path="${target#$HOME/}"
        	local backup_path="$HOME/.backup/$today/${relative_path}"
        	
        	# Create parent directory for backup
        	mkdir -p "$(dirname "$backup_path")"
        	
        	log_info "Backing up existing $itemname to $backup_path"
        
			cp -Lr "$target" "$backup_path" #2>/dev/null
		fi
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

unlink_directory_contents() {
    local source_dir="$1"
    local target_base="$2"

    local old_shopt=$(shopt -p dotglob nullglob 2>/dev/null)
    shopt -s dotglob nullglob
    for item in "$source_dir"/*; do
        [[ -e "$item" ]] || continue
        rm -rf "$target_base/$(basename "$item")"
    done
    eval "$old_shopt" 2>/dev/null || true
}

link_configs() {
    link_directory_contents "$headless_config_source" "$HOME/.config/"
    link_directory_contents "$headless_rc_source" "$HOME"
    link_directory_contents "$headless_bin_source" "$HOME/.local/bin/"

    if [[ "${DOTFILES_HEADLESS:-false}" != true ]]; then
        link_directory_contents "$graphical_config_source" "$HOME/.config/"
        link_directory_contents "$graphical_rc_source" "$HOME"
        link_directory_contents "$graphical_bin_source" "$HOME/.local/bin/"
    fi
}

unlink_configs() {
    unlink_directory_contents "$headless_config_source" "$HOME/.config"
    unlink_directory_contents "$headless_rc_source" "$HOME"
    unlink_directory_contents "$headless_bin_source" "$HOME/.local/bin"

    if [[ "${DOTFILES_HEADLESS:-false}" != true ]]; then
        unlink_directory_contents "$graphical_config_source" "$HOME/.config"
        unlink_directory_contents "$graphical_rc_source" "$HOME"
        unlink_directory_contents "$graphical_bin_source" "$HOME/.local/bin"
    fi
}

restore_latest_backup() {
    local backup_dir
    backup_dir=$(find "$HOME/.backup" -mindepth 1 -maxdepth 1 -type d -printf '%T@ %p\n' 2>/dev/null \
        | sort -nr | awk 'NR == 1 { sub(/^[^ ]+ /, ""); print }')

    if [[ -z "$backup_dir" ]]; then
        log_warn "No backup found to restore"
        return 0
    fi

    log_info "Restoring backup from $backup_dir"
    cp -a "$backup_dir/." "$HOME/"
}

if [[ "${1:-}" == --uninstall ]]; then
    systemctl --user disable --now spotifyd.service espanso.service 2>/dev/null || true
    unlink_configs
    if [[ "${DOTFILES_HEADLESS:-false}" != true ]]; then
        unlink_directory_contents "$theme_dir/gruvbox-plus-kde/plasma/desktoptheme" "$HOME/.local/share/plasma/desktoptheme"
        unlink_directory_contents "$theme_dir/gruvbox-plus-kde/plasma/look-and-feel" "$HOME/.local/share/plasma/look-and-feel"
        unlink_directory_contents "$theme_dir/gruvbox-plus-kde/color-scheme" "$HOME/.local/share/color-schemes"
        unlink_directory_contents "$theme_dir/gruvbox-plus-icon-pack" "$HOME/.local/share/icons"
    fi
    sudo rm -f /usr/bin/spotifyd
    restore_latest_backup
    log_success "Dotfiles configuration removed and latest backup restored"
    exit 0
fi

# Make scripts executable
chmod +x "$headless_bin_source"/*
if [[ "${DOTFILES_HEADLESS:-false}" != true ]]; then
    chmod +x "$graphical_bin_source"/*
fi
if [[ -d "$HOME/.config/sway/scripts" ]]; then
    chmod +x "$HOME/.config/sway/scripts"/*
fi
# Setup zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
	log_info "Setting up oh-my-zsh"
	bash "$script_dir/zsh.sh" && \
		log_success "zsh setup complete"
fi
# Setup Spotifyd and desktop services
if [[ "${DOTFILES_HEADLESS:-false}" != true ]]; then
    if [[ ! "$(which spotifyd 2>/dev/null)" ]]; then
        bash "$script_dir/spotifyd.sh" && \
            log_success "Spotifyd installed"
    fi
fi
# Link configs
link_configs
# Link themes
if [[ "${DOTFILES_HEADLESS:-false}" != true ]]; then
    link_directory_contents "$theme_dir/gruvbox-plus-kde/plasma/desktoptheme/" "$HOME/.local/share/plasma/desktoptheme/"
    link_directory_contents "$theme_dir/gruvbox-plus-kde/plasma/look-and-feel/" "$HOME/.local/share/plasma/look-and-feel/"
    link_directory_contents "$theme_dir/gruvbox-plus-kde/color-scheme/" "$HOME/.local/share/color-schemes/"
    link_directory_contents "$theme_dir/gruvbox-plus-icon-pack/" "$HOME/.local/share/icons/"
fi
# System configuration
if [[ "${DOTFILES_HEADLESS:-false}" != true ]]; then
    systemctl --user enable spotifyd.service
    systemctl --user enable espanso.service
fi
log_info "Setting up Tailscale"
sudo systemctl enable --now tailscaled.service
sudo tailscale set --operator=$USER && \
	log_success "Tailscale setup complete"
sudo systemctl enable --now systemd-timesyncd.service
sudo cp "$script_dir/pol.traineddata" /usr/share/tesseract/tessdata/

sudo systemctl daemon-reload
if [[ "${DOTFILES_HEADLESS:-false}" != true ]]; then
    sudo xhost +SI:localuser:root
    systemctl --user daemon-reload
fi
log_info "Setup completed successfully"
# logout to apply changes
if [[ "${DOTFILES_HEADLESS:-false}" != true ]]; then
    killall startplasma-wayland
fi

