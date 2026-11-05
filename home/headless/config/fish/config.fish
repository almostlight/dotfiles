# fish config
set PATH $PATH $HOME/.local/bin /sbin/*

## Environment variables
if string match -qrq '[aA]rch' (uname -r)
    set -gx DISTRO arch
end

if test "$XDG_SESSION_TYPE" = wayland
    if type -q pkill
        alias logout="pkill -SIGTERM '.*wayland.*'"
    end
    if type -q grim; and type -q slurp; and type -q magick
        alias gpick='grim -g "$(slurp -p)" -t ppm - | magick - -format "%[pixel:p{0,0}]" txt:-'
    end
    if type -q wl-copy
        alias xclip="wl-copy"
    end
end

export QT_QPA_PLATFORMTHEME=qt6ct
export EDITOR=vim
export VISUAL=vim
## Disable fish default greeting 
set fish_greeting
## Run commands if interactive mode
if status is-interactive; and not set -q FASTFETCH_STARTUP
    mkdir -p ~/.vim/backup
    if type -q fastfetch
        set -lx FASTFETCH_STARTUP 1
        fastfetch
    end
end

if test -n "$WAYLAND_DISPLAY"
    if type -q foot
        alias xterm="foot"
    end
    if type -q code
        function code --wraps code --description "run code with fractional scaling"
            command code --ozone-platform=wayland $argv &
        end
    end
end

if type -q supergfxctl
    function supergfxctl --wraps supergfxctl
        command supergfxctl -gs $argv
    end
end

abbr -a cp 'cp -i'
abbr -a mv 'mv -i'
alias l="ls"
alias c="clear"
alias sizeof="du -cksh"
alias whereami="pwd"
if type -q sudo
    alias sudo!="history | head -n1 | xargs sudo"
    alias sudo="sudo "
end
if type -q vim
    alias v="vim"
    alias vl="vim  +\"'\"0"
end
if type -q fastfetch
    alias ff="fastfetch"
    alias neofetch="fastfetch"
end
if type -q sudo; and type -q grub2-mkconfig
    alias update-grub="sudo grub2-mkconfig -o /boot/grub2/grub.cfg"
end
if type -q trash-put
    alias rm="trash-put"
    alias rmdir="trash-put"
end
if type -q ranger
    alias r="ranger"
end
if type -q thefuck
    alias fuck="thefuck"
end
if type -q python3
    alias python="python3"
    alias py="python"
end
if type -q bluetui
    alias bt="bluetui"
end
if type -q xdg-open; and type -q git
    alias git-profile="xdg-open https://github.com/(git config user.name)"
end
if type -q git
    alias git-autopush="git add --all && git commit -am 'autosaving progress' && git push && git status"
end
if type -q sudo; and type -q ether-wake
    alias wol="sudo ether-wake"
end
if type -q sudo; and type -q kexec; and type -q systemctl
    alias kexec-reboot='\
            echo "kernel: $(uname -r)" \
            && sudo kexec -l /boot/vmlinuz-linux --initrd=/boot/initramfs-linux.img --reuse-cmdline \
            && sudo systemctl kexec'
end
if type -q yt-dlp
    alias yt2mp4='yt-dlp -f "bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]" --merge-output-format mp4 '
end