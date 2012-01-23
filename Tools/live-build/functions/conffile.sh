#!/bin/sh

## live-build(7) - System Build Scripts
## Copyright (C) 2006-2011 Daniel Baumann <daniel@debian.org>
##
## live-build comes with ABSOLUTELY NO WARRANTY; for details see COPYING.
## This is free software, and you are welcome to redistribute it
## under certain conditions; see COPYING for details.


Get_conffiles ()
{
	if [ -n "${LB_CONFIG}" ]
	then
		FILES="${LB_CONFIG}"
	else
		for FILE in ${@}
		do
			FILES="${FILES} ${FILE} ${FILE}.${LB_ARCHITECTURES} ${FILE}.${DISTRIBUTION}"
			FILES="${FILES} config/$(echo ${PROGRAM} | sed -e 's|^lb_||')"
			FILES="${FILES} config/$(echo ${PROGRAM} | sed -e 's|^lb_||').${ARCHITECTURE}"
			FILES="${FILES} config/$(echo ${PROGRAM} | sed -e 's|^lb_||').${DISTRIBUTION}"
		done
	fi

	echo ${FILES}
}

Read_conffiles ()
{
	for CONFFILE in Get_conffiles "${@}"
	do
		if [ -f "${CONFFILE}" ]
		then
			if [ -r "${CONFFILE}" ]
			then
				Echo_debug "Reading configuration file %s" "${CONFFILE}"
				. "${CONFFILE}"
			else
				Echo_warning "Failed to read configuration file %s" "${CONFFILE}"
			fi
		fi
	done
}

Print_conffiles ()
{
	for CONFFILE in Get_conffiles "${@}"
	do
		if [ -f "${CONFFILE}" ]
		then
			Echo_file "${CONFFILE}"
		fi
	done
}
