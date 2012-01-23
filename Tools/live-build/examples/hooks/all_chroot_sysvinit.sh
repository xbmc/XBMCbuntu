#!/bin/sh

# Disable all
for _FILE in /etc/init.d/*
do
	update-rc.d -f $(basename ${_FILE}) remove
done

# Re-enable all required (taken from -f standard chroot)
for _PACKAGE in live-boot live-config console-common cron dpkg ifupdown initscripts kbd klogd libc6 libdevmapper1.02 libselinux1 libsepol1 login makedev module-init-tools netbase openbsd-inetd procps sudo sysklogd udev util-linux
do
	if [ -f /var/lib/dpkg/info/${_PACKAGE}.postinst ]
	then
		# Re-configure if existing
		/var/lib/dpkg/info/${_PACKAGE}.postinst configure
	fi
done
