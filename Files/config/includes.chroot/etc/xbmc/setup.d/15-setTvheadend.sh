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

xbmcUser=$1
xbmcParams=$2

sed -i -e "/^TVH_USER/s/\"\(.*\)\"/\"$xbmcUser\"/" /etc/default/tvheadend

mkdir -p /home/$xbmcUser/.hts/tvheadend/accesscontrol
cat > /home/$xbmcUser/.hts/tvheadend/accesscontrol/1 << EOF
{
        "enabled": 1,
        "username": "xbmc",
        "password": "xbmc",
        "comment": "Default access entry",
        "streaming": 1,
        "dvr": 1,
        "dvrallcfg": 1,
        "webui": 1,
        "admin": 1,
        "id": "1"
}
EOF

if [ -d /home/$xbmcUser/.hts ]
then
    chown -R $xbmcUser:$xbmcUser /home/$xbmcUser/.hts
fi

service tvheadend restart
