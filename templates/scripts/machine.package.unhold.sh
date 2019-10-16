#!/bin/sh

. adp-functions

PACKAGES="$*" # list of frozen packages for unhold

for package in $PACKAGES; do
    rm -f /etc/apt/apt.conf.d/hold-$package.conf
done
