#!/bin/sh
#
# «update-launchpad-translations» - Merge a Launchpad translations export with
# a specified branch.
#
# Copyright (C) 2010 Canonical Ltd.
#
# Authors:
#
# - Evan Dandrea <evand@ubuntu.com>
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
# 
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
# 
# You should have received a copy of the GNU General Public License along with
# this program.  If not, see <http://www.gnu.org/licenses/>.
set -e

WORKING_DIR="/tmp/launchpad-export"
repo="$2"
repo=$(readlink -e "$repo") || repo=
if [ -z "$1" ] || [ -z "$repo" ]; then
	echo "$0 launchpad-export.tar.gz path-to-slideshow-repo"
	exit 1
fi
rm -rf $WORKING_DIR
mkdir -p $WORKING_DIR
tar -C $WORKING_DIR -zxvf "$1" 1>/dev/null
save="$pwd"
cd $WORKING_DIR/po
for distro in *; do
	[ -d "$repo/po/$distro" ] || continue
	cd "$distro"
	rename 's/.*-//' *.po
	rm -f *.pot
	for d in $(find -name "*.po" | sed "s,.*/\(.*\)\.po$,\1," | sort | uniq); do
		msgcat --use-first $d.po > "$repo/po/$distro/$d.po"
	done
	cd ..
done
cd $save
rm -rf $WORKING_DIR

for d in $repo/po/*; do
	[ -d $d ] || continue
	for p in $d/*.po; do
		[ -e $p ] || continue
		msgmerge -U $p $d/slideshow-*.pot
	done
done
