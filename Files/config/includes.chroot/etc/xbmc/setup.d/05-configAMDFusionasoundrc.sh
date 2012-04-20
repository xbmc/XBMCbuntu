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

#
# Exit if asoundrc already exists
#

if [ -f /home/$xbmcUser/.asoundrc ] ; then
	exit 0
fi

#
# Exit if system does not contain a AMD Fusion processor
#

AMDCPU=$(cat /proc/cpuinfo | grep 'model name' -m1 | egrep 'AMD E-350 Processor|AMD E-450 Processor')

if [ ! -n "$AMDCPU" ] ; then
	exit 0
fi

#
# AMD Fusion (E-350/E-450) chipset detection
#

# 1002:4383 = ATI Technologies Inc SBx00 Azalia
# 1002:1314 = ATI Wrestler HDMI Audio
AMDFusion=$(lspci -nn | grep '0403' | egrep '1002:4383|1002:1314')

if [ ! -n "$AMDFusion" ] ; then
	exit 0
fi

activationToken="noalsaconfig"

# if strings are NOT the same the token is part of the parameters list
# here we want to stop script if the token is there
if [ "$xbmcParams" != "${xbmcParams%$activationToken*}" ] ; then
	exit 0
fi

#
# Set AMD sound variables
#

HDMICARD=$(aplay -l | grep 'HDMI 0' -m1 | awk -F: '{ print $1 }' | awk '{ print $2 }')
HDMIDEVICE=$(aplay -l | grep 'HDMI 0' -m1 | awk -F: '{ print $2 }' | awk '{ print $5 }')

DIGITALCARD=$(aplay -l | grep 'Digital' -m1 | awk -F: '{ print $1 }' | awk '{ print $2 }')
DIGITALDEVICE=$(aplay -l | grep 'Digital' -m1 | awk -F: '{ print $2 }' | awk '{ print $5 }')

ANALOGCARD=$(aplay -l | grep 'Analog' -m1 | awk -F: '{ print $1 }' | awk '{ print $2 }')
ANALOGDEVICE=$(aplay -l | grep 'Analog' -m1 | awk -F: '{ print $2 }' | awk '{ print $5 }')

#
# Bails out if we don't have digital outputs
#
if [ -z $HDMICARD ] || [ -z $HDMIDEVICE ] || [ -z $DIGITALCARD ] || [ -z $DIGITALDEVICE ]; then
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
		pcm "both"
	}
}

pcm.both {
        type route
        slave {
                pcm multi
                channels 6
        }
        ttable.0.0 1.0
        ttable.1.1 1.0
        ttable.0.2 1.0
        ttable.1.3 1.0
        ttable.0.4 1.0
        ttable.1.5 1.0
}

pcm.multi {
        type multi
        slaves.a {
                pcm "hdmi_hw"
                channels 2
        }
        slaves.b {
                pcm "digital_hw"
                channels 2
        }
        slaves.c {
                pcm "analog_hw"
                channels 2
        }
        bindings.0.slave a
        bindings.0.channel 0
        bindings.1.slave a
        bindings.1.channel 1
        bindings.2.slave b
        bindings.2.channel 0
        bindings.3.slave b
        bindings.3.channel 1
        bindings.4.slave c
        bindings.4.channel 0
        bindings.5.slave c
        bindings.5.channel 1
}

pcm.hdmi_hw {
        type hw
        =HDMICARD=
        =HDMIDEVICE=
        channels 2
}

pcm.hdmi_formatted {
        type plug
        slave {
                pcm hdmi_hw
                rate 48000
                channels 2
        }
}

pcm.hdmi_complete {
        type softvol
        slave.pcm hdmi_formatted
        control.name hdmi_volume
        control.=HDMICARD=
}

pcm.digital_hw {
        type hw
        =DIGITALCARD=
        =DIGITALDEVICE=
        channels 2
}

pcm.analog_hw {
        type hw
        =ANALOGCARD=
        =ANALOGDEVICE=
        channels 2
}
EOF

	sed -i "s/=HDMICARD=/card $HDMICARD/g" /home/$xbmcUser/.asoundrc
	sed -i "s/=HDMIDEVICE=/device $HDMIDEVICE/g" /home/$xbmcUser/.asoundrc

	sed -i "s/=DIGITALCARD=/card $DIGITALCARD/g" /home/$xbmcUser/.asoundrc
	sed -i "s/=DIGITALDEVICE=/device $DIGITALDEVICE/g" /home/$xbmcUser/.asoundrc

	sed -i "s/=ANALOGCARD=/card $ANALOGCARD/g" /home/$xbmcUser/.asoundrc
	sed -i "s/=ANALOGDEVICE=/device $ANALOGDEVICE/g" /home/$xbmcUser/.asoundrc

	chown $xbmcUser:$xbmcUser /home/$xbmcUser/.asoundrc >/dev/null 2>&1 &

	#
	# Setup Triple Audiooutput
	#
	if [ ! -f /home/$xbmcUser/.xbmc/userdata/guisettings.xml ] ; then
		mkdir -p /home/$xbmcUser/.xbmc/userdata &> /dev/null
		cat > /home/$xbmcUser/.xbmc/userdata/guisettings.xml << 'EOF'
<settings>
    <audiooutput>
	<audiodevice>custom</audiodevice>
	<channellayout>0</channellayout>
	<customdevice>plug:both</customdevice>
	<mode>2</mode>
	<passthroughdevice>alsa:hdmi</passthroughdevice>
    </audiooutput>
</settings>
EOF
		chown -R $xbmcUser:$xbmcUser /home/$xbmcUser/.xbmc
	else
		sed -i 's#\(<audiodevice>\)[0-9]*\(</audiodevice>\)#\1'custom'\2#g' /home/$xbmcUser/.xbmc/userdata/guisettings.xml
		sed -i 's#\(<channellayout>\)[0-9]*\(</channellayout>\)#\1'0'\2#g' /home/$xbmcUser/.xbmc/userdata/guisettings.xml
		sed -i 's#\(<customdevice>\)[0-9]*\(</customdevice>\)#\1'plug:both'\2#g' /home/$xbmcUser/.xbmc/userdata/guisettings.xml
		sed -i 's#\(<mode>\)[0-9]*\(</mode>\)#\1'2'\2#g' /home/$xbmcUser/.xbmc/userdata/guisettings.xml
		sed -i 's#\(<passthroughdevice>\)[0-9]*\(</passthroughdevice>\)#\1'alsa:hdmi'\2#g' /home/$xbmcUser/.xbmc/userdata/guisettings.xml
	fi
fi

#
# Unmute digital output
#

for i in $(aplay -l | grep card | awk '{print $2}' | sed -e 's/\://g' | sort | uniq);
do
	oldifs="$IFS"
	IFS="
	"
	for line in $(/usr/bin/amixer -c $i | grep 'Simple mixer control' | grep 'IEC958' | awk '{print $4,$5,$6}');
		do
			/usr/bin/amixer -q -c $i sset $line unmute;
		done;
	IFS="$oldifs"
done;

#
# Store alsa settings
#

alsactl store >/dev/null 2>&1 &

# Debug

echo "--alsa asoundrc script" >> /tmp/debugInfo.txt
cat /home/$xbmcUser/.asoundrc >> /tmp/debugInfo.txt
echo "--alsa cpu info" >> /tmp/debugInfo.txt
cat /proc/cpuinfo >> /tmp/debugInfo.txt

exit 0
