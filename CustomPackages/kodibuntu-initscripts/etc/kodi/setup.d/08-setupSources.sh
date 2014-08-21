#!/bin/bash

# Copyright (C) 2005-2013 Team KODI
# http://www.kodi.tv
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
# along with KODI; see the file COPYING. If not, write to
# the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
# http://www.gnu.org/copyleft/gpl.html

kodiUser=$1
kodiParams=$2

#
# setup directories for KODI sources
#

#create other sources if not exsting
if [ ! -d "/home/$kodiUser/Music" ]; then
	mkdir /home/$kodiUser/Music >/dev/null 2>&1 &
	chmod 755 /home/$kodiUser/Music >/dev/null 2>&1 &
fi

if [ ! -d "/home/$kodiUser/Pictures" ]; then
	mkdir /home/$kodiUser/Pictures >/dev/null 2>&1 &
	chmod 755 /home/$kodiUser/Pictures >/dev/null 2>&1 &
fi

if [ ! -d "/home/$kodiUser/TV Shows" ]; then
	mkdir "/home/$kodiUser/TV Shows" >/dev/null 2>&1 &
	chmod 755 "/home/$kodiUser/TV Shows" >/dev/null 2>&1 &
fi

if [ ! -d "/home/$kodiUser/Movies" ]; then
	mkdir /home/$kodiUser/Movies >/dev/null 2>&1 &
	chmod 755 /home/$kodiUser/Movies >/dev/null 2>&1 &
fi

if [ ! -d "/home/$kodiUser/Downloads" ]; then
        mkdir /home/$kodiUser/Downloads >/dev/null 2>&1 &
        chmod 755 /home/$kodiUser/Downloads >/dev/null 2>&1 &
fi

if [ ! -f /home/$kodiUser/userdata/sources.xml ] ; then
	mkdir -p /home/$kodiUser/.kodi/userdata &> /dev/null
	cat > /home/$kodiUser/.kodi/userdata/sources.xml << EOF
<sources>
  <video>
    <default pathversion="1"></default>
    <source>
      <name>Movies</name>
      <path pathversion="1">/home/$kodiUser/Movies</path>
    </source>
    <source>
      <name>TV Shows</name>
      <path pathversion="1">/home/$kodiUser/TV Shows</path>
    </source>
  </video>
  <music>
    <default pathversion="1"></default>
    <source>
      <name>Music</name>
      <path pathversion="1">/home/$kodiUser/Music</path>
    </source>
  </music>
  <pictures>
    <default pathversion="1"></default>
    <source>
      <name>Pictures</name>
      <path pathversion="1">/home/$kodiUser/Pictures</path>
    </source>
  </pictures>
</sources>
EOF
fi

chown -R $kodiUser:$kodiUser /home/$kodiUser/ >/dev/null 2>&1 &

exit 0
