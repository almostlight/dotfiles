
plugins=(zsh-autosuggestions zsh-history-substring-search zsh-syntax-highlighting)

#!/usr/bin/env zsh
## Run commands if interactive mode
if [[ -o interactive ]]; then
    echo && fastfetch && echo
    # fortune | cowsay
fi

## Environment variables
if [[ $(uname -r) =~ '[wW][sS][lL]' ]]; then
    export BROWSER=wslview
    export DISTRO="wsl"
    alias explorer="explorer.exe"
    alias wsl="wsl.exe"
    alias clip="clip.exe"
elif [[ $(uname -r) =~ '[aA]rch' ]]; then
    export DISTRO="arch"
fi

if [[ $XDG_SESSION_TYPE =~ 'wayland' ]]; then
    alias logout="pkill -SIGTERM '.*wayland.*'"
    alias gpick='grim -g "$(slurp -p)" -t ppm - | magick - -format "%[pixel:p{0,0}]" txt:-'
    alias xclip='wl-copy'
fi

export EDITOR=nvim
# export EDITOR=vim
## Nvim version to use (name of config directory in ~/.config/)
export NVIM_APPNAME="lightvim"
#export NVIM_APPNAME=nvim

## Disable zsh default greeting (fish's set fish_greeting equivalent)
# In zsh, you can disable the greeting by not setting it or using:
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

alias sudo!='fc -ln -1 | xargs sudo'
alias l='ls'

if [[ "$EDITOR" = "nvim" ]] || [[ "$VISUAL" = "nvim" ]]; then
    alias vim="nvim"
fi

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
alias git-profile='xdg-open https://github.com/"$(git config user.name)"'
alias git-autopush='git add --all && git commit -am "saving progress" && git push && git status'
alias wol='sudo ether-wake'

alias kexec-reboot='\
        echo "kernel: $(uname -r)" \
        && sudo kexec -l /boot/vmlinuz-linux --initrd=/boot/initramfs-linux.img --reuse-cmdline \
        && sudo systemctl kexec'

export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

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
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
