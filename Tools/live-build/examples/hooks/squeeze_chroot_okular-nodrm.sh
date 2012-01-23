#!/bin/sh

# This is a hook for live-build(7) to configure KDE's PDF viewer to ignore
# manipulation restriction on "DRM protect" PDF documents.
#
# To enable it, copy or symlink this hook into your config/chroot_local-hooks
# directory.

if [ -d /usr/share/kde4/config ]
then
	# KDE4 (squeeze/sid)

cat > /usr/share/kde4/config/okularpartrc << EOF
[General]
ObeyDRM=false
EOF

fi
