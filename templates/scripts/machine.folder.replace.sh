#!/bin/sh

. adp-functions

FROM_DIR="$1"
TO_DIR="$2"

mv -f "$FROM_DIR" "$TO_DIR"
