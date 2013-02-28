#!/bin/bash

[ -f /etc/polkit-1/localauthority/50-local.d/custom-actions.pkla ] && exit 0
xbmcuser=$1
function polkitfile {
cat <<EOF
[Actions for %xbmcuser% user]
Identity=unix-user:%xbmcuser%
Action=org.freedesktop.upower.*;org.freedesktop.consolekit.system.*;org.freedesktop.udisks.*
ResultAny=yes
ResultInactive=yes
ResultActive=yes
EOF

return 0
}

polkitfile | sed "s/%xbmcuser%/$xbmcuser/g" > /etc/polkit-1/localauthority/50-local.d/custom-actions.pkla && exit 0

