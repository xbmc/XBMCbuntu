#!/bin/bash

[ -f /etc/polkit-1/localauthority/50-local.d/10-allow-update.pkla ] && exit 0

function polkitfile {
cat <<EOF
[Re-enable hibernate by default in upower]
Identity=unix-user:*
Action=org.freedesktop.upower.;org.freedesktop.consolekit.system.;org.freedesktop.udisks.;org.freedesktop.login1.
ResultActive=yes
ResultInactive=yes
ResultAny=yes
EOF
return 0
}

exit 0

