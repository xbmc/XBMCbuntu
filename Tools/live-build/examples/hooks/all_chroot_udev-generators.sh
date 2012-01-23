#!/bin/sh

# This is a hook for live-build(7) to remove udev persistent device generator
# rules.
# To enable it, copy or symlink this hook into your config/chroot_local-hooks
# directory.

rm -f /etc/udev/rules.d/*persistent-net-generator.rules
