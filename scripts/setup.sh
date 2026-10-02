#!/bin/bash
set -Eeuo pipefail

apt_common_pkg_list="git curl jq tailscale vim ranger unzip openssh-client build-essential fastfetch trash-cli tesseract-ocr wget fish"
apt_graphical_pkg_list="firefox sway waybar wmenu wl-clipboard alacritty fonts-firacode"
pacman_common_pkg_list="git curl jq tailscale vim ranger unzip openssh base-devel fastfetch trash-cli tesseract wget fish"
pacman_graphical_pkg_list="firefox sway waybar wmenu wl-clipboard alacritty fira-code-fonts"
dnf_common_pkg_list="git curl jq tailscale vim ranger unzip openssh base-devel fastfetch trash-cli tesseract wget fish"
dnf_graphical_pkg_list="firefox sway waybar wmenu wl-clipboard alacritty fira-code-fonts"
git_dir="$HOME/github"
target_path="$git_dir/dotfiles_by_almostlight"
state_dir="$HOME/.local/state/dotfiles-by-almostlight"
shell_state_file="$state_dir/login-shells"
package_state_file="$state_dir/installed-packages"

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

read -r -p "=> Install or remove this dotfiles setup? [I/r] " action_answer < /dev/tty
if [[ "$action_answer" =~ ^[Rr]$ ]]; then
	action=remove
else
	action=install
fi

read -r -p "=> Is this a WSL/headless installation? [Y/n] " headless_answer < /dev/tty
if [[ "$headless_answer" =~ ^[Nn]$ ]]; then
	headless=false
else
	headless=true
fi

# Server installs are headless-only: only CLI software, then exit early
if [[ "$headless" == true ]]; then
	read -r -p "=> Is this a server installation? [Y/n] " server_answer < /dev/tty
	if [[ "$server_answer" =~ ^[Nn]$ ]]; then
		server=false
	else
		server=true
	fi
else
	server=false
fi

# Install packages based on distro
install_packages() {
	if command -v apt &> /dev/null; then
		sudo apt update
		if [[ "$server" == true ]]; then
			sudo apt install -y $apt_common_pkg_list
		elif [[ "$headless" == false ]]; then
			sudo apt install -y $apt_common_pkg_list $apt_graphical_pkg_list
		else
			sudo apt install -y $apt_common_pkg_list
		fi
    elif command -v pacman &> /dev/null; then
		if [[ "$server" == true ]]; then
			sudo pacman -Syu --noconfirm $pacman_common_pkg_list
		elif [[ "$headless" == false ]]; then
			sudo pacman -S --noconfirm $pacman_common_pkg_list $pacman_graphical_pkg_list
		else
			sudo pacman -S --noconfirm $pacman_common_pkg_list
		fi
    elif command -v dnf &> /dev/null; then
		if [[ "$server" == true ]]; then
			sudo dnf install --skip-unavailable -y $dnf_common_pkg_list
		elif [[ "$headless" == false ]]; then
			sudo dnf install --skip-unavailable -y $dnf_common_pkg_list $dnf_graphical_pkg_list
		else
			sudo dnf install --skip-unavailable -y $dnf_common_pkg_list
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
		    sudo dnf -qy install code
		    # curl -fsS https://dl.brave.com/install.sh | sh
		    # enable espanso
		    sudo setcap "cap_dac_override+p" "$(command -v espanso)"
		    espanso service register
        fi
    fi
}

set_default_shells() {
	local fish_path
	fish_path=$(command -v fish)

	sudo chsh -s "$fish_path" "$USER" || true
	sudo chsh -s "$fish_path" root || true
}

selected_package_list() {
	local common_packages graphical_packages
	if command -v apt &> /dev/null; then
		common_packages="$apt_common_pkg_list"
		graphical_packages="$apt_graphical_pkg_list"
	elif command -v pacman &> /dev/null; then
		common_packages="$pacman_common_pkg_list"
		graphical_packages="$pacman_graphical_pkg_list"
	else
		common_packages="$dnf_common_pkg_list"
		graphical_packages="$dnf_graphical_pkg_list"
	fi
	if [[ "$headless" == false ]]; then
		printf '%s %s\n' "$common_packages" "$graphical_packages"
	else
		printf '%s\n' "$common_packages"
	fi
}

package_is_installed() {
	local package="$1"
	if command -v apt &> /dev/null; then
		dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q 'install ok installed'
	elif command -v pacman &> /dev/null; then
		pacman -Q "$package" &> /dev/null
	elif command -v dnf &> /dev/null; then
		rpm -q "$package" &> /dev/null
	else
		return 1
	fi
}

record_new_packages() {
	if [[ -e "$package_state_file" ]]; then
		return 0
	fi

	mkdir -p "$state_dir"
	: > "$package_state_file"
	local package
	for package in $(selected_package_list); do
		if ! package_is_installed "$package"; then
			printf '%s\n' "$package" >> "$package_state_file"
		fi
	done
}

record_login_shells() {
	if [[ -e "$shell_state_file" ]]; then
		return 0
	fi

	local user_shell root_shell
	user_shell=$(getent passwd "$USER" | cut -d: -f7)
	root_shell=$(getent passwd root | cut -d: -f7)
	mkdir -p "$state_dir"
printf '%s:%s\n' "$USER" "$user_shell" > "$shell_state_file"
printf 'root:%s\n' "$root_shell" >> "$shell_state_file"
}

restore_login_shells() {
	if [[ ! -f "$shell_state_file" ]]; then
		return 0
	fi

	local account shell
	while IFS=: read -r account shell; do
		[[ -n "$account" && -n "$shell" ]] || continue
		sudo chsh -s "$shell" "$account" || true
	done < "$shell_state_file"
	rm -f "$shell_state_file"
}

remove_packages() {
	if [[ ! -s "$package_state_file" ]]; then
		printf 'No package manifest found; leaving installed packages untouched.\n'
		return 0
	fi

	local packages=()
	mapfile -t packages < "$package_state_file"
	if command -v apt &> /dev/null; then
		sudo apt remove -y "${packages[@]}"
	elif command -v pacman &> /dev/null; then
		sudo pacman -Rns --noconfirm "${packages[@]}"
	elif command -v dnf &> /dev/null; then
		sudo dnf remove -y "${packages[@]}"
	fi
	rm -f "$package_state_file"
}

if [[ -d "$HOME/.cache" ]]; then
	find "$HOME/.cache" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +
fi
if [[ "$action" == install ]]; then
	record_new_packages
	install_packages
	record_login_shells
	set_default_shells
fi

if [[ "$server" == true ]]; then
	echo "Server install: deploying CLI software only..."
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
	git clone https://github.com/almostlight/dotfiles.git "$target_path" --depth 1
fi

cd "$target_path"
git submodule update --init --recursive

export DOTFILES_HEADLESS="$headless"
if [[ "$action" == remove ]]; then
	"$target_path/scripts/deploy.sh" --uninstall
	restore_login_shells
	remove_packages
else
	exec "$target_path/scripts/deploy.sh"
fi
