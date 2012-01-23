#!/bin/sh

set -e

DATE="$(LC_ALL=C date +%Y\\\\-%m\\\\-%d)"
PROGRAM="LIVE\\\-BUILD"
VERSION="$(cat ../VERSION)"

echo "Updating version headers..."

for MANPAGE in en/*
do
	SECTION="$(basename ${MANPAGE} | awk -F. '{ print $2 }')"

	sed -i -e "s|^.TH.*$|.TH ${PROGRAM} ${SECTION} ${DATE} ${VERSION} \"Debian Live Project\"|" ${MANPAGE}
done
