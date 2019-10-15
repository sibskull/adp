#!/bin/sh

. adp-functions

FROZEN_PACKAGES="$1" # list of frozen packages

apt-mark hold "$FROZEN_PACKAGES"
