#!/bin/sh

. adp-functions

ROLE="$1"; shift
GROUPS="$*"

roledel "$ROLE" "$GROUPS"
