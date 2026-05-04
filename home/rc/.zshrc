export LANG=en_US.UTF-8

#!/usr/bin/env zsh
## Run commands if interactive mode
if [[ -o interactive ]]; then
    echo && fastfetch && echo
    # fortune | cowsay
fi

## Environment variables
if [[ $(which winget 2>/dev/null) ]]; then 
    export DISTRO=""
elif [[ $(uname -r) =~ '[wW][sS][lL]' ]]; then
    export DISTRO="wsl"
    export BROWSER=wslview
    alias explorer="explorer.exe"
    alias wsl="wsl.exe"
    alias clip="clip.exe"
elif [[ $(uname -r) =~ '[aA]rch' ]]; then
    export DISTRO="arch"
fi

if [[ $XDG_SESSION_TYPE =~ 'wayland' ]]; then
    alias logout="pkill -SIGTERM '.*wayland.*'"
    alias gpick='grim -g "$(slurp -p)" -t ppm - | magick - -format "%[pixel:p{0,0}]" txt:-'
    alias wlclip='wl-copy'
	alias wlprop="echo 'select window' && sleep 3 && kdotool getactivewindow | xargs kdotool getwindowclassname"
fi

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

## Nvim version to use (name of config directory in ~/.config/)
export NVIM_APPNAME="lightvim"
#export NVIM_APPNAME=nvim

## Disable zsh default greeting (fish's set fish_greeting equivalent)
unsetopt login

if [[ -n "$WAYLAND_DISPLAY" ]]; then
    alias xterm="foot"
    code() {
        command code --ozone-platform=wayland "$@" &
    }
fi

supergfxctl() {
    command supergfxctl -gs "$@"
}

visudo() {
	command sudo EDITOR=$EDITOR visudo
}

alias sudo!='fc -ln -1 | xargs sudo'
alias l='ls'

if [[ "$EDITOR" = "nvim" ]] || [[ "$VISUAL" = "nvim" ]]; then
    alias vim="nvim"
fi

alias z='source ~/.zshrc'
alias v='vim'
alias vl='vim -c "'\''0"'
alias ff='fastfetch'

alias update-grub='sudo grub2-mkconfig -o /boot/grub2/grub.cfg'
# alias rm="rmtrash"
# alias rmdir='rmdirtrash'
alias sudo='sudo'
alias r='ranger'
alias whereami='pwd'
alias fuck='thefuck'
alias python='python3'
alias py='python'
alias neofetch='fastfetch'
alias bt='bluetui'
alias time_nvim='nvim --startuptime /dev/stdout +qall && echo && time nvim +q'
alias sizeof='du -cksh'
alias git-profile='xdg-open https://github.com/"$(git config user.name)" 2>/dev/null'
alias git-autopush='git add --all && git commit -am "saving progress" && git push && git status'
alias yesupgrade="yes|sudo dnf update && yes|sudo dnf upgrade|lolcat"
alias wol='sudo ether-wake'

kexec-reboot() {
	local KERNEL="$(uname -r)"
    echo "kernel: $KERNEL"
	sudo kexec -l /boot/vmlinuz-"$KERNEL" --initrd=/boot/initramfs-"$KERNEL".img --reuse-cmdline \
    && sudo systemctl kexec
}

export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH:/usr/local/STMicroelectronics/STM32Cube/STM32CubeProgrammer/bin:/usr/local/STMicroelectronics/STMCUFinder

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
zstyle ':omz:update' frequency 7

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

plugins=(git zsh-autosuggestions zsh-history-substring-search zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

