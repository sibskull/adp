#!/bin/sh

. adp-functions

DIRECTORY="$1"
MODE="$2"

chmod "$MODE" "$DIRECTORY"
