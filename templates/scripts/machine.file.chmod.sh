#!/bin/sh

. adp-functions

FILE="$1"
MODE="$2"

chmod "$MODE" "$FILE"
