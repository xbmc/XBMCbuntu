#!/bin/bash

#      Copyright (C) 2005-2011 Team XBMC
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

xbmcUser=$1
xbmcParams=$2

activationToken="doNotDisableBackslashInXBMC"

# if strings are the same the token is NOT part of the parameters list
# here we want to stop script if the token is NOT there
if [ "$xbmcParams" != "${xbmcParams%$activationToken*}" ] ; then
	exit
fi

#
# Map it to empty to remove the default binding (ToggleFullscreen)
#
if [ ! -f /home/$xbmcUser/.xbmc/userdata/keymaps/noBS.xml ] ; then
	mkdir -p /home/$xbmcUser/.xbmc/userdata/keymaps &> /dev/null
	cat > /home/$xbmcUser/.xbmc/userdata/keymaps/noBS.xml << 'EOF'
<keyboard>
  <global>
    <backslash>osd</backslash>
  </global>
</keyboard>
EOF
	chown -R $xbmcUser:$xbmcUser /home/$xbmcUser/.xbmc >/dev/null 2>&1 &
fi

exit 0
