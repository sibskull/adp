#!/bin/sh

. adp-functions

FILE="$1"
DIRECTORY="$2"

touch "$FILE"
mv "$FILE" "$DIRECTORY"
