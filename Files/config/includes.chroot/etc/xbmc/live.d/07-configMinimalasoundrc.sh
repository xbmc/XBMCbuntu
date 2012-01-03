#!/bin/bash

# Copyright (C) 2005-2008 Team XBMC
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

if [ -f /home/$xbmcUser/.asoundrc ] ; then
	exit
fi

HDMI=$(aplay -l | grep 'HDMI' -m1)
DIGITAL=$(aplay -l | grep 'Digital' -m1)
ANALOG=$(aplay -l | grep 'Analog' -m1)

if [ -n "$HDMI" ] ; then
	SOUND=$HDMI
else
	if [ -n "$DIGITAL" ] ; then
		SOUND=$DIGITAL
	else
        	if [ -n "$ANALOG" ] ; then
			SOUND=$ANALOG
        	else
			exit
		fi
	fi
fi

CARD=$(echo $SOUND | awk -F: '{ print $1 }' | awk '{ print $2 }')
DEVICE=$(echo $SOUND | awk -F: '{ print $2 }' | awk '{ print $5 }')

#
# Bails out if we don't have outputs
#

if [ -z $CARD ] || [ -z $DEVICE ]; then
	exit 0
fi

#
# Bails out if card or device is not numeric
#

if ! [ "$CARD" -eq "$CARD" 2> /dev/null ]; then
	exit 0
fi

if ! [ "$DEVICE" -eq "$DEVICE" 2> /dev/null ]; then
        exit 0
fi

#
# Setup .asoundrc
#

if [ ! -f /home/$xbmcUser/.asoundrc ] ; then
	cat > /home/$xbmcUser/.asoundrc << 'EOF'
pcm.!default {
	type plug
	slave {
		pcm "hw:=CARD=,=DEVICE="
	}
}
EOF
	sed -i "s/=CARD=/$CARD/g" /home/$xbmcUser/.asoundrc
	sed -i "s/=DEVICE=/$DEVICE/g" /home/$xbmcUser/.asoundrc

	chown $xbmcUser:$xbmcUser /home/$xbmcUser/.asoundrc
fi

exit 0
