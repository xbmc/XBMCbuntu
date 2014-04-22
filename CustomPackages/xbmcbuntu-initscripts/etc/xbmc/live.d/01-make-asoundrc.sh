#!/bin/bash
#      Copyright (C) 2005-2014 Team XBMC
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

xbmcuser=$1
homedir=/home/$xbmcuser
[ -z $xbmcuser ] && homedir=$HOME
GUISETTINGS=$homedir/.xbmc/userdata/guisettings.xml

function create_asoundrc {
  [ -f $homedir/.asoundrc ] && echo "Error: $homedir/.asoundrc exists, please remove it manually" && exit 1

  TEMP='
pcm.!default {
  type plug;
  slave.pcm "#DEVICE#";
}
'

  echo $TEMP | sed "s/#DEVICE#/$DEVICE/" > $homedir/.asoundrc
  echo "Alsa config created in $homedir/.asoundrc with following content:"
  cat $homedir/.asoundrc
  [ "$(id -u)" = "0" ] && chown $xbmcuser:$xbmcuser $homedir/.asoundrc
}

if [ -f $GUISETTINGS ]
then
  DEVICE=$(grep "<audiodevice>.*</audiodevice>" $GUISETTINGS | sed -e 's/\(<audiodevice>\)\(.*\)\(<\/audiodevice>\)/\2/g' -e 's/[\t ]//g')
else
  echo "Error: $GUISETTINGS not found"
  exit 1
fi

if [ "${DEVICE:0:4}" = "ALSA" ]
then
  DEVICE=${DEVICE:5}
  create_asoundrc
else
  echo "Error: no alsa device detected. found device: $DEVICE"
  exit 1
fi
