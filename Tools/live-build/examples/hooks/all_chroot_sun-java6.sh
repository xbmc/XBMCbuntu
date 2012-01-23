#!/bin/sh

# This is a hook for live-build(7) to install sun-java.
# To enable it, copy or symlink this hook into your config/chroot_local-hooks
# directory.
#
# Note: This hook requires packages from the non-free category. Make sure you
# enabled it in your configuration.

# live-build sets DEBIAN_FRONTEND to 'noninteractive' to advise debconf to not
# ask any questions while installing packages. Suns redistribution terms for
# Java do not allow this, therefore we need to overwrite DEBIAN_FRONTEND for
# this apt-get call only.

# In case you do accept the license terms, you can also preseed the values
# for a complete non-interactive build, by uncommenting the following three lines:

#echo "sun-java6-bin shared/accepted-sun-dlj-v1-1 boolean true" > /root/preseed
#debconf-set-selections < /root/preseed
#rm -f /root/preseed

DEBIAN_FRONTEND="dialog" apt-get install --yes sun-java6-bin sun-java6-demo \
	sun-java6-fonts sun-java6-javadb sun-java6-jdk sun-java6-jre \
	sun-java6-plugin sun-java6-source

# Ensure that /tmp has the right permissions; apparently sun-java5-doc tampers
# with it
chmod 1777 /tmp

# Set sun-java as default java
update-alternatives --set java /usr/lib/jvm/java-6-sun/jre/bin/java
