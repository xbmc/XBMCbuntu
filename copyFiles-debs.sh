#!/bin/sh

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

echo "----------------------------------------"
echo "Building/copying auxiliary packages ... "
echo "----------------------------------------"

mkdir -p $WORKPATH/Files/config/packages.chroot &> /dev/null

if ! ls $WORKPATH/Tools/xbmcbuntu-plymouth-theme_* > /dev/null 2>&1; then
	cd $WORKPATH/Tools/xbmcbuntu-artwork
	dpkg-buildpackage -rfakeroot -b -uc -us
fi

cp $WORKPATH/Tools/xbmcbuntu-plymouth-theme_* $WORKPATH/Files/config/packages.chroot
cp $WORKPATH/Tools/plymouth-theme-xbmcbuntu-* $WORKPATH/Files/config/packages.chroot


if ! ls $WORKPATH/Tools/syslinux-themes-xbmcbuntu_* > /dev/null 2>&1; then
	cd $WORKPATH/Tools/syslinux-themes-xbmcbuntu
	dpkg-buildpackage -rfakeroot -b -uc -us
fi

cp $WORKPATH/Tools/syslinux-themes-xbmcbuntu-oneiric*.deb $WORKPATH/Files/config/packages.chroot
