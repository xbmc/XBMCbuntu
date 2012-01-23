#!/bin/sh

## live-build(7) - System Build Scripts
## Copyright (C) 2006-2011 Daniel Baumann <daniel@debian.org>
##
## live-build comes with ABSOLUTELY NO WARRANTY; for details see COPYING.
## This is free software, and you are welcome to redistribute it
## under certain conditions; see COPYING for details.


Check_lockfile ()
{
	FILE="${1}"

	if [ -z "${FILE}" ]
	then
		FILE="/var/lock/${PROGRAM}.lock"
	fi

	# Checking lock file
	if [ -f "${FILE}" ]
	then
		Echo_error "${PROGRAM} locked"
		exit 1
	fi
}

Create_lockfile ()
{
	FILE="${1}"

	if [ -z "${FILE}" ]
	then
		FILE="/var/lock/${PROGRAM}.lock"
	fi

	DIRECTORY="$(dirname ${FILE})"

	# Creating lock directory
	mkdir -p "${DIRECTORY}"

	# Creating lock trap
	trap 'ret=${?}; '"rm -f \"${FILE}\";"' exit ${ret}' EXIT HUP INT QUIT TERM

	# Creating lock file
	touch "${FILE}"
}
