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
echo "Copying auxiliary packages ..."
echo "------------------------------"

mkdir -p $WORKPATH/Files/config/packages.chroot &> /dev/null

cp $WORKPATH/buildDEBs/xbmcbuntu-artwork*.deb $WORKPATH/Files/config/packages.chroot
cp $WORKPATH/buildDEBs/xbmcbuntu-icon-theme*.deb $WORKPATH/Files/config/packages.chroot
cp $WORKPATH/buildDEBs/xbmcbuntu-plymouth-theme_* $WORKPATH/Files/config/packages.chroot
cp $WORKPATH/buildDEBs/plymouth-theme-xbmcbuntu-* $WORKPATH/Files/config/packages.chroot

cp $WORKPATH/buildDEBs/syslinux-themes-xbmcbuntu-quantal*.deb $WORKPATH/Files/config/packages.chroot

cp $WORKPATH/buildDEBs/ubiquity-slideshow-xbmcbuntu*.deb $WORKPATH/Files/config/packages.chroot

cp $WORKPATH/buildDEBs/xbmcbuntu-default-settings*.deb $WORKPATH/Files/config/packages.chroot

cp $WORKPATH/buildDEBs/xbmcbuntu-core*.deb $WORKPATH/Files/config/packages.chroot
