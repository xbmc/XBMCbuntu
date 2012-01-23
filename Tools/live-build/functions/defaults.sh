#!/bin/sh

## live-build(7) - System Build Scripts
## Copyright (C) 2006-2011 Daniel Baumann <daniel@debian.org>
##
## live-build comes with ABSOLUTELY NO WARRANTY; for details see COPYING.
## This is free software, and you are welcome to redistribute it
## under certain conditions; see COPYING for details.


Set_defaults ()
{
	## config/common

	if [ -e local/live-build ]
	then
		LB_BASE="${LB_BASE:-${PWD}/local/live-build}"
		PATH="${PWD}/local/live-build/scripts/build:${PATH}"
		export LB_BASE PATH
	else
		LB_BASE="${LB_BASE:-/usr/share/live/build}"
		export LB_BASE
	fi

	# Setting system type
	LB_SYSTEM="${LB_SYSTEM:-live}"

	# Setting mode (currently: debian, emdebian, progress, ubuntu and kubuntu)
	LB_MODE="${LB_MODE:-debian}"

	# Setting distribution name
	case "${LB_MODE}" in
		progress)
			LB_DISTRIBUTION="${LB_DISTRIBUTION:-artax}"
			LB_DERIVATIVE="true"
			;;

		ubuntu|kubuntu)
			LB_DISTRIBUTION="${LB_DISTRIBUTION:-oneric}"
			LB_DERIVATIVE="false"
			;;

		*)
			LB_DISTRIBUTION="${LB_DISTRIBUTION:-wheezy}"
			LB_DERIVATIVE="false"
			;;
	esac

	case "${LB_MODE}" in
		progress)
			case "${LB_DISTRIBUTION}" in
				artax)
					LB_PARENT_DISTRIBUTION="${LB_PARENT_DISTRIBUTION:-squeeze}"
					LB_PARENT_DEBIAN_INSTALLER_DISTRIBUTION="${LB_PARENT_DEBIAN_INSTALLER_DISTRIBUTION:-${LB_PARENT_DISTRIBUTION}}"
					;;


				artax-backports)
					LB_PARENT_DISTRIBUTION="${LB_PARENT_DISTRIBUTION:-squeeze}"
					LB_PARENT_DEBIAN_INSTALLER_DISTRIBUTION="${LB_PARENT_DEBIAN_INSTALLER_DISTRIBUTION:-${LB_PARENT_DISTRIBUTION}}"
					LB_BACKPORTS="false"
					;;

				baureo)
					LB_PARENT_DISTRIBUTION="${LB_PARENT_DISTRIBUTION:-sid}"
					LB_PARENT_DEBIAN_INSTALLER_DISTRIBUTION="${LB_PARENT_DEBIAN_INSTALLER_DISTRIBUTION:-${LB_PARENT_DISTRIBUTION}}"
					;;
			esac
			;;

		*)
			LB_PARENT_DISTRIBUTION="${LB_PARENT_DISTRIBUTION:-${LB_DISTRIBUTION}}"
			LB_PARENT_DEBIAN_INSTALLER_DISTRIBUTION="${LB_PARENT_DEBIAN_INSTALLER_DISTRIBUTION:-${LB_PARENT_DISTRIBUTION}}"
			;;
	esac

	# Setting package manager
	LB_APT="${LB_APT:-apt}"

	# Setting apt ftp proxy
	LB_APT_FTP_PROXY="${LB_APT_FTP_PROXY:-${ftp_proxy}}"
	ftp_proxy="${ftp_proxy:-${LB_APT_FTP_PROXY}}"

	# Setting apt http proxy
	LB_APT_HTTP_PROXY="${LB_APT_HTTP_PROXY:-${http_proxy}}"
	http_proxy="${http_proxy:-${LB_APT_HTTP_PROXY}}"

	# Setting apt pipeline
	# LB_APT_PIPELINE

	APT_OPTIONS="${APT_OPTIONS:---yes}"
	APTITUDE_OPTIONS="${APTITUDE_OPTIONS:---assume-yes}"

	BZIP2_OPTIONS="${BZIP2_OPTIONS:--6}"

	GZIP_OPTIONS="${GZIP_OPTIONS:--6}"

	if gzip --help | grep -qs "\-\-rsyncable"
	then
		GZIP_OPTIONS="$(echo ${GZIP_OPTIONS} | sed -e 's|--rsyncable||') --rsyncable"
	fi

	LZIP_OPTIONS="${LZIP_OPTIONS:--6}"

	LZMA_OPTIONS="${LZMA_OPTIONS:--6}"

	# Setting apt recommends
	case "${LB_MODE}" in
		emdebian|progress)
			LB_APT_RECOMMENDS="${LB_APT_RECOMMENDS:-false}"
			;;

		*)
			LB_APT_RECOMMENDS="${LB_APT_RECOMMENDS:-true}"
			;;
	esac

	# Setting apt secure
	LB_APT_SECURE="${LB_APT_SECURE:-true}"

	# Setting apt source
	case "${LB_MODE}" in
		progress)
			LB_APT_SOURCE_ARCHIVES="${LB_APT_SOURCE_ARCHIVES:-false}"
			;;

		*)
			LB_APT_SOURCE_ARCHIVES="${LB_APT_SOURCE_ARCHIVES:-true}"
			;;
	esac

	# Setting bootstrap program
	if [ -z "${LB_BOOTSTRAP}" ] || ( [ ! -x "$(which ${LB_BOOTSTRAP} 2>/dev/null)" ] && [ "${LB_BOOTSTRAP}" != "copy" ] )
	then
		if [ -x "/usr/sbin/debootstrap" ]
		then
			LB_BOOTSTRAP="debootstrap"
		elif [ -x "/usr/bin/cdebootstrap" ]
		then
			LB_BOOTSTRAP="cdebootstrap"
		else
			Echo_error "Cannot find /usr/sbin/debootstrap or /usr/bin/cdebootstrap. Please install debootstrap or cdebootstrap, or specify an alternative bootstrapping utility."
			exit 1
		fi
	fi

	# Setting cache option
	LB_CACHE="${LB_CACHE:-true}"
	LB_CACHE_INDICES="${LB_CACHE_INDICES:-false}"
	LB_CACHE_PACKAGES="${LB_CACHE_PACKAGES:-true}"
	LB_CACHE_STAGES="${LB_CACHE_STAGES:-bootstrap}"

	# Setting debconf frontend
	LB_DEBCONF_FRONTEND="${LB_DEBCONF_FRONTEND:-noninteractive}"
	LB_DEBCONF_NOWARNINGS="${LB_DEBCONF_NOWARNINGS:-yes}"
	LB_DEBCONF_PRIORITY="${LB_DEBCONF_PRIORITY:-critical}"

	case "${LB_DEBCONF_NOWARNINGS}" in
		true)
			LB_DEBCONF_NOWARNINGS="yes"
			;;

		false)
			LB_DEBCONF_NOWARNINGS="no"
			;;
	esac

	# Setting initramfs hook
	case "${LB_INITRAMFS}" in
		auto)
			case "${LB_MODE}" in
				ubuntu|kubuntu)
					LB_INITRAMFS="casper"
					;;

				*)
					LB_INITRAMFS="live-boot"
					;;
			esac
			;;

		*)
			case "${LB_SYSTEM}" in
				live)
					LB_INITRAMFS="${LB_INITRAMFS:-auto}"
					;;

				normal)
					LB_INITRAMFS="${LB_INITRAMFS:-none}"
					;;
			esac
			;;
	esac

	LB_INITRAMFS_COMPRESSION="${LB_INITRAMFS_COMPRESSION:-gzip}"

	# Setting initsystem
	case "${LB_MODE}" in
		ubuntu|kubuntu)
			case "${LB_INITRAMFS}" in
				live-boot)
					LB_INITSYSTEM="${LB_INITSYSTEM:-upstart}"
					;;
			esac
			;;

		*)
			case "${LB_SYSTEM}" in
				live)
					LB_INITSYSTEM="${LB_INITSYSTEM:-sysvinit}"
					;;

				normal)
					LB_INITSYSTEM="${LB_INITSYSTEM:-none}"
					;;
			esac
			;;
	esac

	# Setting fdisk
	if [ -z "${LB_FDISK}" ] || [ ! -x "${LB_FDISK}" ]
	then
		# Workaround for gnu-fdisk divertion
		# (gnu-fdisk is buggy, #445304).
		if [ -x /sbin/fdisk.distrib ]
		then
			LB_FDISK="fdisk.distrib"
		elif [ -x /sbin/fdisk ]
		then
			LB_FDISK="fdisk"
		else
			Echo_error "Can't process file /sbin/fdisk"
		fi
	fi

	# Setting losetup
	if [ -z "${LB_LOSETUP}" ] || [ "${LB_LOSETUP}" != "/sbin/losetup.orig" ]
	then
		# Workaround for loop-aes-utils divertion
		# (loop-aes-utils' losetup lacks features).
		if [ -x /sbin/losetup.orig ]
		then
			LB_LOSETUP="losetup.orig"
		elif [ -x /sbin/losetup ]
		then
			LB_LOSETUP="losetup"
		else
			Echo_error "Can't process file /sbin/losetup"
		fi
	fi

	if [ "$(id -u)" = "0" ]
	then
		# If we are root, disable root command
		LB_ROOT_COMMAND=""
	else
		if [ -x /usr/bin/sudo ]
		then
			# FIXME: this is false until considered safe
			#LB_ROOT_COMMAND="sudo"
			LB_ROOT_COMMAND=""
		fi
	fi

	if [ "${LB_ARCHITECTURE}" = "i386" ] && [ "$(uname -m)" = "x86_64" ]
	then
		_LINUX32="linux32"
	else
		_LINUX32=""
	fi

	# Setting tasksel
	case "${LB_DISTRIBUTION}" in
		squeeze)
			LB_TASKSEL="${LB_TASKSEL:-tasksel}"
			;;

		*)
			LB_TASKSEL="${LB_TASKSEL:-apt}"
			;;
	esac

	# Setting root directory
	case "${LB_MODE}" in
		debian)
			LB_ROOT="${LB_ROOT:-debian-live}"
			;;

		progress)
			LB_ROOT="${LB_ROOT:-progress-linux}"
			;;

		*)
			LB_ROOT="${LB_ROOT:-${LB_MODE}-live}"
			;;
	esac

	# Setting includes
	LB_INCLUDES="${LB_INCLUDES:-${LB_BASE}/includes}"

	# Setting templates
	LB_TEMPLATES="${LB_TEMPLATES:-${LB_BASE}/templates}"

	# Setting live build options
	_BREAKPOINTS="${_BREAKPOINTS:-false}"
	_COLOR="${_COLOR:-false}"
	_DEBUG="${_DEBUG:-false}"
	_FORCE="${_FORCE:-false}"
	_QUIET="${_QUIET:-false}"
	_VERBOSE="${_VERBOSE:-false}"

	## config/bootstrap

	# Setting architecture value
	if [ -z "${LB_ARCHITECTURES}" ]
	then
		if [ -x "/usr/bin/dpkg" ]
		then
			LB_ARCHITECTURES="$(dpkg --print-architecture)"
		else
			case "$(uname -m)" in
				sparc|powerpc)
					LB_ARCHITECTURES="$(uname -m)"
					;;
				x86_64)
					LB_ARCHITECTURES="amd64"
					;;
				*)
					if [ -e /lib64 ]
					then
						LB_ARCHITECTURES="amd64"
					else
						LB_ARCHITECTURES="i386"
					fi

					Echo_warning "Can't determine architecture, assuming ${LB_ARCHITECTURES}"
					;;
			esac
		fi
	fi

	# Include packages on base
	# LB_BOOTSTRAP_INCLUDE

	# Exclude packages on base
	# LB_BOOTSTRAP_EXCLUDE

	# Setting flavour value
	case "${LB_BOOTSTRAP}" in
		cdebootstrap)
			LB_BOOTSTRAP_FLAVOUR="${LB_BOOTSTRAP_FLAVOUR:-standard}"
			;;
	esac

	# Setting bootstrap keyring
	# LB_BOOTSTRAP_KEYRING

	# Setting mirror to fetch packages from
	case "${LB_MODE}" in
		debian)
			LB_PARENT_MIRROR_BOOTSTRAP="${LB_PARENT_MIRROR_BOOTSTRAP:-http://ftp.de.debian.org/debian/}"
			LB_MIRROR_BOOTSTRAP="${LB_MIRROR_BOOTSTRAP:-${LB_PARENT_MIRROR_BOOTSTRAP}}"
			;;

		emdebian)
			LB_PARENT_MIRROR_BOOTSTRAP="${LB_PARENT_MIRROR_BOOTSTRAP:-http://www.emdebian.org/grip/}"
			LB_MIRROR_BOOTSTRAP="${LB_MIRROR_BOOTSTRAP:-${LB_PARENT_MIRROR_BOOTSTRAP}}"
			;;

		progress)
			LB_PARENT_MIRROR_BOOTSTRAP="${LB_PARENT_MIRROR_BOOTSTRAP:-http://ftp.debian.org/debian/}"
			LB_MIRROR_BOOTSTRAP="${LB_MIRROR_BOOTSTRAP:-http://archive.progress-linux.org/progress/}"
			;;

		ubuntu|kubuntu)
			case "${LB_ARCHITECTURES}" in
				amd64|i386)
					LB_PARENT_MIRROR_BOOTSTRAP="${LB_PARENT_MIRROR_BOOTSTRAP:-http://archive.ubuntu.com/ubuntu/}"
					;;

				*)
					LB_PARENT_MIRROR_BOOTSTRAP="${LB_PARENT_MIRROR_BOOTSTRAP:-http://ports.ubuntu.com/ubuntu-ports/}"
					;;
			esac

			LB_MIRROR_BOOTSTRAP="${LB_MIRROR_BOOTSTRAP:-${LB_PARENT_MIRROR_BOOTSTRAP}}"
			;;
	esac

	LB_PARENT_MIRROR_CHROOT="${LB_PARENT_MIRROR_CHROOT:-${LB_PARENT_MIRROR_BOOTSTRAP}}"
	LB_MIRROR_CHROOT="${LB_MIRROR_CHROOT:-${LB_MIRROR_BOOTSTRAP}}"

	# Setting security mirror to fetch packages from
	case "${LB_MODE}" in
		debian)
			LB_PARENT_MIRROR_CHROOT_SECURITY="${LB_PARENT_MIRROR_CHROOT_SECURITY:-http://security.debian.org/}"
			LB_MIRROR_CHROOT_SECURITY="${LB_MIRROR_CHROOT_SECURITY:-${LB_PARENT_MIRROR_CHROOT_SECURITY}}"
			;;

		emdebian)
			LB_PARENT_MIRROR_CHROOT_SECURITY="${LB_PARENT_MIRROR_CHROOT_SECURITY:-none}"
			LB_MIRROR_CHROOT_SECURITY="${LB_MIRROR_CHROOT_SECURITY:-${LB_PARENT_MIRROR_CHROOT_SECURITY}}"
			;;

		progress)
			LB_PARENT_MIRROR_CHROOT_SECURITY="${LB_PARENT_MIRROR_CHROOT_SECURITY:-http://security.debian.org/}"
			LB_MIRROR_CHROOT_SECURITY="${LB_MIRROR_CHROOT_SECURITY:-${LB_MIRROR_CHROOT}}"
			;;

		ubuntu|kubuntu)
			case "${LB_ARCHITECTURES}" in
				amd64|i386)
					LB_PARENT_MIRROR_CHROOT_SECURITY="${LB_PARENT_MIRROR_CHROOT_SECURITY:-http://security.ubuntu.com/ubuntu/}"
					;;

				*)
					LB_PARENT_MIRROR_CHROOT_SECURITY="${LB_PARENT_MIRROR_CHROOT_SECURITY:-http://ports.ubuntu.com/ubuntu-ports/}"
					;;
			esac

			LB_MIRROR_CHROOT_SECURITY="${LB_MIRROR_CHROOT_SECURITY:-${LB_PARENT_MIRROR_CHROOT_SECURITY}}"
			;;
	esac

	# Setting volatile mirror to fetch packages from
	case "${LB_MODE}" in
		debian)
			LB_PARENT_MIRROR_CHROOT_VOLATILE="${LB_PARENT_MIRROR_CHROOT_VOLATILE:-${LB_PARENT_MIRROR_CHROOT}}"
			LB_MIRROR_CHROOT_VOLATILE="${LB_MIRROR_CHROOT_VOLATILE:-${LB_PARENT_MIRROR_CHROOT}}"
			;;

		progress)
			LB_PARENT_MIRROR_CHROOT_VOLATILE="${LB_PARENT_MIRROR_CHROOT_VOLATILE:-${LB_PARENT_MIRROR_CHROOT}}"
			LB_MIRROR_CHROOT_VOLATILE="${LB_MIRROR_CHROOT_VOLATILE:-${LB_MIRROR_CHROOT}}"
			;;

		ubuntu|kubuntu)
			case "${LB_ARCHITECTURES}" in
				amd64|i386)
					LB_PARENT_MIRROR_CHROOT_VOLATILE="${LB_PARENT_MIRROR_CHROOT_VOLATILE:-http://archive.ubuntu.com/ubuntu/}"
					;;

				*)
					LB_PARENT_MIRROR_CHROOT_VOLATILE="${LB_PARENT_MIRROR_CHROOT_VOLATILE:-http://ports.ubuntu.com/ubuntu-ports/}"
					;;
			esac

			LB_MIRROR_CHROOT_VOLATILE="${LB_MIRROR_CHROOT_VOLATILE:-${LB_PARENT_MIRROR_CHROOT}}"
			;;

		*)
			LB_PARENT_MIRROR_CHROOT_VOLATILE="${LB_PARENT_MIRROR_CHROOT_VOLATILE:-none}"
			LB_MIRROR_CHROOT_VOLATILE="${LB_MIRROR_CHROOT_VOLATILE:-none}"
			;;
	esac

	# Setting backports mirror to fetch packages from
	case "${LB_MODE}" in
		debian)
			LB_PARENT_MIRROR_CHROOT_BACKPORTS="${LB_PARENT_MIRROR_CHROOT_BACKPORTS:-http://backports.debian.org/debian-backports/}"
			LB_MIRROR_CHROOT_BACKPORTS="${LB_MIRROR_CHROOT_BACKPORTS:-${LB_PARENT_MIRROR_CHROOT_BACKPORTS}}"
			;;

		progress)
			LB_MIRROR_CHROOT_BACKPORTS="${LB_MIRROR_CHROOT_BACKPORTS:-${LB_MIRROR_CHROOT}}"
			;;

		*)
			LB_PARENT_MIRROR_CHROOT_BACKPORTS="${LB_PARENT_MIRROR_CHROOT_BACKPORTS:-none}"
			LB_MIRROR_CHROOT_BACKPORTS="${LB_MIRROR_CHROOT_BACKPORTS:-none}"
			;;
	esac

	# Setting mirror which ends up in the image
	case "${LB_MODE}" in
		debian)
			LB_PARENT_MIRROR_BINARY="${LB_PARENT_MIRROR_BINARY:-http://cdn.debian.net/debian/}"
			LB_MIRROR_BINARY="${LB_MIRROR_BINARY:-${LB_PARENT_MIRROR_BINARY}}"
			;;

		progress)
			LB_PARENT_MIRROR_BINARY="${LB_PARENT_MIRROR_BINARY:-http://ftp.debian.org/debian/}"
			LB_MIRROR_BINARY="${LB_MIRROR_BINARY:-${LB_MIRROR_CHROOT}}"
			;;

		emdebian)
			LB_PARENT_MIRROR_BINARY="${LB_PARENT_MIRROR_BINARY:-http://www.emdebian.org/grip/}"
			LB_MIRROR_BINARY="${LB_MIRROR_BINARY:-${LB_PARENT_MIRROR_BINARY}}"
			;;

		ubuntu|kubuntu)
			case "${LB_ARCHITECTURES}" in
				amd64|i386)
					LB_PARENT_MIRROR_BINARY="${LB_PARENT_MIRROR_BINARY:-http://archive.ubuntu.com/ubuntu/}"
				;;

				*)
					LB_PARENT_MIRROR_BINARY="${LB_PARENT_MIRROR_BINARY:-http://ports.ubuntu.com/ubuntu-ports/}"
					;;
			esac

			LB_MIRROR_BINARY="${LB_MIRROR_BINARY:-${LB_PARENT_MIRROR_BINARY}}"
			;;
	esac

	# Setting security mirror which ends up in the image
	case "${LB_MODE}" in
		debian)
			LB_PARENT_MIRROR_BINARY_SECURITY="${LB_PARENT_MIRROR_BINARY_SECURITY:-http://security.debian.org/}"
			LB_MIRROR_BINARY_SECURITY="${LB_MIRROR_BINARY_SECURITY:-${LB_PARENT_MIRROR_BINARY_SECURITY}}"
			;;

		emdebian)
			LB_PARENT_MIRROR_BINARY_SECURITY="${LB_PARENT_MIRROR_BINARY_SECURITY:-none}"
			LB_MIRROR_BINARY_SECURITY="${LB_MIRROR_BINARY_SECURITY:-${LB_PARENT_MIRROR_BINARY_SECURITY}}"
			;;

		progress)
			LB_PARENT_MIRROR_BINARY_SECURITY="${LB_PARENT_MIRROR_BINARY_SECURITY:-http://security.debian.org/}"
			LB_MIRROR_BINARY_SECURITY="${LB_MIRROR_BINARY_SECURITY:-${LB_MIRROR_CHROOT}}"
			;;

		ubuntu|kubuntu)
			case "${LB_ARCHITECTURES}" in
				amd64|i386)
					LB_PARENT_MIRROR_BINARY_SECURITY="${LB_PARENT_MIRROR_BINARY_SECURITY:-http://security.ubuntu.com/ubuntu/}"
					;;

				*)
					LB_PARENT_MIRROR_BINARY_SECURITY="${LB_PARENT_MIRROR_BINARY_SECURITY:-http://ports.ubuntu.com/ubuntu-ports/}"
					;;
			esac

			LB_MIRROR_BINARY_SECURITY="${LB_MIRROR_BINARY_SECURITY:-${LB_PARENT_MIRROR_BINARY_SECURITY}}"
			;;
	esac

	# Setting volatile mirror which ends up in the image
	case "${LB_MODE}" in
		debian)
			LB_PARENT_MIRROR_BINARY_VOLATILE="${LB_PARENT_MIRROR_BINARY_VOLATILE:-${LB_PARENT_MIRROR_BINARY}}"
			LB_MIRROR_BINARY_VOLATILE="${LB_MIRROR_BINARY_VOLATILE:-${LB_PARENT_MIRROR_BINARY}}"
			;;

		progress)
			LB_PARENT_MIRROR_BINARY_VOLATILE="${LB_PARENT_MIRROR_BINARY_VOLATILE:-${LB_PARENT_MIRROR_BINARY}}"
			LB_MIRROR_BINARY_VOLATILE="${LB_MIRROR_BINARY_VOLATILE:-${LB_MIRROR_BINARY}}"
			;;

		ubuntu|kubuntu)
			case "${LB_ARCHITECTURES}" in
				amd64|i386)
					LB_PARENT_MIRROR_BINARY_VOLATILE="${LB_PARENT_MIRROR_BINARY_VOLATILE:-http://archive.ubuntu.com/ubuntu/}"
					;;

				*)
					LB_PARENT_MIRROR_BINARY_VOLATILE="${LB_PARENT_MIRROR_BINARY_VOLATILE:-http://ports.ubuntu.com/ubuntu-ports/}"
					;;
			esac
			;;

		*)
			LB_PARENT_MIRROR_BINARY_VOLATILE="${LB_PARENT_MIRROR_BINARY_VOLATILE:-none}"
			;;
	esac

	# Setting backports mirror which ends up in the image
	case "${LB_MODE}" in
		debian)
			LB_PARENT_MIRROR_BINARY_BACKPORTS="${LB_PARENT_MIRROR_BINARY_BACKPORTS:-http://backports.debian.org/debian-backports/}"
			LB_MIRROR_BINARY_BACKPORTS="${LB_MIRROR_BINARY_BACKPORTS:-${LB_PARENT_MIRROR_BINARY_BACKPORTS}}"
			;;

		progress)
			LB_PARENT_MIRROR_BINARY_BACKPORTS="${LB_PARENT_MIRROR_BINARY_BACKPORTS:-none}"
			LB_MIRROR_BINARY_BACKPORTS="${LB_MIRROR_BINARY_BACKPORTS:-${LB_MIRROR_CHROOT}}"
			;;

		*)
			LB_PARENT_MIRROR_BINARY_BACKPORTS="${LB_PARENT_MIRROR_BINARY_BACKPORTS:-none}"
			LB_MIRROR_BINARY_BACKPORTS="${LB_MIRROR_BINARY_BACKPORTS:-${LB_PARENT_MIRROR_BINARY_BACKPORTS}}"
			;;
	esac

	case "${LB_MODE}" in
		progress)
			LB_PARENT_MIRROR_DEBIAN_INSTALLER="${LB_PARENT_MIRROR_DEBIAN_INSTALLER:-${LB_MIRROR_CHROOT}}"
			LB_MIRROR_DEBIAN_INSTALLER="${LB_MIRROR_DEBIAN_INSTALLER:-${LB_MIRROR_CHROOT}}"
			;;

		*)
			LB_PARENT_MIRROR_DEBIAN_INSTALLER="${LB_PARENT_MIRROR_DEBIAN_INSTALLER:-${LB_PARENT_MIRROR_CHROOT}}"
			LB_MIRROR_DEBIAN_INSTALLER="${LB_MIRROR_DEBIAN_INSTALLER:-${LB_PARENT_MIRROR_CHROOT}}"
			;;
	esac

	# Setting archive areas value
	case "${LB_MODE}" in
		progress)
			LB_PARENT_ARCHIVE_AREAS="${LB_PARENT_ARCHIVE_AREAS:-main}"
			LB_ARCHIVE_AREAS="${LB_ARCHIVE_AREAS:-main}"
			;;

		ubuntu|kubuntu)
			LB_PARENT_ARCHIVE_AREAS="${LB_PARENT_ARCHIVE_AREAS:-main restricted}"
			LB_ARCHIVE_AREAS="${LB_ARCHIVE_AREAS:-${LB_PARENT_ARCHIVE_AREAS}}"
			;;

		*)
			LB_PARENT_ARCHIVE_AREAS="${LB_PARENT_ARCHIVE_AREAS:-main}"
			LB_ARCHIVE_AREAS="${LB_ARCHIVE_AREAS:-${LB_PARENT_ARCHIVE_AREAS}}"
			;;
	esac

	## config/chroot

	# Setting chroot filesystem
	LB_CHROOT_FILESYSTEM="${LB_CHROOT_FILESYSTEM:-squashfs}"

	# Setting whether to expose root filesystem as read only
	LB_EXPOSED_ROOT="${LB_EXPOSED_ROOT:-false}"

	# Setting union filesystem
	LB_UNION_FILESYSTEM="${LB_UNION_FILESYSTEM:-aufs}"

	# Setting distribution hooks
	case "${LB_MODE}" in
		*)
			LB_CHROOT_HOOKS="${LB_CHROOT_HOOKS:-update-apt-file-cache \
				update-apt-xapian-index \
				update-mlocate-database \
				remove-dbus-machine-id \
				remove-openssh-server-host-keys \
				remove-python-py \
				remove-udev-persistent-rules}"
			;;

		kubuntu)
			LB_CHROOT_HOOKS="${LB_CHROOT_HOOKS:-update-apt-file-cache \
				update-apt-xapian-index \
				update-mlocate-database \
				remove-dbus-machine-id \
				remove-gnome-icon-cache \
				remove-openssh-server-host-keys \
				remove-python-py \
				remove-udev-persistent-rules}"
			;;
	esac

	# Setting interactive shell/X11/Xnest
	LB_INTERACTIVE="${LB_INTERACTIVE:-false}"

	# Setting keyring packages
	case "${LB_MODE}" in
		ubuntu|kubuntu)
			LB_KEYRING_PACKAGES="${LB_KEYRING_PACKAGES:-ubuntu-keyring}"
			;;

		*)
			LB_KEYRING_PACKAGES="${LB_KEYRING_PACKAGES:-debian-archive-keyring}"
			;;
	esac

	# Setting linux flavour string
	case "${LB_ARCHITECTURES}" in
		armel)
			case "${LB_MODE}" in
                                ubuntu|kubuntu)
					LB_LINUX_FLAVOURS="${LB_LINUX_FLAVOURS:-omap}"
					;;
				*)
					# armel will have special images: one rootfs image and many additional kernel images.
					# therefore we default to all available armel flavours
					LB_LINUX_FLAVOURS="${LB_LINUX_FLAVOURS:-iop32x ixp4xx kirkwood orion5x versatile}"
					;;
			esac
			;;

		amd64)
			case "${LB_MODE}" in
				ubuntu|kubuntu)
					LB_LINUX_FLAVOURS="${LB_LINUX_FLAVOURS:-generic}"
					;;

				*)
					LB_LINUX_FLAVOURS="${LB_LINUX_FLAVOURS:-amd64}"
					;;
			esac
			;;

		i386)
			case "${LB_MODE}" in
				progress)
					case "${LB_DISTRIBUTION}" in
						artax)
							LB_LINUX_FLAVOURS="${LB_LINUX_FLAVOURS:-686}"
							;;

						*)
							LB_LINUX_FLAVOURS="${LB_LINUX_FLAVOURS:-686-pae}"
							;;
					esac
					;;

				ubuntu|kubuntu)
					LB_LINUX_FLAVOURS="${LB_LINUX_FLAVOURS:-generic}"
					;;

				*)
					case "${LIST}" in
						stripped|minimal)
							LB_LINUX_FLAVOURS="${LB_LINUX_FLAVOURS:-486}"
							;;

						*)
							case "${LB_DISTRIBUTION}" in
								wheezy|sid)
									LB_LINUX_FLAVOURS="${LB_LINUX_FLAVOURS:-486 686-pae}"
									;;

								*)
									LB_LINUX_FLAVOURS="${LB_LINUX_FLAVOURS:-486 686}"
									;;
							esac
							;;
					esac
					;;
			esac
			;;

		ia64)
			case "${LB_MODE}" in
				progress)
					Echo_error "Architecture ${LB_ARCHITECTURES} not supported in the ${LB_MODE} mode."
					exit 1
					;;

				*)
					LB_LINUX_FLAVOURS="${LB_LINUX_FLAVOURS:-itanium}"
					;;
			esac
			;;

		powerpc)
			case "${LB_MODE}" in
				progress)
					Echo_error "Architecture ${LB_ARCHITECTURES} not supported in the ${LB_MODE} mode."
					exit 1
					;;

				ubuntu|kubuntu)
					case "${LIST}" in
						stripped|minimal)
							LB_LINUX_FLAVOURS="${LB_LINUX_FLAVOURS:-powerpc}"
							;;

						*)
							LB_LINUX_FLAVOURS="${LB_LINUX_FLAVOURS:-powerpc powerpc64-smp}"
							;;
					esac
					;;

				*)
					case "${LIST}" in
						stripped|minimal)
							LB_LINUX_FLAVOURS="${LB_LINUX_FLAVOURS:-powerpc}"
							;;

						*)
							LB_LINUX_FLAVOURS="${LB_LINUX_FLAVOURS:-powerpc powerpc64}"
							;;
					esac
					;;
			esac
			;;

		s390)
			case "${LB_MODE}" in
				progress|ubuntu|kubuntu)
					Echo_error "Architecture ${LB_ARCHITECTURES} not supported in the ${LB_MODE} mode."
					exit 1
					;;

				*)
					LB_LINUX_FLAVOURS="${LB_LINUX_FLAVOURS:-s390}"
					;;
			esac
			;;

		sparc)
			case "${LB_MODE}" in
				progress)
					Echo_error "Architecture ${LB_ARCHITECTURES} not supported in the ${LB_MODE} mode."
					exit 1
					;;

				*)
					LB_LINUX_FLAVOURS="${LB_LINUX_FLAVOURS:-sparc64}"
					;;
			esac
			;;

		*)
			Echo_error "Architecture(s) ${LB_ARCHITECTURES} not yet supported (FIXME)"
			exit 1
			;;
	esac

	# Set linux packages
	case "${LB_MODE}" in
		ubuntu|kubuntu)
			LB_LINUX_PACKAGES="${LB_LINUX_PACKAGES:-linux}"
			;;

		*)
			LB_LINUX_PACKAGES="${LB_LINUX_PACKAGES:-linux-image-2.6}"
			;;
	esac

	# Setting package list
	LB_PACKAGE_LISTS="${LB_PACKAGE_LISTS:-standard}"

	# Setting security updates option
	case "${LB_DISTRIBUTION}" in
		wheezy|sid|baureo)
			LB_SECURITY="${LB_SECURITY:-false}"
			;;

		*)
			LB_SECURITY="${LB_SECURITY:-true}"
			;;
	esac

	# Setting volatile updates option
	case "${LB_DISTRIBUTION}" in
		wheezy|sid|baureo)
			LB_VOLATILE="${LB_VOLATILE:-false}"
			;;

		*)
			LB_VOLATILE="${LB_VOLATILE:-true}"
			;;
	esac

	## config/binary

	# Setting image filesystem
	case "${LB_ARCHITECTURES}" in
		sparc)
			LB_BINARY_FILESYSTEM="${LB_BINARY_FILESYSTEM:-ext4}"
			;;

		*)
			LB_BINARY_FILESYSTEM="${LB_BINARY_FILESYSTEM:-fat16}"
			;;
	esac

	# Setting image type
	case "${LB_ARCHITECTURES}" in
		amd64|i386)
			LB_BINARY_IMAGES="${LB_BINARY_IMAGES:-iso-hybrid}"
			;;

		*)
			LB_BINARY_IMAGES="${LB_BINARY_IMAGES:-iso}"
			;;
	esac

	# Setting apt indices
	case "${LB_MODE}" in
		progress)
			LB_APT_INDICES="${LB_APT_INDICES:-none}"
			;;

		*)
			LB_APT_INDICES="${LB_APT_INDICES:-true}"
			;;
	esac

	# Setting bootloader
	if [ -z "${LB_BOOTLOADER}" ]
	then
		case "${LB_ARCHITECTURES}" in
			amd64|i386)
				LB_BOOTLOADER="syslinux"
				;;

			powerpc)
				LB_BOOTLOADER="yaboot"
				;;

			sparc)
				LB_BOOTLOADER="silo"
				;;
		esac
	fi

	# Setting checksums
	LB_CHECKSUMS="${LB_CHECKSUMS:-md5}"

	# Setting compression
	case "${LB_MODE}" in
		progress)
			LB_COMPRESSION="${LB_COMPRESSION:-none}"
			;;

		*)
			LB_COMPRESSION="${LB_COMPRESSION:-gzip}"
			;;
	esac

	# Setting chroot option
	LB_BUILD_WITH_CHROOT="${LB_BUILD_WITH_CHROOT:-true}"

	LB_BUILD_WITH_TMPFS="${LB_BUILD_WITH_TMPFS:-false}"

	# Setting debian-installer option
	case "${LB_MODE}" in
		progress)
			LB_DEBIAN_INSTALLER="${LB_DEBIAN_INSTALLER:-live}"
			;;

		*)
			LB_DEBIAN_INSTALLER="${LB_DEBIAN_INSTALLER:-false}"
			;;
	esac

	LB_DEBIAN_INSTALLER_DISTRIBUTION="${LB_DEBIAN_INSTALLER_DISTRIBUTION:-${LB_DISTRIBUTION}}"

	# Setting debian-installer-gui
	case "${LB_MODE}" in
		debian|progress)
			LB_DEBIAN_INSTALLER_GUI="${LB_DEBIAN_INSTALLER_GUI:-true}"
			;;

		*)
			LB_DEBIAN_INSTALLER_GUI="${LB_DEBIAN_INSTALLER_GUI:-false}"
			;;
	esac

	# Setting debian-installer preseed filename
	if [ -z "${LB_DEBIAN_INSTALLER_PRESEEDFILE}" ]
	then
		if Find_files config/binary_debian-installer/preseed.cfg
		then
			LB_DEBIAN_INSTALLER_PRESEEDFILE="/preseed.cfg"
		fi

		if Find_files config/binary_debian-installer/*.cfg && [ ! -e config/binary_debian-installer/preseed.cfg ]
		then
			Echo_warning "You have placed some preseeding files into config/binary_debian-installer but you didn't specify the default preseeding file through LB_DEBIAN_INSTALLER_PRESEEDFILE. This means that debian-installer will not take up a preseeding file by default."
		fi
	fi

	# Setting boot parameters
	# LB_BOOTAPPEND_LIVE
	if [ -n "${LB_DEBIAN_INSTALLER_PRESEEDFILE}" ]
	then
		case "${LB_BINARY_IMAGES}" in
			iso*)
				_LB_BOOTAPPEND_PRESEED="file=/cdrom/install/${LB_DEBIAN_INSTALLER_PRESEEDFILE}"
				;;

			hdd*)
				case "${LB_MODE}" in
					ubuntu|kubuntu)
						if [ "${LB_DEBIAN_INSTALLER}" = "live" ]
						then
							_LB_BOOTAPPEND_PRESEED="file=/cdrom/install/${LB_DEBIAN_INSTALLER_PRESEEDFILE}"
						else
							_LB_BOOTAPPEND_PRESEED="file=/hd-media/install/${LB_DEBIAN_INSTALLER_PRESEEDFILE}"
						fi
						;;

					*)
						_LB_BOOTAPPEND_PRESEED="file=/hd-media/install/${LB_DEBIAN_INSTALLER_PRESEEDFILE}"
						;;
				esac
				;;

			net)
				case "${LB_DEBIAN_INSTALLER_PRESEEDFILE}" in
					*://*)
						_LB_BOOTAPPEND_PRESEED="file=${LB_DEBIAN_INSTALLER_PRESEEDFILE}"
						;;

					*)
						_LB_BOOTAPPEND_PRESEED="file=/${LB_DEBIAN_INSTALLER_PRESEEDFILE}"
						;;
				esac
				;;
		esac
	fi

	if [ -n ${_LB_BOOTAPPEND_PRESEED} ]
	then
		LB_BOOTAPPEND_INSTALL="${LB_BOOTAPPEND_INSTALL} ${_LB_BOOTAPPEND_PRESEED}"
	fi

	LB_BOOTAPPEND_INSTALL="$(echo ${LB_BOOTAPPEND_INSTALL} | sed -e 's/[ \t]*$//')"

	# Setting grub splash
	# LB_GRUB_SPLASH

	# Setting hostname
	LB_HOSTNAME="${LB_HOSTNAME:-${LB_MODE}}"

	# Setting iso author
	case "${LB_MODE}" in
		debian)
			LB_ISO_APPLICATION="${LB_ISO_APPLICATION:-Debian Live}"
			;;

		emdebian)
			LB_ISO_APPLICATION="${LB_ISO_APPLICATION:-Emdebian Live}"
			;;

		progress)
			LB_ISO_APPLICATION="${LB_ISO_APPLICATION:-Progress Linux}"
			;;

		ubuntu)
			LB_ISO_APPLICATION="${LB_ISO_APPLICATION:-Ubuntu Live}"
			;;

		kubuntu)
			LB_ISO_APPLICATION="${LB_ISO_APPLICATION:-Kubuntu Live}"
			;;
	esac

	# Set iso preparer
	LB_ISO_PREPARER="${LB_ISO_PREPARER:-live-build \$VERSION; http://packages.qa.debian.org/live-build}"

	# Set iso publisher
	case "${LB_MODE}" in
		progress)
			LB_ISO_PUBLISHER="${LB_ISO_PUBLISHER:-Progress Linux; http://www.progress-linux.org/; progress-project@lists.progress-linux.org}"
			;;

		*)
			LB_ISO_PUBLISHER="${LB_ISO_PUBLISHER:-Debian Live project; http://live.debian.net/; debian-live@lists.debian.org}"
			;;
	esac

	# Setting hdd options
	case "${LB_MODE}" in
		debian)
			LB_HDD_LABEL="${LB_HDD_LABEL:-DEBIAN_LIVE}"
			;;

		emdebian)
			LB_HDD_LABEL="${LB_HDD_LABEL:-EMDEBIAN_LIVE}"
			;;

		progress)
			LB_HDD_LABEL="${LB_HDD_LABEL:-PROGRESS_$(echo ${LB_DISTRIBUTION} | tr [a-z] [A-Z])}"
			;;

		ubuntu)
			LB_HDD_LABEL="${LB_HDD_LABEL:-UBUNTU}"
			;;

		kubuntu)
			LB_HDD_LABEL="${LB_HDD_LABEL:-KUBUNTU}"
			;;
	esac

	# Setting hdd size
	LB_HDD_SIZE="${LB_HDD_SIZE:-10000}"

	# Setting iso volume
	case "${LB_MODE}" in
		debian)
			LB_ISO_VOLUME="${LB_ISO_VOLUME:-Debian ${LB_DISTRIBUTION} \$(date +%Y%m%d-%H:%M)}"
			;;

		emdebian)
			LB_ISO_VOLUME="${LB_ISO_VOLUME:-Emdebian ${LB_DISTRIBUTION} \$(date +%Y%m%d-%H:%M)}"
			;;

		progress)
			LB_ISO_VOLUME="${LB_ISO_VOLUME:-Progress ${LB_DISTRIBUTION}}"
			;;

		ubuntu)
			LB_ISO_VOLUME="${LB_ISO_VOLUME:-Ubuntu ${LB_DISTRIBUTION} \$(date +%Y%m%d-%H:%M)}"
			;;

		kubuntu)
			LB_ISO_VOLUME="${LB_ISO_VOLUME:-Ubuntu ${LB_DISTRIBUTION} \$(date +%Y%m%d-%H:%M)}"
			;;
	esac

	# Setting memtest option
	LB_MEMTEST="${LB_MEMTEST:-memtest86+}"

	# Setting win32-loader option
	case "${LB_MODE}" in
		progress|ubuntu|kubuntu)

			;;

		*)
			case "${LB_ARCHITECTURES}" in
				amd64|i386)
					if [ "${LB_DEBIAN_INSTALLER}" != "false" ]
					then
						LB_WIN32_LOADER="${LB_WIN32_LOADER:-true}"
					else
						LB_WIN32_LOADER="${LB_WIN32_LOADER:-false}"
					fi
					;;

				*)
					LB_WIN32_LOADER="${LB_WIN32_LOADER:-false}"
					;;
			esac
			;;
	esac

	# Setting netboot filesystem
	LB_NET_ROOT_FILESYSTEM="${LB_NET_ROOT_FILESYSTEM:-nfs}"

	# Setting netboot server path
	case "${LB_MODE}" in
		progress)
			LB_NET_ROOT_PATH="${LB_NET_ROOT_PATH:-/srv/progress-linux}"
			;;

		*)
			LB_NET_ROOT_PATH="${LB_NET_ROOT_PATH:-/srv/${LB_MODE}-live}"
			;;
	esac

	# Setting netboot server address
	LB_NET_ROOT_SERVER="${LB_NET_ROOT_SERVER:-192.168.1.1}"

	# Setting net cow filesystem
	LB_NET_COW_FILESYSTEM="${LB_NET_COW_FILESYSTEM:-nfs}"

	# Setting net tarball
	LB_NET_TARBALL="${LB_NET_TARBALL:-true}"

	# Setting syslinux theme package
	case "${LB_MODE}" in
		progress)
			LB_SYSLINUX_THEME="${LB_SYSLINUX_THEME:-progress-standard}"
			;;

		ubuntu)
			LB_SYSLINUX_THEME="${LB_SYSLINUX_THEME:-ubuntu-oneiric}"
			;;

		*)
			LB_SYSLINUX_THEME="${LB_SYSLINUX_THEME:-debian-squeeze}"
			;;
	esac

	# Setting username
	case "${LB_MODE}" in
		ubuntu)
			LB_USERNAME="${LB_USERNAME:-ubuntu}"
			;;

		kubuntu)
			LB_USERNAME="${LB_USERNAME:-ubuntu}"
			;;

		*)
			LB_USERNAME="${LB_USERNAME:-user}"
			;;
	esac

	# Setting swap file
	LB_SWAP_FILE_SIZE="${LB_SWAP_FILE_SIZE:-512}"

	## config/source

	# Setting source option
	LB_SOURCE="${LB_SOURCE:-false}"

	# Setting image type
	LB_SOURCE_IMAGES="${LB_SOURCE_IMAGES:-tar}"

	# Setting fakeroot/fakechroot
	LB_USE_FAKEROOT="${LB_USE_FAKEROOT:-false}"
}

Check_defaults ()
{
	if [ "${LB_CONFIG_VERSION}" ]
	then
		# We're only checking when we're actually running the checks
		# that's why the check for emptyness of the version;
		# however, as live-build always declares LB_CONFIG_VERSION
		# internally, this is safe assumption (no cases where it's unset,
		# except when bootstrapping the functions/defaults etc.).
		CURRENT_CONFIG_VERSION="$(echo ${LB_CONFIG_VERSION} | awk -F. '{ print $1 }')"

		if [ ${CURRENT_CONFIG_VERSION} -ge 4 ]
		then
			Echo_error "This config tree is too new for this version of live-build (${VERSION})."
			Echo_error "Aborting build, please get a new version of live-build."

			exit 1
		elif [ ${CURRENT_CONFIG_VERSION} -eq 2 ]
		then
			Echo_error "This config tree is too old for this version of live-build (${VERSION})."
			Echo_error "Aborting build, please repopulate the config tree."
			exit 1
		elif [ ${CURRENT_CONFIG_VERSION} -lt 1 ]
		then
			Echo_warning "This config tree does not specify a format version or has an unknown version number."
			Echo_warning "Continuing build, but it could lead to errors or different results. Please repopulate the config tree."
		fi
	fi

	if echo ${LB_PACKAGE_LISTS} | grep -qs -E "(stripped|minimal)\b"
	then
		# aptitude + stripped|minimal
		if [ "${LB_APT}" = "aptitude" ]
		then
			Echo_warning "You selected LB_PACKAGE_LISTS='%s' and LB_APT='aptitude'" "${LB_PACKAGE_LIST}. This configuration is potentially unsafe, as aptitude is not used in the stripped/minimal package lists."
		fi
	fi

	if [ "${LB_DEBIAN_INSTALLER}" != "false" ]
	then
		# d-i true, no caching
		if ! echo ${LB_CACHE_STAGES} | grep -qs "bootstrap\b" || [ "${LB_CACHE}" != "true" ] || [ "${LB_CACHE_PACKAGES}" != "true" ]
		then
			Echo_warning "You have selected values of LB_CACHE, LB_CACHE_PACKAGES, LB_CACHE_STAGES and LB_DEBIAN_INSTALLER which will result in 'bootstrap' packages not being cached. This configuration is potentially unsafe as the bootstrap packages are re-used when integrating the Debian Installer."
		fi
	fi

	if [ "${LB_BOOTLOADER}" = "syslinux" ]
	then
		# syslinux + fat
		case "${LB_BINARY_FILESYSTEM}" in
			fat*)
				;;
			*)
				Echo_warning "You have selected values of LB_BOOTLOADER and LB_BINARY_FILESYSTEM which are incompatible - syslinux only supports FAT filesystems."
				;;
		esac
	fi

	case "${LB_BINARY_IMAGES}" in
		hdd*)
			# grub or yaboot + hdd
			case "${LB_BOOTLOADER}" in
				grub|yaboot)
					Echo_error "You have selected a combination of bootloader and image type that is currently not supported by live-build. Please use either another bootloader or a different image type."
					exit 1
					;;
			esac
			;;
	esac

	if [ "$(echo \"${LB_ISO_APPLICATION}\" | wc -c)" -gt 128 ]
	then
		Echo_warning "You have specified a value of LB_ISO_APPLICATION that is too long; the maximum length is 128 characters."
	fi

	if [ "$(echo \"${LB_ISO_PREPARER}\" | wc -c)" -gt  128 ]
	then
		Echo_warning "You have specified a value of LB_ISO_PREPARER that is too long; the maximum length is 128 characters."
	fi

	if [ "$(echo \"${LB_ISO_PUBLISHER}\" | wc -c)" -gt 128 ]
	then
		Echo_warning "You have specified a value of LB_ISO_PUBLISHER that is too long; the maximum length is 128 characters."
	fi

	if [ "$(eval "echo \"${LB_ISO_VOLUME}\"" | wc -c)" -gt 32 ]
	then
		Echo_warning "You have specified a value of LB_ISO_VOLUME that is too long; the maximum length is 32 characters."
	fi

	if echo ${LB_PACKAGE_LISTS} | grep -qs -E "(stripped|minimal)\b"
	then
		if [ "${LB_APT_INDICES}" = "true" ]
		then
			Echo_warning "You have selected hook to minimise image size but you are still including package indices with your value of LB_APT_INDICES."
		fi
	fi

	# Architectures to use foreign bootstrap for
	LB_BOOTSTRAP_QEMU_ARCHITECTURES="${LB_BOOTSTRAP_QEMU_ARCHITECTURES:-}"

	# Packages to exclude for the foreign/ports bootstrapping
	LB_BOOTSTRAP_QEMU_EXCLUDE="${LB_PORTS_BOOTSTRAP_EXCLUDE:-}"

	# Ports using foreign bootstrap need a working qemu-*-system. This is the location it
	LB_BOOTSTRAP_QEMU_STATIC="${LB_BOOTSTRAP_QEMU_STATIC:-}"

}
