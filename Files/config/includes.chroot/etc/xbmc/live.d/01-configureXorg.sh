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

# Generates valid xorg.conf for proprietary drivers if missing
if [ -e /etc/X11/xorg.conf ] ; then
        exit 0
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

        apt-get purge libvdpau1 -y

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
                chown -R $xbmcUser:$xbmcUser /home/$xbmcUser/.xbmc
        else
                if grep -i -q usevdpau /home/$xbmcUser/.xbmc/userdata/guisettings.xml ; then
                        sed -i 's#<usevdpau>.*#<usevdpau>false</usevdpau>#' /home/$xbmcUser/.xbmc/userdata/guisettings.xml
                        chown -R $xbmcUser:$xbmcUser /home/$xbmcUser/.xbmc
                fi
        fi

        # run aticonfig
        /usr/lib/fglrx/bin/aticonfig --initial --sync-vsync=on -f
        ATICONFIG_RETURN_CODE=$?

        if [ $ATICONFIG_RETURN_CODE -eq 255 ]; then
                # aticonfig returns 255 on old unsuported ATI cards
                # Let the X default ati driver handle the card

                # revert to mesa
                update-alternatives --set i386-linux-gnu_gl_conf /usr/lib/mesa/ld.so.conf

                # TODO cleanup environment and guisettings

                ldconfig

                modprobe radeon # Required to permit KMS switching and support hardware GL
        fi
fi

exit 0
