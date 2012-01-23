#!/bin/sh

## live-build(7) - System Build Scripts
## Copyright (C) 2006-2011 Daniel Baumann <daniel@debian.org>
##
## live-build comes with ABSOLUTELY NO WARRANTY; for details see COPYING.
## This is free software, and you are welcome to redistribute it
## under certain conditions; see COPYING for details.


Find_files ()
{
	(ls "${@}" | grep -qs .) > /dev/null 2>&1
}

In_list ()
{
	NEEDLES="${1}"
	shift

	for ITEM in ${@}
	do
		for NEEDLE in ${NEEDLES}
		do
			if [ "${NEEDLE}" = "${ITEM}" ]
			then
				return 0
			fi
		done
	done

	return 1
}

Truncate ()
{
	for FILE in ${@}
	do
		: > ${FILE}
	done
}
