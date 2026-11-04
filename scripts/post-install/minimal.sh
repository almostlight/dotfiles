#!/usr/bin/env bash
set -Eeuo pipefail

readonly config_url="https://raw.githubusercontent.com/almostlight/dotfiles/main/home/headless/config/fish/config.fish"
readonly current_user="$(id -un)"
readonly config_path="${HOME}/.config/fish/config.fish"

if [[ $EUID -eq 0 ]]; then
	sudo_cmd=()
else
	if ! command -v sudo >/dev/null 2>&1; then
		printf 'Error: sudo is required when the script is not run as root.\n' >&2
		exit 1
	fi
	sudo_cmd=(sudo)
fi

run_as_root() {
	"${sudo_cmd[@]}" "$@"
}

if command -v apt-get >/dev/null 2>&1; then
	run_as_root apt-get update
	run_as_root apt-get install -y git openssh-server fish wget
	ssh_service=ssh
elif command -v dnf >/dev/null 2>&1; then
	run_as_root dnf install -y git openssh-server fish wget
	ssh_service=sshd
elif command -v pacman >/dev/null 2>&1; then
	run_as_root pacman -Sy --noconfirm git openssh fish wget
	ssh_service=sshd
else
	printf 'Error: supported package manager not found (apt-get, dnf, or pacman).\n' >&2
	exit 1
fi

if command -v systemctl >/dev/null 2>&1; then
	run_as_root systemctl enable --now "$ssh_service"
elif command -v service >/dev/null 2>&1; then
	run_as_root service "$ssh_service" start
else
	printf 'Error: cannot start the SSH server; systemctl or service is required.\n' >&2
	exit 1
fi

fish_path=$(command -v fish)
if ! grep -Fxq "$fish_path" /etc/shells 2>/dev/null; then
	printf '%s\n' "$fish_path" | run_as_root tee -a /etc/shells >/dev/null
fi
if [[ "$(getent passwd "$current_user" | cut -d: -f7)" != "$fish_path" ]]; then
	run_as_root chsh -s "$fish_path" "$current_user"
fi

mkdir -p "$(dirname "$config_path")"
config_tmp=$(mktemp)
trap 'rm -f "$config_tmp"' EXIT
wget --no-verbose --output-document="$config_tmp" "$config_url"
if [[ ! -e "$config_path" ]] || ! cmp -s "$config_tmp" "$config_path"; then
	mv "$config_tmp" "$config_path"
fi

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
key_path="$HOME/.ssh/id_ed25519"
if [[ ! -f "$key_path" ]]; then
	ssh-keygen -t ed25519 -f "$key_path" -N ""
fi
if [[ ! -f "$key_path.pub" ]]; then
	ssh-keygen -y -f "$key_path" > "$key_path.pub"
fi
chmod 600 "$key_path"
chmod 644 "$key_path.pub"

printf '\nYour SSH public key (copy it to GitHub):\n'
cat "$key_path.pub"
printf '\nYour GitHub SSH label:\n'
printf '%s@%s\n' "$(whoami)" "$(hostname)"
printf '\nAdd both values at https://github.com/settings/ssh/new.\n'

printf '\nTesting GitHub SSH access:\n'
ssh_status=0
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new git@github.com || ssh_status=$?
if [[ $ssh_status -ne 0 && $ssh_status -ne 1 ]]; then
	printf 'GitHub SSH test failed with status %d.\n' "$ssh_status" >&2
	exit "$ssh_status"
fi
