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

echo "-------------------------------"
echo "Building auxiliary packages ..."
echo "-------------------------------"

if ! ls $WORKPATH/buildDEBs/xbmcbuntu-artwork_* > /dev/null 2>&1; then
	cd $WORKPATH/buildDEBs/xbmcbuntu-artwork
	dpkg-buildpackage -rfakeroot -b -uc -us
        if [ "$?" -ne "0" ]; then
                exit 1
        fi
fi

if ! ls $WORKPATH/buildDEBs/syslinux-themes-xbmcbuntu_* > /dev/null 2>&1; then
	cd $WORKPATH/buildDEBs/syslinux-themes-xbmcbuntu
	dpkg-buildpackage -rfakeroot -b -uc -us
        if [ "$?" -ne "0" ]; then
                exit 1
        fi
fi

if ! ls $WORKPATH/buildDEBs/ubiquity-slideshow-xbmcbuntu_* > /dev/null 2>&1; then
        cd $WORKPATH/buildDEBs/ubiquity-slideshow-xbmcbuntu
        dpkg-buildpackage -rfakeroot -b -uc -us # ubiquity
        if [ "$?" -ne "0" ]; then
                exit 1
        fi
fi

if ! ls $WORKPATH/buildDEBs/xbmcbuntu-default-settings_* > /dev/null 2>&1; then
        cd $WORKPATH/buildDEBs/xbmcbuntu-default-settings
        dpkg-buildpackage -rfakeroot -b -uc -us
        if [ "$?" -ne "0" ]; then
                exit 1
        fi
fi

if ! ls $WORKPATH/buildDEBs/xbmcbuntu-core_* > /dev/null 2>&1; then
        cd $WORKPATH/buildDEBs/xbmcbuntu-meta
        dpkg-buildpackage -rfakeroot -b -uc -us
        if [ "$?" -ne "0" ]; then
                exit 1
        fi
fi

