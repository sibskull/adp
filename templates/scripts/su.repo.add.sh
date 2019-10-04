#!/bin/sh

. bin/adp-functions

REPO="$1"

apt-repo add "$REPO"
