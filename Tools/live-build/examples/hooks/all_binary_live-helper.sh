#!/bin/sh

# This is a hook for live-build(7) to install live-build and its config into
# the binary image.
# To enable it, copy or symlink this hook into your config/chroot_local-hooks
# directory.

DIRECTORY="binary/tools/live"

mkdir -p "${DIRECTORY}"

cp -a config "${DIRECTORY}"

if [ -e live-build ]
then
	cp -a live-build "${DIRECTORY}"
else
	mkdir -p "${DIRECTORY}"/live-build/bin
	cp -a /usr/bin/lh* "${DIRECTORY}"/live-build/bin

	cp -a /usr/share/live/build "${DIRECTORY}"/live-build/share

	cp -a /usr/share/doc/live-build "${DIRECTORY}"/live-build/doc
fi
