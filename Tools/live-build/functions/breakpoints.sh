#!/bin/sh

## live-build(7) - System Build Scripts
## Copyright (C) 2006-2011 Daniel Baumann <daniel@debian.org>
##
## live-build comes with ABSOLUTELY NO WARRANTY; for details see COPYING.
## This is free software, and you are welcome to redistribute it
## under certain conditions; see COPYING for details.


Breakpoint ()
{
	NAME="${1}"

	if [ "${_BREAKPOINTS}" = "true" ]
	then
		Echo_message "Waiting at %s" "${NAME}"
		read WAIT
	fi
}
