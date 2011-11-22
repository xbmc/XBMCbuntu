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

cat $WORKPATH/auto/config | grep -v debian-installer | grep -v win32-loader > $WORKPATH/auto/config.live
rm $WORKPATH/auto/config
mv $WORKPATH/auto/config.live $WORKPATH/auto/config

rm $WORKPATH/copyFiles-installer.sh

rm $WORKPATH/buildDEBs/build-installer.sh

# Modify menu.lst
if [ -f $WORKPATH/Files/binary_grub/menu.lst ]; then
	  sed -i '/## BEGIN INSTALLER ##/,/## END INSTALLER ##/d' $WORKPATH/Files/binary_grub/menu.lst
fi

# Modify grub.cfg
if [ -f $WORKPATH/Files/binary_grub/grub.cfg ]; then
	  sed -i '/## BEGIN INSTALLER ##/,/## END INSTALLER ##/d' $WORKPATH/Files/binary_grub/grub.cfg
fi
