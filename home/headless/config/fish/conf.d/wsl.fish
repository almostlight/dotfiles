if type -q wsl.exe
    alias wslview="explorer.exe"
    alias explorer="explorer.exe"
    alias wsl="wsl.exe"
    alias clip="clip.exe"
    alias logout="logoff.exe"
    alias logoff="logoff.exe"
    alias shutdown="powershell.exe Stop-Computer"
    alias reboot="powershell.exe Restart-Computer"
    alias reboot-deep="shutdown.exe /g /t 0"
    alias komorebi="komorebi.exe"
    alias komorebi-restart="komorebic.exe stop; komorebic.exe start"
    alias pwsh="pwsh.exe"
    alias cmd="cmd.exe"
    alias powershell="powershell.exe"
    alias notepad="notepad.exe"
    alias calc="calc.exe"
    alias mspaint="mspaint.exe"
    alias taskmgr="taskmgr.exe"
    alias wt="wt.exe"
    alias control="control.exe"
    export BROWSER=wslview
    set -gx DISTRO wsl

    function killall
        /mnt/c/Windows/System32/taskkill.exe /F /IM "$argv[1].exe"
    end
end
