#!/bin/sh

distro=$1
if [ -z $distro ]; then
	echo "Usage: $0 <distro>"
	exit -1
fi

SOURCE=.
BUILD=build

PODIR=$SOURCE/po/$distro
BUILDSLIDES=$BUILD/$distro/slides

if ! which po4a-translate >/dev/null; then
	echo; echo "Error: po4a is not available."
	exit 1
fi

echo "directory = new Object()" > $BUILDSLIDES/directory.js

for locale in $PODIR/*.po; do
	if [ -e $locale ]; then
		localename=$(basename $locale .po)
		localeslides=$BUILDSLIDES/loc.$localename
		
		echo "directory['$localename'] = new Object()" >> $BUILDSLIDES/directory.js
		echo "Found locale: $locale"
		
		for slide in $BUILDSLIDES/*.html; do
			slidename=$(basename $slide)
			[ $slidename = "index.html" ] && continue
			
			outputslide="$localeslides/$slidename"
			[ -e $outputslide ] && rm -f $outputslide
			[ ! -e $localeslides ] && mkdir -p $localeslides
			
			# -k 1 -> if there are any translations at all, keep it.
			po4a-translate -M UTF-8 -f xhtml -m $slide -p $locale -l $outputslide -k 1
			if ! [ -e "$outputslide" ]; then
				rmdir $localeslides 2>/dev/null || true
				echo "              $slidename was not translated for locale $localename"
			else
				echo "directory['$localename']['$slidename'] = true" >> $BUILDSLIDES/directory.js
				#echo "              translated $slide for $locale locale"
			fi
		done
	fi
done
