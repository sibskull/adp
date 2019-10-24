#!/bin/sh

. adp-functions

GROUPS="$*"

for group in $GROUPS; do
    groupadd $group
done
