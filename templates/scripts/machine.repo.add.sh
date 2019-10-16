#!/bin/sh

. adp-functions

REPO="$1"

apt-repo add "$REPO"
