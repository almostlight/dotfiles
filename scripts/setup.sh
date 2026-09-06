#!/bin/bash

apt_common_pkg_list="git curl jq tailscale neovim ranger unzip openssh-client build-essential fastfetch trash-cli tesseract-ocr zsh wget"
apt_graphical_pkg_list="firefox sway waybar wmenu wl-clipboard alacritty fonts-firacode"
pacman_common_pkg_list="git curl jq tailscale neovim ranger unzip openssh base-devel fastfetch trash-cli tesseract zsh wget"
pacman_graphical_pkg_list="firefox sway waybar wmenu wl-clipboard alacritty fira-code-fonts"
dnf_common_pkg_list="git curl jq tailscale neovim ranger unzip openssh base-devel fastfetch trash-cli tesseract zsh wget"
dnf_graphical_pkg_list="firefox sway waybar wmenu wl-clipboard alacritty fira-code-fonts"
fedora_graphical_pkg_list="espanso-wayland yazi code"
git_dir="$HOME/github"
target_path="$git_dir/dotfiles_by_almostlight"

update_repository() {
	local had_local_changes=false
	if [[ -n "$(git status --porcelain)" ]]; then
		had_local_changes=true
		printf 'Local changes found; preserving them while updating the repository...\n'
		if ! git stash push --include-untracked -m "setup.sh preserve local changes"; then
			printf 'Could not preserve local changes; aborting repository update.\n' >&2
			return 1
		fi
	fi

	if ! git pull --rebase; then
		if [[ "$had_local_changes" == true ]]; then
			git stash pop || true
		fi
		return 1
	fi

	if [[ "$had_local_changes" == true ]]; then
		if ! git stash pop; then
			printf 'Repository updated, but local changes could not be reapplied.\n' >&2
			printf 'Resolve the stash conflict manually before running setup again.\n' >&2
			return 1
		fi
	fi
}

read -r -p "Install or remove this dotfiles setup? [I/r] " action_answer
case "$action_answer" in
	[Rr]) action=remove ;;
	*) action=install ;;
esac

read -r -p "Is this a WSL/headless installation? [Y/n] " headless_answer
case "$headless_answer" in
	[Nn]) headless=false ;;
	*) headless=true ;;
esac

# Install packages based on distro
install_packages() {
    if command -v apt &> /dev/null; then
        sudo apt update
		sudo apt install -y $apt_common_pkg_list
		if [[ "$headless" == false ]]; then
			sudo apt install -y $apt_graphical_pkg_list
		fi
    elif command -v pacman &> /dev/null; then
		sudo pacman -Syu --noconfirm $pacman_common_pkg_list
		if [[ "$headless" == false ]]; then
			sudo pacman -S --noconfirm $pacman_graphical_pkg_list
		fi
    elif command -v dnf &> /dev/null; then
		sudo dnf install --skip-unavailable -y $dnf_common_pkg_list
		if [[ "$headless" == false ]]; then
			sudo dnf install --skip-unavailable -y $dnf_graphical_pkg_list
		fi
        if [[ "$headless" == false ]]; then
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
    fi
}

remove_packages() {
	if command -v apt &> /dev/null; then
		sudo apt remove -y $apt_common_pkg_list
		if [[ "$headless" == false ]]; then
			sudo apt remove -y $apt_graphical_pkg_list
		fi
	elif command -v pacman &> /dev/null; then
		sudo pacman -Rns --noconfirm $pacman_common_pkg_list
		if [[ "$headless" == false ]]; then
			sudo pacman -Rns --noconfirm $pacman_graphical_pkg_list
		fi
	elif command -v dnf &> /dev/null; then
		sudo dnf remove -y $dnf_common_pkg_list
		if [[ "$headless" == false ]]; then
			sudo dnf remove -y $dnf_graphical_pkg_list $fedora_graphical_pkg_list
		fi
	fi
}

rm -rf "$HOME/.cache/*"
if [[ "$action" == install ]]; then
	install_packages
fi
echo

mkdir -p "$git_dir"
echo "$target_path"
if [[ -d "$target_path/.git" ]]; then 
	echo "Dotfiles repository target path exists! Pulling repository..."
	cd "$target_path" && update_repository
else
	echo "Cloning dotfiles repository..."
	rm -rf "$target_path"
	git clone git@github.com:almostlight/dotfiles.git "$target_path" --depth 1
fi

cd "$target_path"
git submodule update --init --recursive

export DOTFILES_HEADLESS="$headless"
if [[ "$action" == remove ]]; then
	"$target_path/scripts/deploy.sh" --uninstall
	remove_packages
else
	exec "$target_path/scripts/deploy.sh"
fi

