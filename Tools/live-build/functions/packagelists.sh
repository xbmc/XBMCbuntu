#!/bin/sh

## live-build(7) - System Build Scripts
## Copyright (C) 2006-2011 Daniel Baumann <daniel@debian.org>
##
## live-build comes with ABSOLUTELY NO WARRANTY; for details see COPYING.
## This is free software, and you are welcome to redistribute it
## under certain conditions; see COPYING for details.


Expand_packagelist ()
{
	_LB_EXPAND_QUEUE="$(basename "${1}")"

	shift

	while [ -n "${_LB_EXPAND_QUEUE}" ]
	do
		_LB_LIST_NAME="$(echo ${_LB_EXPAND_QUEUE} | cut -d" " -f1)"
		_LB_EXPAND_QUEUE="$(echo ${_LB_EXPAND_QUEUE} | cut -s -d" " -f2-)"
		_LB_LIST_LOCATION=""
		_LB_NESTED=0
		_LB_ENABLED=1

		for _LB_SEARCH_PATH in ${@} "${LB_BASE:-/usr/share/live/build}/package-lists"
		do
			if [ -e "${_LB_SEARCH_PATH}/${_LB_LIST_NAME}" ]
			then
				_LB_LIST_LOCATION="${_LB_SEARCH_PATH}/${_LB_LIST_NAME}"
				break
			fi
		done

		if [ -z "${_LB_LIST_LOCATION}" ]
		then
			echo "W: Unknown package list '${_LB_LIST_NAME}'" >&2
			continue
		fi

		while read _LB_LINE
		do
			case "${_LB_LINE}" in
				\#if\ *)
					if [ ${_LB_NESTED} -eq 1 ]
					then
						echo "E: Nesting conditionals is not supported" >&2
						exit 1
					fi
					_LB_NESTED=1

					_LB_NEEDLE="$(echo "${_LB_LINE}" | cut -d' ' -f3-)"
					_LB_HAYSTACK="$(eval "echo \$LB_$(echo "${_LB_LINE}" | cut -d' ' -f2)")"

					_LB_ENABLED=0
					for _LB_NEEDLE_PART in ${_LB_NEEDLE}
					do
						for _LB_HAYSTACK_PART in ${_LB_HAYSTACK}
						do
							if [ "${_LB_NEEDLE_PART}" = "${_LB_HAYSTACK_PART}" ]
							then
								_LB_ENABLED=1
							fi
						done
					done
					;;

				\#nif\ *)
					if [ ${_LB_NESTED} -eq 1 ]
					then
						echo "E: Nesting conditionals is not supported" >&2
						exit 1
					fi
					_LB_NESTED=1

					_LB_NEEDLE="$(echo "${_LB_LINE}" | cut -d' ' -f3-)"
					_LB_HAYSTACK="$(eval "echo \$LB_$(echo "${_LB_LINE}" | cut -d' ' -f2)")"

					_LB_ENABLED=0
					for _LB_NEEDLE_PART in ${_LB_NEEDLE}
					do
						for _LB_HAYSTACK_PART in ${_LB_HAYSTACK}
						do
							if [ "${_LB_NEEDLE_PART}" != "${_LB_HAYSTACK_PART}" ]
							then
								_LB_ENABLED=1
							fi
						done
					done
					;;

				\#endif*)
					_LB_NESTED=0
					_LB_ENABLED=1
					;;

				\#*)
					if [ ${_LB_ENABLED} -ne 1 ]
					then
						continue
					fi

					# Find includes
					_LB_INCLUDES="$(echo "${_LB_LINE}" | sed -n \
						-e 's|^#<include> \([^ ]*\)|\1|gp' \
						-e 's|^#include <\([^ ]*\)>|\1|gp')"

					# Add to queue
					_LB_EXPAND_QUEUE="$(echo ${_LB_EXPAND_QUEUE} ${_LB_INCLUDES} |
						sed -e 's|[ ]*$||' -e 's|^[ ]*||')"
					;;

				*)
					if [ ${_LB_ENABLED} -eq 1 ]
					then
						echo "${_LB_LINE}"
					fi
					;;

			esac
		done < "${_LB_LIST_LOCATION}"
	done
}
