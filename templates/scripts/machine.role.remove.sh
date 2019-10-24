#!/bin/sh

. adp-functions

ROLE="$1"; shift
GROUPS="$*" #maybe empty

roledel "$ROLE" "$GROUPS"
