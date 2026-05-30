#!/bin/bash

pkg_list="firefox git curl tailscale sway waybar wmenu wl-clipboard neovim ranger unzip openssh alacritty base-devel fastfetch trash-cli fira-code-fonts tesseract" 
git_dir="$HOME/github"
target_path="$git_dir/dotfiles_by_almostlight"

# Install packages based on distro
install_packages() {
    if command -v apt &> /dev/null; then
        sudo apt update
        sudo apt install -y $pkg_list
    elif command -v pacman &> /dev/null; then
        sudo pacman -Syu --noconfirm $pkg_list
    elif command -v dnf &> /dev/null; then
        sudo dnf install --skip-unavailable -y $pkg_list
		# enable repos
		sudo -qy dnf copr enable lihaohong/yazi 
		sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc &&
		sudo dnf -qy install \
			"https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
			"https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
		sudo dnf -qy install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
		echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
		# install packages
		sudo dnf -qy install espanso-wayland yazi
		# sudo dnf -qy install onedrive
		dnf -qy check-update && sudo dnf -qy install code
		# curl -fsS https://dl.brave.com/install.sh | sh
		# enable espanso
		sudo setcap "cap_dac_override+p" $(which espanso)
		espanso service register
    fi
}

rm -rf "$HOME/.cache/*"
install_packages
clear

mkdir -p "$git_dir"
echo "$target_path"
if [[ -d "$target_path/.git" ]]; then 
	echo "Dotfiles repository target path exists! Pulling repository..."
	cd $target_path && git pull --rebase
else
	echo "Cloning dotfiles repository..."
	rm -rf "$target_path"
	git clone git@github.com:almostlight/dotfiles.git "$target_path" --depth 1
fi

git submodule update --init --recursive

exec "$target_path/scripts/deploy.sh"

