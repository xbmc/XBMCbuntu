#!/bin/bash

#      Copyright (C) 2005-2013 Team KODI
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

kodiUser=$1
kodiParams=$2

sed -i -e "/^TVH_USER/s/\"\(.*\)\"/\"$kodiUser\"/" /etc/default/tvheadend

mkdir -p /home/$kodiUser/.hts/tvheadend/accesscontrol
cat > /home/$kodiUser/.hts/tvheadend/accesscontrol/1 << EOF
{
        "enabled": 1,
        "username": "kodi",
        "password": "kodi",
        "comment": "Default access entry",
        "streaming": 1,
        "dvr": 1,
        "dvrallcfg": 1,
        "webui": 1,
        "admin": 1,
        "id": "1"
}
EOF

if [ -d /home/$kodiUser/.hts ]
then
    chown -R $kodiUser:$kodiUser /home/$kodiUser/.hts
fi

service tvheadend restart
