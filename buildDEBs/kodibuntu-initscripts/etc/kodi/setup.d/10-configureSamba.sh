#!/bin/bash

# Copyright (C) 2005-2013 Team KODI
# http://www.kodi.tv
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
# along with KODI; see the file COPYING. If not, write to
# the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
# http://www.gnu.org/copyleft/gpl.html

kodiUser=$1
kodiParams=$2

#
# stop Samba
#

update-rc.d smbd defaults
service smbd stop

#
# setup smb config file
#
rm -f /etc/samba/smb.conf >/dev/null 2>&1
cat > /etc/samba/smb.conf << EOF

[global]
workgroup = WORKGROUP
server string = %h server (Samba, KODI)
dns proxy = no
name resolve order = hosts wins bcast
guest account = $kodiUser
load printers = no
show add printer wizard = no
log file = /var/log/samba/log.%m
max log size = 1000
syslog = 0
panic action = /usr/share/samba/panic-action %d
encrypt passwords = true
passdb backend = tdbsam
obey pam restrictions = yes
unix password sync = yes
passwd program = /usr/bin/passwd %u
passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .
pam password change = yes
map to guest = bad user

[Movies]
path = /home/$kodiUser/Movies
comment = Video's and Movies Folder
writeable = yes
browseable = yes
guest ok = yes

[Music]
path = /home/$kodiUser/Music
comment = Music Folder
writeable = yes
browseable = yes
guest ok = yes

[TV Shows]
path = /home/$kodiUser/TV Shows
comment = TV Shows Folder
writeable = yes
browseable = yes
guest ok = yes

[Downloads]
path = /home/$kodiUser/Downloads
comment = Downloads Folder
writeable = yes
browseable = yes
guest ok = yes

[Pictures]
path = /home/$kodiUser/Pictures
comment = Pictures
writeable = yes
browseable = yes
guest ok = yes

[System]
path = /home/$kodiUser/.kodi
comment = KODI System Share
writeable = yes
browseable = yes
guest ok = yes
EOF

#
# start Samba
#

service smbd start

exit 0

