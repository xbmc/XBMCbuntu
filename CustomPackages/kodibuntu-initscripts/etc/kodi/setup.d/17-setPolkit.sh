#!/bin/bash

[ -f /etc/polkit-1/localauthority/50-local.d/custom-actions.pkla ] && exit 0
kodiuser=$1
function polkitfile {
cat <<EOF
[Actions for %kodiuser% user]
Identity=unix-user:%kodiuser%
Action=org.freedesktop.upower.*;org.freedesktop.consolekit.system.*;org.freedesktop.udisks.*;org.debian.apt.upgrade-packages;org.debian.apt.update-cache;org.freedesktop.login1.*
ResultAny=yes
ResultInactive=yes
ResultActive=yes
EOF

return 0
}

polkitfile | sed "s/%kodiuser%/$kodiuser/g" > /etc/polkit-1/localauthority/50-local.d/custom-actions.pkla && exit 0

