#!/bin/sh

# This is a hook for live-build(7) to install localepurge.
# To enable it, copy or symlink this hook into your config/chroot_local-hooks
# directory.
#

_PURGE=""

if [ ! -x "$(which symlinks 2>/dev/null)" ]
then
	_PURGE="true"

	apt-get install symlinks
fi

symlinks -c -r -s /

if [ "${_PURGE}" = "true" ]
then
	apt-get remove --purge symlinks
fi
