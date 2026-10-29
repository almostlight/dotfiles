if status is-interactive
	if command -v pveversion
	    set -U fish_greeting
	    clear
	    uptime
	    if test -e /sys/class/power_supply/BAT0/capacity
	        cat /var/log/batcheck.log
	    end
	    pwrstat -status | awk -F' ' '/State/ {print "UPS status:\t", $2, $3}'
	    pct list
		echo
	end
end

alias reboot='echo "unavailable on this system"'
alias enter="pct enter"
alias daemon-reload="systemctl daemon-reload"
