#!/bin/sh

## live-build(7) - System Build Scripts
## Copyright (C) 2006-2011 Daniel Baumann <daniel@debian.org>
##
## live-build comes with ABSOLUTELY NO WARRANTY; for details see COPYING.
## This is free software, and you are welcome to redistribute it
## under certain conditions; see COPYING for details.


set -e

# Adding symlink in /srv/tftp for debian-installer netboot images
ARCHITECTURE="$(dpkg --print-architecture)"

rm -rf /srv/tftp
ln -s /usr/lib/debian-installer/images/${ARCHITECTURE}/text /srv/tftp
