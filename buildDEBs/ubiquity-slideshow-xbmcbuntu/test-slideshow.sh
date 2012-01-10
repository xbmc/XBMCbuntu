#!/bin/bash

TITLE="Slideshow tester"

SOURCE=.
BUILD=$SOURCE/build
SOURCESLIDES=$SOURCE/slideshows

slideshows=""
for show in $SOURCESLIDES/*; do
	showname=$(basename $show)
	#oddly placed files we need to ignore
	[ $showname = "link-core" ] && continue
	#if we're still going, add this slideshow to the list
	select=FALSE
	[ $showname = "ubuntu" ] && select=TRUE
	slideshows="$slideshows $select $showname"
done
slideshow=$(zenity --list --radiolist --column="Pick" --column="Slideshow" $slideshows --title="$TITLE" --text="Choose a slideshow to test")
[ "$slideshow" = "" ] | [ "$slideshow" = "(null)" ] && exit

mv "$BUILD" "$BUILD.backup" 2>/dev/null
trap "[ -e "$BUILD.backup" ] && rm -rf "$BUILD" ; mv "$BUILD.backup" "$BUILD"" 0 1 2 15
make build_$slideshow | tee >(zenity --progress --pulsate --title="$TITLE" --text="Building temporary slideshow for testing.\n<i>(make build_$slideshow)</i>" --auto-close)
./Slideshow.py --path="$BUILD/$slideshow" --controls
