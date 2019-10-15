#!/bin/sh

. adp-functions

PACKAGES="$*" # list of packages for installation

apt-get update
apt-get install $PACKAGES -y
