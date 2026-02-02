#!/bin/bash

pkg_list="git curl tailscale sway waybar wmenu wl-clipboard neovim ranger unzip openssh alacritty base-devel fastfetch trash-cli fira-code-fonts"
git_dir="$HOME/github"
target_path="$git_dir/almostlight/dotfiles"

# Install packages based on distro
install_packages() {
    if command -v apt &> /dev/null; then
        sudo apt update
        sudo apt install -y $pkg_list
    elif command -v pacman &> /dev/null; then
        sudo pacman -Syu --noconfirm $pkg_list
    elif command -v dnf &> /dev/null; then
        sudo dnf install --skip-unavailable -y $pkg_list
		# Enable RPM Fusion repos
		sudo dnf install \
			"https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
			"https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
		# Install Brave Browser
		curl -fsS https://dl.brave.com/install.sh | sh
    fi
}


install_packages
clear
mkdir -p "$git_dir"
echo "Cloning dotfiles repository to $git_dir"
git clone "https://github.com/almostlight/dotfiles.git" "$target_path"
exec "$target_path/scripts/deploy.sh"

