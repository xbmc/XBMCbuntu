#!/bin/sh

kodiuser=$1

echo "$kodiuser             -       nice            -1" >> /etc/security/limits.conf && exit 0 

