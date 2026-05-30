## Environment
export LANG=en_US.UTF-8
export QT_QPA_PLATFORMTHEME=qt6ct
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH:/usr/local/STMicroelectronics/STM32Cube/STM32CubeProgrammer/bin:/usr/local/STMicroelectronics/STMCUFinder

if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
    export VISUAL='vim'
else
    export EDITOR='nvim'
    export VISUAL='nvim'
fi

export NVIM_APPNAME="lightvim"
# export NVIM_APPNAME=nvim

## Distro detection
if (( $+commands[winget] )); then
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

## Wayland
if [[ $XDG_SESSION_TYPE == wayland || -n $WAYLAND_DISPLAY ]]; then
    alias logout="pkill -SIGTERM '.*wayland.*'"
    alias gpick='grim -g "$(slurp -p)" -t ppm - | magick - -format "%[pixel:p{0,0}]" txt:-'
    alias wlclip='wl-copy'
    alias wlprop="echo 'select window' && sleep 3 && kdotool getactivewindow | xargs kdotool getwindowclassname"
    alias xterm="foot"
    code() { command code --ozone-platform=wayland "$@" & }
fi

## Interactive shell greeting
if [[ -o interactive ]]; then
    echo && fastfetch && echo
fi

## Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
HYPHEN_INSENSITIVE="true"
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 7
plugins=(git zsh-autosuggestions zsh-history-substring-search zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

## Functions
supergfxctl()	{ command supergfxctl -gs "$@"; }
visudo()		{ command sudo EDITOR=$EDITOR visudo; }
looking-glass()	{ command looking-glass-client -m KEY_RIGHTCTRL wayland:fractionScale=no win:dontUpscale=yes }

kexec-reboot() {
    local KERNEL="$(uname -r)"
    echo "kernel: $KERNEL"
    sudo kexec -l /boot/vmlinuz-"$KERNEL" --initrd=/boot/initramfs-"$KERNEL".img --reuse-cmdline \
        && sudo systemctl kexec
}

## Aliases — Neovim
if [[ $EDITOR == nvim ]]; then
    alias vim='nvim'
	alias vi='command vim'
    alias v='nvim'
    alias time_nvim='nvim --startuptime /dev/stdout +qall && echo && time nvim +q'
fi
alias vl='vim -c "'\''0"'

## Aliases — shell
alias reload='source ~/.zshrc'
alias ls='ls --color'
alias l='ls'
alias ff='fastfetch'
alias neofetch='fastfetch'
alias whereami='pwd'
alias sizeof='du -cksh'
alias r='yazi'
alias bt='bluetui'
alias python='python3'
alias py='python'
alias fuck='thefuck'
alias sudo!='fc -ln -1 | xargs sudo'

## Aliases — git
alias git-profile='xdg-open https://github.com/"$(git config user.name)" 2>/dev/null'
alias git-autopush='f() { git add --all &&\
	git commit -am "${1:-saving progress}" &&\
	git push &&\
	git status; }; f'

## Aliases — system
alias update-grub='sudo grub2-mkconfig -o /boot/grub2/grub.cfg'
alias yesupgrade="yes | sudo dnf update && yes | sudo dnf upgrade | lolcat"
alias wol='sudo ether-wake'
alias diff="diff -u"

## Safe delete
if (( $+commands[trash-put] )); then
    alias rm='trash-put'
    alias rmdir='trash-put'   # handles directories too
    alias rm!='command rm -i' # for permanent delete
    alias rm-undo='trash-restore'
    alias rm-ls='trash-list'
fi

