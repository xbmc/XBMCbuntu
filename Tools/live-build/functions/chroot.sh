#!/bin/sh

## live-build(7) - System Build Scripts
## Copyright (C) 2006-2011 Daniel Baumann <daniel@debian.org>
##
## live-build comes with ABSOLUTELY NO WARRANTY; for details see COPYING.
## This is free software, and you are welcome to redistribute it
## under certain conditions; see COPYING for details.


Chroot ()
{
	CHROOT="${1}"; shift
	COMMANDS="${@}"

	# Executing commands in chroot
	Echo_debug "Executing: %s" "${COMMANDS}"

	if [ "${LB_USE_FAKEROOT}" != "true" ]
	then
		${LB_ROOT_COMMAND} ${_LINUX32} /usr/sbin/chroot "${CHROOT}" /usr/bin/env -i HOME="/root" PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin" TERM="${TERM}" ftp_proxy="${LB_APT_FTP_PROXY}" http_proxy="${LB_APT_HTTP_PROXY}" DEBIAN_FRONTEND="${LB_DEBCONF_FRONTEND}" DEBIAN_PRIORITY="${LB_DEBCONF_PRIORITY}" DEBCONF_NOWARNINGS="${LB_DEBCONF_NOWARNINGS}" XORG_CONFIG="custom" ${COMMANDS}
	else
		# Building with fakeroot/fakechroot
		${LB_ROOT_COMMAND} ${_LINUX32} /usr/sbin/chroot "${CHROOT}" ${COMMANDS}
	fi

	return "${?}"
}
