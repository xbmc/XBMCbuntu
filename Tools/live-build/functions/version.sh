#!/bin/sh

## live-build(7) - System Build Scripts
## Copyright (C) 2006-2011 Daniel Baumann <daniel@debian.org>
##
## live-build comes with ABSOLUTELY NO WARRANTY; for details see COPYING.
## This is free software, and you are welcome to redistribute it
## under certain conditions; see COPYING for details.


Version ()
{
	Echo "%s, version %s" "${PROGRAM}" "${VERSION}"
	Echo "This program is a part of %s" "${PACKAGE}"
	echo
	Echo "Copyright (C) 2006-2011 Daniel Baumann <daniel@debian.org>"
	echo
	Echo "This program is free software: you can redistribute it and/or modify"
	Echo "it under the terms of the GNU General Public License as published by"
	Echo "the Free Software Foundation, either version 3 of the License, or"
	Echo "(at your option) any later version."
	echo
	Echo "This program is distributed in the hope that it will be useful,"
	Echo "but WITHOUT ANY WARRANTY; without even the implied warranty of"
	Echo "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the"
	Echo "GNU General Public License for more details."
	echo
	Echo "You should have received a copy of the GNU General Public License"
	Echo "along with this program. If not, see <http://www.gnu.org/licenses/>."
	echo
	Echo "The complete text of the GNU General Public License"
	Echo "can be found in /usr/share/common-licenses/GPL-3 file."
	echo
	Echo "Homepage: <http://live.debian.net/>"

	exit 0
}
