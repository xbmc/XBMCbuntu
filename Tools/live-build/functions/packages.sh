#!/bin/sh

## live-build(7) - System Build Scripts
## Copyright (C) 2006-2011 Daniel Baumann <daniel@debian.org>
##
## live-build comes with ABSOLUTELY NO WARRANTY; for details see COPYING.
## This is free software, and you are welcome to redistribute it
## under certain conditions; see COPYING for details.


Check_package ()
{
	FILE="${1}"
	PACKAGE="${2}"

	Check_installed "${FILE}" "${PACKAGE}"

	case "${INSTALL_STATUS}" in
		1)
			_LB_PACKAGES="${_LB_PACKAGES} ${PACKAGE}"
			;;

		2)
			Echo_error "You need to install %s on your host system." "${PACKAGE}"
			exit 1
			;;
	esac
}

Install_package ()
{
	if [ -n "${_LB_PACKAGES}" ] && [ "${LB_BUILD_WITH_CHROOT}" != "false" ]
	then
		case "${LB_APT}" in
			apt|apt-get)
				Chroot chroot "apt-get install -o APT::Install-Recommends=false ${APT_OPTIONS} ${_LB_PACKAGES}"
				;;

			aptitude)
				Chroot chroot "aptitude install --without-recommends ${APTITUDE_OPTIONS} ${_LB_PACKAGES}"
				;;
		esac
	fi
}

Remove_package ()
{
	if [ -n "${_LB_PACKAGES}" ] && [ "${LB_BUILD_WITH_CHROOT}" != "false" ]
	then
		case "${LB_APT}" in
			apt|apt-get)
				Chroot chroot "apt-get remove --purge ${APT_OPTIONS} ${_LB_PACKAGES}"
				;;

			aptitude)
				Chroot chroot "aptitude purge ${APTITUDE_OPTIONS} ${_LB_PACKAGES}"
				;;
		esac
	fi
}

# Check_installed
# uses as return value global var INSTALL_STATUS
# INSTALL_STATUS : 0 if package is installed
#                  1 if package isn't installed and we're in an apt managed system
#                  2 if package isn't installed and we aren't in an apt managed system
Check_installed ()
{
	FILE="${1}"
	PACKAGE="${2}"

	case "${LB_BUILD_WITH_CHROOT}" in
		true)
			if Chroot chroot "dpkg-query -s ${PACKAGE}" 2> /dev/null | grep -qs "Status: install"
			then
				INSTALL_STATUS=0
			else
				INSTALL_STATUS=1
			fi
			;;
		false)
			if which dpkg-query > /dev/null 2>&1
			then
				if Chroot chroot "dpkg-query -s ${PACKAGE}" 2> /dev/null | grep -qs "Status: install"
				then
					INSTALL_STATUS=0
				else
					INSTALL_STATUS=1
				fi
			else
				FILE="$(echo ${FILE} | sed -e 's|chroot||')"

				if [ ! -e "${FILE}" ]
				then
					INSTALL_STATUS=2
				else
					INSTALL_STATUS=0
				fi
			fi
			;;
	esac
}

