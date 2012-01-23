#!/bin/sh

## live-build(7) - System Build Scripts
## Copyright (C) 2006-2011 Daniel Baumann <daniel@debian.org>
##
## live-build comes with ABSOLUTELY NO WARRANTY; for details see COPYING.
## This is free software, and you are welcome to redistribute it
## under certain conditions; see COPYING for details.


Arguments ()
{
	ARGUMENTS="$(getopt --longoptions breakpoints,conffile:,debug,force,help,quiet,usage,verbose,version --name=${PROGRAM} --options c:huv --shell sh -- "${@}")"

	if [ "${?}" != "0" ]
	then
		Echo_error "terminating" >&2
		exit 1
	fi

	eval set -- "${ARGUMENTS}"

	while true
	do
		case "${1}" in
			--breakpoints)
				_BREAKPOINTS="true"
				shift
				;;

			-c|--conffile)
				_CONFFILE="${2}"
				shift 2
				;;

			--debug)
				_DEBUG="true"
				shift
				;;

			--force)
				_FORCE="true"
				shift
				;;

			-h|--help)
				Man
				shift
				;;

			--quiet)
				_QUIET="true"
				shift
				;;

			-u|--usage)
				Usage
				shift
				;;

			--verbose)
				_VERBOSE="true"
				shift
				;;

			-v|--version)
				Version
				shift
				;;

			--)
				shift
				break
				;;

			*)
				Echo_error "internal error %s" "${0}"
				exit 1
				;;
		esac
	done
}
