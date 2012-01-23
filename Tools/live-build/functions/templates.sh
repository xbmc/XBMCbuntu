#!/bin/sh

## live-build(7) - System Build Scripts
## Copyright (C) 2006-2011 Daniel Baumann <daniel@debian.org>
##
## live-build comes with ABSOLUTELY NO WARRANTY; for details see COPYING.
## This is free software, and you are welcome to redistribute it
## under certain conditions; see COPYING for details.


Check_templates ()
{
	PACKAGE="${1}"

	if [ -d "config/templates/${PACKAGE}" ]
	then
		TEMPLATES="config/templates/${PACKAGE}"
	elif [ -d "${LB_TEMPLATES}/${PACKAGE}" ]
	then
		TEMPLATES="${LB_TEMPLATES}/${PACKAGE}"
	else
		Echo_error "%s templates not accessible in %s nor config/templates" "${PACKAGE}" "${LB_TEMPLATES}"
		exit 1
	fi
}
