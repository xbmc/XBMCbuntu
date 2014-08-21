#!/bin/sh
set -e
mkpo ()
{
	mkdir -p "po/$1"
	
	for slide in slideshows/$1/slides/*.html; do
		slidename="$(basename $slide)"
		[ "$slidename" = "index.html" ] && continue
		mkdir -p "po/$1/.tmp"
		po4a-updatepo -M UTF-8 -f xhtml -m $slide -p "po/$1/.tmp/$slidename.pot"
	done
	
	msgcat po/$1/.tmp/*.pot > "po/$1/slideshow-$1.pot"
	rm -r "po/$1/.tmp"
}

mkpo "ubuntu"
mkpo "kubuntu"
mkpo "xubuntu"
mkpo "lubuntu"
mkpo "edubuntu"
mkpo "oem-config-ubuntu"
