#!/bin/sh

. adp-functions

DIRECTORY="$1"
USER="$2"
GROUP="$3"

chown -R "$USER":"$GROUP" "$DIRECTORY"
