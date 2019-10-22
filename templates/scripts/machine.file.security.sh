#!/bin/sh

. adp-functions

FILE="$1"
USER="$2"
GROUP="$3"
MODE="$4"

chown "$USER":"$GROUP" "$FILE"
chmod "$MODE" "$FILE"
