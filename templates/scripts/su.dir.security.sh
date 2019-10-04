#!/bin/sh

. bin/adp-functions

DIR="$1"
USER="$2"
GROUP="$3"

chown -R "$USER":"$GROUP" "$DIR"
