#!/bin/sh

# This is a hook for live-build(7) to remove any kernel except the newest one.
# To enable it, copy or symlink this hook into your config/chroot_local-hooks
# directory.

for VERSION in $(basename $(ls /boot/vmlinuz-* | head -n-1) | sed -e 's|^vmlinuz-||g')
do
	echo apt-get remove --purge linux-image-${VERSION}
done
