#!/bin/bash

# Copyright (C) 2005-2013 Team XBMC
# http://www.xbmc.org
#
# This Program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.
#
# This Program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with XBMC; see the file COPYING. If not, write to
# the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
# http://www.gnu.org/copyleft/gpl.html

xbmcUser=$1
xbmcParams=$2

#
# setup directories for XBMC sources
#

#create other sources if not exsting
if [ ! -d "/home/$xbmcUser/Music" ]; then
	mkdir /home/$xbmcUser/Music >/dev/null 2>&1 &
	chmod 755 /home/$xbmcUser/Music >/dev/null 2>&1 &
fi

if [ ! -d "/home/$xbmcUser/Pictures" ]; then
	mkdir /home/$xbmcUser/Pictures >/dev/null 2>&1 &
	chmod 755 /home/$xbmcUser/Pictures >/dev/null 2>&1 &
fi

if [ ! -d "/home/$xbmcUser/TV Shows" ]; then
	mkdir "/home/$xbmcUser/TV Shows" >/dev/null 2>&1 &
	chmod 755 "/home/$xbmcUser/TV Shows" >/dev/null 2>&1 &
fi

if [ ! -d "/home/$xbmcUser/Movies" ]; then
	mkdir /home/$xbmcUser/Movies >/dev/null 2>&1 &
	chmod 755 /home/$xbmcUser/Movies >/dev/null 2>&1 &
fi

if [ ! -d "/home/$xbmcUser/Downloads" ]; then
        mkdir /home/$xbmcUser/Downloads >/dev/null 2>&1 &
        chmod 755 /home/$xbmcUser/Downloads >/dev/null 2>&1 &
fi

if [ ! -f /home/$xbmcUser/userdata/sources.xml ] ; then
	mkdir -p /home/$xbmcUser/.xbmc/userdata &> /dev/null
	cat > /home/$xbmcUser/.xbmc/userdata/sources.xml << EOF
<sources>
  <video>
    <default pathversion="1"></default>
    <source>
      <name>Movies</name>
      <path pathversion="1">/home/$xbmcUser/Movies</path>
    </source>
    <source>
      <name>TV Shows</name>
      <path pathversion="1">/home/$xbmcUser/TV Shows</path>
    </source>
  </video>
  <music>
    <default pathversion="1"></default>
    <source>
      <name>Music</name>
      <path pathversion="1">/home/$xbmcUser/Music</path>
    </source>
  </music>
  <pictures>
    <default pathversion="1"></default>
    <source>
      <name>Pictures</name>
      <path pathversion="1">/home/$xbmcUser/Pictures</path>
    </source>
  </pictures>
</sources>
EOF
fi

chown -R $xbmcUser:$xbmcUser /home/$xbmcUser/ >/dev/null 2>&1 &

exit 0
