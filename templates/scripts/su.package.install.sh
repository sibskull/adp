#!/bin/sh

. bin/adp-functions

PACKAGES="$1" # list of packages for installation

apt-get install "$PACKAGES" -y
