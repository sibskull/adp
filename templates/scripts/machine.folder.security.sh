#!/bin/sh

. adp-functions

DIRECTORY="$1"
USER="$2"
GROUP="$3"
MODE="$4"

chown -R "$USER":"$GROUP" "$DIRECTORY"
chmod "$MODE" "$DIRECTORY"
