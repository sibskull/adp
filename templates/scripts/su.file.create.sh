#!/bin/sh

. adp-functions

FILE="$1"
DIR="$2"

touch "$FILE"
mv "$FILE" "$DIR"
