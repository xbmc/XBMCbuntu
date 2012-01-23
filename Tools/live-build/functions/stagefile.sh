#!/bin/sh

## live-build(7) - System Build Scripts
## Copyright (C) 2006-2011 Daniel Baumann <daniel@debian.org>
##
## live-build comes with ABSOLUTELY NO WARRANTY; for details see COPYING.
## This is free software, and you are welcome to redistribute it
## under certain conditions; see COPYING for details.


Check_stagefile ()
{
	FILE="${1}"
	NAME="$(basename ${1})"

	# Checking stage file
	if [ -f "${FILE}" ]
	then
		if [ "${_FORCE}" != "true" ]
		then
			# Skipping execution
			Echo_warning "skipping %s, already done" "${NAME}"
			exit 0
		else
			# Forcing execution
			Echo_message "forcing %s" "${NAME}"
			rm -f "${FILE}"
		fi
	fi
}

Create_stagefile ()
{
	FILE="${1}"
	DIRECTORY="$(dirname ${1})"

	# Creating stage directory
	mkdir -p "${DIRECTORY}"

	# Creating stage file
	touch "${FILE}"
}

Require_stagefile ()
{
	NAME="$(basename ${0})"
	FILES="${@}"
	NUMBER="$(echo ${@} | wc -w)"

	for FILE in ${FILES}
	do
		# Find at least one of the required stages
		if [ -f ${FILE} ]
		then
			CONTINUE="true"
			NAME="${NAME} $(basename ${FILE})"
		fi
	done

	if [ "${CONTINUE}" != "true" ]
	then
		if [ "${NUMBER}" -eq 1 ]
		then
			Echo_error "%s: %s missing" "${NAME}" "${FILE}"
		else
			Echo_error "%s: one of %s is missing" "${NAME}" "${FILES}"
		fi

		exit 1
	fi
}
