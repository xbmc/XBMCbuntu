#!/bin/bash

#      Copyright (C) 2005-2013 Team XBMC
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

activationToken="nogenxconf"

# if strings are NOT the same the token is part of the parameters list
# here we want to stop script if the token is there
if [ "$xbmcParams" != "${xbmcParams%$activationToken*}" ] ; then
        exit 0
fi

#
# Generates valid xorg.conf for proprietary drivers
#

if [ -e /etc/X11/xorg.conf ] ; then
	rm -f /etc/X11/xorg.conf
fi

# Identify GPU, Intel by default
GPUTYPE="INTEL"

GPU=$(lspci -nn | grep 0300)

# 10de == NVIDIA
if test "${GPU#*10de}" != "$GPU" ; then
        GPUTYPE="NVIDIA"
else
        # 1002 == AMD
        if test "${GPU#*1002}" != "$GPU" ; then
                GPUTYPE="AMD"
        fi
fi

# Debug info
echo "--Debug info--" > /tmp/debugInfo.txt
echo "--cmdline" >> /tmp/debugInfo.txt
cat /proc/cmdline  >> /tmp/debugInfo.txt
echo "--GPU (lspci): $GPU" >> /tmp/debugInfo.txt
echo "--GPU type: $GPUTYPE" >> /tmp/debugInfo.txt

if [ "$GPUTYPE" = "NVIDIA" ]; then
	# blacklist non-proprietary nvidia drivers
	echo "blacklist nouveau" > /etc/modprobe.d/blacklist-nvidia.conf
	echo "blacklist lbm-nouveau" > /etc/modprobe.d/blacklist-nvidia.conf
	echo "blacklist nvidia-173" > /etc/modprobe.d/blacklist-nvidia.conf
	echo "blacklist nvidia-96" > /etc/modprobe.d/blacklist-nvidia.conf
	echo "alias nvidia nvidia-current" > /etc/modprobe.d/blacklist-nvidia.conf

	nvidiaGLConf=$(update-alternatives --list i386-linux-gnu_gl_conf | grep nvidia)
	update-alternatives --set i386-linux-gnu_gl_conf $nvidiaGLConf

	# run nvidia-xconfig
	/usr/bin/nvidia-xconfig -s --no-logo --no-composite --no-dynamic-twinview --force-generate

	if [ "$xbmcParams" != "${xbmcParams%setdpi*}" ] ; then
		echo "--set DPI" >> /tmp/debugInfo.txt
		sed -i -e 's%Section \"Monitor\"%&\n    Option     \"DPI\" \"120 x 120\"%' /etc/X11/xorg.conf
	fi

	sed -i -e 's%Section \"Screen\"%&\n    Option      \"HWCursor\" \"Off\"%' /etc/X11/xorg.conf
fi

ldconfig

# Debug
if [ -f /etc/X11/xorg.conf ] ; then
	echo "--xorg.conf" >> /tmp/debugInfo.txt
	cat /etc/X11/xorg.conf >> /tmp/debugInfo.txt
else
	echo "No xorg.conf" >> /tmp/debugInfo.txt
fi

echo "--ps" >> /tmp/debugInfo.txt
ps aux >> /tmp/debugInfo.txt

exit 0
