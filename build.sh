#!/bin/bash
#      Copyright (C) 2005-2013 Team KODI
#      http://www.kodi.tv
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
#  along with KODI; see the file COPYING.  If not, write to
#  the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
#  http://www.gnu.org/copyleft/gpl.html

# Typically ran via
# sudo ./buildWithOptions.sh -p http://127.0.0.1:3142 (apt-cacher-ng) 
# sudo ./buildWithOptions.sh -p http://127.0.0.1:8000 (squid-deb-proxy) 
#
# sudo ./buildWithOptions.sh -p http://127.0.0.1:8000 |& tee buildLog.txt

echo
echo "Checking availability of required packages..."

REQUIREDPACKAGES=( git debootstrap asciidoc docbook-xsl curl build-essential debhelper autoconf automake autotools-dev curl subversion unzip squashfs-tools cdbs po4a python-utidylib germinate lzma icon-naming-utils ) # libterm-readline-gnu-perl
NOTINSTALLED=()

for k in "${REQUIREDPACKAGES[@]}" ; do
	if [ "$( dpkg -l | grep "ii  $k " )" = "" ] ; then
		NOTINSTALLED+=($k)
	fi
done

if [ ${#NOTINSTALLED[@]} -gt 0 ]; then
	echo
	echo "FATAL: the following packages are missing, exiting."
	for k in "${NOTINSTALLED[@]}"; do
		echo "  $k";
	done
	exit 1
fi

#
# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi

# Clean our mess on exiting
cleanup()
{
	if [ -n "$WORKPATH" ]; then
		if [ -z "$KEEP_WORKAREA" ]; then
			echo "Cleaning workarea..."
			rm -rf $WORKPATH
			if ls $THISDIR/binary*.iso > /dev/null 2>&1 ; then
				chmod 666 $THISDIR/binary*.iso
			fi
			echo "All clean"
		fi
	fi
}
trap 'cleanup' EXIT TERM INT


THISDIR=$(pwd)
WORKDIR=workarea
WORKPATH=$THISDIR/$WORKDIR
export WORKPATH
export WORKDIR

echo ""

if [ -d "$WORKPATH" ]; then
	echo "Cleaning workarea..."
	rm -rf $WORKPATH
fi
mkdir $WORKPATH

if ls $THISDIR/binary*.iso > /dev/null 2>&1 ; then
	rm $THISDIR/binary*.iso
fi

echo "Creating new workarea..."

# cp all (except git directories) into workarea
rsync -r -l --exclude=.git --exclude=$WORKDIR . $WORKDIR

if [ -z "$SDK_USELOCALLIVEBUILD" ] ; then
	if ! which lb > /dev/null ; then
		echo "package live-build not installed, forcing use of local copy"
		export SDK_USELOCALLIVEBUILD=1
	fi
fi

if [ -n "$SDK_USELOCALLIVEBUILD" ] ; then
	if [ ! -d $WORKPATH/local ]; then
		mkdir $WORKPATH/local
	fi
	cd $WORKPATH/local
	if [ ! -d live-build ]; then
		# Using Ubuntu fork:
		#repoURL="http://archive.ubuntu.com/ubuntu/pool/main/l/live-build/"
		#if [ -z "$SDK_USELATESTLIVEBUILD" ]; then
	    #	latestPackage="live-build_3.0~a57.orig.tar.xz"

		repoURL="http://live.debian.net/files/stable/packages/live-build/orig/"
		if [ -z "$SDK_USELATESTLIVEBUILD" ]; then
		    latestPackage="live-build_3.0.5.orig.tar.xz"
		else
		    latestPackage=$(curl -x "" -s -f $repoURL | grep live-build | grep xz | grep -v "~" | tail -1 | grep -o '"live-build_[^"]*.tar..z"' | sed -e "s/\"//g")
		fi

		if ! ls $latestPackage > /dev/null 2>&1 ; then
			echo "Retrieving live-build tarball..."
			echo " -  Latest package: $latestPackage"

			wget -q --no-proxy "$repoURL$latestPackage" --no-check-certificate
			if [ "$?" -ne "0" ] || [ ! -f $latestPackage ] ; then
				echo "Needed package ($latestPackage) not found, exiting..."
				exit 1
			fi
		fi
		tar xf $latestPackage

		mv live-build-* live-build
	fi

	LB_HOMEDIR=$WORKPATH/local/live-build

	export LIVE_BUILD="${LB_HOMEDIR}"
	export PATH="${LIVE_BUILD}/bin:${PATH}"

	cd $THISDIR
fi

echo "Start building..."
echo ""

cd $WORKPATH

# Execute hooks if env variable is defined
if [ -n "$SDK_BUILDHOOKS" ]; then
	for hook in $SDK_BUILDHOOKS; do
		if [ -x $hook ]; then
			$hook
			if [ "$?" -ne "0" ]; then
				exit 1
			fi
		fi
	done
fi

#
# Build needed packages (if needed)
#
if [ -f $WORKPATH/buildDEBs/build.sh ]; then
	echo ""
	echo "------------------------"
	echo "Build needed packages..."
	echo "------------------------"
	echo ""

	cd $WORKPATH/buildDEBs
	./build.sh
	if [ "$?" -ne "0" ]; then
		exit 1
	fi
	cd $THISDIR
fi

cd $WORKPATH

#
# Copy all needed files in place for the real build
#

filesToRun=$(ls $WORKPATH/copyFiles-*.sh 2> /dev/null)
if [ -n "$filesToRun" ]; then
	for hook in $filesToRun; do
		$hook
		if [ "$?" -ne "0" ]; then
			exit 1
		fi
	done
fi

#
# Perform image build
#

echo ""
echo "----------------------"
echo "Perform image build..."
echo "----------------------"
echo ""

cd $WORKPATH

lb clean
lb config
lb build

cd $THISDIR

#
# Move binary file from workarea
#
for BINARY in $WORKPATH/binary.iso $WORKPATH/binary.hybrid.iso; do
	[ -e "$BINARY" ] || continue
	chmod 666 "$BINARY"
	mv "$BINARY" .
	break
done
