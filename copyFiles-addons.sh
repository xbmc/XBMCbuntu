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

repoBaseURL="http://mirrors.kodi.tv/addons/"
#ADDONSLIST=(script.xbmc.debug.log@isengard script.rss.editor@gotham)
ADDONSLIST=(script.xbmc.debug.log@isengard)

mkdir -p $WORKPATH/configFiles/includes.chroot/etc/skel/.kodi/addons &> /dev/null

cd $WORKPATH

for k in "${ADDONSLIST[@]}" ; do
	IFS='@' read -ra ADDR <<< "$k" echo " $k"
	addonName=${ADDR[0]}
	repoDirectory=${ADDR[1]}	
	echo "  $addonName from $repoDirectory"

	addonPackage=$(ls $addonName*.zip 2> /dev/null)
	if [ -n "$addonPackage" ]; then
		latestPackage=$addonPackage
	else
		addonURL="$repoBaseURL$repoDirectory/$addonName/"

		latestPackage=$(curl -x "" -s -f $addonURL | grep -o "$addonName[^\"]*.zip" | sort -r -k2 -t_ -n | head -n 1)
		if [ ! -f $latestPackage ]; then
			wget --no-proxy -q "$addonURL$latestPackage"
			if [ "$?" -ne "0" ] || [ ! -f $latestPackage ] ; then
				echo "Needed package ($addonName) not found, exiting..."
				exit 1
			fi
		fi
	fi

	unzip -q $latestPackage -d $WORKPATH/configFiles/includes.chroot/etc/skel/.kodi/addons
done

exit 0
