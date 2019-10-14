#!/bin/sh

. adp-functions

SCRIPT="$1"
TIME="$2"

#chmod ugo+x "$SCRIPT"
at -f "$SCRIPT" "$TIME"
