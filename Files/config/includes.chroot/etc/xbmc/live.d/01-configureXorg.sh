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
if [ "$(echo $GPU | grep 10de)" ]; then
        GPUTYPE="NVIDIA"
else
        # 1002 == AMD
        if [ "$(echo $GPU | grep 1002)" ]; then
                GPUTYPE="AMD"
        fi
fi

# Debug info
echo "--Debug info--" > /tmp/debugInfo.txt
echo "--cmdline" >> /tmp/debugInfo.txt
cat /proc/cmdline  >> /tmp/debugInfo.txt
echo "--GPU type: $GPUTYPE" >> /tmp/debugInfo.txt

if grep "only-ubiquity" /proc/cmdline ; then
	if [ "$GPUTYPE" != "INTEL" ]; then
		# Remove kernel modules in memory (to avoid "vesa: Ignoring device with a bound kernel driver")
		if [ "$GPUTYPE" = "NVIDIA" ]; then
			echo "blacklist nouveau" > /etc/modprobe.d/blacklist-nvidia.conf
			echo "blacklist lbm-nouveau" >> /etc/modprobe.d/blacklist-nvidia.conf
			echo "blacklist nvidia-96" >> /etc/modprobe.d/blacklist-nvidia.conf
			echo "blacklist nvidia-173" >> /etc/modprobe.d/blacklist-nvidia.conf
			echo "blacklist nvidia" >> /etc/modprobe.d/blacklist-nvidia.conf
			echo "alias nvidia nvidia-current"  >> /etc/modprobe.d/blacklist-nvidia.conf
			echo "--nvidia blacklisted" >> /tmp/debugInfo.txt

			rmmod nvidia > /dev/null 2>&1 || true
			echo "--lsmod" >> /tmp/debugInfo.txt
			lsmod >> /tmp/debugInfo.txt
		fi
		if [ "$GPUTYPE" = "AMD" ]; then
			echo "blacklist radeon" > /etc/modprobe.d/blacklist-amd.conf
			echo "blacklist fglrx" >> /etc/modprobe.d/blacklist-amd.conf
			echo "--fglrx blacklisted" >> /tmp/debugInfo.txt

			rmmod fglrx > /dev/null 2>&1 || true
			echo "--lsmod" >> /tmp/debugInfo.txt
			lsmod >> /tmp/debugInfo.txt
		fi

		# Use the generic VESA driver
		echo 'Section "Device"' > /etc/X11/xorg.conf
		echo '    Identifier    "Configured Video Device"' >> /etc/X11/xorg.conf
		echo '    Driver        "vesa"' >> /etc/X11/xorg.conf
		echo 'EndSection' >> /etc/X11/xorg.conf
		echo "--using VESA module" >> /tmp/debugInfo.txt
	fi
else
	if [ "$GPUTYPE" = "NVIDIA" ]; then
		update-alternatives --set i386-linux-gnu_gl_conf /usr/lib/nvidia-current/ld.so.conf
		ldconfig

		# run nvidia-xconfig
		/usr/bin/nvidia-xconfig -s --no-logo --no-composite --no-dynamic-twinview --force-generate

		# Disable scaling to make sure the gpu does not loose performance
		sed -i -e 's%Section \"Screen\"%&\n    Option      \"FlatPanelProperties\" \"Scaling = Native\"\n    Option      \"HWCursor\" \"Off\"%' /etc/X11/xorg.conf
	fi

	if [ "$GPUTYPE" = "AMD" ]; then
		# Try fglrx first

		update-alternatives --set i386-linux-gnu_gl_conf /usr/lib/fglrx/ld.so.conf

		echo "LIBVA_DRIVERS_PATH=\"/usr/lib/va/drivers\"" >> /etc/environment
		echo "LIBVA_DRIVER_NAME=\"xvba\"" >> /etc/environment

		apt-get purge libvdpau1 -y >/dev/null 2>&1 &

		ldconfig

		if [ ! -f /home/$xbmcUser/.xbmc/userdata/guisettings.xml ] ; then
			mkdir -p /home/$xbmcUser/.xbmc/userdata &> /dev/null
			cat > /home/$xbmcUser/.xbmc/userdata/guisettings.xml << 'EOF'
<settings>
  <videoplayer>
      <usevdpau>false</usevdpau>
  </videoplayer>
</settings>
EOF
			chown -R $xbmcUser:$xbmcUser /home/$xbmcUser/.xbmc >/dev/null 2>&1 &
		else
			if grep -i -q usevdpau /home/$xbmcUser/.xbmc/userdata/guisettings.xml ; then
				sed -i 's#<usevdpau>.*#<usevdpau>false</usevdpau>#' /home/$xbmcUser/.xbmc/userdata/guisettings.xml
				chown -R $xbmcUser:$xbmcUser /home/$xbmcUser/.xbmc >/dev/null 2>&1 &
			fi
		fi

		# run aticonfig
		/usr/lib/fglrx/bin/aticonfig --initial --sync-vsync=on -f
		ATICONFIG_RETURN_CODE=$?

		#disable underscan
		aticonfig --set-pcs-val=MCIL,DigitalHDTVDefaultUnderscan,0

		if [ $ATICONFIG_RETURN_CODE -eq 255 ]; then
			# aticonfig returns 255 on old unsuported ATI cards
			# Let the X default ati driver handle the card

			# revert to mesa
			update-alternatives --set i386-linux-gnu_gl_conf /usr/lib/i386-linux-gnu/mesa/ld.so.conf

			# TODO cleanup environment and guisettings

			ldconfig

			modprobe radeon # Required to permit KMS switching and support hardware GL
		fi
	fi
fi

# Debug
if [ -f /etc/X11/xorg.conf ] ; then
	echo "--xorg.conf" >> /tmp/debugInfo.txt
	cat /etc/X11/xorg.conf >> /tmp/debugInfo.txt
else
	echo "No xorg.conf" >> /tmp/debugInfo.txt
fi

exit 0
