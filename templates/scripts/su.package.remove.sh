#!/bin/sh

. bin/adp-functions

CLEAN_SETTINGS="$1" # clean the settings of removed packages
PACKAGES="$2" # list of packages for remove

if [ "$CLEAN_SETTINGS" = true ]; then
apt-get remove "$PACKAGES" --purge
else
apt-get remove "$PACKAGES"
fi
