#!/bin/sh

# This is a hook for live-build(7) to enable virtualbox-ose module.
# To enable it, copy or symlink this hook into your config/chroot_local-hooks
# directory.

# Enabling loading of vboxdrv
sed -i -e 's|^LOAD_VBOXDRV_MODULE=.*$|LOAD_VBOXDRV_MODULE=1|' /etc/default/virtualbox-ose
