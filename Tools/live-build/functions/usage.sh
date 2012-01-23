#!/bin/sh

## live-build(7) - System Build Scripts
## Copyright (C) 2006-2011 Daniel Baumann <daniel@debian.org>
##
## live-build comes with ABSOLUTELY NO WARRANTY; for details see COPYING.
## This is free software, and you are welcome to redistribute it
## under certain conditions; see COPYING for details.


Usage ()
{
	printf "%s - %s\n" "${PROGRAM}" "${DESCRIPTION}"
	echo
	Echo "Usage:"
	echo

	if [ -n "${USAGE}" ]
	then
		Echo " ${USAGE}"
		echo
	fi

	printf "  %s [-h|--help]\n" "${PROGRAM}"
	printf "  %s [-u|--usage]\n" "${PROGRAM}"
	printf "  %s [-v|--version]\n" "${PROGRAM}"
	echo
	Echo "Try \"%s --help\" for more information." "${PROGRAM}"

	exit 1
}
