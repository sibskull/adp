#!/bin/sh

. adp-functions

FROM_FILE="$1"
TO_FILE="$2"

mv "$FROM_FILE" "$TO_FILE"
