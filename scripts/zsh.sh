#!/bin/bash 

if command -v apt &> /dev/null; then
	sudo apt install -y zsh git wget
elif command -v pacman &> /dev/null; then
	sudo pacman -S --noconfirm zsh git wget
elif command -v dnf &> /dev/null; then
	sudo dnf install -y zsh git wget
else
	echo "Unsupported package manager" >&2
	exit 1
fi
yes | sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

sudo chsh $USER -s /bin/zsh

