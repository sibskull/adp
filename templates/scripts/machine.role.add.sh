#!/bin/sh

. adp-functions

ROLE="$1"; shift
GROUPS="$*"

roleadd "$ROLE" "$GROUPS"
