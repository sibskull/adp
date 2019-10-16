#!/bin/sh

. adp-functions

PACKAGES="$*" # list of packages for re-installation

apt-get update
apt-get install --reinstall $PACKAGES -y
