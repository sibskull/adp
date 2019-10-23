#!/bin/sh

. adp-functions

SCRIPT="$1"

SCRIPTS_DIR=/tmp/adp-$USER
mkdir -p $SCRIPTS_DIR
SCRIPT_PATH="$SCRIPTS_DIR/$(basename $SCRIPT)"

adp_copy_file "$SCRIPT" "$SCRIPT_PATH"
chmod 700 "$SCRIPT_PATH"
"$SCRIPT_PATH"
rm -f "$SCRIPT_PATH"
