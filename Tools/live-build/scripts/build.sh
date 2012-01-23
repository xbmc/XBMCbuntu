#!/bin/sh

if [ -e local/live-build ]
then
	LB_BASE="${LB_BASE:-${PWD}/local/live-build}"
	PATH="${PWD}/local/live-build/scripts/build:${PATH}"
	export LB_BASE PATH
else
	LB_BASE="${LB_BASE:-/usr/share/live/build}"
	export LB_BASE
fi

# Source global functions
for FUNCTION in "${LB_BASE}"/functions/*.sh
do
	. "${FUNCTION}"
done

# Source local functions
if ls auto/functions/* > /dev/null 2>&1
then
	for FUNCTION in auto/functions/*
	do
		. "${FUNCTION}"
	done
fi
