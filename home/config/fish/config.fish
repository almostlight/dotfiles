## Environment variables 
if string match -qrq '[wW][sS][lL]' (uname -r)
    export BROWSER=wslview
    export DISTRO="wsl"
    alias explorer="explorer.exe"
    alias wsl="wsl.exe"
    alias clip="clip.exe"
else if string match -qrq '[aA]rch' (uname -r)
    export DISTRO="arch"
end

if string match -qrq wayland (echo $XDG_SESSION_TYPE)
    alias logout="pkill -SIGTERM '.*wayland.*'"
    alias gpick='grim -g "$(slurp -p)" -t ppm - | magick - -format "%[pixel:p{0,0}]" txt:-'
    alias xclip='wl-copy'
end

export QT_QPA_PLATFORMTHEME=qt6ct
export EDITOR=nvim
# export EDITOR=vim
## Nvim version to use (name of config directory in ~/.config/)
export NVIM_APPNAME="lightvim"
#export NVIM_APPNAME=nvim

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

if test "$EDITOR" = nvim -o "$VISUAL" = nvim
    alias vim="nvim"
end

alias v vim
alias vl="vim  +\"'\"0"
alias ff="fastfetch"

alias update-grub="sudo grub2-mkconfig -o /boot/grub2/grub.cfg"
# alias rm="rmtrash"
alias rmdir="rmdirtrash"
alias sudo="sudo "
alias r ranger
alias whereami pwd
alias fuck thefuck
alias python python3
alias py python
alias neofetch fastfetch
alias bt bluetui
alias time_nvim="nvim --startuptime /dev/stdout +qall && echo && time nvim +q"
alias sizeof="du -cksh"
alias git-profile="xdg-open https://github.com/"$(git config user.name)""
alias git-autopush="git add --all && git commit -am 'autosaving progress' && git push && git status"
alias wol='sudo ether-wake'

#alias kexec-reboot='\
#        echo "kernel: $(uname -r)" \
#        && kexec -l /boot/vmlinuz-$(uname -r) --initrd=/boot/initrd.img-$(uname -r) --reuse-cmdline \
#        && systemctl kexec'

alias kexec-reboot='\
        echo "kernel: $(uname -r)" \
        && sudo kexec -l /boot/vmlinuz-linux --initrd=/boot/initramfs-linux.img --reuse-cmdline \
        && sudo systemctl kexec'

# Created by `pipx` on 2026-01-10 18:53:31
set PATH $PATH $HOME/.local/bin
