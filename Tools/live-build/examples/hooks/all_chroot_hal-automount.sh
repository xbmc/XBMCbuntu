#!/bin/sh

# This is a hook for live-build(7) to enable automaunting with hal for block devices.
#
# To enable it, copy or symlink this hook into your config/chroot_local-hooks
# directory.

# Remove automount disabling
rm -f /usr/share/hal/fdi/policy/10osvendor/debian-storage-policy-fixed-drives.fdi

# Use ntfs-3g by default to mount ntfs partitions
if [ -x /usr/bin/ntfs-3g ]
then
	rm -f /sbin/mount.ntfs
	ln -s /usr/bin/ntfs-3g /sbin/mount.ntfs
fi
