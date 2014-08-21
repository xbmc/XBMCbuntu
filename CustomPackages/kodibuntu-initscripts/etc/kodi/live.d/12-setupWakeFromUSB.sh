#!/bin/bash

#      Copyright (C) 2005-2013 Team KODI
#      http://www.kodi.tv
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
#  along with KODI; see the file COPYING.  If not, write to
#  the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
#  http://www.gnu.org/copyleft/gpl.html

kodiUser=$1
kodiParams=$2


activationToken="wakeOnUSBRemote"

# if strings are the same the token is NOT part of the parameters list
# here we want to stop script if the token is NOT there
if [ "$kodiParams" = "${kodiParams%$activationToken*}" ] ; then
	exit
fi

DEVICES=$(dmesg | grep input: | grep usb | grep -vi mouse| awk -F/ '{ print $4}')

for device in $DEVICES
	do
		usbPort=$(cat /proc/acpi/wakeup | grep $device | awk '{ print $1}')
		usbStatus=$(cat /proc/acpi/wakeup | grep $usbPort | awk {'print $3}')
		if [ "$usbStatus" = "*disabled" -o "$usbStatus" = "disabled" ]; then
			echo $usbPort > /proc/acpi/wakeup
	fi
done

exit 0
