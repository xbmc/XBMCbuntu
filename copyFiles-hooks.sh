#!/bin/bash

#      Copyright (C) 2005-2013 Team XBMC
#      http://www.xbmc.org
#
#  This Program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2, or (at your option)
#  any later version.
#
#  This Program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with XBMC; see the file COPYING.  If not, write to
#  the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
#  http://www.gnu.org/copyleft/gpl.html

echo "------------------------------"
echo "Copying chroot build hooks ..."
echo "------------------------------"

HOOKS=(
0100-remove-adjtime-configuration.chroot
0110-remove-backup-files.chroot
0120-remove-dbus-machine-id.chroot
0140-remove-log-files.chroot
0160-remove-openssh-server-host-keys.chroot
0170-remove-python-py.chroot
0190-remove-temporary-files.chroot
0200-remove-udev-persistent-rules.chroot
0300-update-apt-file-cache.chroot
0330-update-mlocate-database.chroot
0910-remove-apt-sources-lists.chroot
)



mkdir -p $WORKPATH/configFiles/hooks &> /dev/null

for HOOKFILE in ${HOOKS[*]}
do
	if [ -f $LIVE_BUILD/share/hooks/$HOOKFILE ]
	then
		# echo "copying $LIVE_BUILD/share/hooks/$HOOKFILE to $WORKPATH/configFiles/hooks"
		cp $LIVE_BUILD/share/hooks/$HOOKFILE $WORKPATH/configFiles/hooks
	else
		# echo "copying /usr/share/live/build/hooks/$HOOKFILE to $WORKPATH/configFiles/hooks"
		cp /usr/share/live/build/hooks/$HOOKFILE $WORKPATH/configFiles/hooks
	fi
done
exit 0


