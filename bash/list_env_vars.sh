#!/usr/bin/env bash

echo "\n===Arguments parameters===\n"
echo "\$0: $0"	# :name of shell or shell script.
echo "\$0, \$1, \$2 :$1, $2, $3" # ... :positional parameters.
echo "\$#: $#"	# :number of positional parameters.
echo "\$?: $?"	# :most recent foreground pipeline exit status.
echo "\$-: $-"	# :current options set for the shell.
echo "\$\$: $$"	# :pid of the current shell (not subshell).
echo "\$!: $!" # :is the PID of the most recent background command.

echo -e "\n===Environment parameters===\n"
echo "\$DESKTOP_SESSION: $DESKTOP_SESSION"	# current display manager
echo "\$EDITOR: $EDITOR"	# preferred text editor.
echo "\$LANG: $LANG"	# current language.
echo "\$PATH: $PATH"	# list of directories to search for executable files (i.e. ready-to-run programs)
echo "\$PWD: $PWD"	#  current directory
echo "\$SHELL: $SHELL" # current shell
echo "\$USER: $USER"	# current username
echo "\$HOSTNAME: $HOSTNAME"	# current hostname
