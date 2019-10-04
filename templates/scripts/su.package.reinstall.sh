#!/bin/sh

. bin/adp-functions

PACKAGES="$1" # list of packages for re-installation

apt-get install --reinstall "$PACKAGES" -y
