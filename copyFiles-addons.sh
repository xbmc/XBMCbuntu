#!/bin/bash

#      Copyright (C) 2010-2012 Team KODI
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

echo "--------------------------"
echo "Retrieving addons...      "
echo "--------------------------"

repoURL="http://mirrors.kodi.tv/addons/isengard/"
#ADDONSLIST=(script.rss.editor script.xbmc.audio.mixer script.xbmc.debug.log service.xbmc.versioncheck)
ADDONSLIST=(script.xbmc.debug.log)

mkdir -p $WORKPATH/configFiles/includes.chroot/etc/skel/.kodi/addons &> /dev/null

cd $WORKPATH

for k in "${ADDONSLIST[@]}" ; do
	echo "   $k"

	addonPackage=$(ls $k*.zip 2> /dev/null)
	if [ -n "$addonPackage" ]; then
		latestPackage=$addonPackage
	else
		addonURL="$repoURL$k/"

		latestPackage=$(curl -x "" -s -f $addonURL | grep -o "$k[^\"]*.zip" | sort -r -k2 -t_ -n | head -n 1)
		if [ ! -f $latestPackage ]; then
			wget --no-proxy -q "$addonURL$latestPackage"
			if [ "$?" -ne "0" ] || [ ! -f $latestPackage ] ; then
				echo "Needed package ($k) not found, exiting..."
				exit 1
			fi
		fi
	fi

	unzip -q $latestPackage -d $WORKPATH/configFiles/includes.chroot/etc/skel/.kodi/addons
done

exit 0
