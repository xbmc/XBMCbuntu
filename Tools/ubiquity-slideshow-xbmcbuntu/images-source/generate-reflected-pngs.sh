#!/bin/sh

distro=$1
output=$2
if [ -z $distro ] || [ -z $output ]; then
	echo "Usage: $0 <distro> <output>"
	exit -1
fi

output="$(pwd)/$output"

cd $(dirname $0)
cd "$1"
mkdir out
gimp -i -f -d -b - < ../reflection-script.scm 2>/dev/null
mv out "$output"
