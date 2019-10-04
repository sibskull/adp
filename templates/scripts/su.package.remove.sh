#!/bin/sh

. adp-functions

CLEAN_SETTINGS="$1" # clean the settings of removed packages
PACKAGES="$2" # list of packages for remove

if [ "$CLEAN_SETTINGS" = true ]; then
apt-get remove "$PACKAGES" --purge -y
else
apt-get remove "$PACKAGES" -y
fi
