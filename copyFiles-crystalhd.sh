#!/bin/bash

#      Copyright (C) 2005-2008 Team XBMC
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

echo "--------------------------------"
echo "Retrieving CrystalHD drivers... "
echo "--------------------------------"


repoURL="http://ftp.debian.org/debian/pool/main/c/crystalhd/"
PACKAGELIST=(crystalhd-dkms libcrystalhd3 libcrystalhd-dev)

mkdir -p $WORKPATH/Files/config/packages.chroot &> /dev/null

cd $WORKPATH

for k in "${PACKAGELIST[@]}" ; do
	echo "   $k"

	latestPackage=$(curl -x "" -s -f $repoURL | grep -o "$k[^\"]*_i386.deb" | sort -r -k2 -t_ -n | head -n 1)
	if [ ! -f $latestPackage ]; then
	    wget --no-proxy -q "$repoURL$latestPackage"
	    if [ "$?" -ne "0" ] || [ ! -f $latestPackage ] ; then
		    echo "Needed package ($k) not found, exiting..."
		    exit 1
	    fi
	fi
	cp $latestPackage $WORKPATH/Files/config/packages.chroot
done

