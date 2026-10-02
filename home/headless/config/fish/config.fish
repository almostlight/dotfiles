# fish config
## Environment variables 
if string match -qrq '[wW][sS][lL]' (uname -r)
    export BROWSER=wslview
    export DISTRO="wsl"
    alias explorer="explorer.exe"
    alias wsl="wsl.exe"
	alias reboot="powershell.exe Restart-Computer"
    alias clip="clip.exe"
    alias logout="logoff.exe"
else if string match -qrq '[aA]rch' (uname -r)
    export DISTRO="arch"
end

if string match -qrq wayland (echo $XDG_SESSION_TYPE)
    alias logout="pkill -SIGTERM '.*wayland.*'"
    alias gpick='grim -g "$(slurp -p)" -t ppm - | magick - -format "%[pixel:p{0,0}]" txt:-'
    alias xclip='wl-copy'
end

export QT_QPA_PLATFORMTHEME=qt6ct
export EDITOR=vim
export VISUAL=vim
## Disable fish default greeting 
set fish_greeting
## Run commands if interactive mode
if status is-interactive
    echo
    #fastfetch
    fortune | cowsay
    echo
    if test "$DISTRO" = wsl
        fastfetch --logo Windows\ 11_small
    else if test "$DISTRO" = arch
        fastfetch --logo arch_small
    end
end

if test -n "$WAYLAND_DISPLAY"
    alias xterm="foot"
    function code --wraps code --description "run code with fractional scaling"
        command code --ozone-platform=wayland $argv &
    end
end

function supergfxctl --wraps supergfxctl
    command supergfxctl -gs $argv
end

alias sudo!="history | head -n1 | xargs sudo"
alias l ls

alias v vim
alias vl="vim  +\"'\"0"
alias ff="fastfetch"
alias c='clear'
alias sizeof="du -cksh"
alias update-grub="sudo grub2-mkconfig -o /boot/grub2/grub.cfg"
alias rm="rmtrash"
alias rmdir="rmdirtrash"
alias sudo="sudo "
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
abbr -a cp 'cp -i'
abbr -a mv 'mv -i'
alias r ranger
alias whereami pwd
alias fuck thefuck
alias python python3
alias py python
alias neofetch fastfetch
alias bt bluetui
alias git-profile="xdg-open https://github.com/"$(git config user.name)""
alias git-autopush="git add --all && git commit -am 'autosaving progress' && git push && git status"
alias wol='sudo ether-wake'
alias kexec-reboot='\
        echo "kernel: $(uname -r)" \
        && sudo kexec -l /boot/vmlinuz-linux --initrd=/boot/initramfs-linux.img --reuse-cmdline \
        && sudo systemctl kexec'

# Created by `pipx` on 2026-01-10 18:53:31
set PATH $PATH $HOME/.local/bin
