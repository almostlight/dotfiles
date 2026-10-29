function __history_expand
	set -l cmd (commandline)
	set -l prev (history | head -n 1)

	if test -z "$prev"
		commandline -f execute
		return
	end

	# !!
	set cmd (string replace --all '!!' -- "$prev" "$cmd")

	# Parse previous command into arguments.
	set -l args (string split ' ' -- "$prev")

	if test (count $args) -gt 1
		# !$
		set cmd (string replace --all '!$' -- "$args[-1]" "$cmd")

		# !^
		set cmd (string replace --all '!^' -- "$args[2]" "$cmd")

		# !*
		set -l rest "$args[2..-1]"
		set -l rest_joined (string join ' ' -- $rest)
		set cmd (string replace --all '!*' -- "$rest_joined" "$cmd")
	end

	commandline "$cmd"
	commandline -f execute
end

bind \r __history_expand
